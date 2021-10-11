<?php
include "initializer.php";

class Booking {

	public $conn;
	public $confirmed_status = "confirmed";

	function __construct()
	{
		global $extras_class;
		$this->conn = $extras_class->database();
	}

	//Register new booking
	public function book_new_service($client_user_id, $worker_user_id, $service_id, $appointment_date, $appointment_location, $payment_action, $customer_id, $method, $card_id, $coupon, $status){
		global $extras_class;
		global $services_class;

		$response_array = $extras_class->response("false","e1","Hubo un problema interno (500).", "both");

		$service_details_array = $services_class->get_service_details($service_id);

		if ($service_details_array[0]["status"] == "true") {
			if ($service_details_array[1]["service_data"][0]["price"] != null) {

				$date = date('m/d/Y h:i:s a', time());

				$booking_id = $extras_class->randomCode('booking_');
				while (!$extras_class->unique_id('bookings','booking_id',$booking_id)) {
				  $booking_id = $extras_class->randomCode('booking_');
				}

				$client_user_id = mysqli_real_escape_string($this->conn,$client_user_id);
				$worker_user_id = mysqli_real_escape_string($this->conn,$worker_user_id);
				$service_id = mysqli_real_escape_string($this->conn,$service_id);
				$appointment_date = mysqli_real_escape_string($this->conn,$appointment_date);
				$appointment_location = mysqli_real_escape_string($this->conn,$appointment_location);
				$payment_action = mysqli_real_escape_string($this->conn,$payment_action);

				$payment_details[] = array(
					"customer_id"=>$customer_id,
					"method"=>$method,
					"card_id"=>$card_id
				);
				$payment_details = json_encode($payment_details);

				$coupon = mysqli_real_escape_string($this->conn,$coupon);
				$status = mysqli_real_escape_string($this->conn,$status);


				$sql = "INSERT INTO bookings (booking_id,client_user_id,service_id,appointment_date,appointment_location,payment_action,coupon_id, status,creation_date,payment_details) VALUES ('$booking_id', '$client_user_id', '$service_id', '$appointment_date', '$appointment_location', '$payment_action', '$coupon', '$status', '$date', '$payment_details')";
				if (mysqli_query($this->conn,$sql)) {					
					$request_worker = $this->request_worker($booking_id);
					if ($request_worker[0]["status"] == "true") {
						$response_array = $extras_class->response("true","sc1","Se envió la solicitud a los técnicos.", "console");
						$response_array[] = array('booking_id'=>$booking_id);
					} else {
						$response_array = $extras_class->response("false","e1","Hubo un problema al solicitar tu técnico, no se te ha cobrado nada.", "both");
					}
				} else {
					$response_array = $extras_class->response("false","e1","Registro fallido del booking en fase 1.", "both");
				}

				/*$final_amount = $service_details_array[0]["message"][0]["price"];

				$purchase_details = $this->make_purchase($customer_id, $method, $card_id, $final_amount);
				if ($purchase_details[0]["status"] == "true") {
					//Registrar compra
					$response_array = $extras_class->response("true","s1","En este punto se registraría el servicio comprado.", "both");
				} else {
					//Registrar intento fallido
					$response_array = $extras_class->response("false","e1","Hubo un problema al efectuar la compra.", "both");
				}	*/
			} else {
				$response_array = $extras_class->response("false","e1","Hubo un problema al obtener el precio del servicio.", "both");
			}
		} else {
			$response_array = $extras_class->response("false","e1","Hubo un problema con el servicio solicitado.", "both");
		}

		return $response_array;
	}

	public function request_worker($booking_id){
		//Send notification to all workers
		global $extras_class;
		
		$response_array = $extras_class->response("true","s1","Se notificó a los técnicos del nuevo servicio.", "both");

		return $response_array;
	}

	public function assign_worker($worker_user_id,$booking_id){
		//Update booking with worker id
		global $extras_class;

		$response_array = $extras_class->response("false","e1","Hubo un problema interno (500).", "both");

		if ($extras_class->record_exists('bookings','booking_id',$booking_id)) {
			$sql = "UPDATE bookings SET worker_user_id = '$worker_user_id' WHERE booking_id = '$booking_id';";
			if (mysqli_query($this->conn,$sql)) {
				$update_booking = $this->update_booking_status($booking_id, "assigned_worker");
				if ($update_booking[0]["status"] == "true") {
					$response_array = $extras_class->response("true","s1","Se asignó el técnico exitósamente.", "both");
				} else {
					$response_array = $extras_class->response("false","ec1","Se asignó el técnico, pero hubo un problema para actualizar el estatus de la reservación.", "both");
				}
				
			} else {
				$response_array = $extras_class->response("false","ec1","Hubo un problema para asignar al trabajador.", "both");
			}
		} else {
			$response_array = $extras_class->response("false","ec1","No se encontró un registro de reservación con ese id.", "both");
		}

		return $response_array;
	}

