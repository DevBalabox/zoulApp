<?php
include "initializer.php";

//Session is set to "PvUsrSess"

class User
{

	public $user_id;
	public $conn;
	public $is_logged;
	public $user_data_array;
	public $session_name;

	function __construct()
	{
		global $extras_class;
		$this->conn = $extras_class->database();
		$this->session_name = "ZPUsrSess_coach";
	}


	//Get from extra class
	public function randomCode($prefix)
	{
		global $extras_class;
		return $extras_class->randomCode($prefix);
	}
	//End Get from extra class


	public function new_user($profile_picture_url, $name, $first_lastname, $second_lastname, $mail, $biography, $gender, $password, $method, $facebook_id, $type)
	{
		global $extras_class;
		global $strings_class;

		$response_array = $extras_class->response("false", "e1", "Hubo un problema interno (500).", "both");

		$mail = mysqli_real_escape_string($this->conn, $mail);
		$name = mysqli_real_escape_string($this->conn, $name);
		$first_lastname = mysqli_real_escape_string($this->conn, $first_lastname);
		$second_lastname = mysqli_real_escape_string($this->conn, $second_lastname);
		$password = password_hash(mysqli_real_escape_string($this->conn, $password), PASSWORD_DEFAULT);
		/* $birth_date = mysqli_real_escape_string($this->conn, $birth_date);
		$phone = mysqli_real_escape_string($this->conn, $phone); */
		$birth_date = "";
		$phone = "";

		$biography = mysqli_real_escape_string($this->conn, $biography);
		$gender = mysqli_real_escape_string($this->conn, $gender);
		$method = mysqli_real_escape_string($this->conn, $method);
		$facebook_id = mysqli_real_escape_string($this->conn, $facebook_id);
		$date = date('m/d/Y h:i:s a', time());
		$user_id = $this->randomCode('user_');
		$image_name = "";


		if ($method == "mail") {
			$query = "SELECT * FROM users WHERE mail = '$mail' AND type = '$type' AND method = 'mail'";
			$result = mysqli_query($this->conn, $query);
			if (mysqli_num_rows($result)) {
				$response_array = $extras_class->response("false", "e1", "Este correo ya está registrado.", "both");
				return $response_array;
				exit();
			}
		} else {
			$social_linking = $this->social_linking_register($method, $user_id, $facebook_id, $type);
			if ($social_linking[0]["status"] != "true") {
				$response_array = $extras_class->response("false", "e1", $social_linking[0]["message"], "both");
				return $response_array;
				exit();
			}

			if ($profile_picture_url != "" && $profile_picture_url != null) {
				$image = file_get_contents($profile_picture_url);
				if ($image !== false) {
					$image = base64_encode($image);
					$image_name = $user_id . strtotime("now") . ".png";
					file_put_contents('../images/' . $image_name, base64_decode($image));
				}
			}
		}


		$sql = "INSERT INTO users (user_id,name,first_lastname,second_lastname,mail,password,birth_date,gender,phone,biography,img_url,method,type,creation_date) VALUES ('$user_id', '$name', '$first_lastname', '$second_lastname', '$mail', '$password', '$birth_date', '$gender', '$phone', '$biography', '$image_name', '$method','$type','$date')";
		if (mysqli_query($this->conn, $sql)) {
			$response_array = $extras_class->response("true", "sc1", "Registro exitoso.", "console");
			$response_array[] = array('user_id' => $user_id, 'url' => $extras_class->home_url);
		} else {
			$response_array = $extras_class->response("false", "e1", "Registro fallido.", "both");
		}

		return $response_array;
	}

