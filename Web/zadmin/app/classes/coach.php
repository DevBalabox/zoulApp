<?php
include "initializer.php";

class Coach
{

	public $conn;

	function __construct()
	{
		global $extras_class;
		$this->conn = $extras_class->database();
	}

	//---------------------------- Rest API ---------------------------- 
	//---------------------------- Rest API ---------------------------- 
	//---------------------------- Rest API ---------------------------- 

	public function get_coach_id($user_id)
	{
		global $extras_class;
		$response_array = $extras_class->response("false", "e1", "Hubo un problema interno (500).", "both");

		$query = "SELECT * FROM coaches WHERE user_id = '$user_id'";
		$result = mysqli_query($this->conn, $query);
		if (mysqli_num_rows($result)) {
			while ($row = mysqli_fetch_assoc($result)) {
				$coach_id = $row["coach_id"];
			}
			if ($coach_id != null && $coach_id != "") {
				$response_array = $extras_class->response("true", "sc1", "Se obtuvo el id del coach con éxito.", "both");
				$response_array[] = array('coach_id' => $coach_id);
			} else {
				$response_array = $extras_class->response("false", "e1", "Parece que el id del coach está vacío.", "both");
			}
		} else {
			$response_array = $extras_class->response("false", "e1", "No se encontró ningún coach asociado con este id de usuario.", "both");
		}
		return $response_array;
	}

	public function get_coaches_list($user_id, $status, $discipline_id)
	{
		global $extras_class;
		$data_list_array = array();
		$coaches_array = array();

		$response_array = $extras_class->response("false", "e1", "Hubo un problema interno (500).", "both");

		$query_list_videos = "SELECT * FROM videos WHERE discipline_id = '$discipline_id' ORDER BY id DESC";
		$result_list_videos = mysqli_query($this->conn, $query_list_videos);
		if (mysqli_num_rows($result_list_videos)) {
			while ($row_videos = mysqli_fetch_assoc($result_list_videos)) {
				$coach_id = $row_videos["coach_id"];

				if (!in_array($coach_id, $coaches_array)) {
					array_push($coaches_array, $coach_id);
				}
			}
		} else {
			$response_array = $extras_class->response("false", "e1", "Hubo un problema para obtener la lista de coaches.", "both");
			return $response_array;
			exit();
		}

		if (count($coaches_array) == 0) {
			$response_array = $extras_class->response("false", "e1", "No se encontraron coaches en esta disciplina.", "both");
			return $response_array;
			exit();
		}

		if ($status == "active") {
			for ($i = 0; $i < count($coaches_array); $i++) {
				$coach_id = $coaches_array[$i];
				$query_list = "SELECT * FROM coaches WHERE status = 'activo' AND coach_id = '$coach_id' ORDER BY id DESC";
				$result_list = mysqli_query($this->conn, $query_list);

				if (mysqli_num_rows($result_list)) {
					while ($row = mysqli_fetch_assoc($result_list)) {
						$disciplines_list_array[] = $row;
						$coach_id = $row["coach_id"];
						$coach_user_id = $row["user_id"];
						$facebook_profile = $row["facebook_profile"];
						$instagram_profile = $row["instagram_profile"];
						$youtube_profile = $row["youtube_profile"];

						$query_list_2 = "SELECT * FROM users WHERE user_id = '$coach_user_id' ORDER BY id DESC";
						$result_list_2 = mysqli_query($this->conn, $query_list_2);

						if (mysqli_num_rows($result_list_2)) {
							while ($row_2 = mysqli_fetch_assoc($result_list_2)) {
								$name = $row_2["name"];
								$first_lastname = $row_2["first_lastname"];
								$second_lastname = $row_2["second_lastname"];
								$biography = $row_2["biography"];
								$img_url = $row_2["img_url"];

								$data_list_array[] = array(
									"coach_id" => $coach_id,
									"user_id" => $coach_user_id,
									"name" => $name,
									"first_lastname" => $first_lastname,
									"second_lastname" => $second_lastname,
									"biography" => $biography,
									"img_url" => $img_url,
									"facebook_profile" => $facebook_profile,
									"instagram_profile" => $instagram_profile,
									"youtube_profile" => $youtube_profile
								);
							}
						}
					}
				}
			}
		}


		$response_array = $extras_class->response("true", "sc1", "Se obtuvo la lista de coaches con éxito", "console");
		$response_array[] = array('coaches_list' => $data_list_array);

		return $response_array;
	}

