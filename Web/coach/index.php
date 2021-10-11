<?php include "initializer.php";
if (!$user_class->verify_login()) header('Location: ' . $extras_class->coach_login_url);
$coach_id = "";
$get_coach_id = $coach_class->get_coach_id($user_class->user_id);
if ($get_coach_id[0]["status"] == "true") {
	$coach_id = $get_coach_id[1]["coach_id"];
}
?>

<!DOCTYPE html>
<html>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=gb18030">

	<?php include "meta.php"; ?>

	<title>Panel de Coach</title>

	<meta name="description" content="Coach - Sube tu video">

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
			//toastr.info('MY MESSAGE!');
		}
	</script>

	<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.1.0/jquery.min.js"></script>
	<script src="https://cdnjs.cloudflare.com/ajax/libs/vex-js/3.0.0/js/vex.combined.min.js"></script>
	<link href="https://cdnjs.cloudflare.com/ajax/libs/vex-js/3.0.0/css/vex.min.css" rel="stylesheet" />
	<link href="https://cdnjs.cloudflare.com/ajax/libs/vex-js/3.0.0/css/vex-theme-top.min.css" rel="stylesheet" />

	<style>
		html {
			position: relative;
			min-height: 100%;
		}

		body {
			margin-bottom: 60px;
			color: #505662;
		}

		.help {
			font-size: smaller;
		}

		.page-header {
			padding-bottom: 18px;
			margin: 40px 0 12px;
		}

		.logo {
			width: 100%;
			margin-bottom: 20px;
		}

		.lead {
			font-size: 18px;
			margin: 12px 0px;
			text-align: center;
		}

		.footer {
			position: absolute;
			bottom: 0;
			padding-top: 15px;
			width: 100%;
			/* Set the fixed height of the footer here */
			height: 120px;
			color: #505662;
		}

		.footer a.brand {
			color: #505662;
		}

		.footer a.brand:hover {
			color: #393e46;
			text-decoration: none;
		}

		.footer .container {
			border-top: 1px solid #eee;
			padding-top: 45px;
		}

		/* Custom page CSS */

		.container {
			width: auto;
			max-width: 680px;
			padding: 0 15px;
		}

		.container .text-muted {
			margin: 20px 0;
		}

		#progress-container {
			-webkit-box-shadow: none;
			box-shadow: inset none;
			display: none;
		}

		#drop_zone {
			border: 2px dashed #bbb;
			-moz-border-radius: 5px;
			-webkit-border-radius: 5px;
			border-radius: 5px;
			padding-top: 60px;
			text-align: center;
			font: 20pt bold 'Helvetica';
			color: #bbb;
			height: 140px;
		}

		#video-data {
			margin-top: 1em;
			font-size: 1.1em;
			font-weight: 500;
		}

		/* Bragit buttons, http://websemantics.github.io/bragit/ */
		.ui.bragit.button,
		.ui.bragit.buttons .button {
			background-color: #676f7e;
			color: #fff !important;
		}

		.ui.bragit.label {
			color: #505662 !important;
			border-color: #676f7e !important;
			background-color: #ffffff;
		}

		.ui.bragit.button:focus,
		.ui.bragit.buttons .button:focus,
		.ui.bragit.button:hover,
		.ui.bragit.buttons .button:hover {
			background-color: #505662;
		}

		.ui.bragit.labels .label:focus,
		.ui.bragit.label:focus,
		.ui.bragit.labels .label:hover,
		.ui.bragit.label:hover {
			color: #505662 !important;
			border-color: #505662 !important;
		}

		.ui.labeled .ui.button .star.icon {
			color: #F5CC7A !important;
		}

		body .btn-info {
			color: #fff;
			background-color: #ff8ea0;
			border-color: #e26e80;
			transition: 0.3s;
		}

		body .btn-info:hover {
			background-color: #d86678;
			border-color: #e26e80;
		}

		#video-error {
			background: #ca5050;
			color: #fff;
			padding: 3px 15px;
			border-radius: 15px;
			margin: auto;
			text-align: center;
			margin-top: 15px;
			display: none;
		}
	</style>
</head>

