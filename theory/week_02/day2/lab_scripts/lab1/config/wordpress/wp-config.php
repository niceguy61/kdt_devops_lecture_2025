<?php
define('DB_NAME', 'wordpress');
define('DB_USER', 'wpuser');
define('DB_PASSWORD', 'wppassword');
define('DB_HOST', 'mysql-wordpress:3306');
define('DB_CHARSET', 'utf8mb4');
define('DB_COLLATE', '');

// 보안 키 설정 (실제 환경에서는 고유한 키 사용)
define('AUTH_KEY',         'put your unique phrase here');
define('SECURE_AUTH_KEY',  'put your unique phrase here');
define('LOGGED_IN_KEY',    'put your unique phrase here');
define('NONCE_KEY',        'put your unique phrase here');
define('AUTH_SALT',        'put your unique phrase here');
define('SECURE_AUTH_SALT', 'put your unique phrase here');
define('LOGGED_IN_SALT',   'put your unique phrase here');
define('NONCE_SALT',       'put your unique phrase here');

// Redis 세션 설정
define('WP_REDIS_HOST', 'redis-session');
define('WP_REDIS_PORT', 6379);
define('WP_REDIS_DATABASE', 0);

// 성능 최적화
define('WP_CACHE', true);
define('COMPRESS_CSS', true);
define('COMPRESS_SCRIPTS', true);
define('CONCATENATE_SCRIPTS', true);

// 디버그 설정
define('WP_DEBUG', false);
define('WP_DEBUG_LOG', false);
define('WP_DEBUG_DISPLAY', false);

// 파일 권한
define('FS_METHOD', 'direct');

// 테이블 접두사
$table_prefix = 'wp_';

if ( !defined('ABSPATH') )
    define('ABSPATH', dirname(__FILE__) . '/');

require_once(ABSPATH . 'wp-settings.php');
