<?php

define( 'AUTH_KEY',         '' );
define( 'SECURE_AUTH_KEY',  '' );
define( 'LOGGED_IN_KEY',    '' );
define( 'NONCE_KEY',        '' );
define( 'AUTH_SALT',        '' );
define( 'SECURE_AUTH_SALT', '' );
define( 'LOGGED_IN_SALT',   '' );
define( 'NONCE_SALT',       '' );

$table_prefix = 'wp_';

$config = array(
	'local' => array(
		'environment' => 'local',
		'db_host'     => 'localhost',
		'db_name'     => 'database',
		'db_user'     => 'root',
		'db_password' => '',
		'wp_home'     => 'http://localhost',
		'debug'       => true
	),
	'stage' => array(
		'environment' => 'staging',
		'db_host'     => 'localhost',
		'db_name'     => 'stage_database',
		'db_user'     => 'root',
		'db_password' => '',
		'wp_home'     => 'http://stage.domain.com',
		'debug'       => false
	),
	'live' => array(
		'environment' => 'production',
		'db_host'     => 'localhost',
		'db_name'     => 'live_database',
		'db_user'     => 'root',
		'db_password' => '',
		'wp_home'     => 'http://live.domain.com',
		'debug'       => false
	)
);

foreach( $config as $host => $options ) {
	if ( ! stristr( $_SERVER['HTTP_HOST'], $host ) )
		continue;

	define( 'OWC_ENVIRONMENT', $options['environment'] );
	define( 'DB_HOST',         $options['db_host'] );
	define( 'DB_NAME',         $options['db_name'] );
	define( 'DB_USER',         $options['db_user'] );
	define( 'DB_PASSWORD',     $options['db_password'] );
	define( 'WP_HOME',         $options['wp_home'] ); 

	if ( $options['debug'] ) {
		define( 'WP_DEBUG', true );

		error_reporting( E_ALL );
		ini_set( 'display_errors', 1 );
	} else {
		define( 'WP_DEBUG', false );
	}

	break;
}

define( 'DB_CHARSET', 'utf8' );
define( 'DB_COLLATE', '' );

define( 'WP_SITEURL', WP_HOME . '/wp' );
define( 'WP_CONTENT_URL', WP_HOME . '/wp-content' );
define( 'WP_CONTENT_DIR', dirname( __FILE__ ) . '/wp-content' );

require_once( dirname( __FILE__ ) . '/vendor/autoload.php' );

if ( ! defined( 'ABSPATH' ) )
	define( 'ABSPATH', dirname( __FILE__ ) . '/' );

require_once( ABSPATH . 'wp-settings.php' );