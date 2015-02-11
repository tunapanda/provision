#!/bin/bash

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
PROVISION_AUTO_UPDATE=${PROVISION_AUTO_UPDATE:-true}
PROVISION_BASE_DIR=${PROVISION_BASE_DIR:-"/opt/tunapanda"}
## TODO: Change usernamenumber URLs back to tunapanda
PROVISION_CORE_REPO=${PROVISION_CORE_REPO:-"http://github.com/usernamenumber/provision"}
PROVISION_CORE_DIR=${PROVISION_CORE_DIR:-"${PROVISION_BASE_DIR}/provision"}
PROVISION_CORE_INVENTORY=${PROVISION_CORE_INVENTORY:-"${PROVISION_CORE_DIR}/scripts/inventory.py"}
PROVISION_CORE_VERSION="${PROVISION_CORE_VERSION:-}" # default to current branch or master if no repo
PROVISION_CORE_PLAYBOOK=${PROVISION_CORE_PLAYBOOK:-"${PROVISION_CORE_DIR}/playbooks/main.yml"}

CUSTOM_PLAYBOOK=${PROVISION_CORE_DIR}/custom.yml 
if [ -f $CUSTOM_PLAYBOOK ]
then
    note "Using custom playbook $CUSTOM_PLAYBOOK"
    PROVISION_CORE_PLAYBOOK=$CUSTOM_PLAYBOOK
fi

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
		curl -o - "$1" 
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

# Update packages if the haven't been updated in the last 12 hours
if has_internet && [ $[ $(date +%s) - $(date -r /var/lib/apt/lists/ +%s) ] -gt $[ 60 * 60 * 12 ] ] 
then
	step "Updating package list"
	apt-get update
fi

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
	apt-get install -y python-dev
fi
pip install --upgrade 'ansible>=1.6'
is_installed ansible || die "Something went wrong installing ansible. Cannot continue."

if [ ! -f /root/.ssh/provisioning ]
then
	step "Generating SSH keys for provisioning"

	# Fun fact: apparently you can't generate a new passwordless key, but you can make
	# it passwordless after creating it.
	# Note the 'from=127.0.0.1' in authorized_keys2. This key can only be used locally!
	ssh-keygen -f /root/.ssh/provisioning -N 1234567890 -q
	ssh-keygen -f /root/.ssh/provisioning -p -P 1234567890 -N '' -q
	echo $(cat ~/.ssh/provisioning.pub) from=127.0.0.1 >> ~/.ssh/authorized_keys2
	chmod go-rwx /root/.ssh/authorized_keys2
fi

step "Loading SSH keys"
eval `ssh-agent -s`
ssh-add /root/.ssh/provisioning
ssh-add -l
ssh -i /root/.ssh/provisioning -o StrictHostKeyChecking=no localhost echo 'User key works, host key added!'

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

PROVISION_BOOTSTRAP_DIR="${PROVISION_BOOTSTRAP_DIR:-$PROVISION_CORE_DIR}"
PROVISION_BOOTSTRAP_PLAYBOOK="${PROVISION_BOOTSTRAP_PLAYBOOK:=playbooks/bootstrap.yml}"
PROVISION_BOOTSTRAP_FALLBACK_URL="${PROVISION_BOOTSTRAP_FALLBACK_URL:-https://raw.githubusercontent.com/usernamenumber/provision/${PROVISION_CORE_VERSION}/playbooks/bootstrap.yml}"
PROVISION_BOOTSTRAP_INVENTORY=$PROVISION_CORE_INVENTORY
# Can't find repo. Probably a fresh install, so download the bootstrap playbook
if [ ! -e "$PROVISION_BOOTSTRAP_DIR/$PROVISION_BOOTSTRAP_PLAYBOOK" ]
then
	has_internet || die "Can't find bootstrap playbook, but no net access, so can't retrieve it either"
	RAND=$RANDOM
	PROVISION_BOOTSTRAP_DIR="/tmp"
	PROVISION_BOOTSTRAP_PLAYBOOK="${RAND}bootstrap.yml"
	PROVISION_BOOTSTRAP_INVENTORY="${RAND}inventory.ini"
	step "Provisioning repo not found. Downloading fallback playbook for bootstrapping."
	get_url $PROVISION_BOOTSTRAP_FALLBACK_URL > $PROVISION_BOOTSTRAP_DIR/$PROVISION_BOOTSTRAP_PLAYBOOK
	# TODO: Fix this quick and dirty hack
	get_url https://raw.githubusercontent.com/usernamenumber/provision/${PROVISION_CORE_VERSION}/playbooks/bootstrap_git.yml > bootstrap_git.yml || die "could not get bootstrap_git.yml"
	cat > $PROVISION_BOOTSTRAP_DIR/$PROVISION_BOOTSTRAP_INVENTORY <<EOF
[localhost]
127.0.0.1
EOF
    cat > $PROVISION_BOOTSTRAP_DIR/ansible.cfg <<EOF
[defaults]
host_key_checking=False
EOF
fi

export ANSIBLE_HOST_KEY_CHECKING=False
# Cheap way to ensure that github's host key is known. Otherwise, even with the setting above,
# ansible may stall if it tries to update a repo with an ssh url
ssh -o StrictHostKeyChecking=no git@github.com 'true' &> /dev/null

if $PROVISION_AUTO_UPDATE && has_internet 
then
    step "Running bootstrap playbook"
    pushd ${PROVISION_BOOTSTRAP_DIR} > /dev/null
    ansible-playbook -vvvv \
        -i $PROVISION_BOOTSTRAP_INVENTORY \
        -e "provision_ver=$PROVISION_CORE_VERSION provision_repo=$PROVISION_CORE_REPO provision_dir=$PROVISION_CORE_DIR" \
        $PROVISION_BOOTSTRAP_PLAYBOOK || die "Could not run bootstrap playbook"
    popd > /dev/null
else 
    note "No Internet, so skipping playbook updates"
fi

step "Generating roles.yml"
pushd ${PROVISION_CORE_DIR}/playbooks > /dev/null
cat > roles.yml <<EOF
---
### AUTO-GENERATED (changes will be lost) ###
- hosts: all
  handlers:
    - name: reload nginx
      service: name=nginx state=reloaded
    
  roles:
EOF
  for r in $(find roles/ -maxdepth 1 -mindepth 1 -type d -not -name provision_base)
  do
      f=$(basename $r);
      echo "    - { role: $f, when: ${f}__enabled is defined and ${f}__enabled }" >> roles.yml
  done
popd > /dev/null

step "Running core playbook, ${PROVISION_CORE_PLAYBOOK}"
pushd ${PROVISION_CORE_DIR}/playbooks > /dev/null
ansible-playbook -vvv \
    -i $PROVISION_CORE_INVENTORY \
    $PROVISION_CORE_PLAYBOOK || die "Could not run core playbook"
popd > /dev/null

echo ""
echo '*** ALL DONE! ***'
echo ""