	public function edit_user_profile($user_id, $profile_picture_base64, $name, $first_lastname, $second_lastname, $mail, $biography, $password, $new_password, $method, $facebook_id, $type)
	{
		global $extras_class;
		global $strings_class;

		$response_array = $extras_class->response("false", "e1", "Hubo un problema interno (500).", "both");

		$user_id = mysqli_real_escape_string($this->conn, $user_id);
		$mail = mysqli_real_escape_string($this->conn, $mail);
		$name = mysqli_real_escape_string($this->conn, $name);
		$first_lastname = mysqli_real_escape_string($this->conn, $first_lastname);
		$second_lastname = mysqli_real_escape_string($this->conn, $second_lastname);

		/* $birth_date = mysqli_real_escape_string($this->conn, $birth_date);
		$phone = mysqli_real_escape_string($this->conn, $phone); */
		$biography = mysqli_real_escape_string($this->conn, $biography);
		$method = mysqli_real_escape_string($this->conn, $method);
		$facebook_id = mysqli_real_escape_string($this->conn, $facebook_id);
		$date = date('m/d/Y h:i:s a', time());
		$image_name = "";

		if ($method == "mail") {
			$try_login = $this->verify_credentials($user_id, $password, $type);
			if ($try_login[0]["status"] != "true") {
				$response_array = $extras_class->response("false", "e1", $try_login[0]["message"], "both");
				return $response_array;
				exit();
			}
		} else {
			$try_social_login = $this->verify_social_credentials($user_id, $method, $facebook_id);
			if ($try_social_login[0]["status"] != "true") {
				$response_array = $extras_class->response("false", "e1", $try_social_login[0]["message"], "both");
				return $response_array;
				exit();
			}
		}

		$img_sql = "";
		if ($profile_picture_base64 != "" && $profile_picture_base64 != null) {
			$image_name = $user_id . strtotime("now") . ".png";
			file_put_contents('../images/' . $image_name, base64_decode($profile_picture_base64));
			$img_sql = ", img_url = '$image_name'";
		}

		$pwd_sql = "";
		if ($new_password != null && $new_password != "") {
			$new_password = password_hash(mysqli_real_escape_string($this->conn, $new_password), PASSWORD_DEFAULT);
			$pwd_sql = ", password = '$new_password'";
		}

		if ($method == "mail") {
			$query = "SELECT * FROM users WHERE mail = '$mail' AND type = '$type' AND method = 'mail' AND user_id = '$user_id'";
			$result = mysqli_query($this->conn, $query);
			if (!mysqli_num_rows($result)) {
				$query_2 = "SELECT * FROM users WHERE mail = '$mail' AND type = '$type' AND method = 'mail'";
				$result_2 = mysqli_query($this->conn, $query_2);
				if (mysqli_num_rows($result_2)) {
					$response_array = $extras_class->response("false", "e1", "Este correo ya está siendo utilizado por alguien más.", "both");
					return $response_array;
					exit();
				}
			}
		}


		$sql = "UPDATE users SET name = '$name', mail = '$mail', first_lastname = '$first_lastname', second_lastname = '$second_lastname'" . $pwd_sql . $img_sql . "  WHERE user_id = '$user_id'";
		if (mysqli_query($this->conn, $sql)) {
			$response_array = $extras_class->response("true", "sc1", "Actualización exitosa.", "console");
		} else {
			$response_array = $extras_class->response("false", "e1", "Actualización fallida.", "both");
		}

		return $response_array;
	}

	public function admin_edit_user_profile($user_id, $profile_picture_base64, $name, $first_lastname, $second_lastname, $mail, $birth_date, $gender, $phone, $biography, $method, $type)
	{
		global $extras_class;
		global $strings_class;

		$response_array = $extras_class->response("false", "e1", "Hubo un problema interno (500).", "both");

		$user_id = mysqli_real_escape_string($this->conn, $user_id);
		$mail = mysqli_real_escape_string($this->conn, $mail);
		$name = mysqli_real_escape_string($this->conn, $name);
		$first_lastname = mysqli_real_escape_string($this->conn, $first_lastname);
		$second_lastname = mysqli_real_escape_string($this->conn, $second_lastname);

		$birth_date = mysqli_real_escape_string($this->conn, $birth_date);
		$gender = mysqli_real_escape_string($this->conn, $gender);
		$phone = mysqli_real_escape_string($this->conn, $phone);
		$biography = mysqli_real_escape_string($this->conn, $biography);
		$date = date('m/d/Y h:i:s a', time());
		$image_name = "";

		$img_sql = "";
		if ($profile_picture_base64 != "" && $profile_picture_base64 != null) {
			$image_name = $user_id . strtotime("now") . ".png";
			file_put_contents('../images/' . $image_name, base64_decode($profile_picture_base64));
			$img_sql = ", img_url = '$image_name'";
		}

		if ($method == "mail") {
			$query = "SELECT * FROM users WHERE mail = '$mail' AND type = '$type' AND method = 'mail' AND user_id = '$user_id'";
			$result = mysqli_query($this->conn, $query);
			if (!mysqli_num_rows($result)) {
				$query_2 = "SELECT * FROM users WHERE mail = '$mail' AND type = '$type' AND method = 'mail'";
				$result_2 = mysqli_query($this->conn, $query_2);
				if (mysqli_num_rows($result_2)) {
					$response_array = $extras_class->response("false", "e1", "Este correo ya está siendo utilizado por alguien más.", "both");
					return $response_array;
					exit();
				}
			}
		}

		$sql = "UPDATE users SET name = '$name', mail = '$mail', first_lastname = '$first_lastname', second_lastname = '$second_lastname', biography = '$biography', birth_date = '$birth_date', gender = '$gender', phone = '$phone'" . $img_sql . "  WHERE user_id = '$user_id'";
		if (mysqli_query($this->conn, $sql)) {
			$response_array = $extras_class->response("true", "sc1", "Actualización exitosa.", "console");
		} else {
			$response_array = $extras_class->response("false", "e1", "Actualización fallida.", "both");
		}

		return $response_array;
	}

