## Local VM setup
If you are using a Vagrant VM, you will need to configure Vagrant to attach the USB drive to the VM instead of your host machine

1. Determine the serial number of your USB device by running `VBoxManage list usbhost`
1. Add the following to `~/.vagrant.d/Vagrantfile` (you may need to create this file):
```
# TODO: ':id' below will match any Vagrant VM. This is not optimal, but I 
# haven't yet figured out how to find the value it wants for a particular VM
# Patches welcome. ;)
Vagrant.configure(2) do |config|
  config.vm.provider "virtualbox" do |vb|
    vb.customize ['modifyvm', :id, '--usb', 'on']
    vb.customize ['usbfilter', 'add', '0', '--target', :id, '--name', 'tunapanda_usb', '--serialnumber', 'CEAF24FA']
  end
end
```

## Drive setup
For this module to work, you will need to do format the USB drive with the expected label:

*Note: these instructions assume that the USB drive is connected to a Linux box or VM*

1. Plug the device in
1. Determine what device name it uses: e.g. `sudo blkid`
1. Unmount it if it was auto-mounted: `sudo umount /dev/sdXY`
1. Format and label: `mkfs.ext4 -L DISKLABEL /dev/sdXY`
  * Note: DISKLABEL should match the `disklabel` property defined in `vars/main.yaml`