<body class="gray-body general">

	<?php include "credits.php"; ?>

	<?php include "navbar.php"; ?>

	<!-- Contenido principal -->

	<div class="main">
		<?php
		$dataArray = array(
			"bg_img" => "https://cdn.mos.cms.futurecdn.net/6vntE9WsMpsnCMou2Bp5KF.jpg",
			"title" => "Subir nuevo video",
			"overlayOpacity" => "0.5",
			"overlayColor" => "linear-gradient(45deg, #ff66be, #fdca64)"
		);
		echo '
		<!-- Inicio Header -->
		' . $extras_class->getTemplate("header", $dataArray) . '
		<!-- Fin Header -->
		';
		?>
		<?php if ($coach_id == "") echo '<p class="lead" style="margin-top: 50px">Tu solicitud aún sigue en revisión, nos pondremos en contacto contigo a la brevedad.</p>'; ?>
		<div class="container" style="text-align: center; <?php if ($coach_id == "") echo 'display:none;'; ?>">
			<p class="lead">Si tu video es muy pesado, te recomendamos comprimirlo con alguna de las herramientas que te enviamos en el kit de inicio, si no cuentas con él, puedes contactarnos para que te ayudemos.</p>
			<div id="progress-container" class="progress">
				<div id="progress" class="progress-bar progress-bar-info progress-bar-striped active" role="progressbar" aria-valuenow="46" aria-valuemin="0" aria-valuemax="100" style="width: 0%">&nbsp;0%
				</div>
			</div>
			<div class="row">
				<div class="col-md-12">
					<div id="results"></div>
				</div>
			</div>
			<div class="row">
				<div class="col-md-12">
					<div class="form-group">
						<input type="text" name="name" id="videoName" class="form-control" placeholder="Título del video" minlength="10" maxlength="50" value=""></input>
					</div>
					<div class="form-group">
						<input type="text" name="description" id="videoDescription" class="form-control" placeholder="Descripción del video" minlength="30" maxlength="80" value=""></input>
					</div>
					<div>
						<select name="discipline_id" id="discipline_id" required="" style="width: 100%; max-width: 100%; margin-bottom: 15px;">
							<option value="">Selecciona una disciplina</option>
							<?php
							$conn = $extras_class->database();
							$disciplines_query = "SELECT * FROM disciplines ORDER BY id DESC";
							$disciplines_result = mysqli_query($conn, $disciplines_query);
							if (mysqli_num_rows($disciplines_result)) {
								while ($disciplines_row = mysqli_fetch_assoc($disciplines_result)) {
									$discipline_id = $disciplines_row["discipline_id"];
									echo '<option value="' . $discipline_id . '">' . $disciplines_row["name"] . " " . $disciplines_row["first_lastname"] . " " . $disciplines_row["second_lastname"] . '</option>';
								}
							}
							?>
						</select>
					</div>
					<label class="btn btn-block btn-info">
						Seleccionar video&hellip; <input id="browse" type="file" style="display: none;" accept="video/mp4,video/x-m4v,video/*">
					</label>
					<span id="video-error">Debes llenar todos los campos</span>
				</div>
			</div>
		</div>
	</div>

	<!-- Fin Contenido principal -->

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

	<?php include "footer.php"; ?>

	<?php include "body-js.php"; ?>

	<script type="text/javascript" src="js/vimeo/vimeo-upload.js"></script>
	<script type="text/javascript">
		/**
		 * Called when files are dropped on to the drop target or selected by the browse button.
		 * For each file, uploads the content to Drive & displays the results when complete.
		 */
		function handleFileSelect(evt) {
			evt.stopPropagation()
			evt.preventDefault()
			//console.log()

			if (document.getElementById("videoName").value != "" && document.getElementById("videoDescription").value != "" && document.getElementById("discipline_id").value != "") {

				document.getElementById("videoName").setAttribute("readonly", "readonly")
				document.getElementById("videoDescription").setAttribute("readonly", "readonly")
				document.getElementById("discipline_id").setAttribute("readonly", "readonly")

				var files = evt.dataTransfer ? evt.dataTransfer.files : $(this).get(0).files
				var results = document.getElementById('results')

				/* Clear the results div */
				while (results.hasChildNodes()) results.removeChild(results.firstChild)

				/* Rest the progress bar and show it */
				updateProgress(0)
				document.getElementById('progress-container').style.display = 'block'

				/* Instantiate Vimeo Uploader */
				;
				(new VimeoUpload({
					name: document.getElementById('videoName').value,
					description: document.getElementById('videoDescription').value,
					private: true,
					file: files[0],
					token: "201997d74dfc09af7e7818034bb29802",
					upgrade_to_1080: true,
					onError: function(data) {
						showMessage('<strong>Error</strong>: ' + JSON.parse(data).error, 'danger')
					},
					onProgress: function(data) {
						updateProgress(data.loaded / data.total)
					},
					onComplete: function(videoId, index) {
						var url = 'https://vimeo.com/' + videoId

						if (index > -1) {
							/* The metadata contains all of the uploaded video(s) details see: https://developer.vimeo.com/api/endpoints/videos#/{video_id} */
							url = this.metadata[index].link //

							/* add stringify the json object for displaying in a text area */
							var pretty = JSON.stringify(this.metadata[index], null, 2)

							//console.log(pretty) /* echo server data */
							registerVideo(videoId)
						}

						//showMessage('<strong>Tu video se subió con éxito, mándanos un mensaje para solicitar la publicación de tu video.</strong>: check uploaded video @ <a href="' + url + '">' + url + '</a>. Open the Console for the response details.')
						showMessage('<strong>Tu video se subió con éxito, mándanos un mensaje para solicitar la publicación de tu video.</strong>');
					}
				})).upload()
			} else {
				//console.log("No hay texto")
				document.getElementById("video-error").setAttribute("style", "display:inline-block")
				document.getElementById("browse").value = "";
				//document.getElementById("video-error").innerHTML = "Debes llenar todos los campos";
			}


			/* local function: show a user message */
			function showMessage(html, type) {
				/* hide progress bar */
				document.getElementById('progress-container').style.display = 'none'

				/* display alert message */
				var element = document.createElement('div')
				element.setAttribute('class', 'alert alert-' + (type || 'success'))
				element.innerHTML = html
				results.appendChild(element)
			}
		}

		/**
		 * Dragover handler to set the drop effect.
		 */
		function handleDragOver(evt) {
			evt.stopPropagation()
			evt.preventDefault()
			evt.dataTransfer.dropEffect = 'copy'
		}

		/**
		 * Updat progress bar.
		 */
		function updateProgress(progress) {
			progress = Math.floor(progress * 100)
			var element = document.getElementById('progress')
			element.setAttribute('style', 'width:' + progress + '%')
			element.innerHTML = '&nbsp;' + progress + '%'
		}
		/**
		 * Wire up drag & drop listeners once page loads
		 */
		document.addEventListener('DOMContentLoaded', function() {
			/* var dropZone = document.getElementById('drop_zone') */
			var browse = document.getElementById('browse');
			/* dropZone.addEventListener('dragover', handleDragOver, false)
			dropZone.addEventListener('drop', handleFileSelect, false) */
			browse.addEventListener('change', handleFileSelect, false)
		})
	</script>

	<script>
		function registerVideo(video_id) {
			console.log("Registrar video");
			$.ajax({
				url: '../zadmin/app/mods/mods',
				type: 'POST',
				data: JSON.stringify({
					action: "new_video",
					coach_id: '<?php echo $coach_id ?>',
					title: $("#videoName").val(),
					description: $("#videoDescription").val(),
					discipline_id: $("#discipline_id").val(),
					status: "Privado",
					source: "vimeo",
					external_id: video_id
				}),

				success: function(data) {
					response = data;
					if (response[0].status == "true") {
						//console.log(response[0].message);
						toastr.success("Tu video se subió con éxito");
						/* setTimeout(function() {
							location.reload();
						}, 0); */
					} else {
						console.log(response[0].message);
						toastr.error(response[0].message);
					}
				},
				error: function(jqXHR, status, error) {
					console.log(jqXHR);
					console.log(status);
					console.log(error);
					toastr.error("Hubo un error para realizar la operación");
					button.removeClass("disabled");
				}
			});
		}

		window.onbeforeunload = function() {
			if (document.getElementById("videoName").value != "" || document.getElementById("videoDescription").value != "") {
				return "¿Estás seguro que deseas cerrar esta ventana?"
			}
		}
	</script>
</body>

</html>