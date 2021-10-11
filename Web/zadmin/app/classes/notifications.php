<?php
include "initializer.php";

class Notifications
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

	public function newNotification($user_type,$title, $body, $img_url)
	{
		global $extras_class;

		$get_tokens = $this->get_fcm_tokens($user_type);
		if ($get_tokens[0]["status"] != "true") {
			$response_array = $get_tokens;
			return $response_array;
			exit();
		} else {
			$token_list = $get_tokens[1]["fcm_tokens"]; 
		}

		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL, $extras_class->fcm_url);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

		$headers = [
			'Authorization: key=' . $extras_class->fcm_server_key,
			'Content-Type: application/json'
		];

		$data = '
		{
			"notification": {
				"body": "' . $body . '",
				"title": "' . $title . '",
				"image": "' . $img_url . '",
				"sound": "default"
			},
			"priority": "high",
			"data": {
				"click_action": "FLUTTER_NOTIFICATION_CLICK",
				"id": "1",
				"status": "done"
			},
			"registration_ids": '.$token_list.'
		}
		';

		curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
		curl_setopt($ch, CURLOPT_POSTFIELDS, $data);

		$server_output = curl_exec($ch);

		curl_close($ch);
	}

	public function register_fcm_token($user_id, $fcm_token)
	{
		global $extras_class;
		$response_array = $extras_class->response("false", "e1", "Hubo un problema interno (500).", "both");

		$sql = "INSERT INTO fcm_tokens (user_id, fcm_token)
		SELECT * FROM (SELECT '$user_id', '$fcm_token') AS tmp
		WHERE NOT EXISTS (
			SELECT fcm_token FROM fcm_tokens WHERE fcm_token = '$fcm_token' AND user_id = '$user_id'
		) LIMIT 1;";
		if (mysqli_query($this->conn, $sql)) {
			$response_array = $extras_class->response("true", "sc1", "Se registro  el FCM Token exitósamente.", "console");
		} else {
			$response_array = $extras_class->response("false", "e1", "Hubo un problema para registrar el FCM Token.", "both");
		}
		return $response_array;
	}


	public function delete_fcm_token($user_id,$fcm_token)
    {
        global $extras_class;
        $response_array = $extras_class->response("false", "e1", "Hubo un problema interno (500).", "both");

        $sql = "DELETE FROM fcm_tokens WHERE user_id = '$user_id' AND fcm_token = '$fcm_token'";

        if (mysqli_query($this->conn, $sql)) {
            $response_array = $extras_class->response("true", "sc1", "El FCM token se eliminó con éxito.", "console");
        } else {
            $response_array = $extras_class->response("false", "e1", "Hubo un problema para eliminar el FCM token.", "both");
        }

        return $response_array;
	}
	
	public function get_fcm_tokens($user_type)
	{
		global $extras_class;
		$response_array = $extras_class->response("false", "e1", "Hubo un problema interno (500).", "both");
		$tokens_string = "";

		$query = "SELECT t.fcm_token FROM fcm_tokens as t INNER JOIN users as u WHERE u.user_id = t.user_id AND u.type = '$user_type'";
		$result = mysqli_query($this->conn, $query);
		if (mysqli_num_rows($result)) {
			$tokens_string .= '[';
			while ($row = mysqli_fetch_assoc($result)) {
				$tokens_string .= '"' . $row["fcm_token"] . '",';
			}
			$tokens_string .= ']';
			$response_array = $extras_class->response("true", "sc1", "Se obtuvieron los FCM Tokens exitósamente.", "console");
			$response_array[] = array("fcm_tokens" => $tokens_string);
		} else {
			$response_array = $extras_class->response("false", "e1", "No se encontraron FCM Tokens.", "console");
		}
		return $response_array;
	}
}
