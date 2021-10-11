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
            "title" => "Aviso de Privacidad",
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
            <pre>
        AVISO DE PRIVACIDAD
De conformidad con lo establecido en la Ley Federal de Protección de Datos Personales en
Posesión de los Particulares, ZOUL APP pone a su disposición el siguiente aviso de privacidad.
ZOUL APP, es responsable del uso y protección de sus datos personales, en este sentido y
atendiendo las obligaciones legales establecidas en la Ley Federal de Protección de Datos
Personales en Posesión de los Particulares, a través de este instrumento se informa a los titulares
de los datos, la información que de ellos se recaba y los fines en que se le darán dicha información.
Los datos personales que recabamos de usted serán utilizados para las siguientes finalidades las
cuales son necesarias para concretar nuestra relación con usted, así como atender los servicios y/o
pedidos que solicite:
● Análisis estadístico
● Informar sobre cambios en el servicio
● Dar cumplimiento a obligaciones contratadas con nuestros clientes
● Desarrollar y poner a prueba nuevos productos y funciones
● Actualizar automáticamente la aplicación de ZOUL APP en tu dispositivo
Para llevar acabo las finalidades descritas en el presente aviso de privacidad, utilizaremos los
siguientes datos personales:
● Nombre
● Apellido Paterno
● Apellido Materno
● Correo electrónico
● Género
Por otra parte, informamos a usted, que sus datos personales no serán compartidos con ninguna
autoridad, empresa, organización o persona distintas a nosotros y serán utilizados exclusivamente
para los fines señalados.
Usted tiene en todo momento el derecho a conocer qué datos personales tenemos de usted, para
qué los utilizamos y las condiciones del uso que les damos (Acceso). Asimismo, es su derecho
solicitar la corrección de su información personal en caso de que esté desactualizada, sea inexacta
o incompleta (Rectificación); de igual manera, tiene derecho a que su información se elimine de
nuestros registros o bases de datos cuando considere que la mismo no está siendo utilizada
adecuadamente (Cancelación); así como también a oponerse al uso de sus datos personales para
fines específicos (Oposición). Estos derechos se conocen como derechos ARCO.
Para el ejercicio de cualquiera de los derechos ARCO, se deberá presentar la solicitud respectiva a
través del siguiente correo electrónico:
zoul.app@gmail.com
        </pre>
        </div>

    </div>

    <!-- Fin Contenido principal -->

    <?php include "footer.php"; ?>

    <?php include "body-js.php"; ?>

</body>

</html>