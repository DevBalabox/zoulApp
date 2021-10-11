<?php
//Start session if there is none
if(session_id() == ''){
    session_start();
}

//Get class for extra functions (Database, Random Codes, etc.)
if( !class_exists( 'Extras' ) ) {
    require "../zadmin/app/classes/extras.php";
    $extras_class = new Extras;
}

if( !class_exists( 'Strings' ) ) {
    require "../zadmin/app/classes/strings.php";
    $strings_class = new Strings;
}

if( !class_exists( 'User' ) ) {
    require "../zadmin/app/classes/user.php";
    $user_class = new User;
}

if( !class_exists( 'Worker' ) ) {
    require "../zadmin/app/classes/worker.php";
    $worker_class = new Worker;
}

if( !class_exists( 'Services' ) ) {
    require "../zadmin/app/classes/services.php";
    $services_class = new Services;
}

if( !class_exists( 'Booking' ) ) {
    require "../zadmin/app/classes/booking.php";
    $booking_class = new Booking;
}

/* if( !class_exists( 'Payments' ) ) {
    require "../zadmin/app/classes/payments.php";
    $payments_class = new Payments;
} */

if( !class_exists( 'Coupons' ) ) {
    require "../zadmin/app/classes/coupons.php";
    $coupons_class = new Coupons;
}

if( !class_exists( 'Discipline' ) ) {
    require "../zadmin/app/classes/discipline.php";
    $discipline_class = new Discipline;
}

if( !class_exists( 'Coach' ) ) {
    require "../zadmin/app/classes/coach.php";
    $coach_class = new Coach;
}

if( !class_exists( 'Video' ) ) {
    require "../zadmin/app/classes/video.php";
    $video_class = new Video;
}

if( !class_exists( 'Analytics' ) ) {
    require "../zadmin/app/classes/analytics.php";
    $analytics_class = new Analytics;
}

if( !class_exists( 'Subscription' ) ) {
    require "../zadmin/app/classes/subscription.php";
    $subscription_class = new Subscription;
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

?>