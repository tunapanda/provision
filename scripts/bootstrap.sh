#!/bin/bash

VERBOSITY="-v"
#VERBOSITY="-vvv"

## Basic I/O functions
function die() {
	echo ""
	echo "FATAL ERROR: $1" >&2
	echo ""
	exit 1
}

function note() {
	echo ""
	echo "NOTICE: $1" >&2
	echo ""
}

function step() {
	echo ""
	echo "== $1"
}

## Configs
# All of these can be overridden by setting them as environment vars
PROVISION_AUTO_UPDATE_REPO=${PROVISION_AUTO_UPDATE_REPO:-false}
PROVISION_AUTO_UPGRADE_PACKAGES=${PROVISION_AUTO_UPGRADE_PACKAGES:-false}
PROVISION_BASE_DIR=${PROVISION_BASE_DIR:-"/usr/local/tunapanda"}
PROVISION_CORE_REPO=${PROVISION_CORE_REPO:-"http://github.com/tunapanda/provision"}
PROVISION_CORE_DIR=${PROVISION_CORE_DIR:-"${PROVISION_BASE_DIR}/provision"}
PROVISION_CORE_VERSION="${PROVISION_CORE_VERSION:-}" # default to current branch or master if no repo
PROVISION_CORE_SCRIPT=${PROVISION_CORE_INVENTORY:-"${PROVISION_CORE_DIR}/scripts/provision.py"}
# The Bootstrap playbook is used for first-time setup of the provisioning system
PROVISION_BOOTSTRAP_DIR="${PROVISION_BOOTSTRAP_DIR:-$PROVISION_CORE_DIR}"
PROVISION_BOOTSTRAP_PLAYBOOK="${PROVISION_BOOTSTRAP_PLAYBOOK:=playbooks/bootstrap.yml}"
PROVISION_BOOTSTRAP_FALLBACK_URL="${PROVISION_BOOTSTRAP_FALLBACK_URL:-https://raw.githubusercontent.com/tunapanda/provision/${PROVISION_CORE_VERSION}/playbooks/bootstrap.yml}"
PROVISION_BOOTSTRAP_INVENTORY=$PROVISION_CORE_INVENTORY

## Other support functions
function has_internet() {
	if [ -z "$HAS_INTERNET" ]
	then
		step "Checking internet access" 
		if [ -f $PROVISION_CORE_DIR/scripts/has_internet ] 
		then
		    $PROVISION_CORE_DIR/scripts/has_internet
		else
			    ping -c1 -w5 www.google.com #&> /dev/null
		fi
		HAS_INTERNET=$?
		if [ $HAS_INTERNET -eq 0 ] 
		 then 
			note 'Internet access detected. Great!'
			HAS_INTERNET_STR=true
		else 
			note "No Internet access detected. Some steps will be skipped, and first-time setup may fail."
			HAS_INTERNET_STR=false
		fi
	fi
	return $HAS_INTERNET
}