	public function get_coach_disciplines_list($user_id, $status)
	{
		global $extras_class;
		$disciplines_list_array = array();
		$coach_id = "";

		$response_array = $extras_class->response("false", "e1", "Hubo un problema interno (500).", "both");

		$get_coach_id = $this->get_coach_id($user_id);
		if ($get_coach_id[0]["status"] != "true") {
			$response_array = $extras_class->response("false", "e1", $get_coach_id[0]["message"], "both");
			return $response_array;
			exit();
		} else {
			$coach_id = $get_coach_id[1]["coach_id"];
		}

		$query_list_videos = "SELECT * FROM videos WHERE coach_id = '$coach_id' ORDER BY id DESC";
		$result_list_videos = mysqli_query($this->conn, $query_list_videos);
		if (mysqli_num_rows($result_list_videos)) {
			while ($row_videos = mysqli_fetch_assoc($result_list_videos)) {
				$discipline_id = $row_videos["discipline_id"];

				if (!in_array($discipline_id, $disciplines_list_array)) {
					array_push($disciplines_list_array, $discipline_id);
				}
			}
		} else {
			$response_array = $extras_class->response("false", "e1", "Hubo un problema para obtener la lista de disciplinas.", "both");
			return $response_array;
			exit();
		}

		if (count($disciplines_list_array) == 0) {
			$response_array = $extras_class->response("false", "e1", "No se encontraron disciplinas de este coach.", "both");
			return $response_array;
			exit();
		}

		if ($status == "active") {
			for ($i = 0; $i < count($disciplines_list_array); $i++) {
				$discipline_id = $disciplines_list_array[$i];
				$query_list = "SELECT * FROM disciplines WHERE status = 'Público' AND discipline_id = '$discipline_id' ORDER BY id DESC";
				$result_list = mysqli_query($this->conn, $query_list);

				if (mysqli_num_rows($result_list)) {
					while ($row = mysqli_fetch_assoc($result_list)) {
						$disciplines_list_array_2[] = $row;
					}
				}
			}
		}


		$response_array = $extras_class->response("true", "sc1", "Se obtuvo la lista de disciplinas con éxito", "console");
		$response_array[] = array('disciplines_list' => $disciplines_list_array_2);

		return $response_array;
	}

	public function get_coach_data($user_id, $token)
	{
		global $extras_class;
		global $user_class;
		$coach_data_array = array();
		$response_array = $extras_class->response("false", "e1", "Hubo un problema interno (500).", "both");
		$coach_id = "";

		$verify_user_token = $user_class->verify_user_token($user_id, $token);
		if ($verify_user_token[0]["status"] != "true") {
			$response_array = $extras_class->response("false", "e1", $verify_user_token[0]["message"], "both");
			return $response_array;
			exit();
		}

		$get_coach_id = $this->get_coach_id($user_id);
		if ($get_coach_id[0]["status"] != "true") {
			$response_array = $extras_class->response("false", "e1", $get_coach_id[0]["message"], "both");
			return $response_array;
			exit();
		} else {
			$coach_id = $get_coach_id[1]["coach_id"];
		}

		$query_list = "SELECT * FROM coaches WHERE coach_id = '$coach_id'";
		$result_list = mysqli_query($this->conn, $query_list);

		if (mysqli_num_rows($result_list)) {
			while ($row = mysqli_fetch_assoc($result_list)) {
				$coach_data_array[] = $row;
			}

			$response_array = $extras_class->response("true", "sc1", "Se obtuvo la información del coach con éxito", "console");
			$response_array[] = array('coach_data' => $coach_data_array);
		} else {
			$response_array = $extras_class->response("false", "e1", "Hubo un problema para obtener la información del coach.", "both");
		}

		return $response_array;
	}

	public function update_coach_bank_details($user_id, $bank, $clabe, $card_number, $password)
	{
		global $extras_class;
		global $user_class;
		$response_array = $extras_class->response("false", "e1", "Hubo un problema interno (500).", "both");
		$coach_id = "";

		$verify_user_credentials = $user_class->verify_credentials($user_id, $password, "coach");
		if ($verify_user_credentials[0]["status"] != "true") {
			$response_array = $extras_class->response("false", "e1", $verify_user_credentials[0]["message"], "both");
			return $response_array;
			exit();
		}

		$get_coach_id = $this->get_coach_id($user_id);
		if ($get_coach_id[0]["status"] != "true") {
			$response_array = $extras_class->response("false", "e1", $get_coach_id[0]["message"], "both");
			return $response_array;
			exit();
		} else {
			$coach_id = $get_coach_id[1]["coach_id"];
		}

		$sql = "UPDATE coaches SET bank = '$bank', clabe = '$clabe', card_number = '$card_number' WHERE coach_id = '$coach_id'";
		if (mysqli_query($this->conn, $sql)) {
			$response_array = $extras_class->response("true", "sc1", "Actualización exitosa.", "console");
		} else {
			$response_array = $extras_class->response("false", "e1", "Actualización fallida.", "both");
		}

		return $response_array;
	}

	public function new_coach($user_id)
	{
		global $extras_class;
		$response_array = $extras_class->response("false", "e1", "Hubo un problema interno (500).", "both");

		$coach_id = $extras_class->randomCode('coach_');
		while ($extras_class->record_exists("coaches", "coach_id", $coach_id)) {
			$coach_id = $extras_class->randomCode('coach_');
		}

		$sql = "INSERT INTO coaches (coach_id,user_id, status) VALUES ('$coach_id','$user_id','Activo')";
		if (mysqli_query($this->conn, $sql)) {
			$response_array = $extras_class->response("true", "sc1", "Registro de coach exitoso.", "console");
		} else {
			$response_array = $extras_class->response("false", "e1", "Creación de coach fallida.", "both");
		}
		return $response_array;
	}

	public function revoke_coach($user_id)
	{
		global $extras_class;
		$response_array = $extras_class->response("false", "e1", "Hubo un problema interno (500).", "both");

		$sql = "DELETE FROM coaches WHERE user_id = '$user_id'";
		if (mysqli_query($this->conn, $sql)) {
			$response_array = $extras_class->response("true", "sc1", "Se revocó el coach con éxito.", "console");
		} else {
			$response_array = $extras_class->response("false", "e1", "Hubo un problema para revocar al coach.", "both");
		}
		return $response_array;
	}
}
