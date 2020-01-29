# devbox
Simple vagrant devbox, that gives a decent zsh, emacs, golang, python tmux etc....

## Setup

- Change anything in dotfiles, also emacs config (or .vimrc if you must)
- Alter provision.sh to suit
- On the host, make sure you have keys in ~/.ssh (and a config file for your ssh connections)
- In ~/.zshenv, you should have envs: GIT_USER_NAME, GIT_EMAIL, GITHUB_ORG, GITLAB_ORG etc.

## Create

1. Install Hashicorp Vagrant (https://vagrantup.com)
2. Install plugin: vagrant plugin install vagrant-vbguest, and vagrant plugin install vagrant-disksize
3. Run ```vagrant vbguest```
4. In root, run ```vagrant up```
5. Check for errors
6. Run ```vagrant ssh``` to login

## Notes

- Uses Bodil's excellent emacs setup (with a few small changes): https://github.com/bodil/ohai-emacs
- I was once a VIM user so the vim setup should be usable, but may need some modernising
- zsh is great when combined with oh-my-zsh
- The way I use this is to spin up an env, work in it, and regularly nuke it - avoid snowflakes
- If I want to make changes, I either change the provisioning and rerun, or nuke and rebuild - I try not to change this in the env - avoid snowflakes
- As I need other programming envs, I just add them in, rather than having separate boxes for each env
