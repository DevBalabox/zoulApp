<?php
//Start session if there is none
if(session_id() == ''){
    session_start();
}

//Get class for extra functions (Database, Random Codes, etc.)
if( !class_exists( 'Extras' ) ) {
    require "../classes/extras.php";
    $extras_class = new Extras;
}

if( !class_exists( 'Strings' ) ) {
    require "../classes/strings.php";
    $strings_class = new Strings;
}

if( !class_exists( 'User' ) ) {
    require "../classes/user.php";
    $user_class = new User;
}

if( !class_exists( 'Discipline' ) ) {
    require "../classes/discipline.php";
    $discipline_class = new Discipline;
}

if( !class_exists( 'Coach' ) ) {
    require "../classes/coach.php";
    $coach_class = new Coach;
}

if( !class_exists( 'Video' ) ) {
    require "../classes/video.php";
    $video_class = new Video;
}

if( !class_exists( 'Analytics' ) ) {
    require "../classes/analytics.php";
    $analytics_class = new Analytics;
}

if( !class_exists( 'Subscription' ) ) {
    require "../classes/subscription.php";
    $subscription_class = new Subscription;
}

if( !class_exists( 'Notifications' ) ) {
    require "../classes/notifications.php";
    $notifications_class = new Notifications;
}

if(!function_exists("getString")) {
	function getString($string_name){
		global $strings_class;
		echo $strings_class->$string_name;
	}
}

if(!function_exists("getStringValue")) {
    function getStringValue($string_name){
        global $strings_class;
        return $strings_class->$string_name;
    }
}
