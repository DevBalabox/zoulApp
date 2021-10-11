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

    <title>Página de Inicio - <?php getString("main_title") ?></title>

    <meta name="description" content="Descripción de inicio - <?php getString("main_description") ?>">

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
</head>

<body class="gray-body general">

    <?php include "credits.php"; ?>

    <?php include "navbar.php"; ?>

    <!-- Contenido principal -->

    <div class="main">

        <?php
        $dataArray = array(
            "bg_img" => "https://cdn.mos.cms.futurecdn.net/6vntE9WsMpsnCMou2Bp5KF.jpg",
            "title" => "Analítica",
            "overlayOpacity" => "0.5",
            "overlayColor" => "linear-gradient(45deg, #ff66be, #fdca64)"
        );
        echo '
		<!-- Inicio Header -->
		' . $extras_class->getTemplate("header", $dataArray) . '
		<!-- Fin Header -->
		';
        ?>
        <div class="dashboard col-md-12">

            <div class="tab" tab-name="analytics">

                <?php
                $conn = $extras_class->database();

                //Users count
                $users_query = "SELECT * FROM users WHERE type ='client'";
                $users_result = mysqli_query($conn, $users_query);
                $users_count = mysqli_num_rows($users_result);


                //Coaches count
                $coaches_query = "SELECT * FROM users as a INNER JOIN coaches as b WHERE b.user_id = a.user_id";
                $coaches_result = mysqli_query($conn, $coaches_query);
                $coaches_count = mysqli_num_rows($coaches_result);


                //Disciplines count
                $disciplines_query = "SELECT * FROM disciplines";
                $disciplines_result = mysqli_query($conn, $disciplines_query);
                $disciplines_count = mysqli_num_rows($disciplines_result);

                //Videos count
                $videos_query = "SELECT * FROM videos";
                $videos_result = mysqli_query($conn, $videos_query);
                $videos_count = mysqli_num_rows($videos_result);

                //Views count
                $views_query = "SELECT * FROM views";
                $views_result = mysqli_query($conn, $views_query);
                $views_count = mysqli_num_rows($views_result);


                //Most played count
                $most_played_query = "SELECT v.video_id,vid.title, COUNT(*) AS magnitude 
                FROM views as v
                INNER JOIN videos as vid
                WHERE v.video_id = vid.video_id
                GROUP BY video_id 
                ORDER BY magnitude DESC
                LIMIT 1";
                $most_played_result = mysqli_query($conn, $most_played_query);
                $most_played_row = mysqli_fetch_assoc($most_played_result);
                
                $most_played_video_title = $most_played_row["title"];
                $most_played_count = $most_played_row["magnitude"];

                /* print_r($most_played_video_title);
                print_r($most_played_count); */



                ?>

                <div class="data-cont">

                    <div class="col-md-2">
                        <div class="data-item">
                            <div class="data-item-content">
                                <span class="main-value"><?php print_r($users_count); ?></span>
                                <span class="data-tag">Usuarios</span>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-2">
                        <div class="data-item">
                            <div class="data-item-content">
                                <span class="main-value"><?php print_r($coaches_count); ?></span>
                                <span class="data-tag">Coaches</span>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-2">
                        <div class="data-item">
                            <div class="data-item-content">
                                <span class="main-value"><?php print_r($disciplines_count); ?></span>
                                <span class="data-tag">Disciplinas</span>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-2">
                        <div class="data-item">
                            <div class="data-item-content">
                                <span class="main-value"><?php print_r($videos_count); ?></span>
                                <span class="data-tag">Videos</span>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-2">
                        <div class="data-item">
                            <div class="data-item-content">
                                <span class="main-value"><?php print_r($views_count); ?></span>
                                <span class="data-tag">Reproducciones</span>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-2">
                        <div class="data-item">
                            <div class="data-item-content">
                                <span class="main-value" style="font-size: 25px;">"<?php print_r($most_played_video_title); ?>"</span>
                                <span class="data-tag" style="line-height: normal; display: inline-block; font-size: 15px;">Video más visto<br>con <?php print_r($most_played_count); ?> reproducciones</span>
                            </div>
                        </div>
                    </div>

                </div>

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
    </script>

    <?php include "footer.php"; ?>

    <?php include "body-js.php"; ?>
</body>

</html>