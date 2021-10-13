#!/usr/bin/env php
<?php

$ini = <<<EOF
max_execution_time = {$_SERVER['MAX_EXECUTION_TIME']}
memory_limit = {$_SERVER['MEMORY_LIMIT']}
upload_max_filesize = {$_SERVER['MAX_POST_BODY']}
post_max_size = {$_SERVER['MAX_POST_BODY']}
EOF;

if (!empty($_SERVER['TIMEZONE']) && file_exists("/usr/share/zoneinfo/{$_SERVER['TIMEZONE']}")) {
    $ini .= "\ndate.timezone = {$_SERVER['TIMEZONE']}";
    copy("/usr/share/zoneinfo/{$_SERVER['TIMEZONE']}", '/etc/localtime');
    file_put_contents('/etc/timezone', $_SERVER['TIMEZONE']);
}

file_put_contents('/usr/local/etc/php/conf.d/custom.ini', $ini);

if (!empty($_SERVER['TYPECHO_INSTALL'])) {
    system("su -p www-data -s /usr/bin/env php /app/install.php");
}
