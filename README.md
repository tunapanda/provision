## What is it?
Vagrant + Ansible config for provisioning a virtual machine.

The idea is to do an automated provision a physical machine or a VM using [ansible](http://ansible.com) and [vagrant](http://www.vagrantup.com). The provisioned system can then optionally be used to generate a bootable ISO using a customized version of the sadly now quasi-defunct [remastersys](https://en.wikipedia.org/wiki/Remastersys).

## How do I use it?
See the [Setup document](https://github.com/tunapanda/provision/wiki/Setup)

## How do I add to it?
### Adding a new role
A "role" is a collection of Ansible settings and instructions that deploy a particular service or configuration

1. Create a new [ansible role](http://docs.ansible.com/playbooks_roles.html#roles) directory in `playbooks/roles/`
  * Be sure to make any [variables](http://docs.ansible.com/playbooks_variables.html) defined in your role's `defaults/` directory follow the format `MODULE_NAME__VAR_NAME` (*note the two underscores in the middle*)
  * Don't forget to define [dependencies](http://docs.ansible.com/playbooks_roles.html#role-dependencies) if your role has them.
2. Test your role:
  3. Create a `localconfig.yml` file (use `localconfig.yml.defaults` as a template)
  4. Set `profile` to `dynamic`
  5. In the `vars` section, add `YOU_ROLE_NAME__enabled: true` to the vars section
  6. Follow the setup instructions linked above to provision a fresh VM