	public function admin_edit_coach_profile($user_id, $profile_picture_base64, $name, $first_lastname, $second_lastname, $mail, $birth_date, $gender, $phone, $biography, $method, $type, $bank, $clabe, $card_number, $facebook_profile, $instagram_profile, $youtube_profile, $status)
	{
		global $extras_class;
		global $strings_class;

		$response_array = $extras_class->response("false", "e1", "Hubo un problema interno (500).", "both");

		$user_id = mysqli_real_escape_string($this->conn, $user_id);
		$mail = mysqli_real_escape_string($this->conn, $mail);
		$name = mysqli_real_escape_string($this->conn, $name);
		$first_lastname = mysqli_real_escape_string($this->conn, $first_lastname);
		$second_lastname = mysqli_real_escape_string($this->conn, $second_lastname);

		$birth_date = mysqli_real_escape_string($this->conn, $birth_date);
		$gender = mysqli_real_escape_string($this->conn, $gender);
		$phone = mysqli_real_escape_string($this->conn, $phone);
		$biography = mysqli_real_escape_string($this->conn, $biography);

		$bank = mysqli_real_escape_string($this->conn, $bank);
		$clabe = mysqli_real_escape_string($this->conn, $clabe);
		$card_number = mysqli_real_escape_string($this->conn, $card_number);
		$facebook_profile = mysqli_real_escape_string($this->conn, $facebook_profile);
		$instagram_profile = mysqli_real_escape_string($this->conn, $instagram_profile);
		$youtube_profile = mysqli_real_escape_string($this->conn, $youtube_profile);
		$status = mysqli_real_escape_string($this->conn, $status);

		$date = date('m/d/Y h:i:s a', time());
		$image_name = "";

		$img_sql = "";
		if ($profile_picture_base64 != "" && $profile_picture_base64 != null) {
			$image_name = $user_id . strtotime("now") . ".png";
			file_put_contents('../images/' . $image_name, base64_decode($profile_picture_base64));
			$img_sql = ", b.img_url = '$image_name'";
		}

		if ($method == "mail") {
			$query = "SELECT * FROM users WHERE mail = '$mail' AND type = '$type' AND method = 'mail' AND user_id = '$user_id'";
			$result = mysqli_query($this->conn, $query);
			if (!mysqli_num_rows($result)) {
				$query_2 = "SELECT * FROM users WHERE mail = '$mail' AND type = '$type' AND method = 'mail'";
				$result_2 = mysqli_query($this->conn, $query_2);
				if (mysqli_num_rows($result_2)) {
					$response_array = $extras_class->response("false", "e1", "Este correo ya está siendo utilizado por alguien más.", "both");
					return $response_array;
					exit();
				}
			}
		}

		//$sql = "UPDATE users SET name = '$name', mail = '$mail', first_lastname = '$first_lastname', second_lastname = '$second_lastname', birth_date = '$birth_date', gender = '$gender', phone = '$phone'" . $img_sql . "  WHERE user_id = '$user_id'";
		$sql = "UPDATE users AS b INNER JOIN coaches as g ON b.user_id = g.user_id SET b.name = '$name', b.mail = '$mail', b.first_lastname = '$first_lastname', b.second_lastname = '$second_lastname', b.biography = '$biography', b.birth_date = '$birth_date', b.gender = '$gender', b.phone = '$phone', g.bank = '$bank', g.clabe = '$clabe', g.card_number = '$card_number', g.facebook_profile = '$facebook_profile', g.instagram_profile = '$instagram_profile', g.youtube_profile = '$youtube_profile', g.status = '$status'" . $img_sql . " WHERE b.user_id = '$user_id'";
		if (mysqli_query($this->conn, $sql)) {
			$response_array = $extras_class->response("true", "sc1", "Actualización exitosa.", "console");
		} else {
			$response_array = $extras_class->response("false", "e1", "Actualización fallida.", "both");
		}

		return $response_array;
	}