	public function confirm_service_execution($booking_id, $worker_user_id){
		//Set up all the missing information and processes to confirm the booking
		global $extras_class;
		global $services_class;

		$raw_amount = null;

		$response_array = $extras_class->response("false","e1","Hubo un problema interno (500).", "both");

		if ($extras_class->record_exists('bookings','booking_id',$booking_id)) {

			$booking_data = $this->get_booking_data($booking_id);
			$client_user_id = $booking_data[1]["booking_data"][0]["client_user_id"];
			$payment_action = $booking_data[1]["booking_data"][0]["payment_action"];
			$coupon_id = $booking_data[1]["booking_data"][0]["coupon_id"];
			$service_id = $booking_data[1]["booking_data"][0]["service_id"];

			$payment_details = $booking_data[1]["booking_data"][0]["payment_details"];
			$card_id = json_decode($payment_details)[0]->card_id;


			//Aquí se evalua que exista un servicio asociado a la reservación, y si no se encuentra se envía el error.
			if($service_id != null){
				if (!$extras_class->record_exists('service_list','service_id',$service_id)) {
					$response_array = $extras_class->response("false","e1","El id del servicio que se encuentra en el registro del booking no corresponde a ninguno en la base de datos.", "both");
					return $response_array;
					exit();
				}
			} else {
				$response_array = $extras_class->response("false","e1","En el registro del booking, no está especificado el id del servicio.", "both");
				return $response_array;
				exit();
			}


			//Aquí se obtiene el costo del servicio en la reservación, y si no se encuentra se envía el error.
			$service_data = $services_class->get_service_details($service_id);
			if($service_data[0]["status"] == "true"){
				$raw_amount = $service_data[1]["service_data"][0]["price"];
				$service_title = $service_data[1]["service_data"][0]["title"];
				if ($raw_amount == null or $raw_amount == "") {
					$response_array = $extras_class->response("false","e1","El servicio asociado se encontró, pero hubo un problema para obtener el precio.", "both");
					return $response_array;
					exit();
				}
			} else {
				$response_array = $extras_class->response("false","e1","En el registro del booking, no está especificado el id del servicio.", "both");
				return $response_array;
				exit();
			}

			$assigned_worker = $this->assign_worker($worker_user_id,$booking_id);
			if($assigned_worker[0]["status"] == "true"){
				if ($payment_action == "request_payment") {

					if ($coupon_id != null) {
						$used_coupon = $this->using_coupon($coupon_id, $raw_amount);
						if ($used_coupon[0]["status"] == "true") {
							$final_amount = $used_coupon[1]["final_price"];
						} else {
							$response_array = $extras_class->response("false","e1",$used_coupon[0]["message"], "both");
							return $response_array;
							exit();
						}
					} else {
						$final_amount = $raw_amount;
					}

					if ($final_amount > 10.00) {
						$purchase_details = $this->make_purchase($client_user_id, $method, $card_id, $final_amount,$service_title);
						if ($purchase_details[0]["status"] == "true") {

							//Booking payment logs are updated
							$this->update_booking_payment_logs($booking_id, json_encode($purchase_details[1]["stripe_response"]));

							//Booking status is updated to "active"
							$update_booking = $this->update_booking_status($booking_id, $this->confirmed_status);
							if ($update_booking[0]["status"] == "true") {
								$response_array = $extras_class->response("true","s1","El servicio está confirmado y pagado. Monto pagado: $".number_format($final_amount, 2, '.', '')." mxn", "both");
							} else {
								$response_array = $extras_class->response("false","ec1","Se realizó el cargo, pero hubo un problema para actualizar el estatus de la reservación.", "both");
							}

							//Notification is sent to client and worker to notify the service is succesfully booked

							
						} else {
							//Booking status is updated to "failed_payment"
							//Notification is sent to client and worker to notify the service failed because of payment
							$response_array = $extras_class->response("false","e1",$purchase_details[0]["message"], "both");
						}
					} else {
						//Booking status is updated to "active"
						//Notification is sent to client and worker to notify the service is succesfully booked
						//Service cost was $0 or less than $10.00 mxn that's why there is no need to use Stripe
						$update_booking = $this->update_booking_status($booking_id, $this->confirmed_status);
						if ($update_booking[0]["status"] == "true") {
							$response_array = $extras_class->response("true","s1","La reservación del servicio se confirmó con éxito", "both");
						} else {
							$response_array = $extras_class->response("false","ec1","Hubo un problema para confirmar la reservación.", "both");
						}
					}

				} else {
					//Booking status is updated to "active"
					//Notification is sent to client and worker to notify the service is succesfully booked
					$update_booking = $this->update_booking_status($booking_id, $this->confirmed_status);
					if ($update_booking[0]["status"] == "true") {
						$response_array = $extras_class->response("true","s1","La reservación del servicio se confirmó con éxito", "both");
					} else {
						$response_array = $extras_class->response("false","ec1","Hubo un problema para confirmar la reservación.", "both");
					}
				}
			} else {
				//Problem while assigning worker
				$response_array = $extras_class->response("false","e1", $assigned_worker[0]["message"], "both");
			}
		} else {
			$response_array = $extras_class->response("false","ec1","No se encontró un registro de reservación con ese id.", "both");
		}

		return $response_array;

	}

