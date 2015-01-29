#!/usr/bin/python
# 
# Dynamic inventory for single-server deployments. See docs for details:
#   http://docs.ansible.com/developing_inventory.html
# 

import platform
import argparse
import json
import os
import sys
import yaml

# Error codes
EBADFILE = 1

# Configurables
basedir = os.path.abspath(os.path.dirname(os.path.realpath(__file__)) + "/..")
localconfig_fn = basedir + "/localconfig.yml"

# --help system
parser = argparse.ArgumentParser(description='Custom Ansible inventory generator')
parser.add_argument("--list", action="store_true", default=False)
parser.add_argument("--host", nargs="?", default=False)

# Check for a local configuration
list_output = {}
host_output = {}
if os.path.exists(localconfig_fn):
    try: 
        localconfig = yaml.load(open(localconfig_fn,"r").read())
    except Exception, e:
        sys.stderr.write("WARNING: Could not parse %s. Error text was '%s'\n" % (localconfig_fn,e))
        sys.exit(EBADFILE)
    else:
        if localconfig.has_key("groups"):
            for group in localconfig["groups"]:
                if group == "default":
                    continue
                list_output[group] = { "hosts": [ "127.0.0.1" ] }

        if localconfig.has_key("vars"):
            host_output.update(localconfig["vars"])

# Defaults and best guesses...
if len(list_output) == 0:
    # If no explicit groups are given, 
    # naively assume that any ARM machine
    # counts as a Cubietruck for provisioning
    if "arm" in platform.machine():
        default_group = "cubietruck"
    else:
        default_group = "default"
    list_output = { default_group : { "hosts" : [ "127.0.0.1" ] } }

# Do the deed
args = parser.parse_args()
if args.list:
    print json.dumps(list_output, indent=2)
elif args.host:
    print json.dumps(host_output, indent=2)
