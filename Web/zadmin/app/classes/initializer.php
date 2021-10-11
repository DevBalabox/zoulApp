<?php

//Start session if there is none
if(session_id() == ''){
	ob_start();
    session_start();
}

if( !class_exists( 'Extras' ) ) {
    require "extras.php";
    $extras_class = new Extras;
}

if( !class_exists( 'Strings' ) ) {
    require "strings.php";
    $strings_class = new Strings;
}

if( !class_exists( 'User' ) ) {
    require "user.php";
    $user_class = new User;
}

if( !class_exists( 'Worker' ) ) {
    require "worker.php";
    $worker_class = new Worker;
}

if( !class_exists( 'Services' ) ) {
    require "services.php";
    $services_class = new Services;
}

if( !class_exists( 'Booking' ) ) {
    require "booking.php";
    $booking_class = new Booking;
}

if( !class_exists( 'Payments' ) ) {
    require "payments.php";
    $payments_class = new Payments;
}

if( !class_exists( 'Coupons' ) ) {
    require "coupons.php";
    $coupons_class = new Coupons;
}

if( !class_exists( 'Discipline' ) ) {
    require "discipline.php";
    $discipline_class = new Discipline;
}

if( !class_exists( 'Coach' ) ) {
    require "coach.php";
    $coach_class = new Coach;
}

if( !class_exists( 'Video' ) ) {
    require "video.php";
    $video_class = new Video;
}

if( !class_exists( 'Analytics' ) ) {
    require "analytics.php";
    $analytics_class = new Analytics;
}

if( !class_exists( 'Notifications' ) ) {
    require "notifications.php";
    $notifications_class = new Notifications;
}

if( !class_exists( 'Subscription' ) ) {
    require "subscription.php";
    $subscription_class = new Subscription;
}

date_default_timezone_set('UTC');
date_default_timezone_set("America/Mexico_City");
