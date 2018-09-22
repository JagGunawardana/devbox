#!/bin/zsh

sudo apt-get update && sudo apt-get dist-upgrade --yes && sudo apt-get autoclean && sudo apt-get autoremove
sudo apt-get -y install tmux zip zsh

sudo apt-get -y install irssi pandoc texlive-fonts-recommended vim
sudo apt-get -y install nodejs ruby ruby-dev apt-transport-https build-essential ca-certificates default-jdk fonts-cmu fonts-dejavu
sudo apt-get -y install libmysqlclient-dev mysql-client mysql-server postgresql-10 libpq-dev
sudo apt-get -y install build-essential cmake g++ libffi-dev libssl-dev libxml2-dev libxslt-dev libyaml-dev
sudo apt-get -y install openssl pkg-config zlibc zlib1g-dev
sudo apt-get -y install python-dev python-pip
sudo apt-get -y install fortunes figlet
su -c "pip install awscli --upgrade --user" vagrant
[ -L /home/vagrant/bin/aws ] || ln -s /home/vagrant/.local/bin/aws /home/vagrant/bin/aws
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
if [ -d /home/vagrant/host_home/.aws ]; then
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
if  [ ! -f /home/vagrant/.emacs.d/snippets/flagfile ]; then
	rm -rf /home/vagrant/tmp/snippets
	git clone https://github.com/JagGunawardana/yasnippet-snippets.git /home/vagrant/tmp/snippets
	cp -r /home/vagrant/tmp/snippets/snippets /home/vagrant/.emacs.d
	rm -rf /home/vagrant/tmp/snippets
fi
add-apt-repository ppa:ubuntu-elisp/ppa
apt-get update
sudo apt-get -y install emacs-snapshot emacs-snapshot-el
chown -R vagrant:vagrant /home/vagrant/.emacs.d
if [ ! -d /home/vagrant/.emacs.d/downloads ]; then
	su -c "mkdir /home/vagrant/.emacs.d/downloads" vagrant
	su -c "wget -O /home/vagrant/.emacs.d/downloads/dired+.el https://www.emacswiki.org/emacs/download/dired%2b.el" vagrant
fi

###################### VIM

if  [ ! -d /home/vagrant/.vim/bundle ]; then
	mkdir -p /home/vagrant/.vim/bundle
	git clone https://github.com/VundleVim/Vundle.vim.git /home/vagrant/.vim/bundle/vundle
	chown -R vagrant:vagrant /home/vagrant/.vim
	su -c "echo | echo | vim +PluginInstall +GoInstallBinaries +qall > /dev/null" vagrant
fi

## Helper to download binaries and check the hash
load_bin() {
    if [ $# != 4 ]; then
        echo "Parameter error parameters ($# params), usage $0 URL sha256sum service_name dest"
        exit 1
    fi
    local url=$1
    local checksum=$2
    local service=$3
    local dest=$4
    if [ -f ${dest}/$service ]; then
        echo "Service $service present in $dest - exiting"
        exit 0
    fi
    echo "Downloading $url, checksum should be $checksum"
    rm -f $filename SUM
    wget $url
    filename=$(basename $url)
    echo "$checksum  $filename" > ./SUM
    cat $filename | sha256sum -c ./SUM
    if [ $? -ne 0 ]; then
        echo "Failed to verify checksum for $service"
        exit 1
    fi
    echo "Checksum for $service OK"
    if [[ ${filename:e} -eq "zip" ]]; then
        unzip -o $filename  -d $dest
        chown vagrant:vagrant $dest/*
        chmod +x $dest/*
    fi
    rm -f SUM $filename
}

# Nomad

load_bin "https://releases.hashicorp.com/nomad/0.8.5/nomad_0.8.5_linux_amd64.zip" "e56c0e95e7a724b4fadd8eba32da5a3f2846f67e22e2352b19d1ada2066e063b" nomad /home/vagrant/bin

# Terraform

load_bin "https://releases.hashicorp.com/terraform/0.11.8/terraform_0.11.8_linux_amd64.zip" "84ccfb8e13b5fce63051294f787885b76a1fedef6bdbecf51c5e586c9e20c9b7" terraform /home/vagrant/bin

# Packer

load_bin "https://releases.hashicorp.com/packer/1.2.5/packer_1.2.5_linux_amd64.zip" "bc58aa3f3db380b76776e35f69662b49f3cf15cf80420fc81a15ce971430824c" packer /home/vagrant/bin

###################### Golang
if [ ! -d /home/vagrant/work/go ]; then
	cd /home/vagrant/tmp
	wget https://dl.google.com/go/go1.11.linux-amd64.tar.gz
	echo "b3fcf280ff86558e0559e185b601c9eade0fd24c900b4c63cd14d1d38613e499  go1.11.linux-amd64.tar.gz" > /home/vagrant/tmp/SUM
	cat /home/vagrant/tmp/go1.11.linux-amd64.tar.gz | sha256sum -c /home/vagrant/tmp/SUM
	if [ $? -eq 0 ]; then
		tar -C /usr/local -xzf /home/vagrant/tmp/go1.11.linux-amd64.tar.gz
		ln -fs /usr/local/go/bin/go /usr/bin
	fi
	mkdir -p /home/vagrant/work/go/src
	chown -R vagrant:vagrant /home/vagrant/work
	rm /home/vagrant/tmp/SUM /home/vagrant/tmp/go1.11.linux-amd64.tar.gz
	su -c "go get -u github.com/mdempsky/gocode" vagrant
	su -c "go get -u golang.org/x/tools/cmd/guru" vagrant
	su -c "go get -u golang.org/x/tools/cmd/goimports" vagrant
	su -c "go get -u google.golang.org/grpc" vagrant
	su -c "go get -u github.com/golang/protobuf/..." vagrant
	su -c "go get -u github.com/rogpeppe/godef" vagrant
	su -c "go get -u github.com/smartystreets/goconvey" vagrant
fi

if [ ! -f /home/vagrant/bin/lein ]; then
	cd /home/vagrant/bin
	wget https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein
	chmod a+x /home/vagrant/bin/lein
	chown -R vagrant:vagrant /home/vagrant/bin
	su -c "/home/vagrant/bin/lein" vagrant
fi
