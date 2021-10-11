<?php
//Funciones Extra

class Extras
{

	public $dblocation;
	public $dbuser;
	public $dbpass;
	public $db;

	public $mainurl;
	public $webmastermail;
	public $companymail;
	public $companymail_password;
	public $mailserver;
	public $smtp_port;

	public $templates_path;

	//Permalinks
	public $home_url;
	public $login_url;
	public $gallery_path;
	public $coach_home_url;
	public $coach_login_url;
	public $coach_upload_video_url;
	public $support_url;

	//Assets
	public $logo;

	//Payments
	public $stripe_api_key;
	public $subscription_price_id;
	public $active_non_renewable_code;

	//Vimeo
	public $vimeo_video_api_link;
	public $vimeo_access_token;
	public $vimeo_header;

	//Analytics
	public $required_video_percent;
	public $analytic_days;

	//Notifications
	public $fcm_url;
	public $fcm_server_key;
	public $fcm_test_token;

	function __construct()
	{

		$this->mainurl = "http://balabox-demos.com/zoul/";
		$this->dblocation = "localhost";
		$this->dbuser = "balaboxd_javier";
		$this->dbpass = "wJxci-HHXxWr";
		$this->db = "balaboxd_testzoul";
		$this->webmastermail = 'pruebas.balabox@gmail.com';
		$this->companymail = 'pruebas@balabox-demos.com';
		$this->companymail_password = 'PruebasBalabox.';
		$this->mailserver = 'mail.balabox-demos.com';
		$this->smtp_port = 25;

		$this->templates_path = "/../templates/";

		//Permalinks
		$this->home_url = "https://balabox-demos.com/zoul/zadmin/";
		$this->login_url = "https://balabox-demos.com/zoul/zadmin/login";
		$this->gallery_path = "https://balabox-demos.com/zoul/zadmin/app/images/";
		$this->coach_home_url = "https://balabox-demos.com/zoul/coach/";
		$this->coach_login_url = "https://balabox-demos.com/zoul/coach/login";
		$this->coach_upload_video_url = "https://balabox-demos.com/zoul/coach/new-video";
		$this->support_url = "https://balabox-demos.com/zoul/soporte";

		//Assets
		$this->logo = "https://balabox-demos.com/zoul/zadmin/img/logo-horizontal.png";

		//Payments
		$this->stripe_api_key = "sk_live_f8mJwHxtfsa0g9ZkYZnJ6Xng00licMF6ZP";
		$this->subscription_price_id = "price_1Gy6bhJcLXgiLXLK9GgCj5RW";
		$this->active_non_renewable_code = "anrc";


		//Vimeo
		$this->vimeo_video_api_link = "https://player.vimeo.com/video/";
		$this->vimeo_access_token = "bearer 62dce5af4acd0190b1ea62e1e06dd133";
		$this->vimeo_header = "application/vnd.vimeo.user+json;version=3.0,application/vnd.vimeo.video+json;version=3.4";

		//Analytics
		$this->required_video_percent = 50;
		$this->analytic_days = 7;

		//Notifications
		$this->fcm_url = "https://fcm.googleapis.com/fcm/send";
		$this->fcm_server_key = "AAAABw7IMk4:APA91bEUQ5ZAz4csZUZt8p3SrjjK22uC3q5YXlZMqorg6Ss3SCFXqb0Uul68iuyzY2e1qgJnRe0GrGc96iQwZrMFt-zu_1fRwWw4-QR7xvbylq-E4IpP96XwVWrrgDKWNZtcqQ-2LLSz";
		$this->fcm_test_token = "cl1dMDB7aEz_sl3PHvbvsx:APA91bFGGyQylLdyKOyCtN6aVWx4f6N1qrwSFlb3cRIMwUybMgmzRdIjzIgrSKGsh4C8Pj5MS6y3nNVcmyBxMqOSvO_mw1_e18eV298YG18Rl80546OakIU1bYv4NvaltFsk24AvoGep";
	}

	public function database()
	{
		$conn = mysqli_connect($this->dblocation, $this->dbuser, $this->dbpass, $this->db);
		$conn->set_charset("latin5");
		if (mysqli_connect_errno()) {
			mail($this->webmastermail, 'Error al conectar con base de datos', "Failed to connect to MySQL: " . mysqli_connect_error());
		}

		return $conn;
	}

	public function randomCode($prefix)
	{
		$characters = 'abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
		$string = '';
		$max = strlen($characters) - 1;
		for ($i = 0; $i < 11; $i++) {
			$string .= $characters[mt_rand(0, $max)];
		}

		$code = $prefix . $string;
		return $code;
	}

	public function response($status, $code, $message, $receiver)
	{
		$response_array[] = array("status" => $status, "code" => $code, "message" => $message, "receiver" => $receiver);
		return $response_array;
	}

	public function getTemplate($template, $array)
	{

		$template = file_get_contents(__DIR__ . $this->templates_path . $template . ".html");

		if ($array != "") {
			foreach ($array as $key => $value) {
				$template = str_replace('[[' . $key . ']]', $value, $template);
			}
		}

		return $template;
	}

	public function unique_id($table, $column, $id)
	{
		global $extras_class;
		global $strings_class;
		$is_unique = false;
		$conn = $this->database();

		$query = "SELECT * FROM " . $table . " WHERE " . $column . " = '$id'";
		$result = mysqli_query($conn, $query);
		if (!mysqli_num_rows($result)) {
			$is_unique = true;
		}

		return $is_unique;
	}

	public function record_exists($table, $column, $id)
	{
		global $extras_class;
		global $strings_class;
		$record_exists = false;
		$conn = $this->database();

		$query = "SELECT * FROM " . $table . " WHERE " . $column . " = '$id'";
		$result = mysqli_query($conn, $query);
		if (mysqli_num_rows($result)) {
			$record_exists = true;
		}

		return $record_exists;
	}
}
