<?php include "initializer.php";
$admin_user_class = new User;
$admin_user_class->session_name = "ZPUsrSess_admin";
if ($admin_user_class->verify_login()) header('Location: ' . $extras_class->home_url);
?>

<!DOCTYPE html>
<html>

<head>

  <?php include "meta.php"; ?>

  <title>Página de Inicio - <?php getString("main_title") ?></title>

  <meta name="description" content="Descripción de inicio - <?php getString("main_description") ?>">

  <?php include "head-css.php"; ?>

  <?php include "head-js.php"; ?>

  <style>
    body {
      background-color: #e2e2e2 !important;
      text-align: center;
    }

    .card {
      background: #fff;
      border-radius: 10px;
      display: inline-block;
      margin: 2%;
      text-align: center;
      width: 500px;
      max-width: 100%;
      padding: 30px 15px;
      border: 1px solid #d8d8d8;
      box-shadow: 0px 3px 8px rgba(0, 0, 0, 0.2);
    }

    .form-cont input,
    textarea {
      width: 100%;
      display: block;
      margin: auto;
      margin-bottom: 7px;
      background: #eaeaea;
      padding: 5px 15px;
      border-radius: 3px;
      border: 1px solid #e0e0e0;
    }

    .form-cont .send-btn {
      display: inline-block;
      background: #ff8aa2;
      color: #fff;
      border: none;
      padding: 10px 20px;
      border-radius: 4px;
    }

    .disabled-btn {
      background: gray !important;
      pointer-events: none !important;
    }

    .logo {
      width: 200px;
      margin: auto;
      height: 100px;
    }

    .logo img {
      max-width: 100%;
      max-height: 100%;
    }

    .form-cont h2 {
      margin: 15px 0px;
      font-size: 30px;
      font-weight: 300;
    }

    #login_form .tag-input {
      width: 350px;
      margin: 15px auto;
    }
  </style>

</head>

<body class="gray-body general">

  <?php include "credits.php"; ?>

  <?php
  $dataArray = array(
    "logo" => $extras_class->logo,
    "home_url" => $extras_class->home_url,
    "message" => '<span>¿No eres el administrador? Dirígete aquí </span>',
    "button" => '<a href="#" class="xx-btn-2">Inicio</a>'
  );
  echo '
<!-- Inicio Navbar -->
' . $extras_class->getTemplate("navbar", $dataArray) . '
<!-- Fin Navbar -->
';
  ?>

  <!-- Contenido principal -->
  <div class="main">
    <div class="login-signup">
      <div class="card">
        <div class="logo">
          <img src="<?php echo $extras_class->logo ?>">
        </div>
        <?php
        if (!$admin_user_class->verify_login()) {
          echo $admin_user_class->verify_login();
          echo '
            <div class="form-cont">
              <h2>Inicia sesión</h2>
              <form id="login_form">
              <div class="tag-input">      
                <input type="email" name="mail" placeholder="Tu correo" required>
              </div>
              <div class="tag-input">
                <input type="password" name="password" placeholder="Tu contraseña" required>
                <input type="hidden" name="user_type" value="admin">
              </div>
                <button type="button" class="send-btn" onclick="trylogin();">Iniciar sesión</button>
              </form>
              <span id="response-text"></span>
            <div>
            ';
        } else {
          $admin_user_class->trigger_login("admin");
          echo '
            <h2>Bienvenido ' . $user_class->user_data_array["name"] . '</h2>
            <span><strong>Nombre: </strong>' . $admin_user_class->user_data_array["name"] . '</span><br>
            <span><strong>Correo: </strong>' . $admin_user_class->user_data_array["mail"] . '</span><br>
            <hr>
            <button type="button" class="send-btn" onclick="logout();">Cerrar sesión</button>
            <span></span>
            ';
        }
        ?>
      </div>
    </div>
  </div>

  <!-- Fin Contenido principal -->

  <?php include "footer.php"; ?>

  <?php include "body-js.php"; ?>

</body>

</html>