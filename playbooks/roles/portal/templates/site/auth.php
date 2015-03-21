<?php
/*
*
* Authentication method is based on 
* http://www.andybev.com/index.php/Using_iptables_and_PHP_to_create_a_captive_portal
*
*/

function do_auth($auth_type) {
    $auth_default_class = "auth_none";
    $auth_class = "auth_{$auth_type}";
    if ( class_exists($auth_class) ) {
        $auth = new $auth_class();
    } else {
        $auth = new $auth_default_class();
    }
    $auth->go();
}

// Simple auth mode that does nothing
class auth_none {
    public function go() {
        return true;
    }
}

// Real auth modes should extend this class
// Do not use auth_base directly. It won't work!
abstract class auth_base {
    // Path to the arp command on the local server
    public $arp = "/usr/sbin/arp";

    // The following file is used to keep track of users
    public $records_fn = "{{ portal__users }}";

    public $mac = null;
    public $records = null;

    abstract public function get_name();
    abstract public function get_email();
    abstract public function do_authorized();
    abstract public function do_unknown();

    public function go() {
        if ( $this->auth_record_exists() ) {
            return $this->do_authorized();
        } else {
            return $this->do_unknown();
        }
    }

    public function get_remote_ip() {
        return $_SERVER['REMOTE_ADDR'];
    }

    public function get_mac() {
        if ( is_null($this->mac) ) {
            // Attempt to get the client mac address
            $mac = shell_exec("$this->arp -a ".$this->get_remote_ip());
            preg_match('/..:..:..:..:..:../',$mac , $matches);
            @$mac = $matches[0];
            if (!isset($mac)) { 
                // Can't grant access without a MAC
                // TODO: throw exception?
                return false;
            }
            $this->mac = $mac;
        }
        return $this->mac;
    }

    public function get_date() {
        return date("d.m.Y");
    }

    public function get_records() {
        if ( is_null($this->records) ) {
            $records_by_mac = array();
            if ( file_exists($this->records_fn) ) {
                foreach (file($this->records_fn) as $line) {
                    $parts = explode("\t",$line);
                    // Skip empty/malformed lines
                    if (sizeof($parts) == 1) {
                        continue;
                    }
                    $mac = $parts[3];
                    $records_by_mac[$mac] = $line;
                }
            }
            $this->records = $records_by_mac;
        }
        return $this->records;
    }

    public function auth_record_exists() {
        $mac = $this->get_mac();
        $records = $this->get_records();
        return array_key_exists($mac,$records);
    }

    public function authorize() {
        // Get existing records and update or create
        // entry for the current MAC
        $mac = $this->get_mac();
        $date = $this->get_date();
        $records = $this->get_records();
        if ( array_key_exists($mac,$records) ) {
            // Update datestamp
            $update = explode("\t",$records[$mac]);
            $update[4] = $date;
        } else {
            $update = Array(
                $this->get_name(),
                $this->get_email(),
                $this->get_remote_ip(),
                $mac,
                $date
            );
        }
        $records[$mac] = implode("\t",$update);

		// Write updated file
        $records_str = implode("\n",array_values($records))."\n";
		file_put_contents($this->records_fn,$records_str,LOCK_EX);

		// Remove and re-add a rule to exempt this MAC from redirection
		// (easier than searching for an existing chain before adding)
		exec("sudo iptables -D {{ portal__capture_chain }} -t mangle -m mac --mac-source $mac -j RETURN");
		exec("sudo iptables -I {{ portal__capture_chain }} 1 -t mangle -m mac --mac-source $mac -j RETURN");
		
		// The following line remove connection tracking for the PC
		// This clears any previous (incorrect) route info for the redirection
		exec("sudo rmtrack ".$_SERVER['REMOTE_ADDR']);
    }
}

class auth_agreement extends auth_base {
    public function get_name() {
        return "Anonymous (via auth_agreement)";
    }
    public function get_email() {
        return "anon@localhost";
    }
    public function do_authorized() {
        // Update the auth record's timestamp, but don't print any messages
        $this->authorize();
?>		
		{{ portal__auth_agreement_complete }}
<?php
    }
    public function do_unknown() {
        if ( isset ($_POST['agreed']) ) {
            // Create a new auth record
            $this->do_authorized();
            if ( isset($_REQUEST['orig_url']) ) {
                print "<p><strong><a href='{$_REQUEST['orig_url']}'>Click here to continue to your original destination!</a></strong></p>";
            }
            print "<p>Don't forget to bookmark this page so you can access it easily in the future!</p>";
            print "</div>";
        } else {
?>
      <div class='auth notification'>
	  <h3>You do not have access to the Internet (yet)</h3>
      {{ portal__auth_agreement_text }}
      </div>
      <form method='POST' action="">
<?php
      if ( isset($_REQUEST['orig_url']) ) {
        print "<input type='hidden' name='orig_url' value='{$_REQUEST['orig_url']}'>";
      }
?>
	  <input type="hidden" name="agreed" value=1>
	  <input type='submit' name='submit' value="{{ portal__auth_agreement_buttontext }}">
	  </form>
<?php
        }
    }
}
?>
<!-- position: 0 -->
<div class="indexmodule">
	<?php do_auth("{{ portal__auth }}"); ?>
</div>
