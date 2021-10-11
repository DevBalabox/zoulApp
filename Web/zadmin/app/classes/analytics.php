<?php
include "initializer.php";

class Analytics
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

    public function new_view($user_id, $video_id, $video_duration)
    {
        global $extras_class;
        $response_array = $extras_class->response("false", "e1", "Hubo un problema interno (500).", "both");

        $sql = "INSERT INTO views (user_id,video_id, streamed_time) VALUES ('$user_id', '$video_id', '$video_duration')";
        if (mysqli_query($this->conn, $sql)) {
            $response_array = $extras_class->response("true", "sc1", "Se registro la vista exitósamente.", "console");
        } else {
            $response_array = $extras_class->response("false", "e1", "Hubo un problema para registrar la vista.", "both");
        }
        return $response_array;
    }

    public function new_user_view($user_id, $video_id, $video_duration)
    {
        global $extras_class;
        $response_array = $extras_class->response("false", "e1", "Hubo un problema interno (500).", "both");

        $sql = "INSERT INTO user_views (user_id,video_id, streamed_time) VALUES ('$user_id', '$video_id', '$video_duration')";
        if (mysqli_query($this->conn, $sql)) {
            $response_array = $extras_class->response("true", "sc1", "Se registro la vista exitósamente.", "console");
        } else {
            $response_array = $extras_class->response("false", "e1", "Hubo un problema para registrar la vista.", "both");
        }
        return $response_array;
    }

    public function get_user_statics($user_id)
    {
        global $extras_class;
        $response_array = $extras_class->response("false", "e1", "Hubo un problema interno (500).", "both");
        $disciplines_array = array();
        $total_time = 0;
        $m_array = array();
        $days = $extras_class->analytic_days;

        $sql = "SELECT * FROM user_views WHERE user_id = '$user_id'";
        $result = mysqli_query($this->conn, $sql);
        if (mysqli_num_rows($result)) {
            while ($row = mysqli_fetch_assoc($result)) {
                $video_id = $row["video_id"];

                $sql_disciplines = "SELECT * FROM videos WHERE video_id = '$video_id'";
                $result_disciplines = mysqli_query($this->conn, $sql_disciplines);
                if (mysqli_num_rows($result_disciplines)) {
                    while ($row_disciplines = mysqli_fetch_assoc($result_disciplines)) {
                        $discipline_id = $row_disciplines["discipline_id"];

                        if (!in_array($discipline_id, $disciplines_array)) {
                            array_push($disciplines_array, $discipline_id);
                        }
                    }
                }

                array_push($m_array, $video_id);
            }
        } else {
            $response_array = $extras_class->response("false", "e1", "Aún no cuentas con analítica.", "console");
            return $response_array;
            exit();
        }

        $sql = "SELECT * FROM user_views WHERE user_id = '$user_id' AND (`creation_date` > DATE_SUB(now(), INTERVAL '$days' DAY)) ORDER BY id DESC";
        $result = mysqli_query($this->conn, $sql);
        if (mysqli_num_rows($result)) {
            while ($row = mysqli_fetch_assoc($result)) {
                $streamed_time = $row["streamed_time"];
                $total_time = $total_time + $streamed_time;
                array_push($m_array, $video_id);
            }

            $total_time = round($total_time / 60);
            $response_array = $extras_class->response("true", "sc1", "Se obtuvo la analítica con éxito", "console");
            $data_array[] = array('days_period' => $days, 'total_time' => $total_time, 'unit' => "minutos", 'disciplines_count' => count($disciplines_array));
        } else {
            $response_array = $extras_class->response("true", "sc1", "Aún no cuentas con nueva analítica en estos últimos " . $days . " días, pero te mostramos las disciplinas aprendidas en todo tu ciclo.", "console");
            $$data_array[] = array('days_period' => $days, 'total_time' => 0, 'unit' => "minutos", 'disciplines_count' => count($disciplines_array));
        }
        $response_array[] = array("data" => $data_array);

        return $response_array;
    }

    public function get_coach_statics($user_id)
    {
        global $extras_class;
        global $coach_class;
        $response_array = $extras_class->response("false", "e1", "Hubo un problema interno (500).", "both");
        $periods_array = array();
        $coach_id = "";

        $get_coach_id = $coach_class->get_coach_id($user_id);
        if ($get_coach_id[0]["status"] != "true") {
            $response_array = $extras_class->response("false", "e1", $get_coach_id[0]["message"], "both");
            return $response_array;
            exit();
        } else {
            $coach_id = $get_coach_id[1]["coach_id"];
        }

        $sql = "SELECT a.id, count(*) as total_views, a.creation_date FROM views as a INNER JOIN videos as b WHERE b.coach_id = '$coach_id' AND b.video_id = a.video_id GROUP BY YEAR(a.creation_date), month(a.creation_date) ORDER by a.creation_date DESC";
        $result = mysqli_query($this->conn, $sql);
        if (mysqli_num_rows($result)) {
            while ($row = mysqli_fetch_assoc($result)) {
                $total_views = $row["total_views"];
                $date_period = $row["creation_date"];

                setlocale(LC_TIME, "es_ES");
                $date_period = strtoupper(strftime("%B, %Y", strtotime($date_period)));

                $periods_array[] = array("period" => $date_period, "views" => $total_views);
            }

            $response_array = $extras_class->response("true", "sc1", "Se obtuvo la analítica con éxito", "console");
            $response_array[] = array('periods' => $periods_array);
        } else {
            $response_array = $extras_class->response("false", "e1", "Aún no cuentas con analítica.", "console");
            return $response_array;
            exit();
        }

        return $response_array;
    }
}
