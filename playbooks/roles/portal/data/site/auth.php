<?php
/*
*
* Based on http://www.andybev.com/index.php/Using_iptables_and_PHP_to_create_a_captive_portal
*
*/

function print_auth_form() {
?>
	  <h3>Please Sign In (<?=$mac?>)</h3>
	  <p>To access the Internet, please enter your details:</p>
	  <form method='POST'>
	  <table border=0 cellpadding=5 cellspacing=0>
	  <tr><td>Your full name:</td><td><input type='text' name='name'></td></tr>
	  <tr><td>Your email address:</td><td><input type='text' name='email'></td></tr>
	  <tr><td></td><td><input type='submit' name='submit' value='Submit'></td></tr>
	  </table>
	  </form>
<?php
}

function validate_auth_form() {
	// TODO: Actual validation of some kind
	return true;	
}

// Path to the arp command on the local server
$arp = "/usr/sbin/arp";

// The following file is used to keep track of users
$users_fn = "/opt/tunapanda/data/captive_portal/users";

// Attempt to get the client mac address
$mac = shell_exec("$arp -a ".$_SERVER['REMOTE_ADDR']);
preg_match('/..:..:..:..:..:../',$mac , $matches);
@$mac = $matches[0];
if (!isset($mac)) { 
	print "Cannot get MAC address, so cannot grant net access";
	exit();
}
    
// Note whether this MAC is already in the users list. While doing
// this we can also prepare a version of the file with an updated 
// timestamp, but won't write it unless the form has been submitted
$users = file($users);
$users_updated = array();
$already_recorded = false;
$match_pattern = "/".preg_quote($mac)."/";
foreach (file($users) as $line) {
	if ( ! preg_match($match_pattern,$line) ) {
		$users_updated[] = $line;
	} else {
		$already_recorded = true;
	}
}
$users_updated[] = $_POST['name']."\t".$_POST['email']."\t"
	.$_SERVER['REMOTE_ADDR']."\t$mac\t".date("d.m.Y");

// Main content
if (isset($_POST['email']) || isset($_POST['name']))  {
	if ( ! validate_auth_form() ) {
		print "<div class='error'>ERROR: Bad auth information. Try again.</div>";
		print_auth_form();
	} else {
		// Write updated file
		file_put_contents($users,implode("\n",$users_updated)."\n",LOCK_EX);
		
		// Remove and re-add a rule to exempt this MAC from redirection
		// (easier than searching for an existing chain before adding)
		exec("sudo iptables -D captive -t mangle -m mac --mac-source $mac -j RETURN");
		exec("sudo iptables -I captive 1 -t mangle -m mac --mac-source $mac -j RETURN");
		
		// The following line removes connection tracking for the PC
		// This clears any previous (incorrect) route info for the redirection
		exec("sudo rmtrack ".$_SERVER['REMOTE_ADDR']);
		print ("Full access already granted");
	}
} else if ($already_recorded) {
	print ("Full access granted");
} else {
	print_auth_form();
} 
