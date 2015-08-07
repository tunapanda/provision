## What is it?
Vagrant + Ansible config for provisioning a virtual machine.

The idea is to do an automated provision a physical machine or a VM using [ansible](http://ansible.com) and [vagrant](http://www.vagrantup.com). 

## How do I use it?
See the [Setup](https://github.com/tunapanda/provision/wiki/Setup) wiki page for details, but here's a quick-start guide to creating a VM with a default config plus some optional customization:

1. Install [Vagrant](http://vagrantup.com)
2. Clone this repo
  2. `git clone https://github.com/tunapanda/provision.git`
  2. `cd provision`
3. (optional) Customize the config
  4. `cp localconfig.yml.defaults localconfig.yml`
  5. Read the comments in that file and make whatever changes seem appropriate
4. Provision!
  1. `vagrant up`
  2. When provisioning completes, follow the instructions printed at the end to add a line to your `/etc/hosts` file (Windows users will have to figure out how to do this themselves, or just use the server's IP)
5. Investigate!
  6. Visit the server with your web browser, but note the following:
    * The search boxes on the portal page don't (yet) work without some manual configuration. See post-provisioning instructions in the [setup doc](https://github.com/tunapanda/provision/wiki/Setup). 
    * The provisioning process starts several background jobs that continue downloading content even after it "completes", so not all content will be there the first time you access the site.

## How do I add to it?
See the [Extending](https://github.com/tunapanda/provision/wiki/Extending-the-provisioning-system) wiki page. 
