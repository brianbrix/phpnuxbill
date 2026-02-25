<?php
// Clear Smarty template cache
$cacheDir = __DIR__ . '/ui/cache/';

function deleteFilesInDir($dir) {
    $count = 0;
    if (!is_dir($dir)) return $count;
    $files = glob($dir . '*', GLOB_MARK);
    foreach ($files as $file) {
        if (is_dir($file)) {
            $count += deleteFilesInDir($file);
            @rmdir($file);
        } else {
            if (@unlink($file)) $count++;
        }
    }
    return $count;
}

$count = deleteFilesInDir($cacheDir);
echo "<h2>Smarty Cache Cleared!</h2>";
echo "<p>Deleted $count cache files from: $cacheDir</p>";
echo "<p><a href='/'>Go to Home Page</a></p>";
