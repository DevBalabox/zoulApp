<?php include "initializer.php"; ?>
<!DOCTYPE html>
<html>

<head>
    <meta http-equiv="Content-Type" content="text/html; charset=gb18030">

    <?php include "meta.php"; ?>

    <title>Zoul - Soporte ?></title>

    <meta name="description" content="Zoul - Soporte">

    <?php include "head-css.php"; ?>

    <?php include "head-js.php"; ?>

    <style>
        .card {
            background: #ffffff;
            padding: 10px;
            text-align: center;
            max-width: 900px;
            margin: 25px auto;
            border-radius: 7px;
            box-shadow: 0px 3px 3px rgba(0, 0, 0, 0.2);
        }

        body pre {
            font-family: sans-serif;
            background: transparent;
            border: none;
            font-size: 15px;
        }

        .zparagraph {
            display: block;
            font-size: 16px;
            font-weight: 400;
        }
    </style>

</head>

<body class="gray-body general">

    <?php include "credits.php"; ?>

    <?php
    $dataArray = array(
        "logo" => $extras_class->logo,
        "home_url" => $extras_class->coach_home_url,
        "message" => '<span>Stay fitness, stay home. </span>',
        "button" => '<a href="../" class="xx-btn-2">Descargar app</a>'
    );
    echo '
<!-- Inicio Navbar -->
' . $extras_class->getTemplate("navbar", $dataArray) . '
<!-- Fin Navbar -->
';
    ?>

    <!-- Contenido principal -->

    <div class="main">
        <?php
        $dataArray = array(
            "bg_img" => "https://cdn.mos.cms.futurecdn.net/6vntE9WsMpsnCMou2Bp5KF.jpg",
            "title" => "Ayuda y soporte",
            "overlayOpacity" => "0.5",
            "overlayColor" => "linear-gradient(45deg, #ff66be, #fdca64)"
        );
        echo '
		<!-- Inicio Header -->
		' . $extras_class->getTemplate("header", $dataArray) . '
		<!-- Fin Header -->
		';
        ?>

        <div class="card">
            <h2>INFORMACIÓN DE SOPORTE</h2>
            <span class="zparagraph">
                Si tienes algún problema con alguno de los servicios digitales proporcionados por Zoul, no dudes en comunicarlo al equipo de soporte. Agradecemos mucho tu apoyo reportando las inconsistencias y problemas que genere alguno de nuestros productos.<br>
                Por favor escríbenos un correo a:
            </span>
            <a href="mailto:zoul.app@gmail.com">zoul.app@gmail.com</a>
            <span class="zparagraph">
                O si necesitas ayuda urgente puedes contactarnos al siguiente teléfono:
            </span>
            <a href="tel:2225548302">222 554 8302</a>
        </div>

    </div>

    <!-- Fin Contenido principal -->

    <?php include "footer.php"; ?>

    <?php include "body-js.php"; ?>

</body>

</html>