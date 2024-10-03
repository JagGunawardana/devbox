# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.provider "vmware_desktop" do |vmware|
      vmware.gui = false
      vmware.allowlist_verified = true
      vmware.utility_certificate_path = "/opt/vagrant-vmware-desktop/certificates"
      vmware.vmx["memsize"] = "16384"
      vmware.vmx["numvcpus"] = "4"
    end
    config.vm.box = "bento/ubuntu-24.04"
    config.vm.box_version = "202407.22.0"
    config.vm.hostname = 'plato'
    config.vm.synced_folder "~/", "/home/vagrant/host_home"
    config.vm.network "private_network", ip: '10.2.0.12'
    config.ssh.forward_agent = true
    config.vm.provision "file",
    	source: "~/.ssh", 
	destination: "$HOME/.hostssh"

    config.vm.provision "file",
        source: "~/.aws",
	destination: "$HOME/.aws"

    config.vm.provision "file",
    	source: "./bin", 
	destination: "$HOME/bin"

    config.vm.provision "file",
    	source: "./.emacs.d",
	destination: "$HOME/.emacs"

    config.vm.provision "file",
    	source: "./dotfiles",
	destination: "$HOME"

    config.vm.provision "docker",
    	images: ["alpine"]

    config.vm.provision "shell",
        privileged: true,
    inline: "apt-get -y install zsh"

    config.vm.provision "shell",
    	privileged: true,
	path: "provision.sh"
end