	public function make_purchase($user_id, $method, $card_id, $amount, $description){
		global $extras_class;
		global $payments_class;

		$response_array = $extras_class->response("false","e1","Hubo un problema interno (500).", "both");

		$execute_charge = $payments_class->execute_charge($user_id,$amount,$card_id,$description);
		if ($execute_charge[0]["status"] == "true") {
			$response_array = $extras_class->response("true","s1","La compra se efectuó con éxito.", "both");	
			$response_array[] = array("stripe_response"=>$execute_charge[1]["stripe_response"]);			
		} else {
			$response_array = $extras_class->response("false","e1",$execute_charge[0]["message"], "both");
		}

		return $response_array;
	}

	public function update_booking_status($booking_id, $status){
		//Update booking status
		global $extras_class;

		$response_array = $extras_class->response("false","e1","Hubo un problema interno (500).", "both");

		if ($extras_class->record_exists('bookings','booking_id',$booking_id)) {
			$sql = "UPDATE bookings SET status = '$status' WHERE booking_id = '$booking_id';";
			if (mysqli_query($this->conn,$sql)) {
				$response_array = $extras_class->response("true","s1","Se actualizó el estatus exitósamente.", "both");
			} else {
				$response_array = $extras_class->response("false","ec1","Hubo un problema para actualizar el estatus de la reservación.", "both");
			}
		} else {
			$response_array = $extras_class->response("false","ec1","No se encontró un registro de reservación con ese id.", "both");
		}

		return $response_array;
	}

	public function update_booking_payment_logs($booking_id, $logs){
		//Update booking status
		global $extras_class;

		$response_array = $extras_class->response("false","e1","Hubo un problema interno (500).", "both");

		if ($extras_class->record_exists('bookings','booking_id',$booking_id)) {
			$sql = "UPDATE bookings SET payment_logs = '$logs' WHERE booking_id = '$booking_id';";
			if (mysqli_query($this->conn,$sql)) {
				$response_array = $extras_class->response("true","s1","Se actualizó el registro de logs de la reservación exitósamente.", "both");
			} else {
				$response_array = $extras_class->response("false","ec1","Hubo un problema para actualizar los logs de la reservación.", "both");
			}
		} else {
			$response_array = $extras_class->response("false","ec1","No se encontró un registro de reservación con ese id.", "both");
		}

		return $response_array;
	}

	public function using_coupon($coupon_id, $raw_amount){
		global $extras_class;
		global $coupons_class;

		//$coupon_discount = 150.20;
		$coupon_data = $coupons_class->verify_coupon($coupon_id);
		if ($coupon_data[0]["status"] == "true") {
			$coupon_discount_type = $coupon_data[1]["coupon_data"][0]["discount_type"];
			$coupon_discount = $coupon_data[1]["coupon_data"][0]["discount"];

			$final_price = $raw_amount - $coupon_discount;
			if ($final_price<0) {
				$final_price = 0.00;
			}

			$response_array = $extras_class->response("true","s1","La reservación del servicio se confirmó con éxito", "both");
			$response_array[] = array("final_price"=>$final_price);

		} else {
			$response_array = $extras_class->response("false","ec1",$coupon_data[0]["message"], "both");
		}

		return $response_array;
	}

