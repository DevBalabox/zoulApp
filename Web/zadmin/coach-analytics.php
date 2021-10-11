<?php include "initializer.php";
$admin_user_class = new User;
$admin_user_class->session_name = "ZPUsrSess_admin";
if (!$admin_user_class->verify_login()) header('Location: ' . $extras_class->login_url);
if (!isset($_GET["cid"])) {
    header('Location: ' . $extras_class->login_url);
} else {
    $coach_id = $_GET["cid"];
}
?>

<!DOCTYPE html>
<html>

<head>
    <meta http-equiv="Content-Type" content="text/html; charset=gb18030">

    <?php include "meta.php"; ?>

    <title>Analítica de coach</title>

    <meta name="description" content="Analítica de coach">

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
        .date-item {
            width: 200px;
            display: inline-block;
            background: linear-gradient(to right, #4CAF50, #61c142);
            margin: 10px;
            border-radius: 7px;
        }

        .date-item .period {
            color: #fff;
            background: rgba(255, 255, 255, 0.3);
            display: block;
            margin: 5px;
            padding: 10px;
            border-radius: 5px;
            font-size: 25px;
            text-align: center;
        }

        .date-item .count {
            font-size: 60px;
            color: #fff;
            text-align: center;
            margin: 0px;
            line-height: 60px;
        }

        .sm-txt {
            font-size: 20px;
            display: block;
            color: #fff;
            text-align: center;
            margin: 0px;
            margin-bottom: 15px;
        }

        .coach_mini .coach-name {
            font-size: 20px;
        }

        .coach-profile-pic {
            width: 150px;
            height: 150px;
            background: #969696;
            display: block;
            border-radius: 160px;
            margin: auto;
            margin-bottom: 10px;
            background-size: cover;
            background-position: center;
        }

        .coach_mini .coach-name {
            font-size: 30px;
            font-weight: 300;
            margin-bottom: 15px;
            display: block;
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
            "title" => "Analítica de coach",
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

            <div class="tab" tab-name="analytics" style="text-align: center;">

                <?php
                $conn = $extras_class->database();

                $coach_sql = "SELECT u.name,u.img_url FROM users as u INNER JOIN coaches as c WHERE c.coach_id = '$coach_id' AND c.user_id = u.user_id";
                $coach_result = mysqli_query($conn, $coach_sql);
                if (mysqli_num_rows($coach_result)) {
                    while ($coach_row = mysqli_fetch_assoc($coach_result)) {
                        $name = $coach_row["name"];
                        $img_url = $coach_row["img_url"];

                        echo '<div class="coach_mini"><div class="coach-profile-pic" style="background-image: url(\'' . $extras_class->gallery_path . $img_url . '\')"></div><span class="coach-name">' . $name . '</span></div>';
                    }
                } else {
                    echo 'ijhj';
                }

                $sql = "SELECT a.id, count(*) as total_views, a.creation_date FROM views as a INNER JOIN videos as b WHERE b.coach_id = '$coach_id' AND b.video_id = a.video_id GROUP BY YEAR(a.creation_date), month(a.creation_date) ORDER by a.creation_date DESC";
                $result = mysqli_query($conn, $sql);
                if (mysqli_num_rows($result)) {
                    while ($row = mysqli_fetch_assoc($result)) {
                        $total_views = $row["total_views"];
                        $date_period = $row["creation_date"];

                        setlocale(LC_TIME, "es_ES");
                        $date_period = strtoupper(strftime("%B, %Y", strtotime($date_period)));

                        echo '<div class="date-item"><h2 class="period">' . $date_period . '</h2><h2 class="count">' . $total_views . '</h2><span class="sm-txt">vistas</span></div>';
                    }
                } else {
                    echo '<span class="no-analytics">Este coach aún no tiene analítica</span>';
                }


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