function is_installed() {
	[ $# -eq 0 ] && return 2
	which $1 &> /dev/null
	return $?
}

function get_url() {
	if is_installed curl
	then
		curl -k -o - "$1" 
	elif is_installed wget
	then
		wget -O - "$1"
	elif is_installed elinks
	then
		elinks -dump "$1"
	else
		die "Cannot retrieve urls. Please install curl, wget, or elinks"
	fi
}

if [ $EUID -ne 0 ]
then
	die 'Must be run as root!'
fi

if has_internet 
then 
	# Update packages if the haven't been updated in the last 12 hours
	if [ $[ $(date +%s) - $(date -r /var/lib/apt/lists/ +%s) ] -gt $[ 60 * 60 * 12 ] ] 
	then
		step "Updating package list"
		apt-get update
	fi
else
    note 'No Internet connection detected. Updates will be skipped, and first-time deployment will fail!'
fi

if $PROVISION_AUTO_UPGRADE_PACKAGES && has_internet 
then
	step "Upgrading packages"
	apt-get upgrade -y
fi

step "Checking dependencies..."
if ! is_installed git
then
	has_internet || die "git is required, but we can't install it without a net connection"	
	step "Installing git"
	apt-get install -y git
fi

if ! is_installed pip 
then
	has_internet || die "Pip is required, but we can't install it without a net connection"	
	step "Installing pip dependencies"
	apt-get install -y python-dev 
	step "Getting pip"
	get_url 'https://bootstrap.pypa.io/get-pip.py' | python
	is_installed pip || die "Can't install pip. See: https://pip.pypa.io/en/latest/installing.html"
fi

if ! is_installed sshd 
then
	step "Installing ssh server"
	has_internet || die "An ssh server is required, but we can't install it without a net connection"	
	apt-get install -y openssh-server 
	is_installed sshd || die "Something when wrong installing the ssh server. Cannot continue."
fi

if ! is_installed ansible 
then
	step "Installing Ansible"
	has_internet || die "Ansible is required, but we can't install it without a net connection"	
	apt-get install -y python-dev && 
	pip install --upgrade 'ansible>=1.6'
fi
is_installed ansible || die "Something went wrong installing ansible. Cannot continue."

if [ -z "$PROVISION_CORE_VERSION" ]
then
    # If the repo has been checked out, use the current branch
    if [ -d ${PROVISION_CORE_DIR}/.git ]
    then
        pushd $PROVISION_CORE_DIR > /dev/null
        PROVISION_CORE_VERSION=$(basename $(git symbolic-ref HEAD))
        popd > /dev/null
    else
        PROVISION_CORE_VERSION="master"
    fi
fi

# Can't find repo. Probably a fresh install, so download the bootstrap playbook
if [ ! -e "$PROVISION_BOOTSTRAP_DIR/$PROVISION_BOOTSTRAP_PLAYBOOK" ]
then
	step "Bootstrapping playbook not found. Performing first-time setup..."
	has_internet || die "Can't find bootstrap playbook, but no net access, so can't retrieve it either"
	RAND=$RANDOM
	PROVISION_BOOTSTRAP_DIR="/tmp"
	PROVISION_BOOTSTRAP_PLAYBOOK="${RAND}bootstrap.yml"
	PROVISION_BOOTSTRAP_INVENTORY="${RAND}inventory.ini"
	get_url $PROVISION_BOOTSTRAP_FALLBACK_URL > $PROVISION_BOOTSTRAP_DIR/$PROVISION_BOOTSTRAP_PLAYBOOK
	cat > $PROVISION_BOOTSTRAP_DIR/$PROVISION_BOOTSTRAP_INVENTORY <<EOF
[localhost]
127.0.0.1
EOF
fi

## Removing this, because it breaks offline compatability, and it shouldn't be
## needed. Leaving commented for now as a TODO reminder.
# Cheap way to ensure that github's host key is known. Otherwise, even with the setting above,
# ansible may stall if it tries to update a repo with an ssh url
#ssh -o StrictHostKeyChecking=no git@github.com 'true' &> /dev/null
export ANSIBLE_HOST_KEY_CHECKING=false

# If auto-update is enabled, this will pull the latest from github
# ** potentially overwriting local changes!! **
if $PROVISION_AUTO_UPDATE_REPO && has_internet 
then
    step "Running bootstrap playbook"
    pushd ${PROVISION_BOOTSTRAP_DIR} > /dev/null
    ansible-playbook $VERBOSITY \
	-c local \
        -i $PROVISION_BOOTSTRAP_INVENTORY \
        -e "provision_ver=$PROVISION_CORE_VERSION provision_repo=$PROVISION_CORE_REPO provision_dir=$PROVISION_CORE_DIR" \
        $PROVISION_BOOTSTRAP_PLAYBOOK || die "Could not run bootstrap playbook"
    popd > /dev/null
fi

step 'Ready to start provisioning!'
if ${PROVISION_CORE_DIR}/scripts/provision.py
then
	echo ""
	echo '*** ALL DONE! ***'
	echo ""
else
	echo ""
	echo '!!! PROVISIONING FAILED !!!'
	echo ""
fi