	public function update_profile_picture($user_id, $profile_picture_base64, $token)
	{
		global $extras_class;
		global $strings_class;

		$response_array = $extras_class->response("false", "e1", "Hubo un problema interno (500).", "both");

		$token = mysqli_real_escape_string($this->conn, $token);

		$user_public_data = $this->get_user_public_data($user_id, $token);
		if ($user_public_data[0]["status"] != "true") {
			$response_array = $user_public_data;
			return $response_array;
			exit();
		}

		$image_name = "";

		if ($profile_picture_base64 != "" && $profile_picture_base64 != null) {
			$image_name = $user_id . strtotime("now") . ".png";
			file_put_contents('../images/' . $image_name, base64_decode($profile_picture_base64));
		}

		$sql = "UPDATE users SET img_url = '$image_name' WHERE user_id = '$user_id'";
		if (mysqli_query($this->conn, $sql)) {
			$response_array = $extras_class->response("true", "sc1", "Actualización exitosa.", "console");
		} else {
			$response_array = $extras_class->response("false", "e1", "Actualización fallida.", "both");
		}

		return $response_array;
	}

	public function set_new_password($password, $restoken)
	{
		global $extras_class;
		global $strings_class;

		$response_array = $extras_class->response("false", "e1", "Hubo un problema interno (500).", "both");

		$restoken = mysqli_real_escape_string($this->conn, $restoken);
		$password = password_hash(mysqli_real_escape_string($this->conn, $password), PASSWORD_DEFAULT);

		$query = "SELECT * FROM restokens WHERE restoken_id = '$restoken' AND status = 'available'";
		$result = mysqli_query($this->conn, $query);
		if (mysqli_num_rows($result)) {
			$sql = "UPDATE users JOIN restokens rt ON rt.user_id = users.user_id SET password = '$password' WHERE rt.restoken_id = '$restoken'";
			if (mysqli_query($this->conn, $sql)) {
				$response_array = $extras_class->response("true", "sc1", "Tu contraseña se cambió con éxito.", "console");
				$sql = "UPDATE restokens SET status = 'used' WHERE restoken_id = '$restoken'";
				mysqli_query($this->conn, $sql);
			} else {
				$response_array = $extras_class->response("false", "e1", "Hubo un problema para actualizar tu contraseña.", "both");
			}
		} else {
			$response_array = $extras_class->response("false", "e1", "El token de restablecimiento no es válido.", "both");
		}

		return $response_array;
	}

	public function social_linking_register($source, $user_id, $id, $type)
	{
		global $extras_class;
		global $strings_class;

		$response_array = $extras_class->response("false", "e1", "Hubo un problema interno (500).", "both");

		$query = "SELECT * FROM social_linking WHERE source = '$source' AND social_id = '$id'";
		$result = mysqli_query($this->conn, $query);
		if (mysqli_num_rows($result)) {
			while ($row = mysqli_fetch_assoc($result)) {
				$existing_user_id = $row['user_id'];

				$query_2 = "SELECT * FROM users WHERE method = '$source' AND user_id = '$existing_user_id' AND type = '$type'";
				$result_2 = mysqli_query($this->conn, $query_2);
				if (mysqli_num_rows($result_2)) {
					$response_array = $extras_class->response("false", "e1", "Este usuario ya está registrado, intenta directamente iniciando sesión.", "both");
					return $response_array;
					exit();
				}
			}
		}

		$sql = "INSERT INTO social_linking (source,user_id,social_id) VALUES ('$source', '$user_id', '$id')";
		if (mysqli_query($this->conn, $sql)) {

			$response_array = $extras_class->response("true", "sc1", "Registro social exitoso.", "console");
			$response_array[] = array('user_id' => $user_id, 'url' => $extras_class->home_url);
		} else {
			$response_array = $extras_class->response("false", "e1", "Registro social fallido.", "both");
		}

		return $response_array;
	}

