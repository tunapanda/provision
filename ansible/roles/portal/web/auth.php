<?php
/*
*
* Based on http://www.andybev.com/index.php/Using_iptables_and_PHP_to_create_a_captive_portal
*
*/

$server_name = "127.0.0.1";
$domain_name = "x2go.org";
$site_name = "x2go";

// Path to the arp command on the local server
$arp = "/usr/sbin/arp";

// The following file is used to keep track of users
$users = "/usr/local/tunapanda/data/wap/users";

// Check if we've been redirected by firewall to here.
// If so redirect to registration address
if ($_SERVER['SERVER_NAME']!="$server_name.$domain_name") {
  header("location:http://$server_name.$domain_name/index.php?add="
    .urlencode($_SERVER['SERVER_NAME'].$_SERVER['REQUEST_URI']));
  exit;
}

// Attempt to get the client's mac address
$mac = shell_exec("$arp -a ".$_SERVER['REMOTE_ADDR']);
preg_match('/..:..:..:..:..:../',$mac , $matches);
@$mac = $matches[0];
if (!isset($mac)) { exit; }

if (!isset($_POST['email']) || !isset($_POST['name'])) {
  // Name or email address not entered therefore display form
  ?>
  <h1>Welcome to <?php echo $site_name;?></h1>
  To access the Internet you must first enter your details:<br><br>
  <form method='POST'>
  <table border=0 cellpadding=5 cellspacing=0>
  <tr><td>Your full name:</td><td><input type='text' name='name'></td></tr>
  <tr><td>Your email address:</td><td><input type='text' name='email'></td></tr>
  <tr><td></td><td><input type='submit' name='submit' value='Submit'></td></tr>
  </table>
  </form>
  <?php
} else {
    enable_address();
}

// This function enables the PC on the system by calling iptables, and also saving the
// details in the users file for next time the firewall is reset

function enable_address() {

    global $name;
    global $email;
    global $mac;
    global $users;

    file_put_contents($users,$_POST['name']."\t".$_POST['email']."\t"
        .$_SERVER['REMOTE_ADDR']."\t$mac\t".date("d.m.Y")."\n",FILE_APPEND + LOCK_EX);
    
    // Add PC to the firewall
    exec("sudo iptables -I internet 1 -t mangle -m mac --mac-source $mac -j RETURN");
    // The following line removes connection tracking for the PC
    // This clears any previous (incorrect) route info for the redirection
    exec("sudo rmtrack ".$_SERVER['REMOTE_ADDR']);

    sleep(1);
    header("location:http://".$_GET['add']);
    exit;
}

// Function to print page header
function print_header() {

  ?>
  <html>
  <head><title>Welcome to <?php echo $site_name;?></title>
  <META HTTP-EQUIV="CACHE-CONTROL" CONTENT="NO-CACHE">
  <LINK rel="stylesheet" type="text/css" href="./style.css">
  </head>

  <body bgcolor=#FFFFFF text=000000>
  <?php
}

// Function to print page footer
function print_footer() {
  echo "</body>";
  echo "</html>";

}

?>
