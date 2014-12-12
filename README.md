## What is it?
Vagrant + Ansible config for provisioning a virtual machine.

The idea is to do an automated provision a VM using [ansible](http://ansible.com) and [vagrant](http://www.vagrantup.com), then use that VM as a base to create an ISO using a customized version of the sadly now quasi-defunct [remastersys](https://en.wikipedia.org/wiki/Remastersys).

## How do I use it?
1. Install the dependencies:
 * Vagrant
 * Virtualbox
 * Ansible
2. Clone this repo
3. (optional) Modify `ansible/config.yml` to enable and disable modules (see below) by setting `MODULE_NAME__enabled`
  * Please **DO NOT** commit changes to this file. You can prevent git from commiting your changes by running `git update-index --assume-unchanged config.yml` (yes, we need to implement a better way to deal with this)
  * You can also use this file to override any other setting in `roles/*/vars/main.yml`
3. In the repo dir, run `vagrant up`
  * **Note:** This starts with a very basic Ubuntu VM and then installs a bunch of stuff e.g. Gnome, so expect the initial provisioning to take a *long* time!
4. Do either of the following:
  * *Build ISO as part of provisioning*: 
    1. In the repo dir, edit `config.yml` and set `build_iso__enabled: true`
    1. Run `vagrant provision`
  * *Build ISO later*:
    1. Mess around, experiment with the scripts, etc
    1. Run `vagrant provision`
    1. Repeat previous steps as necessary
    1. When you are ready to build the iso, connect to the VM with `vagrant ssh`
    1. On the VM, run `sudo /vagrant/data/build/remastersys/bin/remastersys backup`

If all goes well, a new ISO image will be created in `/vagrant/data/build` (aka `*repo_dir*/data/build` on the host system).


## How do I add a module to it?
A "module" is an ansible role that deploys a particular service or configuration

1. Create a new [ansible role](http://docs.ansible.com/playbooks_roles.html#roles) directory in `ansible/roles/`
  * Be sure to make any [variables](http://docs.ansible.com/playbooks_variables.html) defined in your role's `vars/` directory follow the format `MODULE_NAME__VAR_NAME` (note the two underscores in the middle)
  * Be sure to include a `MODULE_NAME__enabled` variable.
2. Add a line to `ansible/main.yml`, following the format used for other roles in that file.
  * *DO NOT* make your role execute unconditionally. Always use a `__enabled` variable!
