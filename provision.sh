#!/bin/zsh

sudo apt-get update && sudo apt-get dist-upgrade --yes && sudo apt-get autoclean && sudo apt-get autoremove
sudo apt-get -y install tmux zip zsh

sudo apt-get -y install irssi pandoc texlive-fonts-recommended vim rlwrap
sudo apt-get -y install ruby ruby-dev apt-transport-https build-essential ca-certificates default-jdk fonts-cmu fonts-dejavu
sudo apt-get -y install libmysqlclient-dev mysql-client mysql-server postgresql-10 libpq-dev postgis
sudo apt-get -y install build-essential cmake g++ libffi-dev libssl-dev libxml2-dev libxslt-dev libyaml-dev ntp jq
sudo apt-get -y install openssl pkg-config zlibc zlib1g-dev
sudo apt-get -y install python-dev-is-python3 python3-pip
sudo apt-get -y install phantomjs httpie
sudo apt-get -y install fortunes figlet
sudo apt-get -y install redis-server mongodb
sudo apt-get -y install fonts-powerline
sudo apt-get -y install awscli
sudo snap install --classic heroku

# Chrome headless
sudo apt-get install -y libappindicator1 fonts-liberation
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome*.deb

sudo locale-gen en_GB.UTF-8

###################### Sort out file permissions

