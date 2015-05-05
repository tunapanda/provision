## What is it?
Vagrant + Ansible config for provisioning a virtual machine.

The idea is to do an automated provision a physical machine or a VM using [ansible](http://ansible.com) and [vagrant](http://www.vagrantup.com). The provisioned system can then optionally be used to generate a bootable ISO using a customized version of the sadly now quasi-defunct [remastersys](https://en.wikipedia.org/wiki/Remastersys).

## How do I use it?
The very basics (test VM with default config):

1. Install [Vagrant](http://vagrantup.com)
2. Clone this repo
  2. `git clone https://github.com/tunapanda/provision/`
  2. `cd provision`
3. (optional) Customize the config
  4. `cp localconfig.yml.defaults localconfig.yml`
  5. Read the comments in that file and make whatever changes seem appropriate
4. Provision!
  1. `vagrant up`
  
See the [Setup](https://github.com/tunapanda/provision/wiki/Setup) wiki page for more.

## How do I add to it?
See the [Extending](https://github.com/tunapanda/provision/wiki/Extending-the-provisioning-system) wiki page. 
