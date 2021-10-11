<?php
include "initializer.php";

class Video
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

    public function get_video_playlist($user_id, $status, $coach_id, $discipline_id)
    {
        global $extras_class;
        $data_list_array = array();

        $response_array = $extras_class->response("false", "e1", "Hubo un problema interno (500).", "both");

        if ($status == "active") {

            $discipline_query = "";
            if ($discipline_id != "" && $discipline_id != null) {
                $discipline_query = "AND discipline_id = '$discipline_id'";
            }

            $query_list_videos = "SELECT * FROM videos WHERE coach_id = '$coach_id' AND status = 'Público' " . $discipline_query . " ORDER BY id DESC";
            $result_list_videos = mysqli_query($this->conn, $query_list_videos);
            if (mysqli_num_rows($result_list_videos)) {
                while ($row_videos = mysqli_fetch_assoc($result_list_videos)) {
                    $video_id = $row_videos["video_id"];
                    $title = $row_videos["title"];
                    $description = $row_videos["description"];
                    $img_url = $row_videos["img_url"];
                    $source = $row_videos["source"];
                    $external_id = $row_videos["external_id"];

                    $video_details = $this->get_video_details($source, $external_id);
                    if ($video_details[0]["status"] == "true") {
                        $video_details = $video_details[1];
                    } else {
                        $video_details = null;
                    }

                    $is_fav = $this->is_fav($user_id, $video_id);
                    $video_flag = "false";
                    if ($is_fav[0]["status"] == "true") {
                        $video_flag = "true";
                    }

                    $data_list_array[] = array(
                        "video_id" => $video_id,
                        "is_favorite" => $video_flag,
                        "title" => $title,
                        "description" => $description,
                        "img_url" => $img_url,
                        "video_details" => $video_details
                    );
                }
            } else {
                $response_array = $extras_class->response("false", "e1", "No se encontraron videos de este coach.", "both");
                return $response_array;
                exit();
            }
        } else {
            $response_array = $extras_class->response("false", "e1", "No pudimos encontrar videos con ese estatus.", "both");
            return $response_array;
            exit();
        }


        $response_array = $extras_class->response("true", "sc1", "Se obtuvo la lista de videos con éxito", "console");
        $response_array[] = array('videos_list' => $data_list_array);

        return $response_array;
    }

    public function is_fav($user_id, $video_id)
    {
        global $extras_class;
        $response_array = $extras_class->response("false", "e1", "Hubo un problema interno (500).", "both");

        $query_list_favs = "SELECT * FROM favorites WHERE user_id = '$user_id' AND video_id = '$video_id'";
        $result_list_favs = mysqli_query($this->conn, $query_list_favs);
        if (mysqli_num_rows($result_list_favs)) {
            $response_array = $extras_class->response("true", "sc1", "El video está marcado como favorito.", "console");
        } else {
            $response_array = $extras_class->response("false", "e1", "El video no está marcado como favorito.", "console");
        }

        return $response_array;
    }

    public function get_video_details($source, $video_id)
    {
        global $extras_class;
        $response_array = $extras_class->response("false", "e1", "Hubo un problema interno (500).", "both");
        $url = "";
        $header = "";
        $access_token = "";

        switch ($source) {
            case 'vimeo':
                $url = $extras_class->vimeo_video_api_link . $video_id . "/config";
                $header = $extras_class->vimeo_header;
                $access_token = $extras_class->vimeo_access_token;
                break;
        }

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

        $headers = [
            'Authorization: ' . $access_token,
            'Accept: ' . $header,
            'Content-Type: application/json'
        ];

        curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);

        $server_output = curl_exec($ch);

        curl_close($ch);

        $output_array = json_decode($server_output);
        /* $video_url = $output_array->request->files->dash->hls->cdns->akfire_interconnect_quic->url; */
        $thumbnail_size = "640";
        $duration = $output_array->video->duration;
        $thumbnail = $output_array->video->thumbs->$thumbnail_size;
        $default_cdn = $output_array->request->files->hls->default_cdn;
        $video_url = $output_array->request->files->hls->cdns->$default_cdn->url;
        $time_unit = "mins.";



        if (is_int($duration)) {
            $required_time = round($duration * ($extras_class->required_video_percent / 100));
            if ($duration > 3600) {
                $duration = gmdate("H:i:s", $duration);
                $time_unit = "hrs.";
            } else {
                $duration = gmdate('i:s', $duration);
            }
        }

        $response_array = $extras_class->response("true", "sc1", "Se obtuvo la información del video con éxito", "console");
        $response_array[] = array("thumbnail" => $thumbnail . "?v=" . rand(1, 1000), 'url' => $video_url, 'duration' => $duration . " " . $time_unit, 'required_time' => $required_time);

        return $response_array;
    }

    public function mark_video($user_id, $video_id, $fav_action)
    {
        global $extras_class;
        $response_array = $extras_class->response("false", "e1", "Hubo un problema interno (500).", "both");

        if ($fav_action == "fav") {
            $query_list_favs = "SELECT * FROM favorites WHERE user_id = '$user_id' AND video_id = '$video_id'";
            $result_list_favs = mysqli_query($this->conn, $query_list_favs);
            if (!mysqli_num_rows($result_list_favs)) {
                $sql = "INSERT INTO favorites (user_id,video_id) VALUES ('$user_id', '$video_id')";
                if (mysqli_query($this->conn, $sql)) {
                    $response_array = $extras_class->response("true", "sc1", "El video se marcó como favorito.", "console");
                } else {
                    $response_array = $extras_class->response("false", "e1", "Hubo un problema para marcar el video como favorito.", "both");
                }
            } else {
                $response_array = $extras_class->response("true", "sc1", "El video ya está marcado como favorito.", "console");
            }
        } else if ($fav_action == "unfav") {
            $sql = "DELETE FROM favorites WHERE user_id = '$user_id' AND video_id ='$video_id'";
            if (mysqli_query($this->conn, $sql)) {
                $response_array = $extras_class->response("true", "sc1", "El video se desmarcó como favorito.", "console");
            } else {
                $response_array = $extras_class->response("false", "e1", "Parece que ya estaba desmarcado ese video como favorito.", "both");
            }
        }

        return $response_array;
    }

    public function get_favorite_videos($user_id)
    {
        global $extras_class;
        $data_list_array = array();

        $response_array = $extras_class->response("false", "e1", "Hubo un problema interno (500).", "both");

        $query_list_favs = "SELECT * FROM favorites WHERE user_id = '$user_id' ORDER BY id DESC";
        $result_list_favs = mysqli_query($this->conn, $query_list_favs);
        if (mysqli_num_rows($result_list_favs)) {
            while ($row_favs = mysqli_fetch_assoc($result_list_favs)) {
                $video_id = $row_favs["video_id"];

                $query_list_videos = "SELECT * FROM videos WHERE video_id = '$video_id' ORDER BY id DESC";
                $result_list_videos = mysqli_query($this->conn, $query_list_videos);
                if (mysqli_num_rows($result_list_videos)) {
                    while ($row_videos = mysqli_fetch_assoc($result_list_videos)) {
                        $video_id = $row_videos["video_id"];
                        $title = $row_videos["title"];
                        $description = $row_videos["description"];
                        $img_url = $row_videos["img_url"];
                        $source = $row_videos["source"];
                        $external_id = $row_videos["external_id"];

                        $video_details = $this->get_video_details($source, $external_id);
                        if ($video_details[0]["status"] == "true") {
                            $video_details = $video_details[1];
                        } else {
                            $video_details = null;
                        }

                        $is_fav = $this->is_fav($user_id, $video_id);
                        $video_flag = "false";
                        if ($is_fav[0]["status"] == "true") {
                            $video_flag = "true";
                        }

                        $data_list_array[] = array(
                            "video_id" => $video_id,
                            "is_favorite" => $video_flag,
                            "title" => $title,
                            "description" => $description,
                            "img_url" => $img_url,
                            "video_details" => $video_details
                        );
                    }
                }
            }
        } else {
            $response_array = $extras_class->response("false", "e1", "Aún no tienes videos favoritos.", "console");
            return $response_array;
            exit();
        }

        $response_array = $extras_class->response("true", "sc1", "Se obtuvo la lista de videos con éxito", "console");
        $response_array[] = array('videos_list' => $data_list_array);

        return $response_array;
    }

    public function admin_edit_video($video_id, $coach_id, $discipline_id, $external_id, $title, $description, $status, $source)
    {
        global $extras_class;
        global $notifications_class;

        $response_array = $extras_class->response("false", "e1", "Hubo un problema interno (500).", "both");

        if ($extras_class->record_exists("videos", "video_id", $video_id)) {
            $sql = "UPDATE videos SET coach_id = '$coach_id', discipline_id = '$discipline_id', external_id = '$external_id', title = '$title', description = '$description', status = '$status', source = '$source'  WHERE video_id = '$video_id'";
            if (mysqli_query($this->conn, $sql)) {
                $response_array = $extras_class->response("true", "sc1", "Actualización exitosa.", "console");

                if ($status == "Público") {
                    $sqlcoach = "SELECT * FROM users u 
                    INNER JOIN coaches c on c.user_id = u.user_id
                    WHERE c.coach_id = '$coach_id'";

                    $resultcoach = mysqli_query($this->conn, $sqlcoach);
                    if (mysqli_num_rows($resultcoach)) {
                        $coachname = "";
                        $disciplinetitle = "";

                        while ($rowcoach = mysqli_fetch_assoc($resultcoach)) {
                            $coachname = $rowcoach["name"] . " " . $rowcoach["first_lastname"];
                        }

                        $sqldiscipline = "SELECT * FROM disciplines WHERE discipline_id = '$discipline_id'";
                        $resultdiscipline = mysqli_query($this->conn, $sqldiscipline);
                        if (mysqli_num_rows($resultdiscipline)) {
                            while ($rowdiscipline = mysqli_fetch_assoc($resultdiscipline)) {
                                $disciplinetitle = $rowdiscipline["name"];
                            }
                        }

                        if ($coachname != "" && $disciplinetitle != "") $notifications_class->newNotification("client", "Nuevo video de " . $coachname, "Entra a " . $disciplinetitle . " para ver esta nueva rutina de " . $coachname, "");
                    }
                }
            } else {
                $response_array = $extras_class->response("false", "e1", "Actualización fallida.", "both");
            }
        }

        return $response_array;
    }

    public function delete_video($video_id)
    {
        global $extras_class;

        $response_array = $extras_class->response("false", "e1", "Hubo un problema interno (500).", "both");

        $sql = "DELETE FROM videos WHERE video_id = '$video_id'";

        if (mysqli_query($this->conn, $sql)) {
            $response_array = $extras_class->response("true", "sc1", "El video se eliminó con éxito.", "console");
        } else {
            $response_array = $extras_class->response("false", "e1", "Hubo un problema para eliminar el video.", "both");
        }

        return $response_array;
    }

    public function new_video($coach_id, $discipline_id, $external_id, $title, $description, $status, $source)
    {
        global $extras_class;
        global $strings_class;

        $response_array = $extras_class->response("false", "e1", "Hubo un problema interno (500).", "both");

        $coach_id = mysqli_real_escape_string($this->conn, $coach_id);
        $discipline_id = mysqli_real_escape_string($this->conn, $discipline_id);
        $external_id = mysqli_real_escape_string($this->conn, $external_id);
        $title = mysqli_real_escape_string($this->conn, $title);
        $description = mysqli_real_escape_string($this->conn, $description);
        $status = mysqli_real_escape_string($this->conn, $status);
        $source = mysqli_real_escape_string($this->conn, $source);
        $date = date('m/d/Y h:i:s a', time());
        $video_id = $extras_class->randomCode('video_');

        $sql = "INSERT INTO videos (video_id,coach_id,discipline_id,external_id,title,description,img_url,status,source) VALUES ('$video_id', '$coach_id', '$discipline_id', '$external_id', '$title', '$description', 'video_placeholder.png', '$status', '$source')";
        if (mysqli_query($this->conn, $sql)) {
            $response_array = $extras_class->response("true", "sc1", "Registro de video exitoso.", "console");
            $response_array[] = array('video_id' => $video_id);
        } else {
            $response_array = $extras_class->response("false", "e1", "Registro de video fallido.", "both");
        }

        return $response_array;
    }
}
