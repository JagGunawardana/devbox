# devbox
Simple vagrant devbox, that gives a decent zsh, emacs, golang, python etc....

## Setup

Change anything in dotfiles, also emacs config (or .vimrc if you must)
Alter provision.sh to suit
On the host, make sure you have keys in ~/.ssh (and a config file)
In ~/.zshenv, you should have envs: GIT_USER_NAME, GIT_EMAIL

## Create

1. Install Hashicorp Vagrant (https://vagrantup.com)
2. In root, run ```vagrant up```
3. Check for errors
4. Run ```vagrant ssh```
