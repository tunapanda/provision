<?php
/*
* Modular content portal adapted from worldpossible.org's Project RACHEL:
*	https://github.com/needlestack/rachel-content
*/

function rachel_sort_bypos($a, $b) {
    return $a['position'] - $b['position'];
}

function rachel_get_modlist($moddir="modules") {
    if ( ! is_dir($moddir) ) {
        throw new Exception("No module directory found.");
    }

    $handle = opendir($moddir);
    $count = 0;
    $modules = array();
    while ($file = readdir($handle)) {
        if (preg_match("/^\./", $file)) continue; // skip hidden
        if (is_dir("$moddir/$file")) { 
        	// look in dirs
            $dir = "$moddir/$file";
            if (file_exists("$dir/index.htmlf")) { // check for index fragment
                $count++;
                $frag = "index.htmlf";
                $content = file_get_contents("$dir/$frag");
                preg_match("/<!-- *position *\: *(\d+) *-->/", $content, $match);
                $mod_data = array(
                    'file' => $file,
                    'dir'  => $dir, // this is used by the include to know it's directory
                    'frag' => "$dir/$frag", // this is what is actually included
                    'position' => $match[1]
                );
			} 
            else {
                # there was no index fragment, so...
                $mod_data = array(
                    'file' => $file, // this is the name of the module
                    'dir'  => $dir, // this is the module's directory
                    'frag' => "nofrag.php", // we include a special fragment
                    'position' => 9999
                );
            } 
			if (file_exists("$dir/sync_in_progress")) {
				$mod_data['syncing'] = true;	
				$mod_data['position'] = 8888;	
			} else {
				$mod_data['syncing'] = false;
			}
			array_push($modules, $mod_data);
        }
    }
    closedir($handle);
    usort($modules, 'rachel_sort_bypos');
    return $modules;
}

function rachel_print_mod_fragment($mod) {
    $file = $mod['file']; // only matters for modules without a fragment
    $dir  = $mod['dir'];
    if ($mod['syncing']) {
    	print "<div class='warning'>{$mod['file']} appears to be syncing new content. This module may not work properly until the sync has completed.</div>";
    }
    print "<pre>"; print_r($mod,true); print "</pre>";
    include $mod['frag'];
}
?>