	public function try_login($mail, $password, $user_type)
	{
		global $extras_class;
		global $strings_class;

		$response_array = $extras_class->response("false", "e1", "Hubo un problema interno (500).", "both");

		$query = "SELECT * FROM users WHERE mail = '$mail' AND type = '$user_type' AND method = 'mail'";
		$result = mysqli_query($this->conn, $query);

		/* Ver si el correo existe */
		if (mysqli_num_rows($result)) {
			while ($row = mysqli_fetch_assoc($result)) {
				$password_db = $row['password'];
				$user_id = $row['user_id'];
				$user_type = $row['type'];
			}

			/* Comparar las contraseñas */
			if (password_verify($password, $password_db)) {
				$response_array = $extras_class->response("true", "sc1", "Sesión iniciada", "console");

				$create_token = $this->create_login_token($user_id);
				if ($create_token[0]["status"] == "true") {
					if ($create_token[1]["token"] != null) {
						$response_array[] = array('user_id' => $user_id, 'user_type' => $user_type, 'token' => $create_token[1]["token"], 'link' => $extras_class->home_url);
						$this->user_id = $user_id;
						$this->trigger_login($user_type);
					}
				}
			} else {
				$response_array = $extras_class->response("false", "e1", "No coinciden las contraseñas", "both");
			}
		} else {
			$response_array = $extras_class->response("false", "e1", "El correo no está registrado", "both");
		}

		return $response_array;
	}


	public function verify_credentials($user_id, $password, $user_type)
	{
		global $extras_class;
		global $strings_class;

		$response_array = $extras_class->response("false", "e1", "Hubo un problema interno (500).", "both");

		$query = "SELECT * FROM users WHERE user_id = '$user_id' AND type = '$user_type' AND method = 'mail'";
		$result = mysqli_query($this->conn, $query);

		/* Ver si el correo existe */
		if (mysqli_num_rows($result)) {
			while ($row = mysqli_fetch_assoc($result)) {
				$password_db = $row['password'];
				$user_id = $row['user_id'];
				$user_type = $row['type'];
			}

			/* Comparar las contraseñas */
			if (password_verify($password, $password_db)) {
				$response_array = $extras_class->response("true", "sc1", "Credenciales verificadas", "console");
			} else {
				$response_array = $extras_class->response("false", "e1", "No coinciden las contraseñas", "both");
			}
		} else {
			$response_array = $extras_class->response("false", "e1", "El usuario no aparece registrado", "both");
		}

		return $response_array;
	}


	public function try_social_login($source, $id, $type)
	{
		global $extras_class;
		global $strings_class;

		$response_array = $extras_class->response("false", "e1", "Hubo un problema interno (500).", "both");

		$query = "SELECT * FROM social_linking WHERE source = '$source' AND social_id = '$id'";
		$result = mysqli_query($this->conn, $query);

		if (mysqli_num_rows($result)) {
			while ($row = mysqli_fetch_assoc($result)) {
				$user_id = $row['user_id'];

				$query_2 = "SELECT * FROM users WHERE method = '$source' AND user_id = '$user_id' AND type = '$type'";
				$result_2 = mysqli_query($this->conn, $query_2);
				if (mysqli_num_rows($result_2)) {

					$create_token = $this->create_login_token($user_id);
					if ($create_token[0]["status"] == "true") {
						if ($create_token[1]["token"] != null) {
							$response_array = $extras_class->response("true", "sc1", "Sesión iniciada", "console");
							$response_array[] = array('user_id' => $user_id, 'user_type' => $type, 'token' => $create_token[1]["token"], 'link' => $extras_class->home_url);
							$this->user_id = $user_id;
							$this->trigger_login($type);
						}
					} else {
						$response_array = $extras_class->response("false", "e1", $create_token[0]["message"], "both");
					}

					return $response_array;
					exit();
				} else {
					$response_array = $extras_class->response("false", "e1", "¡Estás en el inicio de sesión incorrecto!", "both");
				}
			}
		} else {
			$response_array = $extras_class->response("false", "e1", "¡Aún no te has registrado con esta cuenta!", "both");
		}

		return $response_array;
	}

	public function verify_social_credentials($user_id, $source, $id)
	{
		global $extras_class;
		global $strings_class;

		$response_array = $extras_class->response("false", "e1", "Hubo un problema interno (500).", "both");

		$query = "SELECT * FROM social_linking WHERE source = '$source' AND user_id = '$user_id' AND social_id = '$id'";
		$result = mysqli_query($this->conn, $query);

		if (mysqli_num_rows($result)) {
			$response_array = $extras_class->response("true", "sc1", "Credenciales correctas", "console");
		} else {
			$response_array = $extras_class->response("false", "e1", "No coinciden las credenciales", "both");
		}

		return $response_array;
	}

