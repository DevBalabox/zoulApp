<?php include "initializer.php"; ?>

<!DOCTYPE html>
<html>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=gb18030">

	<?php include "meta.php"; ?>

	<title>Zoul - <?php getString("main_title") ?></title>

	<meta name="description" content="Zoul Fitness - <?php getString("main_description") ?>">

	<?php include "head-css.php"; ?>

	<?php include "head-js.php"; ?>

	<style>
		.big-icon {
			background-image: url('img/icon.jpg');
			width: 300px;
			height: 300px;
			background-size: cover;
			background-position: center;
			border-radius: 60px;
			overflow: hidden;
			margin: auto;
		}

		.slogan {
			display: block;
			margin: 15px 0px;
			font-size: 35px;
			font-weight: 100;
		}

		.stores img {
			display: inline-block;
			width: 160px;
		}
	</style>
</head>

<body class="gray-body general">

	<?php include "credits.php"; ?>

	<!-- Contenido principal -->

	<div class="main">

		<div class="just-center">
			<div class="centered-cont">
				<div class="big-icon"></div>
				<span class="slogan">Stay fitness, stay home.</span>
				<div class="stores">
					<a target="_blank" href="https://apps.apple.com/mx/app/zoul/id1520512174">
						<img src="img/appstore.png">
					</a>

					<a target="_blank" href="https://play.google.com/store/apps/details?id=com.zoul.zoul">
						<img src="img/playstore.png">
					</a>

				</div>
			</div>
		</div>

	</div>

	<!-- Fin Contenido principal -->

	<?php include "footer.php"; ?>

	<?php include "body-js.php"; ?>

</body>

</html>