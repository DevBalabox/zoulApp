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
            "title" => "Términos de uso",
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
            <pre style="white-space: pre-line;">
            Términos y Condiciones de uso de la Aplicación

Los presentes términos y condiciones (en lo sucesivo los "Términos y Condiciones de la Aplicación") contienen los acuerdos que rigen la relación entre Zoul app, con las personas (en lo sucesivo el o los “Usuario(s)”) que descarguen la aplicación. Al descargar la Aplicación, el Usuario deberá manifestar su aceptación de los presentes Términos y Condiciones de la Aplicación a efecto de poder usar la Aplicación, y en caso de que no los acepte, el Usuario deberá de abstenerse de usar la Aplicación.

Cualquier término no definido en los presentes Términos y Condiciones de la Aplicación se entenderán definidos en los Términos y Condiciones del Sitio. Cualquier cuestión no prevista por los Términos y Condiciones de la Aplicación, los Términos y Condiciones del Sitio se aplicarán de forma supletoria. En caso de interpretación o controversia con entre los Términos y Condiciones de la Aplicación y los Términos y Condiciones del Sitio, prevalecerán los últimos sobre los primeros.

Servicios
.

Para que la aplicación pueda prestar los Servicios, el Usuario se obliga a ingresar los datos solicitados en el registro de la aplicación y se le podrá asignar una clave de usuario y una contraseña para que el Usuario ingrese de tiempo en tiempo a su cuenta respectiva. 

El Usuario o los Autorizados podrán realizar a través de la Aplicación lo siguiente:

Visualizar rutinas de ejercicio
Tener información de su progreso semanal
Suscribirse y realizar el pago
Cancelar la suscripción cuando el usuario lo desee.

Exigimos que la aplicación respete la privacidad del Usuario, y los permisos que otorgue el Usuario a la Aplicación controlará el modo en el que ésta use, almacene y transfiera dicho contenido e información.
        </pre>
        </div>

    </div>

    <!-- Fin Contenido principal -->

    <?php include "footer.php"; ?>

    <?php include "body-js.php"; ?>

</body>

</html>