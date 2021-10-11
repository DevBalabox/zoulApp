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

    <script src='https://ajax.aspnetcdn.com/ajax/jquery.validate/1.10.0/jquery.validate.min.js'></script>

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
            "bg_img" => "https://www.outsideonline.com/sites/default/files/styles/full-page/public/2020/03/18/at-home-workout-yoga_h.jpg?itok=S0R1vbEk",
            "title" => "Videos",
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

            <div class="tab" tab-name="videos" style="text-align: center;">

                <button type="button" action="create_new" class="btn btn-primary" data-toggle="modal" data-target="#newVideo">Crear nuevo video</button>
                <?php
                $url = "https://api.vimeo.com/me/videos?fields=uri,name,download&page=1&per_page=100";
                $header = $extras_class->vimeo_header;
                $access_token = $extras_class->vimeo_access_token;

                $ch = curl_init();
                curl_setopt($ch, CURLOPT_URL, $url);
                curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

                $headers = [
                    'Authorization: ' . $access_token,
                    'Accept: ' . $header,
                    'Content-Type: application/json'
                ];

                curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);

                $server_output = curl_exec($ch);

                curl_close($ch);

                $output_array = json_decode($server_output);
                $video_list = (array) $output_array->data;

                function get_all_users()
                {
                    global $extras_class;
                    $conn = $extras_class->database();
                    $table_header = false;
                    global $video_list;

                    $rules = array(
                        "id" => array("key" => "id", "name" => "ID", "type" => "hidden"),
                        "video_id" => array("key" => "video_id", "name" => "ID de Video", "type" => "hidden"),
                        "coach_id" => array("key" => "coach_id", "name" => "Coach", "type" => "get_coaches"),
                        "discipline_id" => array("key" => "discipline_id", "name" => "Disciplina", "type" => "get_disciplines"),
                        "external_id" => array("key" => "external_id", "name" => "Video", "type" => "get_videos"),
                        "title" => array("key" => "title", "name" => "Título", "type" => "text"),
                        "description" => array("key" => "description", "name" => "Descripción", "type" => "textarea"),
                        "status" => array("key" => "status", "name" => "Estatus", "type" => "dropdown", "options" => ["Público", "Privado", "Próximamente"]),
                        "source" => array("key" => "source", "name" => "Proveedor", "type" => "dropdown", "options" => ["vimeo"]),
                        "img_url" => array("key" => "featured_img", "name" => "Imagen de portada", "type" => "hidden"),
                        "creation_date" => array("key" => "creation_date", "name" => "Fecha de creación", "type" => "blocked"),
                    );

                    $query = "SELECT * FROM videos ORDER BY id DESC";
                    $result = mysqli_query($conn, $query);

                    /* Ver si el correo existe */
                    if (mysqli_num_rows($result)) {
                        echo '<div class="table-cont"><table class="table table-striped">';

                        while ($row = mysqli_fetch_assoc($result)) {
                            if (!$table_header) {
                                echo '<thead><tr>';
                                echo '<th scope="col" style="background: none"></th>';
                                echo '<th scope="col">Video</th>';
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
                            echo '<tr><form video_id="' . $row["video_id"] . '">';
                            echo '<th scope="row"><button action="edit" type="button" onclick="updateRow(\'' . $row["video_id"] . '\', this)">Actualizar</button><button action="delete" onclick="deleteDialog(\'' . $row["title"] . '\',\'' . $row["video_id"] . '\', this)" type="button">Eliminar</button></th>';

                            echo '<input type="hidden" name="action" value="admin_edit_video" id="action_' . $row["video_id"] . '">';

                            echo '<th scope="row" style="text-align:center"><button type="button" action="play" onclick="openVideo(\'' . $row["external_id"] . '\')" data-toggle="modal" data-target="#myModal"><i class="fa fa-play"></i> Ver video</button></th>';
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
                                        echo '<input type="hidden" id="main_picture_' . $row["video_id"] . '" name="' . $rules[$field]["key"] . '">';
                                        break;

                                    case "get_coaches":
                                        echo '<th scope="row"><select name="' . $rules[$field]["key"] . '">';
                                        echo '<option value="">Selecciona una opción</option>';

                                        $coaches_query = "SELECT * FROM users as a INNER JOIN coaches as b WHERE b.user_id = a.user_id ORDER BY a.id DESC";
                                        $coaches_result = mysqli_query($conn, $coaches_query);
                                        if (mysqli_num_rows($coaches_result)) {
                                            while ($coaches_row = mysqli_fetch_assoc($coaches_result)) {
                                                $coach_id = $coaches_row["coach_id"];
                                                $selected = $row[$field] == $coach_id ? 'selected' : '';
                                                echo '<option value="' . $coach_id . '" ' . $selected . '>' . $coaches_row["name"] . " " . $coaches_row["first_lastname"] . " " . $coaches_row["second_lastname"] . '</option>';
                                            }
                                        }
                                        echo '</select></th>';
                                        break;

                                    case "get_disciplines":
                                        echo '<th scope="row"><select name="' . $rules[$field]["key"] . '">';
                                        echo '<option value="">Selecciona una opción</option>';

                                        $disciplines_query = "SELECT * FROM disciplines ORDER BY id DESC";
                                        $disciplines_result = mysqli_query($conn, $disciplines_query);
                                        if (mysqli_num_rows($disciplines_result)) {
                                            while ($disciplines_row = mysqli_fetch_assoc($disciplines_result)) {
                                                $discipline_id = $disciplines_row["discipline_id"];
                                                $selected = $row[$field] == $discipline_id ? 'selected' : '';
                                                echo '<option value="' . $discipline_id . '" ' . $selected . '>' . $disciplines_row["name"] . " " . $disciplines_row["first_lastname"] . " " . $disciplines_row["second_lastname"] . '</option>';
                                            }
                                        }
                                        echo '</select></th>';
                                        break;

                                    case "get_videos":

                                        echo '<th scope="row"><select name="' . $rules[$field]["key"] . '">';
                                        echo '<option value="">Selecciona el video</option>';

                                        foreach ($video_list as $video_item) {
                                            $vid_id = str_replace("/videos/", "", $video_item->uri);
                                            $vid_name = $video_item->name;
                                            $selected = $row[$field] == $vid_id ? 'selected' : '';
                                            echo '<option value="' . $vid_id . '" ' . $selected . '>' . $vid_name . '</option>';
                                        }

                                        echo '</select>';
                                        break;

                                    default:
                                        echo '<th scope="row"><input type="text" name="' . $field . '" value="' . strval($row[$field]) . '"></th>';
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
                        echo '</div></table>';
                    }
                }

                function formify($data_array, $rules)
                {
                    $begin_tag = '<div class><table style="width:100%"><tr>';
                    $html = '<div class><table style="width:100%"><tr>';
                    foreach ($data_array as $field => $value) {
                        //acciones
                        if (array_key_exists($field, $rules)) {
                            $type = $rules[$field]["type"];
                            $html .= '<th>' . $rules[$field]["name"] . '</th>';
                        } else {
                            $html .= '<th>' . ucfirst($field) . '</th>';
                        }
                    }
                    $html = '<tr></div>';

                    return $html;
                }

                get_all_users();
                ?>

            </div>

        </div>
    </div>

    <!-- Modal -->
    <div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">

                <div class="modal-body" style="padding: 0px;">
                    <!-- 16:9 aspect ratio -->
                    <div class="embed-responsive embed-responsive-16by9">
                        <iframe id="videoFrame" src="" width="640" height="360" frameborder="0" allow="autoplay; fullscreen" allowfullscreen></iframe>
                    </div>

                </div>

            </div>
        </div>
    </div>

    <!-- Formulario de nueva disciplina -->
    <div class="modal fade" id="newVideo" tabindex="-1" role="dialog" aria-labelledby="newVideoLabel" aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="newVideoLabel">Nuevo Video</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <form id="new_video">
                        <input type="hidden" name="action" value="new_video">

                        <div class="form-group">
                            <label class="col-form-label">¿A qué Coach corresponde el video?:</label>
                            <?php
                            $conn = $extras_class->database();
                            echo '<select name="coach_id" required>';
                            echo '<option value="">Selecciona un coach</option>';

                            $coaches_query = "SELECT * FROM users as a INNER JOIN coaches as b WHERE b.user_id = a.user_id ORDER BY a.id DESC";
                            $coaches_result = mysqli_query($conn, $coaches_query);
                            if (mysqli_num_rows($coaches_result)) {
                                while ($coaches_row = mysqli_fetch_assoc($coaches_result)) {
                                    $coach_id = $coaches_row["coach_id"];
                                    echo '<option value="' . $coach_id . '">' . $coaches_row["name"] . " " . $coaches_row["first_lastname"] . " " . $coaches_row["second_lastname"] . '</option>';
                                }
                            }
                            echo '</select>';
                            ?>
                        </div>

                        <div class="form-group">
                            <label class="col-form-label">¿De qué disciplina es?:</label>
                            <select name="discipline_id" required>
                                <option value="">Selecciona una disciplina</option>
                                <?php
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

                        <div class="form-group">
                            <label class="col-form-label">Escoge el video:</label>
                            <select name="external_id" required>
                                <option value="">Selecciona el video</option>
                                <?php
                                foreach ($video_list as $video_item) {
                                    $vid_id = str_replace("/videos/", "", $video_item->uri);
                                    $vid_name = $video_item->name;

                                    $discipline_id = $disciplines_row["discipline_id"];
                                    echo '<option value="' . $vid_id . '">' . $vid_name . '</option>';
                                }
                                ?>
                            </select>
                        </div>

                        <div class="form-group">
                            <label class="col-form-label">Título del video:</label>
                            <input type="text" class="form-control" name="title" required>
                        </div>
                        <div class="form-group">
                            <label class="col-form-label">Descripción:</label>
                            <textarea class="form-control" name="description" required></textarea>
                        </div>
                        <div class="form-group">
                            <label class="col-form-label">Estatus:</label>
                            <select name="status" required>
                                <option value="Público" selected>Público</option>
                                <option value="Privado">Privado</option>
                                <option value="Próximamente">Próximamente</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label class="col-form-label">Proveedor:</label>
                            <select name="source" required>
                                <option value="vimeo" selected>Vimeo</option>
                            </select>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancelar</button>
                    <button type="button" class="btn btn-primary" onclick="insert_db_element(this)">Crear video</button>
                </div>
            </div>
        </div>
    </div>
    <!-- Fin formulario de nueva disciplina -->

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

        function encodeImageFileAsURL(element, video_id) {
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
                    $(".user-pic[video_id=" + video_id + "]").css("background-image", "url(" + dataurl + ")");
                    $('#main_picture_' + video_id).attr("value", dataurl.split(',')[1]);
                }

            }
            reader.readAsDataURL(file);



            /* var reader = new FileReader();
            reader.onloadend = function() {
            	imagebase64 = reader.result;
            	//console.log(imagebase64);
            	$(".user-pic[video_id=" + video_id + "]").css("background-image", "url(" + imagebase64 + ")");
            	$('#main_picture_' + video_id).attr("value", imagebase64);
            }
            reader.readAsDataURL(file); */
        }
    </script>

    <script>
        /* function updateRow(video_id) {
			$('form[video_id="' + video_id + '"]').addClass("editable");
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

        function updateRow(video_id, button) {
            var form = $('form[video_id="' + video_id + '"]');
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
                    toastr.error("Hubo un error para realizar la operación");
                    button.removeClass("disabled");
                }
            });
        }

        function insert_db_element(button) {
            if ($("#new_video").valid()) {
                var form = $("#new_video");
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
                            setTimeout(function() {
                                location.reload();
                            }, 0);
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
                        toastr.error("Hubo un error para realizar la operación");
                        button.removeClass("disabled");
                    }
                });
            }
        }

        vex.defaultOptions.className = 'vex-theme-top';

        function deleteRow(video_id, button) {
            $('#action_' + video_id).val("delete_video");
            var form = $('form[video_id="' + video_id + '"]');
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
                        setTimeout(function() {
                            location.reload();
                        }, 0);
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

        function deleteDialog(video_name, video_id, button) {
            vex.dialog.confirm({
                message: '¿Estás seguro que quieres eliminar el video titulado "' + video_name + '"?',
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
                        deleteRow(video_id, button);
                    }
                }
            })
        }
    </script>

    <script>
        function openVideo(id) {
            var url = "https://player.vimeo.com/video/";
            var video_id = id;
            $("#videoFrame").attr("src", url + video_id);
        }

        $('#myModal').on("hide.bs.modal", function() {
            $("#videoFrame").attr("src", "");
        });
    </script>

    <?php include "footer.php"; ?>

    <?php include "body-js.php"; ?>
</body>

</html>