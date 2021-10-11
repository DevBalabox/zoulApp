<?php
include "initializer.php";

class Discipline
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

	//Get list of all the disciplines
	public function get_disciplines_list($status)
	{
		global $extras_class;
		$disciplines_list_array = array();

		$response_array = $extras_class->response("false", "e1", "Hubo un problema interno (500).", "both");

		if ($status == "public") {
			$query_list = "SELECT * FROM disciplines WHERE status != 'privado' ORDER BY name";
			$result_list = mysqli_query($this->conn, $query_list);

			if (mysqli_num_rows($result_list)) {
				while ($row = mysqli_fetch_assoc($result_list)) {
					$disciplines_list_array[] = $row;
				}
				$response_array = $extras_class->response("true", "sc1", $disciplines_list_array, "console");
			} else {
				$response_array = $extras_class->response("false", "e1", "Hubo un problema para obtener la lista de disciplinas.", "both");
			}
		}

		return $response_array;
	}

	public function admin_edit_discipline($discipline_id, $featured_img, $name, $short_description, $status)
	{
		global $extras_class;
		global $notifications_class;

		$response_array = $extras_class->response("false", "e1", "Hubo un problema interno (500).", "both");

		$img_sql = "";
		if ($featured_img != "" && $featured_img != null) {
			$image_name = $discipline_id . strtotime("now") . ".png";
			file_put_contents('../images/' . $image_name, base64_decode($featured_img));
			$img_sql = ", img_url = '$image_name'";
		}

		if ($extras_class->record_exists("disciplines", "discipline_id", $discipline_id)) {
			$sql = "UPDATE disciplines SET name = '$name', short_description = '$short_description', status = '$status'" . $img_sql . "  WHERE discipline_id = '$discipline_id'";
			if (mysqli_query($this->conn, $sql)) {
				$response_array = $extras_class->response("true", "sc1", "Actualización exitosa.", "console");
				if($status == "Público") $notifications_class->newNotification("client","Nueva disciplina: ".$name,"Entra y descubre lo mejor de ".$name,$extras_class->gallery_path.$image_name);
			} else {
				$response_array = $extras_class->response("false", "e1", "Actualización fallida.", "both");
			}
		}

		return $response_array;
	}

	public function delete_discipline($discipline_id)
	{
		global $extras_class;

		$response_array = $extras_class->response("false", "e1", "Hubo un problema interno (500).", "both");

		$sql = "DELETE FROM disciplines WHERE discipline_id = '$discipline_id'";

		if (mysqli_query($this->conn, $sql)) {
			$response_array = $extras_class->response("true", "sc1", "La disciplina se eliminó con éxito.", "console");
		} else {
			$response_array = $extras_class->response("false", "e1", "Hubo un problema para eliminar la disciplina.", "both");
		}

		return $response_array;
	}

	public function new_discipline($featured_img, $title, $description, $status)
	{
		global $extras_class;
		global $strings_class;
		global $notifications_class;

		$response_array = $extras_class->response("false", "e1", "Hubo un problema interno (500).", "both");

		$title = mysqli_real_escape_string($this->conn, $title);
		$description = mysqli_real_escape_string($this->conn, $description);
		$status = mysqli_real_escape_string($this->conn, $status);
		$date = date('m/d/Y h:i:s a', time());
		$discipline_id = $extras_class->randomCode('discipline_');
		$image_name = "";

		$image_name = "";
		if ($featured_img != "" && $featured_img != null) {
			$image_name = $discipline_id . strtotime("now") . ".png";
			file_put_contents('../images/' . $image_name, base64_decode($featured_img));
		}

		$sql = "INSERT INTO disciplines (discipline_id,name,short_description,img_url,status) VALUES ('$discipline_id', '$title', '$description', '$image_name', '$status')";
		if (mysqli_query($this->conn, $sql)) {
			$response_array = $extras_class->response("true", "sc1", "Registro de disciplina exitoso.", "console");
			$response_array[] = array('discipline_id' =>$discipline_id);
			if($status == "Público") $notifications_class->newNotification("client","Nueva disciplina: ".$title,"Entra y descubre lo mejor de ".$title,$extras_class->gallery_path.$image_name);
		} else {
			$response_array = $extras_class->response("false", "e1", "Registro de disciplina fallido.", "both");
		}

		return $response_array;
	}
}
