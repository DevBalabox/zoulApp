<?php include "initializer.php";
//header('Location: ' . $extras_class->support_url);
?>
<!DOCTYPE html>
<html>

<head>
    <meta http-equiv="Content-Type" content="text/html; charset=gb18030">

    <?php include "meta.php"; ?>

    <title>Restablece tu contraseña</title>

    <meta name="description" content="Zoul Fitness - Restablece tu contraseña">

    <?php include "head-css.php"; ?>

    <?php include "head-js.php"; ?>

    <style>
        .card {
            background: #ffffff;
            padding: 15px;
            text-align: center;
            width: 500px;
            max-width: 90%;
            margin: 25px auto;
            border-radius: 7px;
            box-shadow: 0px 3px 3px rgba(0, 0, 0, 0.2);
        }

        .tag-input select,
        .tag-input input {
            -webkit-appearance: none;
            -moz-appearance: none;
            appearance: none;
            background: none;
            border: none;
            border-style: none;
            border-radius: 0px;
            border-bottom: 2px solid #ff8ea0;
            width: 100%;
            color: #8a8a8a;
            padding: 10px;
            outline: none;
        }

        .tag-input label.error {
            background: #dc6767;
            color: #fff;
            font-size: 14px;
            font-weight: 400;
            border-radius: 12px;
            display: inline-block;
            padding: 1px 15px;
        }

        .send-btn {
            background: #8BC34A;
            color: #fff;
            border: none;
            display: inline-block;
            padding: 9px 15px;
            border-radius: 4px;
        }

        .disabled-btn {
            background: grey !important;
            pointer-events: none !important;
        }

        #response-text {
            display: block;
            margin-top: 8px;
            font-size: 15px;
            color: gray;
        }

        label.input-labl {
            font-size: 14px;
            color: #2d2d2d;
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
            "title" => "Restablecer contraseña",
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
            <div class="form-cont">
                <span style="font-size: 15px;color: #6d6d6d;">Ingresa tu correo para que te enviemos un link para restablecer tu contraseña</span>
                <form id="restoken_form">
                    <div class="tag-input">
                        <label class="input-labl">Ingresa tu correo</label>
                        <input type="email" name="mail" placeholder="ejemplo@zoul.com" required>
                    </div>

                    <div class="tag-input">
                        <label class="input-labl">¿Eres coach?</label>
                        <select name="user_type" required>
                            <option selected value="coach">Sí</option>
                            <option value="client">No</option>
                        </select>
                    </div>

                    <button type="button" class="send-btn" onclick="sendRestoken();">Enviar link de restablecimiento</button>
                </form>
                <span id="response-text"></span>

            </div>
        </div>

        <!-- Fin Contenido principal -->

        <?php include "footer.php"; ?>

        <?php include "body-js.php"; ?>

        <script>
            jQuery.extend(jQuery.validator.messages, {
                required: "Es necesario llenar este campo.",
                email: "Debes ingresar un correo válido."
            });
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

            function sendRestoken() {
                var form = $("#restoken_form");
                var clicked_btn = $("#restoken_form .send-btn");
                $("#restoken_form").append('<input type="hidden" name="action" value="send_restoken" id="form_action">');
                if ($("#restoken_form").valid()) {
                    $("#response-text").empty();
                    clicked_btn.addClass("disabled-btn");
                    $.ajax({
                        url: "https://zoulapp.com/zadmin/app/mods/mods",
                        type: 'POST',
                        data: JSON.stringify(getFormData(form)),

                        success: function(data) {
                            response = data;
                            if (response[0].status == "true") {
                                clicked_btn.removeClass("disabled-btn");
                                $("#response-text").empty();
                                $("#response-text").append(response[0].message);
                                setTimeout(function() {
                                    location.reload();
                                }, 4000);

                            } else {
                                clicked_btn.removeClass("disabled-btn");
                                $("#response-text").empty();
                                $("#response-text").append(response[0].message);
                            }
                        },
                        error: function(jqXHR, status, error) {
                            console.log(jqXHR);
                            console.log(status);
                            console.log(error);
                            alert("Hubo un error");
                        }
                    });
                }
            }
        </script>

</body>

</html>