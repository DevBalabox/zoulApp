<?php
include "initializer.php";

class Subscription
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

    /* public function check_subscription($user_id)
    {
        global $extras_class;
        $response_array = $extras_class->response("false", "e1", "Hubo un problema interno (500).", "both");
        $status = null;

        $query = "SELECT * FROM subscriptions WHERE user_id = '$user_id'";
        $result = mysqli_query($this->conn, $query);
        if (mysqli_num_rows($result)) {
            while ($row = mysqli_fetch_assoc($result)) {
                $status = $row['status'];
            }
            if ($status == "active") {
                $response_array = $extras_class->response("true", "sc1", "La suscripción del usuario se encuentra activa.", "both");
            } else {
                $response_array = $extras_class->response("false", "e1", "La suscripción del usuario se encuentra inactiva.", "both");
            }
        } else {
            $response_array = $extras_class->response("false", "e1", "No se encontró ningún registro de suscripción para el usuario.", "both");
        }

        return $response_array;
    } */

    public function get_subscription_id($user_id)
    {
        global $extras_class;
        $response_array = $extras_class->response("false", "e1", "Hubo un problema interno (500).", "both");
        $status = null;

        $query = "SELECT * FROM subscriptions WHERE user_id = '$user_id'";
        $result = mysqli_query($this->conn, $query);
        if (mysqli_num_rows($result)) {
            while ($row = mysqli_fetch_assoc($result)) {
                $subscription_id = $row['subscription_id'];
            }
            $response_array = $extras_class->response("true", "sc1", "El id de la suscripción se obtuvo con éxito.", "console");
            $response_array[] = array("subscription_id" => $subscription_id);
        } else {
            $response_array = $extras_class->response("false", "e2", "No se encontró un id de suscripción.", "both");
        }

        return $response_array;
    }
    

    public function add_subscription($user_id, $subscription_id)
    {
        global $extras_class;
        $response_array = $extras_class->response("false", "e1", "Hubo un problema interno (500).", "both");
        $status = null;

        $query = "SELECT * FROM subscriptions WHERE user_id = '$user_id'";
        $result = mysqli_query($this->conn, $query);
        if (mysqli_num_rows($result)) {
            $sql = "UPDATE subscriptions SET subscription_id = '$subscription_id' WHERE user_id = '$user_id'";
            if (mysqli_query($this->conn, $sql)) {
                $response_array = $extras_class->response("true", "sc1", "Actualización de suscripción exitosa.", "console");
            } else {
                $response_array = $extras_class->response("false", "e2", "Hubo un problema al actualizar la suscripción.", "both");
            }
        } else {

            $sql = "INSERT INTO subscriptions (subscription_id,user_id) VALUES ('$subscription_id', '$user_id')";
            if (mysqli_query($this->conn, $sql)) {
                $response_array = $extras_class->response("true", "sc1", "Suscripción exitosa.", "console");
            } else {
                $response_array = $extras_class->response("false", "e1", "Suscripción fallida.", "both");
            }
        }

        return $response_array;
    }
}
