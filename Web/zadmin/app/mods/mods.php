<?php
//Initialize clasess and session
include "mods-start.php";
$json_call = false;
$errores_array = array();
$httpCode = null;

if (!isset($_POST["action"])) {
	$body = @file_get_contents('php://input');
	$data = json_decode($body);
	error_log($body);
	$action = $data->action;
	if ($action == null || $action == "") {
		$httpCode = 400;
		array_push($errores_array, 'No hay una llamada concreta');
	} else {
		$json_call = true;
	}
} else {
	$action = $_POST["action"];
}

$response_array = $extras_class->response("false", "e1", "Hola amigo, cómo llegaste aquí?.", "both");

switch ($action) {
	case 'login':
		if ($json_call) {
			$mail = $data->mail;
			if ($mail == null) {
				array_push($errores_array, 'Falta el campo de correo');
			}

			$password = $data->password;
			if ($password == null) {
				array_push($errores_array, 'Falta el campo de contraseña');
			}

			$user_type = $data->user_type;
			if ($user_type == null) {
				array_push($errores_array, 'Falta el campo de tipo de usuario');
			}

			if (count($errores_array) != 0) {
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $user_class->try_login(
					$mail,
					$password,
					$user_type
				);
			}
		} else {
			$response_array = $user_class->try_login(
				$_POST["mail"],
				$_POST["password"],
				$_POST["user_type"]
			);
		}
		break;

	case 'social_login':
		if ($json_call) {
			$source = $data->source;
			if ($source == null) {
				array_push($errores_array, 'Falta el campo de medio');
			}

			$id = $data->id;
			if ($id == null) {
				array_push($errores_array, 'Falta el campo de ID social');
			}

			$user_type = $data->user_type;
			if ($user_type == null) {
				array_push($errores_array, 'Falta el campo de tipo de usuario');
			}

			if (count($errores_array) != 0) {
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $user_class->try_social_login(
					$source,
					$id,
					$user_type
				);
			}
		} else {
			$response_array = $user_class->try_social_login(
				$_POST["source"],
				$_POST["id"],
				$_POST["user_type"]
			);
		}
		break;

	case 'signup':
		if ($json_call) {

			$profile_picture_url = $data->profile_picture_url;

			$name = $data->name;
			//error_log($name);
			if ($name == null) {
				array_push($errores_array, 'Falta el campo de nombre');
			}

			$first_lastname = $data->first_lastname;
			if ($first_lastname == null) {
				array_push($errores_array, 'Falta el campo de apellido paterno');
			}

			$second_lastname = $data->second_lastname;
			if ($second_lastname == null) {
				array_push($errores_array, 'Falta el campo de apellido materno');
			}

			$mail = $data->mail;
			if ($mail == null) {
				array_push($errores_array, 'Falta el campo de correo');
			}

			$biography = $data->biography;

			$gender = $data->gender;

			$password = $data->password;

			$facebook_id = $data->facebook_id;

			$method = $data->method;
			if ($method == null) {
				array_push($errores_array, 'Falta el campo de tipo de método');
			} else {
				if ($method == "facebook") {
					if ($facebook_id == null) {
						array_push($errores_array, 'Falta el ID de Facebook');
					}
				} else {
					if ($password == null) {
						array_push($errores_array, 'Falta el campo de contraseña');
					}
				}
			}

			$user_type = $data->user_type;
			if ($user_type == null) {
				array_push($errores_array, 'Falta el campo de tipo de usuario');
			} else {
				if ($user_type == "coach") {
					if ($biography == null) {
						array_push($errores_array, 'Falta el campo de biografía');
					}
				}
			}

			if (count($errores_array) != 0) {
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $user_class->new_user(
					$profile_picture_url,
					$name,
					$first_lastname,
					$second_lastname,
					$mail,
					$biography,
					$gender,
					$password,
					$method,
					$facebook_id,
					$user_type
				);
			}
		}
		break;


	case 'edit_profile':
		if ($json_call) {

			$profile_picture_base64 = $data->profile_picture_base64;

			$user_id = $data->user_id;
			if ($user_id == null) {
				array_push($errores_array, 'Falta el campo de ID de usuario');
			}

			$name = $data->name;
			if ($name == null) {
				array_push($errores_array, 'Falta el campo de nombre');
			}

			$first_lastname = $data->first_lastname;
			if ($first_lastname == null) {
				array_push($errores_array, 'Falta el campo de apellido paterno');
			}

			$second_lastname = $data->second_lastname;
			if ($second_lastname == null) {
				array_push($errores_array, 'Falta el campo de apellido materno');
			}

			$mail = $data->mail;
			if ($mail == null) {
				array_push($errores_array, 'Falta el campo de correo');
			}

			$biography = $data->biography;

			$password = $data->password;

			$new_password = $data->new_password;

			$facebook_id = $data->facebook_id;

			$method = $data->method;
			if ($method == null) {
				array_push($errores_array, 'Falta el campo de tipo de método');
			} else {
				if ($method == "facebook") {
					if ($facebook_id == null) {
						array_push($errores_array, 'Falta el ID de Facebook');
					}
				} else {
					if ($password == null) {
						array_push($errores_array, 'Falta el campo de contraseña');
					}
				}
			}

			$user_type = $data->user_type;
			if ($user_type == null) {
				array_push($errores_array, 'Falta el campo de tipo de usuario');
			}

			if (count($errores_array) != 0) {
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $user_class->edit_user_profile(
					$user_id,
					$profile_picture_base64,
					$name,
					$first_lastname,
					$second_lastname,
					$mail,
					$biography,
					$password,
					$new_password,
					$method,
					$facebook_id,
					$user_type
				);
			}
		} else {
			$response_array = $user_class->edit_user_profile(
				$_POST["user_id"],
				$_POST["profile_picture_base64"],
				$_POST["name"],
				$_POST["first_lastname"],
				$_POST["second_lastname"],
				$_POST["mail"],
				$_POST["biography"],
				$_POST["password"],
				$_POST["new_password"],
				$_POST["method"],
				$_POST["facebook_id"],
				$_POST["user_type"]
			);
		}
		break;

	case 'admin_edit_profile':
		if ($json_call) {

			$profile_picture_base64 = $data->profile_picture_base64;

			$user_id = $data->user_id;
			if ($user_id == null) {
				array_push($errores_array, 'Falta el campo de ID de usuario');
			}

			$name = $data->name;
			if ($name == null) {
				array_push($errores_array, 'Falta el campo de nombre');
			}

			$first_lastname = $data->first_lastname;
			if ($first_lastname == null) {
				array_push($errores_array, 'Falta el campo de apellido paterno');
			}

			$second_lastname = $data->second_lastname;
			if ($second_lastname == null) {
				array_push($errores_array, 'Falta el campo de apellido materno');
			}

			$mail = $data->mail;
			if ($mail == null) {
				array_push($errores_array, 'Falta el campo de correo');
			}

			$method = $data->method;
			if ($method == null) {
				array_push($errores_array, 'Falta el campo de tipo de método');
			}

			$birth_date = $data->birth_date;
			$gender = $data->gender;
			$phone = $data->phone;

			$biography = $data->biography;

			$user_type = $data->user_type;
			if ($user_type == null) {
				array_push($errores_array, 'Falta el campo de tipo de usuario');
			}

			if (count($errores_array) != 0) {
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $user_class->admin_edit_user_profile(
					$user_id,
					$profile_picture_base64,
					$name,
					$first_lastname,
					$second_lastname,
					$mail,
					$birth_date,
					$gender,
					$phone,
					$biography,
					$method,
					$user_type
				);
			}
		}
		break;

	case 'admin_edit_coach':
		if ($json_call) {

			$profile_picture_base64 = $data->profile_picture_base64;

			$user_id = $data->user_id;
			if ($user_id == null) {
				array_push($errores_array, 'Falta el campo de ID de usuario');
			}

			$name = $data->name;
			if ($name == null) {
				array_push($errores_array, 'Falta el campo de nombre');
			}

			$first_lastname = $data->first_lastname;
			if ($first_lastname == null) {
				array_push($errores_array, 'Falta el campo de apellido paterno');
			}

			$second_lastname = $data->second_lastname;
			if ($second_lastname == null) {
				array_push($errores_array, 'Falta el campo de apellido materno');
			}

			$mail = $data->mail;
			if ($mail == null) {
				array_push($errores_array, 'Falta el campo de correo');
			}

			$method = $data->method;
			if ($method == null) {
				array_push($errores_array, 'Falta el campo de tipo de método');
			}

			$birth_date = $data->birth_date;
			$gender = $data->gender;
			$phone = $data->phone;

			$biography = $data->biography;
			if ($biography == null) {
				array_push($errores_array, 'Falta el campo de biografía');
			}

			$user_type = $data->user_type;
			if ($user_type == null) {
				array_push($errores_array, 'Falta el campo de tipo de usuario');
			}

			$bank = $data->bank;
			if ($bank == null) {
				array_push($errores_array, 'Falta el campo de banco');
			}

			$clabe = $data->clabe;
			if ($clabe == null) {
				array_push($errores_array, 'Falta el campo de CLABE');
			}

			$card_number = $data->card_number;
			if ($card_number == null) {
				array_push($errores_array, 'Falta el campo de número de tarjeta');
			}

			$facebook_profile = $data->facebook_profile;
			if ($facebook_profile == null) {
				array_push($errores_array, 'Falta el campo de perfil de facebook');
			}

			$instagram_profile = $data->instagram_profile;
			if ($instagram_profile == null) {
				array_push($errores_array, 'Falta el campo de perfil de instagram');
			}

			$youtube_profile = $data->youtube_profile;
			if ($youtube_profile == null) {
				array_push($errores_array, 'Falta el campo de perfil de Youtube');
			}

			$status = $data->status;
			if ($status == null) {
				array_push($errores_array, 'Falta el campo de perfil de estatus');
			}

			if (count($errores_array) != 0) {
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $user_class->admin_edit_coach_profile(
					$user_id,
					$profile_picture_base64,
					$name,
					$first_lastname,
					$second_lastname,
					$mail,
					$birth_date,
					$gender,
					$phone,
					$biography,
					$method,
					$user_type,
					$bank,
					$clabe,
					$card_number,
					$facebook_profile,
					$instagram_profile,
					$youtube_profile,
					$status
				);
			}
		}
		break;

	case 'new_coach':
		if ($json_call) {
			$user_id = $data->user_id;
			if ($user_id == null) {
				array_push($errores_array, 'Falta el campo de ID de usuario');
			}

			if (count($errores_array) != 0) {
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $coach_class->new_coach(
					$user_id
				);
			}
		}
		break;

	case 'revoke_coach':
		if ($json_call) {
			$user_id = $data->user_id;
			if ($user_id == null) {
				array_push($errores_array, 'Falta el campo de ID de usuario');
			}

			if (count($errores_array) != 0) {
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $coach_class->revoke_coach(
					$user_id
				);
			}
		}
		break;

	case 'send_restoken':
		if ($json_call) {
			$mail = $data->mail;
			if ($mail == null) {
				array_push($errores_array, 'Falta el campo de correo');
			}

			$user_type = $data->user_type;
			if ($user_type == null) {
				array_push($errores_array, 'Falta el campo de tipo de usuario');
			}

			if (count($errores_array) != 0) {
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $user_class->send_restoken(
					$mail,
					$user_type
				);
			}
		}
		break;

	case 'set_new_password':
		if ($json_call) {
			$password = $data->password;
			if ($password == null) {
				array_push($errores_array, 'Falta el campo de contraseña');
			}

			$restoken = $data->restoken;
			if ($restoken == null) {
				array_push($errores_array, 'Falta el campo de tipo de usuario');
			}

			if (count($errores_array) != 0) {
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $user_class->set_new_password(
					$password,
					$restoken
				);
			}
		}
		break;

	case 'update_profile_picture':
		if ($json_call) {
			$user_id = $data->user_id;
			if ($user_id == null) {
				array_push($errores_array, 'Falta el campo de ID de usuario');
			}

			$profile_picture_base64 = $data->profile_picture_base64;
			if ($profile_picture_base64 == null) {
				array_push($errores_array, 'Falta el campo de imagen en base 64');
			}

			$token = $data->token;
			if ($token == null) {
				array_push($errores_array, 'Falta el campo de token');
			}

			if (count($errores_array) != 0) {
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $user_class->update_profile_picture(
					$user_id,
					$profile_picture_base64,
					$token
				);
			}
		} else {
			$response_array = $user_class->update_profile_picture(
				$_POST["user_id"],
				$_POST["profile_picture_base64"],
				$_POST["token"]
			);
		}
		break;


	case 'validate_token':
		if ($json_call) {
			$user_id = $data->user_id;
			if ($user_id == null) {
				array_push($errores_array, 'Falta el campo de ID de usuario');
			}

			$token = $data->token;
			if ($token == null) {
				array_push($errores_array, 'Falta el campo de token');
			}

			if (count($errores_array) != 0) {
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $user_class->verify_user_token(
					$user_id,
					$token
				);
			}
		} else {
			$response_array = $user_class->verify_user_token(
				$_POST["user_id"],
				$_POST["token"]
			);
		}
		break;

	case 'delete_user':
		if ($json_call) {
			$user_id = $data->user_id;
			if ($user_id == null) {
				array_push($errores_array, 'Falta el campo de ID de usuario');
			}

			if (count($errores_array) != 0) {
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $user_class->delete_user(
					$user_id
				);
			}
		}
		break;

	case 'delete_video':
		if ($json_call) {
			$video_id = $data->video_id;
			if ($video_id == null) {
				array_push($errores_array, 'Falta el campo de ID de video');
			}

			if (count($errores_array) != 0) {
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $video_class->delete_video(
					$video_id
				);
			}
		}
		break;

	case 'delete_discipline':
		if ($json_call) {
			$discipline_id = $data->discipline_id;
			if ($discipline_id == null) {
				array_push($errores_array, 'Falta el campo de ID de disciplina');
			}

			if (count($errores_array) != 0) {
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $discipline_class->delete_discipline(
					$discipline_id
				);
			}
		}
		break;

	case 'new_discipline':
		if ($json_call) {
			$title = $data->title;
			if ($title == null) {
				array_push($errores_array, 'Falta el campo de nombre de disciplina');
			}

			$description = $data->description;
			if ($description == null) {
				array_push($errores_array, 'Falta el campo de descripción');
			}

			$status = $data->status;
			if ($status == null) {
				array_push($errores_array, 'Falta el campo de estatus');
			}

			$featured_img = $data->featured_img;

			if (count($errores_array) != 0) {
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $discipline_class->new_discipline(
					$featured_img,
					$title,
					$description,
					$status

				);
			}
		}
		break;

	case 'new_video':
		if ($json_call) {

			$coach_id = $data->coach_id;
			if ($coach_id == null) {
				array_push($errores_array, 'Falta seleccionar el coach');
			}

			$discipline_id = $data->discipline_id;
			if ($discipline_id == null) {
				array_push($errores_array, 'Falta seleccionar la disciplina');
			}

			$external_id = $data->external_id;
			if ($external_id == null) {
				array_push($errores_array, 'Falta el campo de ID externo');
			}

			$title = $data->title;
			if ($title == null) {
				array_push($errores_array, 'Falta el campo de título del video');
			}

			$description = $data->description;
			if ($description == null) {
				array_push($errores_array, 'Falta el campo de descripción');
			}

			$status = $data->status;
			if ($status == null) {
				array_push($errores_array, 'Falta el campo de estatus');
			}

			$source = $data->source;
			if ($source == null) {
				array_push($errores_array, 'Falta el campo de proveedor');
			}

			if (count($errores_array) != 0) {
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $video_class->new_video(
					$coach_id,
					$discipline_id,
					$external_id,
					$title,
					$description,
					$status,
					$source
				);
			}
		}
		break;

	case 'get_coach_data':
		if ($json_call) {
			$user_id = $data->user_id;
			if ($user_id == null) {
				array_push($errores_array, 'Falta el campo de ID de usuario');
			}

			$token = $data->token;
			if ($token == null) {
				array_push($errores_array, 'Falta el campo de token');
			}

			if (count($errores_array) != 0) {
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $coach_class->get_coach_data(
					$user_id,
					$token
				);
			}
		} else {
			$response_array = $coach_class->get_coach_data(
				$_POST["user_id"],
				$_POST["token"]
			);
		}
		break;

	case 'get_coach_disciplines_list':
		if ($json_call) {
			$user_id = $data->user_id;
			if ($user_id == null) {
				array_push($errores_array, 'Falta el campo de ID de usuario');
			}

			$status = $data->status;
			if ($status == null) {
				array_push($errores_array, 'Falta el campo de status');
			}

			if (count($errores_array) != 0) {
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $coach_class->get_coach_disciplines_list(
					$user_id,
					$status
				);
			}
		} else {
			$response_array = $coach_class->get_coach_disciplines_list(
				$_POST["user_id"],
				$_POST["status"]
			);
		}
		break;

	case 'update_coach_bank_details':
		if ($json_call) {
			$user_id = $data->user_id;
			if ($user_id == null) {
				array_push($errores_array, 'Falta el campo de ID de usuario');
			}

			$bank = $data->bank;
			if ($bank == null) {
				array_push($errores_array, 'Falta el campo de banco');
			}

			$clabe = $data->clabe;
			if ($clabe == null) {
				array_push($errores_array, 'Falta el campo de CLABE');
			}

			$card_number = $data->card_number;
			if ($card_number == null) {
				array_push($errores_array, 'Falta el campo de número de tarjeta');
			}

			$password = $data->password;
			if ($password == null) {
				array_push($errores_array, 'Falta el campo de contraseña');
			}

			if (count($errores_array) != 0) {
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $coach_class->update_coach_bank_details(
					$user_id,
					$bank,
					$clabe,
					$card_number,
					$password
				);
			}
		} else {
			$response_array = $coach_class->update_coach_bank_details(
				$_POST["user_id"],
				$_POST["bank"],
				$_POST["clabe"],
				$_POST["card_number"],
				$_POST["password"]
			);
		}
		break;


	case 'verify_login_js':
		$response_array = $user_class->verify_login_js();
		break;

	case 'logout':
		$httpCode = 200;
		$response_array = $user_class->logout();
		break;

		//---------------------------- Rest API ---------------------------- 
		//---------------------------- Rest API ---------------------------- 
		//---------------------------- Rest API ---------------------------- 

	case 'get_user_private_data':
		if ($json_call) {
			$user_id = $data->user_id;
			if ($user_id == null) {
				array_push($errores_array, 'Falta el campo de id de usuario');
			}

			$mail = $data->mail;
			if ($mail == null) {
				array_push($errores_array, 'Falta el campo de correo');
			}

			$password = $data->password;
			if ($password == null) {
				array_push($errores_array, 'Falta el campo de contraseña');
			}

			if (count($errores_array) != 0) {
				$httpCode = 400;
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $user_class->get_user_private_data(
					$user_id,
					$mail,
					$password
				);
			}
		} else {
			$response_array = $user_class->get_user_private_data(
				$_POST["user_id"],
				$_POST["mail"],
				$_POST["password"]
			);
		}
		break;

	case 'get_user_public_data':
		if ($json_call) {
			$user_id = $data->user_id;
			if ($user_id == null) {
				array_push($errores_array, 'Falta el campo de id de usuario');
			}

			$token = $data->token;
			if ($token == null) {
				array_push($errores_array, 'Falta el campo de token');
			}

			if (count($errores_array) != 0) {
				$httpCode = 400;
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $user_class->get_user_public_data(
					$user_id,
					$token
				);
			}
		} else {
			$response_array = $user_class->get_user_public_data(
				$_POST["user_id"],
				$_POST["token"]
			);
		}
		break;

	case 'get_all_users':
		if ($json_call) {
			$user_id = $data->user_id;
			if ($user_id == null) {
				array_push($errores_array, 'Falta el campo de id de usuario');
			}

			$token = $data->token;
			if ($token == null) {
				array_push($errores_array, 'Falta el campo de token');
			}

			if (count($errores_array) != 0) {
				$httpCode = 400;
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $user_class->get_user_public_data(
					$user_id,
					$token
				);
			}
		} else {
			$response_array = $user_class->get_user_public_data(
				$_POST["user_id"],
				$_POST["token"]
			);
		}
		break;

	case 'get_worker_public_data':
		if ($json_call) {
			$user_id = $data->user_id;
			if ($user_id == null) {
				array_push($errores_array, 'Falta el campo de is de usuario');
			}

			if (count($errores_array) != 0) {
				$httpCode = 400;
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $worker_class->get_worker_public_data(
					$user_id
				);
			}
		} else {
			$response_array = $worker_class->get_worker_public_data(
				$_POST["user_id"]
			);
		}
		break;

	case 'get_disciplines_list':
		if ($json_call) {

			$status = $data->status;
			if ($status == null) {
				array_push($errores_array, 'Falta el campo de estatus');
			}

			if (count($errores_array) != 0) {
				$httpCode = 400;
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $discipline_class->get_disciplines_list(
					$status
				);
			}
		} else {
			$response_array = $discipline_class->get_disciplines_list($_POST["status"]);
		}
		break;

	case 'admin_edit_discipline':
		if ($json_call) {

			$discipline_id = $data->discipline_id;
			if ($discipline_id == null) {
				array_push($errores_array, 'Falta el campo de ID de disciplina');
			}

			$featured_img = $data->featured_img;

			$name = $data->name;
			if ($name == null) {
				array_push($errores_array, 'Falta el campo de nombre de disciplina');
			}

			$short_description = $data->short_description;
			if ($short_description == null) {
				array_push($errores_array, 'Falta el campo de descripción');
			}

			$status = $data->status;
			if ($status == null) {
				array_push($errores_array, 'Falta el campo de estatus');
			}

			if (count($errores_array) != 0) {
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $discipline_class->admin_edit_discipline(
					$discipline_id,
					$featured_img,
					$name,
					$short_description,
					$status
				);
			}
		}
		break;

	case 'admin_edit_video':
		if ($json_call) {

			$video_id = $data->video_id;
			if ($video_id == null) {
				array_push($errores_array, 'Falta el campo de ID de video');
			}

			$coach_id = $data->coach_id;
			if ($coach_id == null) {
				array_push($errores_array, 'Falta seleccionar el coach');
			}

			$discipline_id = $data->discipline_id;
			if ($discipline_id == null) {
				array_push($errores_array, 'Falta seleccionar la disciplina');
			}

			$external_id = $data->external_id;
			if ($external_id == null) {
				array_push($errores_array, 'Falta el campo de ID externo');
			}

			$title = $data->title;
			if ($title == null) {
				array_push($errores_array, 'Falta el campo de título del video');
			}

			$description = $data->description;
			if ($description == null) {
				array_push($errores_array, 'Falta el campo de descripción');
			}

			$status = $data->status;
			if ($status == null) {
				array_push($errores_array, 'Falta el campo de estatus');
			}

			$source = $data->source;
			if ($source == null) {
				array_push($errores_array, 'Falta el campo de proveedor');
			}

			if (count($errores_array) != 0) {
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $video_class->admin_edit_video(
					$video_id,
					$coach_id,
					$discipline_id,
					$external_id,
					$title,
					$description,
					$status,
					$source
				);
			}
		}
		break;

	case 'get_coaches_list':
		if ($json_call) {
			$httpCode = 500; //Por si hay un error en la lógica

			$user_id = $data->user_id;
			if ($user_id == null) {
				array_push($errores_array, 'Falta el campo de ID de usuario');
			}

			$status = $data->status;
			if ($status == null) {
				array_push($errores_array, 'Falta el campo de status');
			}

			$discipline_id = $data->discipline_id;
			if ($discipline_id == null) {
				array_push($errores_array, 'Falta el campo de ID de disciplina');
			}

			if (count($errores_array) != 0) {
				$httpCode = 400;
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $coach_class->get_coaches_list(
					$user_id,
					$status,
					$discipline_id
				);
			}
		} else {
			$response_array = $coach_class->get_coaches_list(
				$_POST["user_id"],
				$_POST["status"],
				$_POST["discipline_id"]
			);
		}
		break;


	case 'get_video_playlist':
		if ($json_call) {
			$httpCode = 500; //Por si hay un error en la lógica

			$user_id = $data->user_id;
			if ($user_id == null) {
				array_push($errores_array, 'Falta el campo de ID de usuario');
			}

			$status = $data->status;
			if ($status == null) {
				array_push($errores_array, 'Falta el campo de status');
			}

			$coach_id = $data->coach_id;
			if ($coach_id == null) {
				array_push($errores_array, 'Falta el campo de ID de coach');
			}

			$discipline_id = $data->discipline_id;

			if (count($errores_array) != 0) {
				$httpCode = 400;
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $video_class->get_video_playlist(
					$user_id,
					$status,
					$coach_id,
					$discipline_id
				);
			}
		} else {
			$response_array = $video_class->get_video_playlist(
				$_POST["user_id"],
				$_POST["status"],
				$_POST["coach_id"],
				$_POST["discipline_id"]
			);
		}
		break;

	case 'mark_video':
		if ($json_call) {
			$httpCode = 500; //Por si hay un error en la lógica

			$user_id = $data->user_id;
			if ($user_id == null) {
				array_push($errores_array, 'Falta el campo de ID de usuario');
			}

			$video_id = $data->video_id;
			if ($video_id == null) {
				array_push($errores_array, 'Falta el campo de ID de video');
			}

			$fav_action = $data->fav_action;
			if ($fav_action == null) {
				array_push($errores_array, 'Falta el campo de acción de video');
			}

			if (count($errores_array) != 0) {
				$httpCode = 400;
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $video_class->mark_video(
					$user_id,
					$video_id,
					$fav_action
				);
			}
		} else {
			$response_array = $video_class->mark_video(
				$_POST["user_id"],
				$_POST["video_id"],
				$_POST["fav_action"]
			);
		}
		break;

	case 'get_favorite_videos':
		if ($json_call) {
			$httpCode = 500; //Por si hay un error en la lógica

			$user_id = $data->user_id;
			if ($user_id == null) {
				array_push($errores_array, 'Falta el campo de ID de usuario');
			}

			if (count($errores_array) != 0) {
				$httpCode = 400;
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $video_class->get_favorite_videos(
					$user_id
				);
			}
		} else {
			$response_array = $video_class->get_favorite_videos(
				$_POST["user_id"]
			);
		}
		break;

	case 'new_view':
		if ($json_call) {
			$httpCode = 500; //Por si hay un error en la lógica

			$user_id = $data->user_id;
			if ($user_id == null) {
				array_push($errores_array, 'Falta el campo de ID de usuario');
			}

			$video_id = $data->video_id;
			if ($video_id == null) {
				array_push($errores_array, 'Falta el campo de ID de video');
			}

			$video_duration = $data->video_duration;
			if ($video_duration == null) {
				array_push($errores_array, 'Falta el campo de duración de video');
			}

			if (count($errores_array) != 0) {
				$httpCode = 400;
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $analytics_class->new_view(
					$user_id,
					$video_id,
					$video_duration
				);
			}
		} else {
			$response_array = $analytics_class->new_view(
				$_POST["user_id"],
				$_POST["video_id"],
				$_POST["video_duration"]
			);
		}
		break;

	case 'new_user_view':
		if ($json_call) {
			$httpCode = 500; //Por si hay un error en la lógica

			$user_id = $data->user_id;
			if ($user_id == null) {
				array_push($errores_array, 'Falta el campo de ID de usuario');
			}

			$video_id = $data->video_id;
			if ($video_id == null) {
				array_push($errores_array, 'Falta el campo de ID de video');
			}

			$video_duration = $data->video_duration;
			if ($video_duration == null) {
				array_push($errores_array, 'Falta el campo de duración de video');
			}

			if (count($errores_array) != 0) {
				$httpCode = 400;
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $analytics_class->new_user_view(
					$user_id,
					$video_id,
					$video_duration
				);
			}
		} else {
			$response_array = $analytics_class->new_user_view(
				$_POST["user_id"],
				$_POST["video_id"],
				$_POST["video_duration"]
			);
		}
		break;

	case 'register_fcm_token':
		if ($json_call) {
			$httpCode = 500; //Por si hay un error en la lógica

			$user_id = $data->user_id;
			if ($user_id == null) {
				array_push($errores_array, 'Falta el campo de ID de usuario');
			}

			$fcm_token = $data->fcm_token;
			if ($fcm_token == null) {
				array_push($errores_array, 'Falta el campo de FCM Token');
			}

			if (count($errores_array) != 0) {
				$httpCode = 400;
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $notifications_class->register_fcm_token(
					$user_id,
					$fcm_token
				);
			}
		}
		break;

	case 'clear_session_data':
		if ($json_call) {
			$httpCode = 500; //Por si hay un error en la lógica

			$user_id = $data->user_id;
			if ($user_id == null) {
				array_push($errores_array, 'Falta el campo de ID de usuario');
			}

			$token = $data->token;

			$fcm_token = $data->fcm_token;

			if (count($errores_array) != 0) {
				$httpCode = 400;
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $user_class->clear_session_data(
					$user_id,
					$token,
					$fcm_token
				);
			}
		}
		break;


	case 'get_user_statics':
		if ($json_call) {
			$httpCode = 500; //Por si hay un error en la lógica

			$user_id = $data->user_id;
			if ($user_id == null) {
				array_push($errores_array, 'Falta el campo de ID de usuario');
			}

			if (count($errores_array) != 0) {
				$httpCode = 400;
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $analytics_class->get_user_statics(
					$user_id
				);
			}
		} else {
			$response_array = $analytics_class->get_user_statics(
				$_POST["user_id"]
			);
		}
		break;

	case 'get_coach_statics':
		if ($json_call) {
			$httpCode = 500; //Por si hay un error en la lógica

			$user_id = $data->user_id;
			if ($user_id == null) {
				array_push($errores_array, 'Falta el campo de ID de usuario');
			}

			if (count($errores_array) != 0) {
				$httpCode = 400;
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $analytics_class->get_coach_statics(
					$user_id
				);
			}
		} else {
			$response_array = $analytics_class->get_coach_statics(
				$_POST["user_id"]
			);
		}
		break;

	case 'get_service_details':
		if ($json_call) {
			$httpCode = 500; //Por si hay un error en la lógica

			$service_id = $data->service_id;
			if ($service_id == null) {
				array_push($errores_array, 'Falta el campo de id de servicio');
			}

			if (count($errores_array) != 0) {
				$httpCode = 400;
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $services_class->get_service_details(
					$service_id
				);
			}
		} else {
			$response_array = $services_class->get_service_details(
				$_POST["service_id"]
			);
		}
		break;

	case 'book_new_service':
		if ($json_call) {
			$httpCode = 500; //Por si hay un error en la lógica

			$client_user_id = $data->client_user_id;
			if ($client_user_id == null) {
				array_push($errores_array, 'Falta el campo client_user_id');
			}

			$worker_user_id = $data->worker_user_id;
			/*if($worker_user_id == null){
				array_push($errores_array, 'Falta el campo worker_user_id');
			}*/

			$service_id = $data->service_id;
			if ($service_id == null) {
				array_push($errores_array, 'Falta el campo service_id');
			}

			$appointment_date = $data->appointment_date;
			if ($appointment_date == null) {
				array_push($errores_array, 'Falta el campo appointment_date');
			}

			$appointment_location = $data->appointment_location;
			if ($appointment_location == null) {
				array_push($errores_array, 'Falta el campo appointment_location');
			}

			$payment_action = $data->payment_action;
			if ($payment_action == null) {
				array_push($errores_array, 'Falta el campo payment_action');
			}

			$customer_id = $data->customer_id;
			if ($customer_id == null) {
				array_push($errores_array, 'Falta el campo customer_id');
			}

			$method = $data->method;
			if ($method == null) {
				array_push($errores_array, 'Falta el campo method');
			}

			$card_id = $data->card_id;
			/*if($card_id == null){
				array_push($errores_array, 'Falta el campo card_id');
			}*/

			$coupon = $data->coupon;
			/*if($coupon == null){
				array_push($errores_array, 'Falta el campo coupon');
			}*/

			$status = $data->status;
			if ($status == null) {
				array_push($errores_array, 'Falta el campo status');
			}

			if (count($errores_array) != 0) {
				$httpCode = 400;
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $booking_class->book_new_service(
					$client_user_id,
					$worker_user_id,
					$service_id,
					$appointment_date,
					$appointment_location,
					$payment_action,
					$customer_id,
					$method,
					$card_id,
					$coupon,
					$status
				);
			}
		} else {
			$response_array = $booking_class->book_new_service(
				$_POST["client_user_id"],
				$_POST["worker_user_id"],
				$_POST["service_id"],
				$_POST["appointment_date"],
				$_POST["appointment_location"],
				$_POST["customer_id"],
				$_POST["method"],
				$_POST["card_id"],
				$_POST["coupon"],
				$_POST["status"]
			);
		}
		break;

	case 'confirm_service_execution':
		if ($json_call) {
			$httpCode = 500; //Por si hay un error en la lógica

			$booking_id = $data->booking_id;
			if ($booking_id == null) {
				array_push($errores_array, 'Falta el campo bookig_id');
			}

			$worker_user_id = $data->worker_user_id;
			if ($worker_user_id == null) {
				array_push($errores_array, 'Falta el campo worker_user_id');
			}

			if (count($errores_array) != 0) {
				$httpCode = 400;
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $booking_class->confirm_service_execution(
					$booking_id,
					$worker_user_id
				);
			}
		} else {
			$response_array = $booking_class->confirm_service_execution(
				$_POST["booking_id"],
				$_POST["worker_user_id"]
			);
		}
		break;

	case 'check_on_worker':
		if ($json_call) {
			$httpCode = 500; //Por si hay un error en la lógica

			$booking_id = $data->booking_id;
			if ($booking_id == null) {
				array_push($errores_array, 'Falta el campo bookig_id');
			}

			if (count($errores_array) != 0) {
				$httpCode = 400;
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $booking_class->check_on_worker(
					$booking_id
				);
			}
		} else {
			$response_array = $booking_class->check_on_worker(
				$_POST["booking_id"]
			);
		}
		break;

	case 'get_booking_data':
		if ($json_call) {
			$httpCode = 500; //Por si hay un error en la lógica

			$booking_id = $data->booking_id;
			if ($booking_id == null) {
				array_push($errores_array, 'Falta el campo bookig_id');
			}

			if (count($errores_array) != 0) {
				$httpCode = 400;
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $booking_class->get_booking_data(
					$booking_id
				);
			}
		} else {
			$response_array = $booking_class->get_booking_data(
				$_POST["booking_id"]
			);
		}
		break;

	case 'get_client_bookings':
		if ($json_call) {
			$httpCode = 500; //Por si hay un error en la lógica

			$user_id = $data->user_id;
			if ($user_id == null) {
				array_push($errores_array, 'Falta el campo user_id');
			}

			if (count($errores_array) != 0) {
				$httpCode = 400;
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $booking_class->get_client_bookings(
					$user_id
				);
			}
		} else {
			$response_array = $booking_class->get_client_bookings(
				$_POST["user_id"]
			);
		}
		break;

	case 'get_worker_bookings':
		if ($json_call) {
			$httpCode = 500; //Por si hay un error en la lógica

			$worker_user_id = $data->worker_user_id;
			if ($worker_user_id == null) {
				array_push($errores_array, 'Falta el campo worker_user_id');
			}

			if (count($errores_array) != 0) {
				$httpCode = 400;
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $booking_class->get_worker_bookings(
					$worker_user_id
				);
			}
		} else {
			$response_array = $booking_class->get_worker_bookings(
				$_POST["worker_user_id"]
			);
		}
		break;

	case 'get_avaialble_bookings_requests':
		if ($json_call) {
			$httpCode = 500; //Por si hay un error en la lógica

			$worker_user_id = $data->worker_user_id;
			if ($worker_user_id == null) {
				array_push($errores_array, 'Falta el campo worker_user_id');
			}

			if (count($errores_array) != 0) {
				$httpCode = 400;
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $booking_class->get_avaialble_bookings_requests(
					$worker_user_id
				);
			}
		} else {
			$response_array = $booking_class->get_avaialble_bookings_requests(
				$_POST["worker_user_id"]
			);
		}
		break;

	case 'create_stripe_customer':
		if ($json_call) {
			$httpCode = 500; //Por si hay un error en la lógica

			$user_id = $data->user_id;
			if ($user_id == null) {
				array_push($errores_array, 'Falta el campo user_id');
			}

			$token = $data->token;
			if ($token == null) {
				array_push($errores_array, 'Falta el campo token');
			}

			if (count($errores_array) != 0) {
				$httpCode = 400;
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $payments_class->create_stripe_customer(
					$user_id,
					$token
				);
			}
		} else {
			$response_array = $payments_class->create_stripe_customer(
				$_POST["user_id"],
				$_POST["token"]
			);
		}
		break;

	case 'get_stripe_customer_data':
		if ($json_call) {
			$httpCode = 500; //Por si hay un error en la lógica

			$user_id = $data->user_id;
			if ($user_id == null) {
				array_push($errores_array, 'Falta el campo user_id');
			}

			if (count($errores_array) != 0) {
				$httpCode = 400;
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $payments_class->get_stripe_customer_data(
					$user_id
				);
			}
		} else {
			$response_array = $payments_class->get_stripe_customer_data(
				$_POST["user_id"]
			);
		}
		break;

	case 'add_new_card':
		if ($json_call) {
			$httpCode = 500; //Por si hay un error en la lógica

			$user_id = $data->user_id;
			if ($user_id == null) {
				array_push($errores_array, 'Falta el campo user_id');
			}

			$card_token = $data->card_token;
			if ($card_token == null) {
				array_push($errores_array, 'Falta el campo card_token');
			}

			$token = $data->token;
			if ($token == null) {
				array_push($errores_array, 'Falta el campo token');
			}

			if (count($errores_array) != 0) {
				$httpCode = 400;
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $payments_class->add_new_card(
					$user_id,
					$card_token,
					$token
				);
			}
		} else {
			$response_array = $payments_class->add_new_card(
				$_POST["user_id"],
				$_POST["card_token"],
				$_POST["token"]
			);
		}
		break;

	case 'add_payment_method':
		if ($json_call) {
			$httpCode = 500; //Por si hay un error en la lógica

			$user_id = $data->user_id;
			if ($user_id == null) {
				array_push($errores_array, 'Falta el campo user_id');
			}

			$payment_method = $data->payment_method;
			if ($payment_method == null) {
				array_push($errores_array, 'Falta el campo payment_method');
			}

			$token = $data->token;
			if ($token == null) {
				array_push($errores_array, 'Falta el campo token');
			}

			if (count($errores_array) != 0) {
				$httpCode = 400;
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $payments_class->add_payment_method(
					$user_id,
					$payment_method,
					$token
				);
			}
		} else {
			$response_array = $payments_class->add_payment_method(
				$_POST["user_id"],
				$_POST["payment_method"],
				$_POST["token"]
			);
		}
		break;

	case 'get_stripe_customers_cards':
		if ($json_call) {
			$httpCode = 500; //Por si hay un error en la lógica

			$user_id = $data->user_id;
			if ($user_id == null) {
				array_push($errores_array, 'Falta el campo user_id');
			}

			if (count($errores_array) != 0) {
				$httpCode = 400;
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $payments_class->get_stripe_customers_cards(
					$user_id
				);
			}
		} else {
			$response_array = $payments_class->get_stripe_customers_cards(
				$_POST["user_id"]
			);
		}
		break;

	case 'remove_card':
		if ($json_call) {
			$httpCode = 500; //Por si hay un error en la lógica

			$user_id = $data->user_id;
			if ($user_id == null) {
				array_push($errores_array, 'Falta el campo user_id');
			}

			$card_id = $data->card_id;
			if ($card_id == null) {
				array_push($errores_array, 'Falta el campo card_id');
			}

			if (count($errores_array) != 0) {
				$httpCode = 400;
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $payments_class->remove_card(
					$user_id,
					$card_id
				);
			}
		} else {
			$response_array = $payments_class->remove_card(
				$_POST["user_id"],
				$_POST["card_id"]
			);
		}
		break;

	case 'create_subscription':
		if ($json_call) {
			$httpCode = 500; //Por si hay un error en la lógica

			$user_id = $data->user_id;
			if ($user_id == null) {
				array_push($errores_array, 'Falta el campo user_id');
			}

			$card_id = $data->card_id;
			if ($card_id == null) {
				array_push($errores_array, 'Falta el campo card_id');
			}

			if (count($errores_array) != 0) {
				$httpCode = 400;
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $payments_class->create_subscription(
					$user_id,
					$card_id
				);
			}
		} else {
			$response_array = $payments_class->create_subscription(
				$_POST["user_id"],
				$_POST["card_id"]
			);
		}
		break;

	case 'check_subscription':
		if ($json_call) {
			$httpCode = 500; //Por si hay un error en la lógica

			$user_id = $data->user_id;
			if ($user_id == null) {
				array_push($errores_array, 'Falta el campo user_id');
			}

			if (count($errores_array) != 0) {
				$httpCode = 400;
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $payments_class->check_subscription(
					$user_id
				);
			}
		} else {
			$response_array = $payments_class->check_subscription(
				$_POST["user_id"]
			);
		}
		break;

	case 'cancel_subscription':
		if ($json_call) {
			$httpCode = 500; //Por si hay un error en la lógica

			$user_id = $data->user_id;
			if ($user_id == null) {
				array_push($errores_array, 'Falta el campo user_id');
			}

			if (count($errores_array) != 0) {
				$httpCode = 400;
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $payments_class->cancel_subscription(
					$user_id
				);
			}
		} else {
			$response_array = $payments_class->cancel_subscription(
				$_POST["user_id"]
			);
		}
		break;

	case 'execute_charge':
		if ($json_call) {
			$httpCode = 500; //Por si hay un error en la lógica

			$user_id = $data->user_id;
			if ($user_id == null) {
				array_push($errores_array, 'Falta el campo user_id');
			}

			$amount = $data->amount;
			if ($amount == null) {
				array_push($errores_array, 'Falta el campo amount');
			}

			$payment_source = $data->payment_source;
			if ($payment_source == null) {
				array_push($errores_array, 'Falta el campo payment_source');
			}

			$description = $data->description;
			if ($description == null) {
				array_push($errores_array, 'Falta el campo description');
			}

			if (count($errores_array) != 0) {
				$httpCode = 400;
				$response_array = $extras_class->response("false", "e1", $errores_array, "both");
			} else {
				$httpCode = 200;
				$response_array = $payments_class->execute_charge(
					$user_id,
					$amount,
					$payment_source,
					$description
				);
			}
		} else {
			$response_array = $payments_class->execute_charge(
				$_POST["user_id"],
				$_POST["amount"],
				$_POST["payment_source"],
				$_POST["description"]
			);
		}
		break;

	default:
		$response_array = $extras_class->response("false", "e1", "Hola amigo, cómo llegaste aquí?.", "both");
		break;
}

if ($json_call) {
	header('Content-type: application/json');
	http_response_code($httpCode);
}
echo json_encode($response_array);
