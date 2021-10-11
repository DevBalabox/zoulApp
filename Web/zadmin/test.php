<?php include "initializer.php"; ?>

<!DOCTYPE html>
<html>

<head>
    <meta http-equiv="Content-Type" content="text/html; charset=gb18030">

    <?php include "meta.php"; ?>

    <title>Página de Inicio - <?php getString("main_title") ?></title>

    <meta name="description" content="Descripción de inicio - <?php getString("main_description") ?>">

    <?php include "head-css.php"; ?>

    <?php include "head-js.php"; ?>


</head>

<body class="gray-body general">

    <?php include "credits.php"; ?>

    <?php include "navbar.php"; ?>

    <button type="button" class="btn btn-primary btn-lg" data-toggle="modal" data-target="#myModal">
        Launch demo modal
    </button>

    <!-- Modal -->
    <div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                    <h4 class="modal-title" id="myModalLabel">Modal title</h4>
                </div>
                <div class="modal-body">
                    ...
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                    <button type="button" class="btn btn-primary">Save changes</button>
                </div>
            </div>
        </div>
    </div>

    <script>
        $('#myModal').on('hidden.bs.modal', function(e) {
            // do something...
            alert("Hey");
        })
    </script>

    <?php include "footer.php"; ?>

    <?php include "body-js.php"; ?>
</body>

</html>