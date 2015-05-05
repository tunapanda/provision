#!/usr/bin/python
# 
# Helper script for ansible, which also provides a dynamic 
# ansible inventory. See docs for details on the inventory part:
#   http://docs.ansible.com/developing_inventory.html
# 
import platform as platform_details
import argparse
import json
import os
import sys
import yaml
import subprocess

## ERROR HANDLING
def die(msg,error_code=1):
    sys.stderr.write("\n*** FATAL: %s\n\n" % msg)
    sys.exit(error_code)
    
def dbg(msg,msg_level=2):
    debug_level = config.get("debug",0)
    if msg_level <= debug_level:
        print "\n### DEBUG: %s\n" % msg

## SETTINGS
# Important paths
my_fn = os.path.realpath(__file__)
base_dir = os.path.abspath(os.path.join(os.path.dirname(my_fn),".."))
playbook_dir = os.path.join(base_dir,"playbooks")
inventory_fn = my_fn
localconfig_fn = base_dir + "/localconfig.yml"
localconfig_defaults_fn = localconfig_fn + ".defaults"

# Load default configuration
config = {}
if os.path.exists(localconfig_defaults_fn):
    try: 
        config.update(yaml.load(open(localconfig_defaults_fn,"r").read()))
    except Exception, e:
        die("Could not parse %s. Error text was '%s'" % (localconfig_defaults_fn,e))
else:
    die("Could not find base config file at %s" % localconfig_defaults_fn)

# Load (optional) local configuration
if os.path.exists(localconfig_fn):
    try: 
        config.update(yaml.load(open(localconfig_fn,"r").read()))
    except Exception, e:
        die("Could not parse %s. Error text was '%s'" % (localconfig_fn,e))
        
# Template for defining the default playbook
# Roles are defined in get_dynamic_plays()
dynamic_playbook_tpl = """---
# This file is overwritten every time provisioning
# is done with the default profile. All local 
# changes will be lost!

- include: common/base.yml
- hosts: all
  handlers:
    - include: common/handlers.yml
%(roles)s
- include: util_print_stats.yml
"""
    
# Don't include these in the default playbook.
# Typically this is for roles that are in 
# common/base.yml because they need to be run first
dynamic_playbook_skip_roles = [ 
    "users",
    "networking",
    "external_data_drive",
    "provision_base"
]

## SUPPORT FUNCTIONS 
# Get profile from config. This is basically the playbook name, minus
# the extension. It's used for defining a custom group, and some other
# things.
def get_profile():        
    # See if we are given a profile in config
    profile = config.get("profile")
    
    # Strip the enstension, if present
    if profile.endswith(".yml"):
        profile = profile[:-4]
        
    return profile
    
# Get profile from config. This is the name of an (optional) ansible
# group with special hardware-related settings 
def get_platform():
    # See if we are given a profile in config
    platform = config.get("platform")
    
    # If not, the default value can depend on a few things...
    if platform in ("auto",None):
        # Vagrant (and others) may override the default platform with
        # an environment variable
        if os.environ.has_key("PROVISION_DEFAULT_PLATFORM"):
            platform = os.environ["PROVISION_DEFAULT_PLATFORM"]
        
        # Or if we're on an ARM device, assume cubietruck
        elif "arm" in platform_details.machine():
            platform = "cubietruck"
            
        # Otherwise, assume no special action is needed
        else:
            platform = None
            
    # Add prefix, if missing
    if platform is not None and not platform.startswith("platform_"):
        platform = "platform_" + platform
            
    return platform
    
# Group memberships to output in --list mode
def get_groups():
    groups   = {}
    platform = get_platform()
    if platform is not None:
        groups[platform] = { "hosts" : ["127.0.0.1"] }
        
    profile = get_profile()
    if profile is not None:
        groups[profile]  = { "hosts" : ["127.0.0.1"] }
        
    return groups
    
# Playbook(s) to be executed. 
def get_playbooks():
    playbooks = []
    
    # See if there is an optional platform-specific playbook
    platform = get_platform()
    if platform is not None:
        platform_playbook = platform + ".yml"
        if os.path.exists(os.path.join(playbook_dir,platform_playbook)):
            playbooks.append(platform_playbook)
    
    # Now for the required profile-specific playbook...
    # If custom.yml exists, just use it.
    if os.path.exists(os.path.join(playbook_dir,"custom.yml")):
        profile_playbook = "custom.yml"
        
    # Otherwise, use what we're given in the settings
    else:   
        profile  = get_profile()
        profile_playbook = profile + ".yml"
        
        # If the profile is "dynamic", create a dynamic playbook
        if profile_playbook == "dynamic.yml":
            plays = get_dynamic_plays()
            open(os.path.join(playbook_dir,profile_playbook),"w").write(plays)
            
        # Confirm that the playbook actually exists
        if not os.path.exists(os.path.join(playbook_dir,profile_playbook)):
            die("Could not find or create %s/%s" % (playbook_dir,profile_playbook))
            
    playbooks.append(profile_playbook)
            
    return playbooks

# Host vars to output in --host mode and pass to playbook
def get_vars():
    vars = config.get("vars",{})
    if vars is None:
        vars = {}
    return vars

# Dynamically build a playbook that runs any enabled role
def get_default_roles():
    roles = ["  roles:"]
    for d in os.listdir(os.path.join(playbook_dir,"roles")):
        if d in dynamic_playbook_skip_roles:
            continue
        if not os.path.isdir(os.path.join(playbook_dir,"roles",d)):
            continue
        roles.append("    - { role: %(role)s, when: %(role)s__enabled is defined and %(role)s__enabled }" % { "role" : d })
    return "\n".join(roles)
        
def get_dynamic_plays(tpl=dynamic_playbook_tpl):
    return tpl % { "roles": get_default_roles() }

## DO THE DEED...
if __name__ == "__main__":
    # CLI args and --help ouput
    parser = argparse.ArgumentParser(description='Custom Ansible inventory generator')
    parser.add_argument("--list", action="store_true", default=False)
    parser.add_argument("--host", nargs="?", default=False)
    parser.add_argument("--dftprofile", nargs="?", default=False)
    args = parser.parse_args()
    
    # Debugging can be enabled by setting the `debug`
    # value in localconfig.yml. The message below
    # only prints if debugging is enabled.
    debug = config.get("debug",0)
    dbg("Debug output level %s enabled" % debug,1)
    
    if args.list:
        print json.dumps(get_groups(), indent=2)
    elif args.host:
        print json.dumps(get_vars(), indent=2)
    else:
        if os.getuid() != 0:
            die("Must run as root/sudo!")
            
        orig_dir = os.getcwd()
        os.chdir(playbook_dir)
        
        cmd = ["ansible-playbook"]
        cmd += ["-i", inventory_fn]
        cmd += ["-c", "local"]
        for (var,val) in get_vars().items():
            cmd += ['-e','%s="%s"' % (var,val)]
        if debug > 0:
            cmd.append("-" + "v" * debug)
        cmd += get_playbooks()
              
        print "\n*** Deploying profile '%s' for platform '%s' with command:" % (get_profile(),get_platform())
        print "  %s\n" % " ".join(cmd)
        sys.stdout.flush()
        ret = subprocess.call(cmd)
        os.chdir(orig_dir)
        sys.exit(ret)
    

