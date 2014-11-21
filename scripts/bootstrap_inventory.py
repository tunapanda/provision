#!/usr/bin/python
import platform
import argparse
import json
import os

ansibledir = os.path.abspath(os.path.dirname(os.path.realpath(__file__)) + "/../ansible")
parser = argparse.ArgumentParser(description='Custom Ansible inventory generator')
parser.add_argument("--list", action="store_true", default=False)
parser.add_argument("--host", nargs="?", default=False)

groups = ["local"]
options = {}
def disable_all_roles():
    global options
    for role in os.listdir(ansibledir + "/roles"):
        if os.path.isdir(role):
            continue
        options[role + "__enabled"] = False

def config_cubietruck():
    enabled_roles = []
    #enabled_roles = ["kalite","wikipedia"]
    disable_all_roles()
    for role in enabled_roles:
        options[role + "__enabled"] = True
    groups.append("cubietruck")
    groups.append("wap")

# Naively assume that any ARM machine
# counts as a Cubietruck for provisioning
if "arm" in platform.machine():
    config_cubietruck()

args = parser.parse_args()
if args.list:
    results = {}
    for group in groups:
        results[group] = { "hosts" : ["127.0.0.1"] }
    print json.dumps(results, indent=2)
elif args.host:
    print json.dumps(options, indent=2)
