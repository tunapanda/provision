## What is it?
Vagrant + Ansible config for provisioning a virtual machine.

The idea is to provision, then use that system as a base to create an ISO.

*Note:* The data/ dir contains everything needed to provision the server, including .deb packages and ansible plays. The data/ dir is shared to the VM as /usr/local/tunapanda/, which means it will be included in an install ISO made with e.g. remastersys. Result: to update an offline server, just rsync updated content into /usr/local/tunapanda/ and re-run ansible!

## Beware
This is still very eary and mostly un-tested. Hopefully it will at least be enough to give people an idea of what it's supposed to do. 

## How do I use it?
1. Install the dependencies:
 * Vagrant
 * Virtualbox
 * Ansible
2. Clone this repo
3. In the repo dir, run `vagrant up`

*Note:* This starts with a very basic Ubuntu VM and then installs a bunch of stuff e.g. Gnome, so expect the initial provisioning to take a while!
