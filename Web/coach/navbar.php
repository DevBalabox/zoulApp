<?php
$dataArray = array(
	"logo"=>$extras_class->logo,
	"home_url"=>$extras_class->home_url,
	"message"=>'<span>Bienvenido</span>',
	"button" =>'<a nohref="" onclick="logout();" class="xx-btn-2">Cerrar sesión</a>'
);
echo '
<!-- Inicio Navbar -->
'.$extras_class->getTemplate("navbar",$dataArray).'
<!-- Fin Navbar -->
';
?>