	public function create_login_token($user_id)
	{
		global $extras_class;
		global $strings_class;
		$response_array = $extras_class->response("false", "e1", "Hubo un problema interno (500).", "both");

		$token = $this->randomCode('token_');

		while ($extras_class->record_exists("login_tokens", "token", $token)) {
			$token = $this->randomCode('token_');
		}

		$sql = "INSERT INTO login_tokens (user_id,token, status) VALUES ('$user_id', '$token','active')";
		if (mysqli_query($this->conn, $sql)) {
			$response_array = $extras_class->response("true", "sc1", "Registro exitoso.", "console");
			$response_array[] = array('token' => $token);
		} else {
			$response_array = $extras_class->response("false", "e1", "Creación de token fallida.", "both");
		}
		return $response_array;
	}

	public function trigger_login($user_type)
	{
		global $extras_class;
		$conn = $extras_class->database();

		if ($this->user_id != "") {
			if ($user_type != "" && $user_type != null) {
				if ($user_type == "admin") {
					$this->session_name = "ZPUsrSess_admin";
				}
			}
			$_SESSION[$this->session_name] = $this->user_id;
			ob_end_flush();
			$this->is_logged = true;

			//Get user data
			$user_id = $this->user_id;
			$query = "SELECT * FROM users WHERE user_id = '$user_id'";
			$result = mysqli_query($conn, $query);

			if (mysqli_num_rows($result)) {
				$this->user_data_array = mysqli_fetch_assoc($result);
			}
			//End get user data

		} else {
			$this->is_logged = false;
		}
	}

	public function verify_login()
	{
		if ($_SESSION[$this->session_name] != "") {
			$this->user_id = $_SESSION[$this->session_name];
			ob_end_flush();
			$this->is_logged = true;
		} else {
			$this->is_logged = false;
		}

		return $this->is_logged;
	}

	public function verify_login_js()
	{
		global $extras_class;
		global $strings_class;

		$response_array = $extras_class->response("false", "e1", "No loggeado", "both");

		if ($_SESSION['PvUsrSess'] != "") {
			$this->user_id = $_SESSION['PvUsrSess'];
			ob_end_flush();
			$response_array = $extras_class->response("true", "e1", "loggeado", "both");
		}

		return $response_array;
	}

	public function delete_user($user_id)
	{
		global $extras_class;

		$response_array = $extras_class->response("false", "e1", "Hubo un problema interno (500).", "both");

		$sql = "DELETE FROM users WHERE user_id = '$user_id'";

		if (mysqli_query($this->conn, $sql)) {
			$response_array = $extras_class->response("true", "sc1", "El usuario se eliminó con éxito.", "console");
		} else {
			$response_array = $extras_class->response("false", "e1", "Hubo un problema para eliminar al usuario.", "both");
		}

		return $response_array;
	}

	public function send_restoken($mail, $user_type)
	{
		global $extras_class;

		$response_array = $extras_class->response("false", "e1", "Hubo un problema interno (500).", "both");
		$mail = mysqli_real_escape_string($this->conn, $mail);
		$user_type = mysqli_real_escape_string($this->conn, $user_type);

		$sql = "SELECT * FROM users WHERE mail = '$mail' AND type = '$user_type'";
		$result = mysqli_query($this->conn, $sql);
		if (mysqli_num_rows($result)) {
			while ($row = mysqli_fetch_assoc($result)) {
				$user_id = $row['user_id'];
				$user_name = $row["name"];
				$user_first_lastname = $row["first_lastname"];
			}

			$restoken_id = $this->randomCode('restoken_');

			$sql_2 = "INSERT INTO restokens (restoken_id,user_id) VALUES ('$restoken_id', '$user_id')";
			if (mysqli_query($this->conn, $sql_2)) {
				//Enviar correo
				$name = 'Zoul';
				$mailtxt = file_get_contents('../templates/mails/restore-password.html');
				$mailtxt = str_replace('%link%', $extras_class->mainurl . "new-password?rtk=" . $restoken_id, $mailtxt);

				require_once '../libraries/swiftmailer/lib/swift_required.php';
				$transport = Swift_SmtpTransport::newInstance('zoulapp.com', 587)
					->setUsername($extras_class->companymail)
					->setPassword($extras_class->companymail_password);
				$mailer = Swift_Mailer::newInstance($transport);
				$message = Swift_Message::newInstance('Restablece tu contraseña de Zoul App')
					->setFrom(array($extras_class->companymail => 'Equipo de Zoul'))
					->setTo(array($mail => $user_name . " " . $user_first_lastname))
					->setBody('Restablece tu contraseña de Zoul App');

				if ($mailtxt != '') {
					$message->addPart($mailtxt, 'text/html');
				}
				$result = $mailer->send($message);

				if ($result) {
					$response_array = $extras_class->response("true", "sc1", "Revisa tu correo, enviamos un link de restablecimiento. (En ocasiones el correo puede llegar a Spam)", "console");
				} else {
					$response_array = $extras_class->response("false", "e1", "Hubo un problema para enviar tu link de restablecimiento, comunícate con nosotros.", "both");
				}
			} else {
				$response_array = $extras_class->response("false", "e1", "Hubo un problema al intentar crear tu llave de restablecimiento, comunícate con nosotros.", "both");
			}
		} else {
			$response_array = $extras_class->response("false", "e1", "Parece que ese correo aún no está registrado.", "both");
		}

		return $response_array;
	}

