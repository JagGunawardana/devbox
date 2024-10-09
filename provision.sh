#!/bin/zsh

##### resize the disk first

#sudo growpart /dev/sda 3
#sudo lvextend -l+100%FREE /dev/ubuntu-vg/ubuntu-lv
#sudo resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv

###### Install packages

sudo apt-get update && sudo apt-get dist-upgrade --yes && sudo apt-get autoclean && sudo apt-get autoremove
sudo apt-get -y install tmux zip zsh
sudo apt-get -y install irssi pandoc texlive-fonts-recommended vim rlwrap
sudo apt-get -y install apt-transport-https build-essential ca-certificates default-jdk fonts-cmu fonts-dejavu
sudo apt-get -y install libmysqlclient-dev mysql-client mysql-server postgresql-10 libpq-dev postgis postgresql-client
sudo apt-get -y install build-essential cmake g++ libffi-dev libssl-dev libxml2-dev libxslt-dev libyaml-dev ntp jq
sudo apt-get -y install openssl pkg-config zlibc zlib1g-dev
sudo apt-get -y install python-dev-is-python3 python3-pip
sudo apt-get -y install python3.12-venv
sudo apt-get -y install phantomjs httpie
sudo apt-get -y install fortunes figlet
sudo apt-get -y install redis-server mongodb
sudo apt-get -y install fonts-powerline
sudo apt-get -y install awscli
sudo snap install --classic emacs
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

###################### HTTPie

curl -SsL https://packages.httpie.io/deb/KEY.gpg | sudo gpg --dearmor -o /usr/share/keyrings/httpie.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/httpie.gpg] https://packages.httpie.io/deb ./" | sudo tee /etc/apt/sources.list.d/httpie.list > /dev/null
sudo apt update
sudo apt install httpie

###################### Java
sudo apt install -y wget apt-transport-https gpg
wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor | tee /etc/apt/trusted.gpg.d/adoptium.gpg > /dev/null
echo "deb https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list
apt update 
apt install temurin-21-jdk

###################### Node
sudo apt-get -y  install nodejs npm
sudo npm install -g shadow-cljs karma-cli

###################### EMacs
echo "EMACS ..."
test -d /home/vagrant/.emacs.d || git clone https://github.com/JagGunawardana/ohai-emacs /home/vagrant/.emacs.d
cp -r /home/vagrant/.emacs/* /home/vagrant/.emacs.d
rm -rf .emacs
chown -R vagrant:vagrant /home/vagrant/.emacs.d
python -m venv /home/vagrant/.emacs.d/venv
/home/vagrant/.emacs.d/venv/bin/python3 -m pip install semgrep
ln -s /home/vagrant/.emacs.d/venv/bin/semgrep /home/vagrant/bin/semgrep
if  [ ! -f /home/vagrant/.emacs.d/snippets/flagfile ]; then
	rm -rf /home/vagrant/tmp/snippets
	git clone https://github.com/JagGunawardana/yasnippet-snippets.git /home/vagrant/tmp/snippets
	cp -r /home/vagrant/tmp/snippets/snippets /home/vagrant/.emacs.d
	rm -rf /home/vagrant/tmp/snippets
fi

if [ ! -d /home/vagrant/.emacs.d/downloads ]; then
	su -c "mkdir /home/vagrant/.emacs.d/downloads" vagrant
	su -c "wget -O /home/vagrant/.emacs.d/downloads/dired+.el https://www.emacswiki.org/emacs/download/dired%2b.el" vagrant
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

# Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

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

curl -L -O https://github.com/clojure/brew-install/releases/latest/download/linux-install.sh
chmod +x linux-install.sh
sudo ./linux-install.sh

if [ ! -f /home/vagrant/bin/bbin ]; then
	curl -o- -L https://raw.githubusercontent.com/babashka/bbin/v0.2.1/bbin > /home/vagrant/bin/bbin && chmod +x /home/vagrant/bin/bbin
	curl -sLO https://raw.githubusercontent.com/babashka/babashka/master/install && chmod +x install && ./install --dir /home/vagrant/bin
fi

clojure -Ttools install-latest :lib com.github.seancorfield/clj-new :as clj-new

####################### AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install


####################### Kubectl 
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin

