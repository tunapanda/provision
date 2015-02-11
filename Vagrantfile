# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  config.vm.box = "hashicorp/precise64"
  config.vm.synced_folder ".", "/opt/tunapanda/provision"

  # These environment vars can be used to alter the behavior of
  # the bootstrapping script.
$script = <<SCRIPT
export PROVISION_BASE_DIR="#{ENV['PROVISION_BASE_DIR']}"
export PROVISION_CORE_REPO="#{ENV['PROVISION_CORE_REPO']}"
export PROVISION_CORE_DIR="#{ENV['PROVISION_CORE_DIR']}"
export PROVISION_CORE_PLAYBOOK="#{ENV['PROVISION_CORE_PLAYBOOK']}"
export PROVISION_CORE_INVENTORY="#{ENV['PROVISION_CORE_INVENTORY']}"
export PROVISION_CORE_VERSION="#{ENV['PROVISION_CORE_VERSION']}"
export PROVISION_BOOTSTRAP_DIR="#{ENV['PROVISION_BOOTSTRAP_DIR']}"
export PROVISION_BOOTSTRAP_PLAYBOOK="#{ENV['PROVISION_BOOTSTRAP_PLAYBOOK']}"
export PROVISION_BOOTSTRAP_INVENTORY="#{ENV['PROVISION_BOOTSTRAP_INVENTORY']}"
export PROVISION_BOOTSTRAP_FALLBACK_URL="#{ENV['PROVISION_BOOTSTRAP_FALLBACK_URL']}"
/opt/tunapanda/provision/scripts/bootstrap.sh
SCRIPT

  config.vm.provision "shell", inline: $script, keep_color: true
  #config.vm.provision "shell", path: "scripts/bootstrap.sh", keep_color: true

### Uncomment this block for the old vagrant-based ansible 
#  config.vm.provision "ansible" do |ansible|
#    ansible.verbose = "vvvv"
#    ansible.playbook = "playbooks/main.yml"
#    ansible.sudo = true
#  end

  config.vm.provider "virtualbox" do |vb|
    vb.gui = true
  end

  config.vm.provider :aws do |aws, override|
    aws.access_key_id = ENV['AWS_KEY']
    aws.secret_access_key = ENV['AWS_SECRET']
    aws.keypair_name = ENV['AWS_KEYNAME']
    override.ssh.private_key_path = ENV['AWS_KEYPATH']


    # http://cloud-images.ubuntu.com/locator/ec2/
    aws.ami = "ami-ecda6c84" # ubuntu 12.04 64

    # This one is a 2 years old experiment so it might not be so good
    # http://cloud.ubuntu.com/2012/05/ready-to-try-arm-on-the-cloud-try-it-on-amazon-ec2/
    # aws.ami = "ami-aef328c7" # ubuntu 12.04 arm image

    aws.region = "us-east-1"
    aws.instance_type = "m3.medium"

    aws.security_groups = ["Widely open"] # you have to add this security group on the selected region
    aws.tags = {
      'Name' => 'x2go',
    }
    override.ssh.username = "ubuntu"
    override.vm.box = "dummy"
    override.vm.box_url = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"
  end

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # If true, then any SSH connections made will enable agent forwarding.
  # Default value: false
  config.ssh.forward_agent = true

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  #config.vm.provider "virtualbox" do |vb|
    # Don't boot with headless mode
  #  vb.gui = true
  #
  #   # Use VBoxManage to customize the VM. For example to change memory:
  #   vb.customize ["modifyvm", :id, "--memory", "1024"]
  #end
  #
  # View the documentation for the provider you're using for more
  # information on available options.

  # Enable provisioning with CFEngine. CFEngine Community packages are
  # automatically installed. For example, configure the host as a
  # policy server and optionally a policy file to run:
  #
  # config.vm.provision "cfengine" do |cf|
  #   cf.am_policy_hub = true
  #   # cf.run_file = "motd.cf"
  # end
  #
  # You can also configure and bootstrap a client to an existing
  # policy server:
  #
  # config.vm.provision "cfengine" do |cf|
  #   cf.policy_server_address = "10.0.2.15"
  # end

  # Enable provisioning with Puppet stand alone.  Puppet manifests
  # are contained in a directory path relative to this Vagrantfile.
  # You will need to create the manifests directory and a manifest in
  # the file default.pp in the manifests_path directory.
  #
  # config.vm.provision "puppet" do |puppet|
  #   puppet.manifests_path = "manifests"
  #   puppet.manifest_file  = "site.pp"
  # end

  # Enable provisioning with chef solo, specifying a cookbooks path, roles
  # path, and data_bags path (all relative to this Vagrantfile), and adding
  # some recipes and/or roles.
  #
  # config.vm.provision "chef_solo" do |chef|
  #   chef.cookbooks_path = "../my-recipes/cookbooks"
  #   chef.roles_path = "../my-recipes/roles"
  #   chef.data_bags_path = "../my-recipes/data_bags"
  #   chef.add_recipe "mysql"
  #   chef.add_role "web"
  #
  #   # You may also specify custom JSON attributes:
  #   chef.json = { mysql_password: "foo" }
  # end

  # Enable provisioning with chef server, specifying the chef server URL,
  # and the path to the validation key (relative to this Vagrantfile).
  #
  # The Opscode Platform uses HTTPS. Substitute your organization for
  # ORGNAME in the URL and validation key.
  #
  # If you have your own Chef Server, use the appropriate URL, which may be
  # HTTP instead of HTTPS depending on your configuration. Also change the
  # validation key to validation.pem.
  #
  # config.vm.provision "chef_client" do |chef|
  #   chef.chef_server_url = "https://api.opscode.com/organizations/ORGNAME"
  #   chef.validation_key_path = "ORGNAME-validator.pem"
  # end
  #
  # If you're using the Opscode platform, your validator client is
  # ORGNAME-validator, replacing ORGNAME with your organization name.
  #
  # If you have your own Chef Server, the default validation client name is
  # chef-validator, unless you changed the configuration.
  #
  #   chef.validation_client_name = "ORGNAME-validator"
end