	public function logout()
	{
		global $extras_class;
		global $strings_class;
		session_unset();
		if (ini_get("session.use_cookies")) {
			$params = session_get_cookie_params();
			setcookie(
				session_name(),
				'',
				time() - 42000,
				$params["path"],
				$params["domain"],
				$params["secure"],
				$params["httponly"]
			);
		} // Finally, destroy the session.
		session_destroy();
		$response_array = $extras_class->response("true", "e1", "Logout exitoso", "both");
		$response_array[] = array('url' => $extras_class->home_url);

		return $response_array;
	}


	public function getPublicUserInfo($user_id)
	{

		if ($user_id == "") {
			if ($this->verify_login()) {
				$user_id = $this->user_id;
			}
		}

		$query = "SELECT * FROM users WHERE user_id = '$user_id'";
		$result = mysqli_query($this->conn, $query);
		if (mysqli_num_rows($result)) {
			$row = mysqli_fetch_assoc($result);
		} else {
			$row = "";
		}

		return $row;
	}


	//---------------------------- Rest API ---------------------------- 
	//---------------------------- Rest API ---------------------------- 
	//---------------------------- Rest API ---------------------------- 

	public function get_user_private_data_2($user_id, $mail, $password)
	{
		global $extras_class;
		global $strings_class;
		$data_list_array = array();

		$query = "SELECT * FROM users WHERE mail = '$mail' AND user_id = '$user_id'";
		$result = mysqli_query($this->conn, $query);

		/* Ver si el correo existe */
		if (mysqli_num_rows($result)) {
			while ($row = mysqli_fetch_assoc($result)) {
				$password_db = $row['password'];
				$data_list_array[] = $row;
			}

			/* Comparar las contraseñas */
			if (password_verify($password, $password_db)) {
				$response_array = $extras_class->response("true", "sc1", "Se obtuvo la información pública del usuario con éxito", "console");
				$response_array[] = array("user_data" => $data_list_array);
			} else {
				$response_array = $extras_class->response("false", "e1", "No coinciden las contraseñas", "both");
			}
		} else {
			$response_array = $extras_class->response("false", "e1", "Los datos no coinciden", "both");
		}

		return $response_array;
	}

	public function get_user_private_data($user_id, $mail, $password)
	{
		global $extras_class;
		global $strings_class;
		$data_list_array = array();

		$query = "SELECT * FROM users WHERE mail = '$mail' AND user_id = '$user_id'";
		$result = mysqli_query($this->conn, $query);

		/* Ver si el correo existe */
		if (mysqli_num_rows($result)) {
			while ($row = mysqli_fetch_assoc($result)) {
				$password_db = $row['password'];
				$data_list_array[] = $row;
			}

			/* Comparar las contraseñas */
			if (password_verify($password, $password_db)) {
				$response_array = $extras_class->response("true", "sc1", $data_list_array, "console");
			} else {
				$response_array = $extras_class->response("false", "e1", "No coinciden las contraseñas", "both");
			}
		} else {
			$response_array = $extras_class->response("false", "e1", "Los datos no coinciden", "both");
		}

		return $response_array;
	}