	public function check_on_worker($booking_id){
		global $extras_class;
		global $worker_class;
		
		$response_array = $extras_class->response("false","e1","Hubo un problema interno (500).", "both");

		if ($extras_class->record_exists('bookings','booking_id',$booking_id)) {
			$query = "SELECT * FROM bookings WHERE booking_id = '$booking_id' AND worker_user_id IS NOT NULL AND status = '$this->confirmed_status'";
			$result = mysqli_query($this->conn, $query);
			if(mysqli_num_rows($result)){
				while($row = mysqli_fetch_assoc($result)) {
				  $worker_user_id = $row['worker_user_id'];
				}

				$worker_public_data = $worker_class->get_worker_public_data($worker_user_id);
				if ($worker_public_data[0]["status"] == "true") {
					$response_array = $extras_class->response("true","s1","Ya hay un técnico asignado y el servicio fue agendado.", "both");
					$response_array[] = array("worker_data"=>$worker_public_data[1]["worker_data"]);
				} else {
					$response_array = $extras_class->response("false","ec1","Ya está confirmada la reserva, y ya hay un id de técnico asignado, pero no se localizó el usuario del técnico en la base de datos.", "both");
				}
				
			} else {
				$response_array = $extras_class->response("false","ec1","Aún no hay un técnico asignado", "both");
			}
		} else {
			$response_array = $extras_class->response("false","ec1","No se encontró un registro de reservación con ese id.", "both");
		}

		return $response_array;
	}

	public function get_booking_data($booking_id){
		global $extras_class;
		$response_array = $extras_class->response("false","e1","Hubo un problema interno (500).", "both");

		if ($extras_class->record_exists('bookings','booking_id',$booking_id)) {
			$query = "SELECT * FROM bookings WHERE booking_id = '$booking_id'";
			$result = mysqli_query($this->conn, $query);
			if(mysqli_num_rows($result)){
				$row = mysqli_fetch_assoc($result);
				$booking_data[] = $row;
				$response_array = $extras_class->response("true","s1","Se obtuvo la información del booking con éxito.", "both");
				$response_array[] = array("booking_data"=>$booking_data);
			}
		} else {
			$response_array = $extras_class->response("false","ec1","No se encontró un registro de reservación con ese id.", "both");
		}

		return $response_array;
	}

	public function get_client_bookings($client_user_id){
		global $extras_class;
		global $worker_class;
		global $services_class;

		$response_array = $extras_class->response("false","e1","Hubo un problema interno (500).", "both");

		$bookings_array;

		if ($extras_class->record_exists('users','user_id',$client_user_id)) {			
			$query = "SELECT * FROM bookings WHERE client_user_id = '$client_user_id' ORDER BY id DESC";
			$result = mysqli_query($this->conn, $query);
			if(mysqli_num_rows($result)){
				while($row = mysqli_fetch_assoc($result)) {
					$appointment_details = "";
					$booking_filtered_array = "";

					$worker_user_id = $row['worker_user_id'];
					$service_id = $row['service_id'];

					//Get all data

					$service_details = $services_class->get_service_details($service_id);

					$worker_public_data = $worker_class->get_worker_public_data($worker_user_id);

					$appointment_details[] = array("scheduled_time"=>$row['appointment_date'], "worker"=>$worker_public_data[1]["worker_data"][0]["name"], "worker_phone"=>$worker_public_data[1]["worker_data"][0]["phone"],"location"=>$row['appointment_location']);

					$payment_details = json_decode($row['payment_details']);
					if ($payment_details != null) {
						$card_lastnumbers = $payment_details[0]->card_id;
						$card_brand = $payment_details[0]->card_id;
					}

					//Prepare array
					$booking_filtered_array = array(
						"filter"=>"coming",
						"booking_id"=>$row['booking_id'],
						"paid_amount"=>$row['paid_amount'],
						"full_date"=>$row['creation_date'],
						"display_date"=>$row['creation_date'],
						"card_lastnumbers"=>$card_lastnumbers,
						"card_brand"=>$card_brand,
						"service_details"=>$service_details[1]["service_data"],
						"appointment_details"=>$appointment_details
					);

					$bookings_array[] = $booking_filtered_array;
				}
				$response_array = $extras_class->response("true","s1","Se obtuvo la lista de bookings para el usuario seleccionado con éxito.", "both");
				$response_array[] = array("bookings_list"=> $bookings_array);
			} else {
				$response_array = $extras_class->response("false","ec1","Este usuario aún no tiene reservaciones.", "both");
			}
		} else {
			$response_array = $extras_class->response("false","ec1","No se encontró el usuario para el que se quiere saber las reservaciones.", "both");
		}

		return $response_array;
	}

