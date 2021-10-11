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
		
	</div>

	<!-- Fin Contenido principal -->

	<?php include "footer.php"; ?>

	<?php include "body-js.php"; ?>

</body>

</html>