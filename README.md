## What is it?
Vagrant + Ansible config for provisioning a virtual machine.

The idea is to do an automated provision a VM using [ansible](ansible.com) and [vagrant](http://www.vagrantup.com), then use that VM as a base to create an ISO using the sadly now quasi-defunct [remastersys](https://en.wikipedia.org/wiki/Remastersys).

## How do I use it?
1. Install the dependencies:
 * Vagrant
 * Virtualbox
 * Ansible
2. Clone this repo
3. (optional) Modify `data/ansible/config.yml` to enable and disable modules
3. In the repo dir, run `vagrant up`
  * **Note:** This starts with a very basic Ubuntu VM and then installs a bunch of stuff e.g. Gnome, so expect the initial provisioning to take a *long* time!
4. Connect to the VM with `vagrant ssh`
5. Run `sudo /vagrant/data/build/remastersys/bin/remastersys backup`

If all goes well, a new ISO image will be created in `/vagrant/data/build` (aka `*repo_dir*/data/build` on the host system).

