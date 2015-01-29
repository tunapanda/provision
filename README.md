## What is it?
Vagrant + Ansible config for provisioning a virtual machine.

The idea is to do an automated provision a physical machine or a VM using [ansible](http://ansible.com) and [vagrant](http://www.vagrantup.com). The provisioned system can then optionally be used to generate a bootable ISO using a customized version of the sadly now quasi-defunct [remastersys](https://en.wikipedia.org/wiki/Remastersys).

## How do I use it?
See the [Setup document](https://github.com/tunapanda/provision/wiki/Setup)

## How do I add a module to it?
A "module" is an ansible role that deploys a particular service or configuration

1. Create a new [ansible role](http://docs.ansible.com/playbooks_roles.html#roles) directory in `playbooks/roles/`
  * Be sure to make any [variables](http://docs.ansible.com/playbooks_variables.html) defined in your role's `defaults/` directory follow the format `MODULE_NAME__VAR_NAME` (*note the two underscores in the middle*)
  * Be sure to include a `MODULE_NAME__enabled` variable, set to `false`.
2. Test your module by creating a `localconfig.yml` (use `localconfig.yml.sample` as a template), and adding `MODULE_NAME__enabled: true` to the vars section. 
