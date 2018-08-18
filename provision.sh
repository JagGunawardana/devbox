#!/bin/bash

sudo apt-get update && sudo apt-get dist-upgrade --yes && sudo apt-get autoclean && sudo apt-get autoremove
sudo apt-get -y install tmux zip zsh

sudo apt-get -y install irssi pandoc texlive-fonts-recommended vim
sudo apt-get -y install nodejs ruby ruby-dev apt-transport-https build-essential ca-certificates default-jdk fonts-cmu fonts-dejavu
sudo apt-get -y install libmysqlclient-dev mysql-client mysql-server postgresql-10 libpq-dev
sudo apt-get -y install build-essential cmake g++ libffi-dev libssl-dev libxml2-dev libxslt-dev libyaml-dev
sudo apt-get -y install openssl pkg-config zlibc zlib1g-dev
sudo apt-get -y install python-dev python-pip
sudo apt-get -y install fortunes

sudo locale-gen en_GB.UTF-8

###################### Sort out file permissions

for i in /home/vagrant/.hostssh/*; do
	test -f /home/vagrant/.ssh/$(basename $i) || cat $i >> /home/vagrant/.ssh/$(basename $i)
done

chmod 600 /home/vagrant/.ssh/*
chmod 700 /home/vagrant/.ssh
chown -R vagrant:vagrant /home/vagrant/.ssh
find . -maxdepth 1 -type f  -exec chown vagrant:vagrant {} \; -name ".*"
mkdir -p /home/vagrant/tmp && chown -R vagrant:vagrant /home/vagrant/tmp
mkdir -p /home/vagrant/bin && chown -R vagrant:vagrant /home/vagrant/bin

###################### Vagrant user
chsh -s /bin/zsh vagrant
usermod -a -G docker,sudo,root vagrant

###################### Env from host
if [ -f /home/vagrant/host_home/.zshenv ]; then
	cp /home/vagrant/host_home/.zshenv /home/vagrant
	chown vagrant:vagrant /home/vagrant/.zshenv
fi

###################### AWS creds from host
if [ -f /home/vagrant/host_home/.aws ]; then
	cp -r /home/vagrant/host_home/.aws /home/vagrant
	chown vagrant:vagrant /home/vagrant/.aws
fi

###################### ZSH
test -d /home/vagrant/.oh-my-zsh || git clone https://github.com/robbyrussell/oh-my-zsh.git /home/vagrant/.oh-my-zsh
chown -R vagrant:vagrant /home/vagrant/.oh-my-zsh

###################### EMacs
test -d /home/vagrant/.emacs.d || git clone https://github.com/JagGunawardana/ohai-emacs /home/vagrant/.emacs.d
cp -r /home/vagrant/.emacs/* /home/vagrant/.emacs.d
rm -rf .emacs
if  [ ! -d /home/vagrant/tmp/snippets ]; then
	git clone https://github.com/JagGunawardana/yasnippet-snippets.git /home/vagrant/tmp/snippets
	cp -r /home/vagrant/tmp/snippets/snippets /home/vagrant/.emacs.d
fi
add-apt-repository ppa:ubuntu-elisp/ppa
apt-get update
sudo apt-get -y install emacs-snapshot emacs-snapshot-el
chown -R vagrant:vagrant /home/vagrant/.emacs.d

###################### VIM
if  [ ! -d /home/vagrant/.vim/bundle ]; then
	mkdir -p /home/vagrant/.vim/bundle
	git clone https://github.com/VundleVim/Vundle.vim.git /home/vagrant/.vim/bundle/vundle
	chown -R vagrant:vagrant /home/vagrant/.vim
	su -c "echo | echo | vim +PluginInstall +GoInstallBinaries +qall > /dev/null" vagrant
fi


###################### Golang
if [ ! -d /home/vagrant/work/go ]; then
	cd /home/vagrant/tmp
	wget https://dl.google.com/go/go1.10.3.linux-amd64.tar.gz
	echo "fa1b0e45d3b647c252f51f5e1204aba049cde4af177ef9f2181f43004f901035  go1.10.3.linux-amd64.tar.gz" > /home/vagrant/tmp/SUM
	cat /home/vagrant/tmp/go1.10.3.linux-amd64.tar.gz | sha256sum -c /home/vagrant/tmp/SUM
	if [ $? -eq 0 ]; then
		tar -C /usr/local -xzf /home/vagrant/tmp/go1.10.3.linux-amd64.tar.gz
		ln -fs /usr/local/go/bin/go /usr/bin
	fi
	mkdir -p /home/vagrant/work/go/src
	chown -R vagrant:vagrant /home/vagrant/work
	rm /home/vagrant/tmp/SUM /home/vagrant/tmp/go1.10.3.linux-amd64.tar.gz
	su -c "go get -u github.com/nsf/gocode" vagrant
	su -c "go get -u golang.org/x/tools/cmd/guru" vagrant
	su -c "go get -u golang.org/x/tools/cmd/goimports" vagrant
	su -c "go get -u google.golang.org/grpc" vagrant
	su -c "go get -u github.com/golang/protobuf/..." vagrant
	su -c "go get -u github.com/rogpeppe/godef" vagrant
	su -c "go get -u github.com/smartystreets/goconvey" vagrant
fi

if [ ! -f /home/vagrant/bin/terraform ]; then
	cd /home/vagrant/tmp
	wget https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.7_linux_amd64.zip
	echo "6b8ce67647a59b2a3f70199c304abca0ddec0e49fd060944c26f666298e23418 terraform_0.11.7_linux_amd64.zip" > /home/vagrant/tmp/SUM
	cat /home/vagrant/tmp/terraform_0.11.7_linux_amd64.zip | sha256sum -c /home/vagrant/tmp/SUM
	if [ $? -eq 0 ]; then
		unzip /home/vagrant/tmp/terraform_0.11.7_linux_amd64.zip -d /home/vagrant/bin
	fi
	chown -R vagrant:vagrant /home/vagrant/bin
	rm /home/vagrant/tmp/SUM /home/vagrant/tmp/terraform_0.11.7_linux_amd64.zip
fi

if [ ! -f /home/vagrant/bin/packer ]; then
	cd /home/vagrant/tmp
	wget https://releases.hashicorp.com/packer/1.2.5/packer_1.2.5_linux_amd64.zip
	echo "bc58aa3f3db380b76776e35f69662b49f3cf15cf80420fc81a15ce971430824c  packer_1.2.5_linux_amd64.zip" > /home/vagrant/tmp/SUM
	cat /home/vagrant/tmp/packer_1.2.5_linux_amd64.zip | sha256sum -c /home/vagrant/tmp/SUM
	if [ $? -eq 0 ]; then
		unzip /home/vagrant/tmp/packer_1.2.5_linux_amd64.zip -d /home/vagrant/bin
	fi
	chown -R vagrant:vagrant /home/vagrant/bin
	rm /home/vagrant/tmp/SUM /home/vagrant/tmp/packer_1.2.5_linux_amd64.zip
fi

if [ ! -f /home/vagrant/bin/lein ]; then
	cd /home/vagrant/bin
	wget https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein
	chmod a+x /home/vagrant/bin/lein
	chown -R vagrant:vagrant /home/vagrant/bin
	su -c "/home/vagrant/bin/lein" vagrant
fi
