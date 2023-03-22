# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.box = "ubuntu/jammy64"
    config.disksize.size = "50GB"
    config.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--memory", "4096", "--cpus", "1"]
    end
    config.vbguest.auto_update = true
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
    	source: "~/.gcp", 
	destination: "$HOME/.gcp"

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
    	images: ["consul"]

    config.vm.provision "shell",
        privileged: true,
    inline: "apt-get -y install zsh"

    config.vm.provision "shell",
    	privileged: true,
	path: "provision.sh"

end