	public function get_worker_bookings($worker_user_id){
		global $extras_class;
		global $worker_class;
		global $services_class;
		global $user_class;

		$response_array = $extras_class->response("false","e1","Hubo un problema interno (500).", "both");

		$bookings_array;

		if ($extras_class->record_exists('users','user_id',$worker_user_id)) {			
			$query = "SELECT * FROM bookings WHERE worker_user_id = '$worker_user_id' ORDER BY id DESC";
			$result = mysqli_query($this->conn, $query);
			if(mysqli_num_rows($result)){
				while($row = mysqli_fetch_assoc($result)) {
					$appointment_details = "";
					$booking_filtered_array = "";

					$client_user_id = $row['client_user_id'];
					$service_id = $row['service_id'];

					//Get all data

					$service_details = $services_class->get_service_details($service_id);

					$user_public_data = $user_class->get_user_public_data($client_user_id);


					$appointment_details[] = array("scheduled_time"=>$row['appointment_date'], "client"=>$user_public_data[1]["user_data"][0]["name"], "phone"=>$user_public_data[1]["user_data"][0]["phone"],"location"=>$row['appointment_location']);

					$payment_details = json_decode($row['payment_details']);
					if ($payment_details != null) {
						$card_lastnumbers = $payment_details[0]->card_id;
						$card_brand = $payment_details[0]->card_id;
					}

					//Prepare array
					$booking_filtered_array = array(
						"filter"=>"coming",
						"booking_id"=>$row['booking_id'],
						"paid_amount"=>$row['paid_amount'],
						"full_date"=>$row['creation_date'],
						"display_date"=>$row['creation_date'],
						"card_lastnumbers"=>$card_lastnumbers,
						"card_brand"=>$card_brand,
						"service_details"=>$service_details[1]["service_data"],
						"appointment_details"=>$appointment_details
					);

					$bookings_array[] = $booking_filtered_array;
				}
				$response_array = $extras_class->response("true","s1","Se obtuvo la lista de bookings para el trabajador seleccionado con éxito.", "both");
				$response_array[] = array("bookings_list"=> $bookings_array);
			} else {
				$response_array = $extras_class->response("false","ec1","Este trabajador aún no tiene reservaciones.", "both");
			}
		} else {
			$response_array = $extras_class->response("false","ec1","No se encontró el usuario para el que se quiere saber las reservaciones.", "both");
		}

		return $response_array;
	}


	public function get_avaialble_bookings_requests($worker_user_id){
		global $extras_class;
		global $worker_class;
		global $services_class;
		global $user_class;

		$response_array = $extras_class->response("false","e1","Hubo un problema interno (500).", "both");

		$bookings_array;

		if ($extras_class->record_exists('users','user_id',$worker_user_id)) {			
			$query = "SELECT * FROM bookings WHERE status = 'looking_for_worker' ORDER BY id DESC";
			$result = mysqli_query($this->conn, $query);
			if(mysqli_num_rows($result)){
				while($row = mysqli_fetch_assoc($result)) {
					$appointment_details = "";
					$booking_filtered_array = "";

					$client_user_id = $row['client_user_id'];
					$service_id = $row['service_id'];

					//Get all data

					$service_details = $services_class->get_service_details($service_id);

					$user_public_data = $user_class->get_user_public_data($client_user_id);


					$appointment_details[] = array("scheduled_time"=>$row['appointment_date'], "client"=>$user_public_data[1]["user_data"][0]["name"], "phone"=>$user_public_data[1]["user_data"][0]["phone"],"location"=>$row['appointment_location']);

					//Prepare array
					$booking_filtered_array = array(
						"filter"=>"coming",
						"booking_id"=>$row['booking_id'],
						"paid_amount"=>$row['paid_amount'],
						"full_date"=>$row['creation_date'],
						"display_date"=>$row['creation_date'],
						"service_details"=>$service_details[1]["service_data"],
						"appointment_details"=>$appointment_details
					);

					$bookings_array[] = $booking_filtered_array;
				}
				$response_array = $extras_class->response("true","s1","Se obtuvo la lista de bookings para el trabajador seleccionado con éxito.", "both");
				$response_array[] = array("bookings_list"=> $bookings_array);
			} else {
				$response_array = $extras_class->response("false","ec1","No hay nuevas solicitudes.", "both");
			}
		} else {
			$response_array = $extras_class->response("false","ec1","No se encontró el usuario para el que se quiere saber las reservaciones.", "both");
		}

		return $response_array;
	}
}
?>