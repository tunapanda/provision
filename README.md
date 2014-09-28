## What is it?
Vagrant + Ansible config for provisioning a virtual machine.

The idea is to provision, then use that system as a base to create an ISO.

**Note:** The data/ dir contains everything needed to provision the server, including .deb packages and ansible plays. The data/ dir is shared to the VM as /usr/local/tunapanda/, which means it will be included in an install ISO made with e.g. remastersys. Result: to update an offline server, just rsync updated content into /usr/local/tunapanda/ and re-run ansible!

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