	public function get_user_public_data($user_id, $token)
	{
		global $extras_class;
		global $strings_class;
		global $payments_class;
		$data_list_array = array();

		$subscription_status = "inactive";
		$end_of_cicle = "";

		$check_subscription = $payments_class->check_subscription($user_id);
		if ($check_subscription[0]["status"] == "true") {
			if ($check_subscription[0]["code"] == $extras_class->active_non_renewable_code) {
				$subscription_status = "active_non_renewable";
				$end_of_cicle = $check_subscription[1]["end_of_cicle"];
			} else {
				$subscription_status = "active";
			}
		}

		$verify_user_token = $this->verify_user_token($user_id, $token);
		if ($verify_user_token[0]["status"] != "true") {
			$response_array = $extras_class->response("false", "e1", $verify_user_token[0]["message"], "both");
			return $response_array;
			exit();
		}

		$query = "SELECT * FROM users WHERE user_id = '$user_id'";
		$result = mysqli_query($this->conn, $query);

		/* Ver si el correo existe */
		if (mysqli_num_rows($result)) {
			while ($row = mysqli_fetch_assoc($result)) {
				$password_db = $row['password'];
				$data_list_array[] = array("user_id" => $row['user_id'], "name" => $row['name'], "first_lastname" => $row['first_lastname'], "second_lastname" => $row['second_lastname'], "mail" => $row['mail'], "phone" => $row['phone'], "biography" => $row['biography'], "birth_date" => $row['birth_date'], "img_url" => $row['img_url'], "type" => $row['type'], "method" => $row['method'], "subscription_status" => $subscription_status, "end_of_cicle" => $end_of_cicle);
			}

			$response_array = $extras_class->response("true", "sc1", "La información pública del usuario se obtuvo con éxito", "console");
			$response_array[] = array('user_data' => $data_list_array);
		} else {
			$response_array = $extras_class->response("false", "e1", "No se ha encontrado nada para este ID", "both");
		}

		return $response_array;
	}

	public function verify_user_token($user_id, $token)
	{
		global $extras_class;
		global $services_class;

		$response_array = $extras_class->response("false", "e1", "Hubo un problema interno (500).", "both");

		$query = "SELECT * FROM login_tokens WHERE user_id = '$user_id' AND token = '$token'";
		$result = mysqli_query($this->conn, $query);

		if (mysqli_num_rows($result)) {
			while ($row = mysqli_fetch_assoc($result)) {
				$status = $row['status'];
			}

			if ($status != null) {
				if ($status == "active") {
					$response_array = $extras_class->response("true", "sc1", "El token es válido", "console");
				} else {
					$response_array = $extras_class->response("false", "e1", "El token no se encuentra activo, inicia sesión para obtener uno nuevo.", "console");
				}
			} else {
				$response_array = $extras_class->response("false", "e1", "Hubo un problema al obtener el estatus del token, inicia sesión para obtener uno nuevo.", "console");
			}
		} else {
			$response_array = $extras_class->response("false", "e1", "El token proporcionado no existe.", "console");
		}

		return $response_array;
	}

	public function delete_login_token($user_id, $token)
	{
		global $extras_class;
		$response_array = $extras_class->response("false", "e1", "Hubo un problema interno (500).", "both");

		$sql = "DELETE FROM login_tokens WHERE user_id = '$user_id' AND token = '$token'";

		if (mysqli_query($this->conn, $sql)) {
			$response_array = $extras_class->response("true", "sc1", "El token se eliminó con éxito.", "console");
		} else {
			$response_array = $extras_class->response("false", "e1", "Hubo un problema para eliminar el token.", "both");
		}

		return $response_array;
	}

	public function clear_session_data($user_id, $token, $fcm_token)
	{
		global $extras_class;
		global $notifications_class;

		$final_message = "";
		$average_status = false;

		$response_array = $extras_class->response("false", "e1", "Hubo un problema interno (500).", "both");

		$user_id = mysqli_real_escape_string($this->conn, $user_id);
		$token = mysqli_real_escape_string($this->conn, $token);
		$fcm_token = mysqli_real_escape_string($this->conn, $fcm_token);

		if ($fcm_token != null && $fcm_token != "") {
			$delete_fcm_token = $notifications_class->delete_fcm_token($user_id, $fcm_token);
			if ($delete_fcm_token[0]["status"] != "true") {
				$final_message .= $delete_fcm_token[0]["message"];
				$average_status = "false";
			} else {
				$final_message .= $delete_fcm_token[0]["message"];
				$average_status = "true";
			}
		}

		if ($token != null && $token != "") {
			$delete_login_token = $this->delete_login_token($user_id, $token);
			if ($delete_login_token[0]["status"] != "true") {
				$final_message .= ", " . $delete_login_token[0]["message"];
				$average_status = "false";
			} else {
				$final_message .= ", " . $delete_fcm_token[0]["message"];
				$average_status = "true";
			}
		}

		$response_array = $extras_class->response($average_status, "avg1", $final_message, "console");


		return $response_array;
	}
}