for i in /home/vagrant/.hostssh/*; do
	test -f /home/vagrant/.ssh/$(basename $i) || cat $i >> /home/vagrant/.ssh/$(basename $i)
done

echo "... Copied keys"

echo "Setting SSH permissions....."
chmod 600 /home/vagrant/.ssh/*
chmod 700 /home/vagrant/.ssh

echo ".. key perms"

chown -R vagrant:vagrant /home/vagrant/.ssh

echo "Setting cloud dir owners....."
chown -R vagrant:vagrant /home/vagrant/.aws
chown -R vagrant:vagrant /home/vagrant/.gcp

echo "Setting dirs ....."
mkdir -p /home/vagrant/tmp && chown -R vagrant:vagrant /home/vagrant/tmp
mkdir -p /home/vagrant/bin && chown -R vagrant:vagrant /home/vagrant/bin
touch /home/vagrant/.z && chown vagrant:vagrant /home/vagrant/.z

###################### Vagrant user
echo "Varant user shell ...."
chsh -s /bin/zsh vagrant
usermod -a -G docker,sudo,root vagrant

echo "Vagrant git ....."
su -c "git config --global url.\"git@github.com:\".insteadOf \"https://github.com/\"" vagrant
su -c "git config --global url.\"git@gitlab.com:\".insteadOf \"https://gitlab.com/\"" vagrant

###################### Env from host
echo "Host env ..."
ls -al /home/vagrant/host_home
if [ -f /home/vagrant/host_home/.zshenv ]; then
	echo "Copying host env ....."
	ls -al /home/vagrant/host_home
	cp /home/vagrant/host_home/.zshenv /home/vagrant
	chown vagrant:vagrant /home/vagrant/.zshenv
fi

###################### AWS creds from host
echo "AWS creds ..."
if [ -d /home/vagrant/host_home/.aws ]; then
	cp -r /home/vagrant/host_home/.aws /home/vagrant
	chown vagrant:vagrant /home/vagrant/.aws
fi

###################### ZSH
echo "ZSH ..."
test -d /home/vagrant/.oh-my-zsh || git clone https://github.com/robbyrussell/oh-my-zsh.git /home/vagrant/.oh-my-zsh
chown -R vagrant:vagrant /home/vagrant/.oh-my-zsh

###################### Python

pip install virtualenv
pip install virtualenvwrapper

###################### Node
echo "Node ....."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - &&\
    sudo apt-get install -y nodejs npm
sudo npm install -g shadow-cljs karma-cli

###################### ZSH
###################### EMacs
echo "EMACS ..."
test -d /home/vagrant/.emacs.d || git clone https://github.com/JagGunawardana/ohai-emacs /home/vagrant/.emacs.d
cp -r /home/vagrant/.emacs/* /home/vagrant/.emacs.d
rm -rf .emacs
if  [ ! -f /home/vagrant/.emacs.d/snippets/flagfile ]; then
	rm -rf /home/vagrant/tmp/snippets
	git clone https://github.com/JagGunawardana/yasnippet-snippets.git /home/vagrant/tmp/snippets
	cp -r /home/vagrant/tmp/snippets/snippets /home/vagrant/.emacs.d
	rm -rf /home/vagrant/tmp/snippets
	add-apt-repository ppa:ubuntu-elisp/ppa
	apt-get update
	sudo apt-get -y install emacs-snapshot emacs-snapshot-el
	chown -R vagrant:vagrant /home/vagrant/.emacs.d
fi
if [ ! -d /home/vagrant/.emacs.d/downloads ]; then
	su -c "mkdir /home/vagrant/.emacs.d/downloads" vagrant
	su -c "wget -O /home/vagrant/.emacs.d/downloads/dired+.el https://www.emacswiki.org/emacs/download/dired%2b.el" vagrant
fi

###################### VIM
echo "VIM ...."
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
    if [ -e ${dest}/$service ]; then
        echo "Service $service present in $dest - exiting"
        return 0
    fi
    echo "Downloading $url, checksum should be $checksum"
    filename=$(basename $url)
    rm -f $filename SUM
    wget -nv $url
    echo "$checksum  $filename" > ./SUM
    cat $filename | sha256sum -c ./SUM
    if [ $? -ne 0 ]; then
        echo "Failed to verify checksum for $service"
        exit 1
    fi
    echo "Checksum for $service OK"
    if [[ ${filename: -4}  == ".zip" ]]; then
	echo "Expanding $filename - ZIP"
        unzip -o $filename  -d $dest
        chown -R vagrant:vagrant $dest/*
        chmod +x $dest/*
    fi
    if [[ ${filename: -7} == ".tar.gz" ]]; then
	echo "Expanding $filename - GZIP"
        mv $filename  $dest
        cd $dest && tar zxvf $filename  $service
        chown -R vagrant:vagrant $dest/*
    fi
    rm -f SUM $filename
}

# Nomad

load_bin "https://releases.hashicorp.com/nomad/0.8.5/nomad_0.8.5_linux_amd64.zip" "e56c0e95e7a724b4fadd8eba32da5a3f2846f67e22e2352b19d1ada2066e063b" nomad /home/vagrant/bin

# Terraform
load_bin "https://releases.hashicorp.com/terraform/1.5.1/terraform_1.5.1_linux_amd64.zip" "31754361a9b16564454104bfae8dd40fc6b0c754401c51c58a1023b5e193aa29" terraform /home/vagrant/bin

# Packer

load_bin "https://releases.hashicorp.com/packer/1.2.5/packer_1.2.5_linux_amd64.zip" "bc58aa3f3db380b76776e35f69662b49f3cf15cf80420fc81a15ce971430824c" packer /home/vagrant/bin

# docker-compose

sudo curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Google cloud SDK

#load_bin "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-255.0.0-linux-x86_64.tar.gz" 18fcbc81b3b095ff5ef92fd41286a045f782c18d99a976c0621140a8fde3fbad google-cloud-sdk /home/vagrant/bin
#test -L /home/vagrant/bin/gcloud || chmod +x /home/vagrant/bin/google-cloud-sdk/install.sh && su -c "/home/vagrant/bin/google-cloud-sdk/install.sh" vagrant && su -c "ln -s /home/vagrant/bin/google-cloud-sdk/bin/gcloud /home/vagrant/bin/gcloud" vagrant
#test -L /home/vagrant/bin/kubectl || su -c "/home/vagrant/bin/gcloud components install kubectl" vagrant && su -c "ln -s /home/vagrant/bin/google-cloud-sdk/bin/kubectl /home/vagrant/bin/kubectl" vagrant
#test -L /home/vagrant/bin/gsutil || su -c "ln -s /home/vagrant/bin/google-cloud-sdk/bin/gsutil /home/vagrant/bin/gsutil" vagrant

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
	su -c "GOPATH=/home/vagrant/work/go go get -u github.com/mdempsky/gocode" vagrant
	su -c "GOPATH=/home/vagrant/work/go go get -u golang.org/x/tools/cmd/guru" vagrant
	su -c "GOPATH=/home/vagrant/work/go go get -u golang.org/x/tools/cmd/goimports" vagrant
	su -c "GOPATH=/home/vagrant/work/go go get -u google.golang.org/grpc" vagrant
	su -c "GOPATH=/home/vagrant/work/go go get -u github.com/golang/protobuf/..." vagrant
	su -c "GOPATH=/home/vagrant/work/go go get -u github.com/rogpeppe/godef" vagrant
	su -c "GOPATH=/home/vagrant/work/go go get -u github.com/smartystreets/goconvey" vagrant
	su -c "GOPATH=/home/vagrant/work/go go get -u github.com/mna/pigeon" vagrant
fi

###################### Clojure

if [ ! -f /home/vagrant/bin/lein ]; then
	cd /home/vagrant/bin
	wget -q https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein
	chmod a+x /home/vagrant/bin/lein
	chown -R vagrant:vagrant /home/vagrant/bin
	su -c "/home/vagrant/bin/lein" vagrant
	# Install clojure-lsp
	sudo bash < <(curl -s https://raw.githubusercontent.com/clojure-lsp/clojure-lsp/master/install)
fi

if [ ! -f /home/vagrant/bin/linux-install-1.11.1.1224.sh ]; then
        cd /home/vagrant/bin
	wget -q https://download.clojure.org/install/linux-install-1.11.1.1224.sh
	chmod a+x /home/vagrant/bin/linux-install-1.11.1.1224.sh
	chown -R vagrant:vagrant /home/vagrant/bin-1.11.1.1224.sh
	sudo /home/vagrant/bin/linux-install-1.11.1.1224.sh
fi
