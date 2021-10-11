<?php include "initializer.php";
$admin_user_class = new User;
$admin_user_class->session_name = "ZPUsrSess_admin";
if (!$admin_user_class->verify_login()) header('Location: ' . $extras_class->login_url);
?>

<!DOCTYPE html>
<html>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=gb18030">

	<?php include "meta.php"; ?>

	<title>Coaches - <?php getString("main_title") ?></title>

	<meta name="description" content="Coaches - <?php getString("main_description") ?>">

	<?php include "head-css.php"; ?>

	<?php include "head-js.php"; ?>

	<link href="https://cdnjs.cloudflare.com/ajax/libs/toastr.js/2.0.1/css/toastr.css" rel="stylesheet" />
	<script src="https://cdnjs.cloudflare.com/ajax/libs/toastr.js/2.0.1/js/toastr.js"></script>
	<script>
		function notificationme() {
			toastr.options = {
				"closeButton": false,
				"debug": false,
				"newestOnTop": false,
				"progressBar": true,
				"preventDuplicates": true,
				"onclick": null,
				"showDuration": "100",
				"hideDuration": "1000",
				"timeOut": "5000",
				"extendedTimeOut": "1000",
				"showEasing": "swing",
				"hideEasing": "linear",
				"showMethod": "show",
				"hideMethod": "hide"
			};
			toastr.info('MY MESSAGE!');
		}
	</script>


	<!-- <script src="https://github.hubspot.com/vex/dist/js/vex.combined.js"></script>
	<link href="https://github.hubspot.com/vex/dist/css/vex.css" rel="stylesheet" />
	<link href="https://github.hubspot.com/vex/dist/css/vex-theme-default.css" rel="stylesheet" />
	<link href="https://github.hubspot.com/vex/dist/css/vex-theme-os.css" rel="stylesheet" />
	<link href="https://github.hubspot.com/vex/dist/css/vex-theme-plain.css" rel="stylesheet" />
	<link href="https://github.hubspot.com/vex/dist/css/vex-theme-flat-attack.css" rel="stylesheet" />
	<link href="https://github.hubspot.com/vex/dist/css/vex-theme-wireframe.css" rel="stylesheet" />
	<link href="https://github.hubspot.com/vex/dist/css/vex-theme-flat-attack.css" rel="stylesheet"/> -->

	<style type="text/css">
		body.gray-body {
			background: #f1f1f1;
		}

		.small-card {
			height: 160px;
			background: #fff;
			border-radius: 10px;
			box-shadow: 0px 3px 8px rgba(0, 0, 0, 0.1);
			overflow: hidden;
			margin-bottom: 15px;
		}

		.ftd-img {
			height: 100%;
			background: #cacaca;
			background-image: url(https://i0.wp.com/zblogged.com/wp-content/uploads/2019/02/FakeDP.jpeg?resize=567%2C580&ssl=1);
			background-size: cover;
			background-position: center;
		}

		.small-card .title {
			font-size: 23px;
			margin: 10px 0px;
			margin-top: 15px;
		}

		.small-card .subtitle {
			display: block;
		}

		.inputfile {
			width: 0.1px;
			height: 0.1px;
			opacity: 0;
			overflow: hidden;
			position: absolute;
			z-index: -1;
		}

		.inputfile+label {
			font-size: 14px;
			transition: 0.3s;
			font-weight: 400;
			color: white;
			background-color: #8BC34A;
			display: inline-block;
			margin: auto;
			text-align: center;
			padding: 2px 6px;
			border-radius: 50px;
			margin-top: 5px;
		}

		.inputfile:focus+label,
		.inputfile+label:hover {
			background-color: #7ba54b;
		}

		.inputfile+label {
			cursor: pointer;
			/* "hand" cursor */
		}

		.inputfile:focus+label {
			outline: 1px dotted #000;
			outline: -webkit-focus-ring-color auto 5px;
		}

		.divider-title {
			text-align: center;
			margin: 40px 0px;
			font-weight: 300;
			color: #484848;
		}
	</style>

	<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.1.0/jquery.min.js"></script>
	<script src="https://cdnjs.cloudflare.com/ajax/libs/vex-js/3.0.0/js/vex.combined.min.js"></script>
	<link href="https://cdnjs.cloudflare.com/ajax/libs/vex-js/3.0.0/css/vex.min.css" rel="stylesheet" />
	<link href="https://cdnjs.cloudflare.com/ajax/libs/vex-js/3.0.0/css/vex-theme-top.min.css" rel="stylesheet" />
</head>

<body class="gray-body general">

	<?php include "credits.php"; ?>

	<?php include "navbar.php"; ?>

	<!-- Contenido principal -->

	<div class="main">

		<?php
		$dataArray = array(
			"bg_img" => "https://images.squarespace-cdn.com/content/v1/56303067e4b0363ff28ad288/1510077286710-RJ90853YR1CRFNSX1B1U/ke17ZwdGBToddI8pDm48kNvT88LknE-K9M4pGNO0Iqd7gQa3H78H3Y0txjaiv_0fDoOvxcdMmMKkDsyUqMSsMWxHk725yiiHCCLfrh8O1z5QPOohDIaIeljMHgDF5CVlOqpeNLcJ80NK65_fV7S1USOFn4xF8vTWDNAUBm5ducQhX-V3oVjSmr829Rco4W2Uo49ZdOtO_QXox0_W7i2zEA/Hand+shake+background.jpg?format=2500w",
			"title" => "Coaches",
			"overlayOpacity" => "0.5",
			"overlayColor" => "linear-gradient(45deg, #ff66be, #fdca64)"
		);
		echo '
		<!-- Inicio Navbar -->
		' . $extras_class->getTemplate("header", $dataArray) . '
		<!-- Fin Navbar -->
		';
		?>
		<div class="dashboard col-md-12">

			<div class="tab" tab-name="coach">
				<?php
				function get_all_users()
				{
					global $extras_class;
					global $coach_class;
					$conn = $extras_class->database();
					$table_header = false;

					$rules = array(
						"id" => array("key" => "id", "name" => "ID", "type" => "hidden"),
						"name" => array("key" => "name", "name" => "Nombre", "type" => "text"),
						"user_id" => array("key" => "user_id", "name" => "ID de Usuario", "type" => "hidden"),
						"first_lastname" => array("key" => "first_lastname", "name" => "Primer apellido", "type" => "text"),
						"second_lastname" => array("key" => "second_lastname", "name" => "Segundo apellido", "type" => "text"),
						"mail" => array("key" => "mail", "name" => "Correo", "type" => "text"),
						"password" => array("key" => "password", "name" => "Contraseña", "type" => "hidden"),
						"birth_date" => array("key" => "birth_date", "name" => "Fecha de nacimiento", "type" => "date"),
						"gender" => array("key" => "gender", "name" => "Género", "type" => "dropdown", "options" => ["Hombre", "Mujer", "Otro"]),
						"phone" => array("key" => "phone", "name" => "Teléfono", "type" => "phone"),
						"biography" => array("key" => "biography", "name" => "Biografía", "type" => "textarea"),
						"img_url" => array("key" => "profile_picture_base64", "name" => "Foto de perfil", "type" => "base64"),
						"method" => array("key" => "method", "name" => "Método de registro", "type" => "blocked"),
						"type" => array("key" => "user_type", "name" => "Tipo de usuario", "type" => "hidden"),
						"creation_date" => array("key" => "creation_date", "name" => "Fecha de registro", "type" => "blocked"),
						"coach_id" => array("key" => "coach_id", "name" => "ID de Coach", "type" => "hidden"),
						"bank" => array("key" => "bank", "name" => "Banco", "type" => "text"),
						"clabe" => array("key" => "clabe", "name" => "CLABE", "type" => "text"),
						"card_number" => array("key" => "card_number", "name" => "Número de tarjeta", "type" => "text"),
						"facebook_profile" => array("key" => "facebook_profile", "name" => "Facebook", "type" => "text"),
						"instagram_profile" => array("key" => "instagram_profile", "name" => "Instagram", "type" => "text"),
						"youtube_profile" => array("key" => "youtube_profile", "name" => "Youtube", "type" => "text"),
						"status" => array("key" => "status", "name" => "Estatus", "type" => "dropdown", "options" => ["Activo", "Inactivo", "Oculto"]),
					);

					$query = "SELECT * FROM users as a INNER JOIN coaches as b WHERE b.user_id = a.user_id ORDER BY a.id DESC";
					$result = mysqli_query($conn, $query);

					/* Ver si el correo existe */
					if (mysqli_num_rows($result)) {
						echo '<table class="table table-striped">';

						while ($row = mysqli_fetch_assoc($result)) {
							if (!$table_header) {
								echo '<thead><tr>';
								echo '<th scope="col" style="background: none"></th>';
								echo '<th scope="col">Foto de perfil</th>';
								foreach ($row as $field => $value) {
									//acciones
									$type = $rules[$field]["type"];
									if ($type != "hidden" && $type != "base64") {
										if (array_key_exists($field, $rules)) {
											$type = $rules[$field]["type"];
											echo '<th scope="col">' .  $rules[$field]["name"] . '</th>';
										} else {
											echo '<th scope="col">' . ucfirst($field) . '</th>';
										}
									}
								}
								echo '</tr></thead>';
								echo '<tbody>';

								$table_header = true;
							}

							$coach_id = "";
							$get_coach_id = $coach_class->get_coach_id($row["user_id"]);
							if ($get_coach_id[0]["status"] == "true") {
								$coach_id = $get_coach_id[1]["coach_id"];
							}

							echo '<tr><form user_id="' . $row["user_id"] . '">';
							echo '<th scope="row"><button action="revoke_coach" onclick="revokeCoachDialog(\'' . $row["name"] . '\',\'' . $row["user_id"] . '\', this)" type="button">Revocar coach</button><button action="edit" type="button" onclick="updateRow(\'' . $row["user_id"] . '\', this)">Actualizar</button><button action="delete" onclick="deleteDialog(\'' . $row["name"] . '\',\'' . $row["user_id"] . '\', this)" type="button">Eliminar</button><a class="streams-btn" target="_blank" href="coach-analytics?cid=' . $coach_id . '">Reproducciones</a></th>';

							echo '<input type="hidden" name="action" value="admin_edit_coach" id="action_' . $row["user_id"] . '">';

							if (array_key_exists("img_url", $rules)) {
								if ($rules["img_url"]["type"] == "base64") {
									echo '<th scope="row" style="text-align:center"><div class="user-pic" user_id="' . $row["user_id"] . '" style="background-image: url(\'' . $extras_class->gallery_path . $row["img_url"] . '\')"></div><input accept="image/x-png,image/gif,image/jpeg" type="file" id="file_' . $row["user_id"] . '" class="inputfile" onchange="encodeImageFileAsURL(this,\'' . $row["user_id"] . '\')" /><label for="file_' . $row["user_id"] . '">Cambiar foto</label></th>';
								}
							}
							foreach ($row as $field => $value) {
								//acciones
								$type = $rules[$field]["type"];
								switch ($type) {
									case "text":
										echo '<th scope="row"><input type="text" name="' . $rules[$field]["key"] . '" value="' . strval($row[$field]) . '"></th>';
										break;

									case "textarea":
										echo '<th scope="row"><textarea name="' . $rules[$field]["key"] . '" rows="4">' . strval($row[$field]) . '</textarea></th>';
										break;

									case "phone":
										echo '<th scope="row"><input type="tel" name="' . $rules[$field]["key"] . '" value="' . strval($row[$field]) . '"></th>';
										break;

									case "date":
										echo '<th scope="row"><input type="date" name="' . $rules[$field]["key"] . '" value="' . strval($row[$field]) . '"></th>';
										break;

									case "dropdown":
										echo '<th scope="row"><select name="' . $rules[$field]["key"] . '">';
										echo '<option value="">Selecciona una opción</option>';
										$options = (array) $rules[$field]["options"];
										foreach ($options as $option) {
											$selected = $row[$field] == $option ? 'selected' : '';
											echo '<option value="' . $option . '" ' . $selected . '>' . $option . '</option>';
										}
										echo '</select></th>';
										break;

									case "hidden":
										echo '<input type="hidden" name="' . $rules[$field]["key"] . '" value="' . strval($row[$field]) . '">';
										break;

									case "blocked":
										echo '<input type="hidden" name="' . $rules[$field]["key"] . '" value="' . strval($row[$field]) . '">';
										echo '<th scope="row">' . strval($row[$field]) . '</th>';
										break;

									case "base64":
										echo '<input type="hidden" id="main_picture_' . $row["user_id"] . '" name="' . $rules[$field]["key"] . '">';
										break;

									default:
										echo '<th scope="row"><input type="text" name="' . $rules[$field]["key"] . '" value="' . strval($row[$field]) . '"></th>';
										break;
								}

								/* if ($type != "hidden") {
									if (array_key_exists($field, $rules)) {
										echo '<th scope="row"><input type="text" name="'.$field.'" value="'.$row[$field].'"></th>';
									} else {
										echo '<th scope="row">' . ucfirst($row[$field]) . '</th>';
									}
								} */
							}
							echo '</form></tr>';
						}

						echo '</tbody>';
						echo '</table>';
					}
				}

				function get_all_prospects()
				{
					global $extras_class;

					$conn = $extras_class->database();
					$table_header = false;

					$rules = array(
						"id" => array("key" => "id", "name" => "ID", "type" => "hidden"),
						"name" => array("key" => "name", "name" => "Nombre", "type" => "text"),
						"user_id" => array("key" => "user_id", "name" => "ID de Usuario", "type" => "hidden"),
						"first_lastname" => array("key" => "first_lastname", "name" => "Primer apellido", "type" => "text"),
						"second_lastname" => array("key" => "second_lastname", "name" => "Segundo apellido", "type" => "text"),
						"mail" => array("key" => "mail", "name" => "Correo", "type" => "text"),
						"password" => array("key" => "password", "name" => "Contraseña", "type" => "hidden"),
						"birth_date" => array("key" => "birth_date", "name" => "Fecha de nacimiento", "type" => "hidden"),
						"gender" => array("key" => "gender", "name" => "Género", "type" => "hidden", "options" => ["Hombre", "Mujer", "Otro"]),
						"phone" => array("key" => "phone", "name" => "Teléfono", "type" => "hidden"),
						"biography" => array("key" => "biography", "name" => "Biografía", "type" => "textarea"),
						"img_url" => array("key" => "profile_picture_base64", "name" => "Foto de perfil", "type" => "base64"),
						"method" => array("key" => "method", "name" => "Método de registro", "type" => "blocked"),
						"type" => array("key" => "user_type", "name" => "Tipo de usuario", "type" => "hidden"),
						"creation_date" => array("key" => "creation_date", "name" => "Fecha de creación", "type" => "blocked"),
					);

					$query = "SELECT * FROM users WHERE users.user_id NOT IN (SELECT user_id FROM coaches) AND type = 'coach' ORDER BY id DESC";
					$result = mysqli_query($conn, $query);

					/* Ver si el correo existe */
					if (mysqli_num_rows($result)) {
						echo '<table class="table table-striped">';

						while ($row = mysqli_fetch_assoc($result)) {
							if (!$table_header) {
								echo '<thead><tr>';
								echo '<th scope="col" style="background: none"></th>';
								echo '<th scope="col">Foto de perfil</th>';
								foreach ($row as $field => $value) {
									//acciones
									$type = $rules[$field]["type"];
									if ($type != "hidden" && $type != "base64") {
										if (array_key_exists($field, $rules)) {
											$type = $rules[$field]["type"];
											echo '<th scope="col">' .  $rules[$field]["name"] . '</th>';
										} else {
											echo '<th scope="col">' . ucfirst($field) . '</th>';
										}
									}
								}
								echo '</tr></thead>';
								echo '<tbody>';

								$table_header = true;
							}

							echo '<tr><form user_id="' . $row["user_id"] . '">';
							echo '<th scope="row"><button action="new_coach" onclick="becomeCoachDialog(\'' . $row["name"] . '\',\'' . $row["user_id"] . '\', this)" type="button">Hacer coach</button><button action="edit" type="button" onclick="updateRow(\'' . $row["user_id"] . '\', this)">Actualizar</button><button action="delete" onclick="deleteDialog(\'' . $row["name"] . '\',\'' . $row["user_id"] . '\', this)" type="button">Eliminar</button></th>';

							echo '<input type="hidden" name="action" value="admin_edit_profile" id="action_' . $row["user_id"] . '">';

							if (array_key_exists("img_url", $rules)) {
								if ($rules["img_url"]["type"] == "base64") {
									echo '<th scope="row" style="text-align:center"><div class="user-pic" user_id="' . $row["user_id"] . '" style="background-image: url(\'' . $extras_class->gallery_path . $row["img_url"] . '\')"></div><input accept="image/x-png,image/gif,image/jpeg" type="file" id="file_' . $row["user_id"] . '" class="inputfile" onchange="encodeImageFileAsURL(this,\'' . $row["user_id"] . '\')" /><label for="file_' . $row["user_id"] . '">Cambiar foto</label></th>';
								}
							}
							foreach ($row as $field => $value) {
								//acciones
								$type = $rules[$field]["type"];
								switch ($type) {
									case "text":
										echo '<th scope="row"><input type="text" name="' . $rules[$field]["key"] . '" value="' . strval($row[$field]) . '"></th>';
										break;

									case "textarea":
										echo '<th scope="row"><textarea name="' . $rules[$field]["key"] . '" rows="4">' . strval($row[$field]) . '</textarea></th>';
										break;

									case "phone":
										echo '<th scope="row"><input type="tel" name="' . $rules[$field]["key"] . '" value="' . strval($row[$field]) . '"></th>';
										break;

									case "date":
										echo '<th scope="row"><input type="date" name="' . $rules[$field]["key"] . '" value="' . strval($row[$field]) . '"></th>';
										break;

									case "dropdown":
										echo '<th scope="row"><select name="' . $rules[$field]["key"] . '" value="' . strval($row[$field]) . '">';
										$options = (array) $rules[$field]["options"];
										foreach ($options as $option) {
											echo '<option value="' . $option . '">' . $option . '</option>';
										}
										echo '</select></th>';
										break;

									case "hidden":
										echo '<input type="hidden" name="' . $rules[$field]["key"] . '" value="' . strval($row[$field]) . '">';
										break;

									case "base64":
										echo '<input type="hidden" id="main_picture_' . $row["user_id"] . '" name="' . $rules[$field]["key"] . '">';
										break;

									default:
										echo '<th scope="row"><input type="text" name="' . $rules[$field]["key"] . '" value="' . strval($row[$field]) . '"></th>';
										break;
								}

								/* if ($type != "hidden") {
									if (array_key_exists($field, $rules)) {
										echo '<th scope="row"><input type="text" name="'.$field.'" value="'.$row[$field].'"></th>';
									} else {
										echo '<th scope="row">' . ucfirst($row[$field]) . '</th>';
									}
								} */
							}
							echo '</form></tr>';
						}

						echo '</tbody>';
						echo '</table>';
					}
				}

				echo '<div class="table-cont">';
				get_all_users();
				echo '<h2 class="divider-title">Solicitantes para ser coach</h2>';
				get_all_prospects();
				echo '</div>';
				?>

			</div>

		</div>
	</div>

	<!-- Fin Contenido principal -->

	<?php
	echo '
	<!-- Inicio Navbar -->
	' . $extras_class->getTemplate("bottom-menu", $dataArray) . '
	<!-- Fin Navbar -->
	';
	?>

	<script>
		var imagebase64 = "";

		function encodeImageFileAsURL(element, user_id) {
			var file = element.files[0];

			var img = document.createElement("img");
			var reader = new FileReader();
			reader.onload = function(e) {
				img.src = e.target.result
				img.onload = function() {
					var canvas = document.createElement("canvas");
					var ctx = canvas.getContext("2d");
					ctx.drawImage(img, 0, 0);

					var MAX_WIDTH = 600;
					var MAX_HEIGHT = 600;
					var width = img.width;
					var height = img.height;

					if (width > height) {
						if (width > MAX_WIDTH) {
							height *= MAX_WIDTH / width;
							width = MAX_WIDTH;
						}
					} else {
						if (height > MAX_HEIGHT) {
							width *= MAX_HEIGHT / height;
							height = MAX_HEIGHT;
						}
					}
					canvas.width = width;
					canvas.height = height;
					var ctx = canvas.getContext("2d");
					ctx.drawImage(img, 0, 0, width, height);

					var dataurl = canvas.toDataURL("image/png", 0.5);

					//console.log(dataurl);
					$(".user-pic[user_id=" + user_id + "]").css("background-image", "url(" + dataurl + ")");
					$('#main_picture_' + user_id).attr("value", dataurl.split(',')[1]);
				}

			}
			reader.readAsDataURL(file);



			/* var reader = new FileReader();
			reader.onloadend = function() {
				imagebase64 = reader.result;
				//console.log(imagebase64);
				$(".user-pic[user_id=" + user_id + "]").css("background-image", "url(" + imagebase64 + ")");
				$('#main_picture_' + user_id).attr("value", imagebase64);
			}
			reader.readAsDataURL(file); */
		}
	</script>

	<script>
		/* function updateRow(user_id) {
			$('form[user_id="' + user_id + '"]').addClass("editable");
		} */
	</script>

	<script>
		function getFormData(form) {
			var unindexed_array = form.serializeArray();
			var indexed_array = {};

			$.map(unindexed_array, function(n, i) {
				indexed_array[n['name']] = n['value'];
			});

			console.log(indexed_array);

			return indexed_array;
		}

		function updateRow(user_id, button) {
			var form = $('form[user_id="' + user_id + '"]');
			var button = $(button);
			button.addClass("disabled");
			$.ajax({
				url: 'app/mods/mods',
				type: 'POST',
				data: JSON.stringify(getFormData(form)),

				success: function(data) {
					response = data;
					if (response[0].status == "true") {
						console.log(response[0].message);
						toastr.success(response[0].message);
					} else {
						console.log(response[0].message);
						toastr.error(response[0].message);
					}
					button.removeClass("disabled");
				},
				error: function(jqXHR, status, error) {
					console.log(jqXHR);
					console.log(status);
					console.log(error);
					$("#action").remove();
					button.removeClass("disabled");
				}
			});
		}

		vex.defaultOptions.className = 'vex-theme-top';

		function becomeCoach(user_id, button) {
			$('#action_' + user_id).val("new_coach");
			var form = $('form[user_id="' + user_id + '"]');
			//button.addClass("disabled");
			$.ajax({
				url: 'app/mods/mods',
				type: 'POST',
				data: JSON.stringify(getFormData(form)),

				success: function(data) {
					response = data;
					if (response[0].status == "true") {
						console.log(response[0].message);
						toastr.success(response[0].message);
						location.reload();
					} else {
						console.log(response[0].message);
						toastr.error(response[0].message);
					}
					//button.removeClass("disabled");
				},
				error: function(jqXHR, status, error) {
					console.log(jqXHR);
					console.log(status);
					console.log(error);
					$("#action").remove();
					//button.removeClass("disabled");
				}
			});
		}

		function revokeCoach(user_id, button) {
			$('#action_' + user_id).val("revoke_coach");
			var form = $('form[user_id="' + user_id + '"]');
			//button.addClass("disabled");
			$.ajax({
				url: 'app/mods/mods',
				type: 'POST',
				data: JSON.stringify(getFormData(form)),

				success: function(data) {
					response = data;
					if (response[0].status == "true") {
						console.log(response[0].message);
						toastr.success(response[0].message);
						location.reload();
					} else {
						console.log(response[0].message);
						toastr.error(response[0].message);
					}
					//button.removeClass("disabled");
				},
				error: function(jqXHR, status, error) {
					console.log(jqXHR);
					console.log(status);
					console.log(error);
					$("#action").remove();
					//button.removeClass("disabled");
				}
			});
		}

		function deleteRow(user_id, button) {
			$('#action_' + user_id).val("delete_user");
			var form = $('form[user_id="' + user_id + '"]');
			//button.addClass("disabled");
			$.ajax({
				url: 'app/mods/mods',
				type: 'POST',
				data: JSON.stringify(getFormData(form)),

				success: function(data) {
					response = data;
					if (response[0].status == "true") {
						console.log(response[0].message);
						toastr.success(response[0].message);
					} else {
						console.log(response[0].message);
						toastr.error(response[0].message);
					}
					//button.removeClass("disabled");
				},
				error: function(jqXHR, status, error) {
					console.log(jqXHR);
					console.log(status);
					console.log(error);
					$("#action").remove();
					//button.removeClass("disabled");
				}
			});
		}

		function deleteDialog(user_name, user_id, button) {
			vex.dialog.confirm({
				message: '¿Estás seguro que quieres eliminar a ' + user_name + "?",
				buttons: [
					$.extend({}, vex.dialog.buttons.YES, {
						text: 'Sí, eliminar'
					}),
					$.extend({}, vex.dialog.buttons.NO, {
						text: 'No, cancelar'
					})
				],
				callback: function(value) {
					if (value) {
						deleteRow(user_id, button);
						console.log('Successfully destroyed the planet.')
					} else {
						console.log('Chicken.')
					}
				}
			})
		}

		function becomeCoachDialog(user_name, user_id, button) {
			vex.dialog.confirm({
				message: '¿Estás seguro que quieres hacer a ' + user_name + " un coach?",
				buttons: [
					$.extend({}, vex.dialog.buttons.YES, {
						text: 'Sí, estoy seguro'
					}),
					$.extend({}, vex.dialog.buttons.NO, {
						text: 'No, cancelar'
					})
				],
				callback: function(value) {
					if (value) {
						becomeCoach(user_id, button);
					}
				}
			})
		}

		function revokeCoachDialog(user_name, user_id, button) {
			vex.dialog.confirm({
				message: '¿Estás seguro que quieres revocar al coach ' + user_name + "?",
				buttons: [
					$.extend({}, vex.dialog.buttons.YES, {
						text: 'Sí, estoy seguro'
					}),
					$.extend({}, vex.dialog.buttons.NO, {
						text: 'No, cancelar'
					})
				],
				callback: function(value) {
					if (value) {
						revokeCoach(user_id, button);
					}
				}
			})
		}
	</script>

	<?php include "footer.php"; ?>

	<?php include "body-js.php"; ?>
</body>

</html>