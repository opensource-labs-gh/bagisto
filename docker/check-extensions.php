<?php
$required = [
    'bcmath',
    'calendar',
    'ctype',
    'curl',
    'dom',
    'exif',
    'fileinfo',
    'gd',
    'intl',
    'json',
    'mbstring',
    'openssl',
    'pdo_mysql',
    'tokenizer',
    'zip',
    'redis',
    'opcache',
];

$missing = [];
foreach ($required as $ext) {
    if (!extension_loaded($ext)) {
        $missing[] = $ext;
    }
}

if (empty($missing)) {
    echo "✅ All required PHP extensions are installed.\n";
} else {
    echo "❌ Missing extensions: " . implode(', ', $missing) . "\n";
}