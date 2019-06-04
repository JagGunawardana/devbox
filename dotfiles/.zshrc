# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="muse"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git docker postgres vi-mode python jsontools paver pep8 vagrant wd z terraform nomad golang lein emoji-clock chucknorris copyfile)

# User configuration

export GOPATH=~/work/go
export GO111MODULE=on

export PATH=~/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:~/bin:/usr/local/packer
export PATH=$PATH:/usr/local/go/bin:~/work/go/bin:$GOPATH/bin
export PATH=$PATH:~/bin/proto/bin

# For Phantom JS (cljs testing)
export QT_QPA_PLATFORM=offscreen

# export MANPATH="/usr/local/man:$MANPATH"

source $ZSH/oh-my-zsh.sh

# Emacs to edit (emacsclient)
export EDITOR=ef
bindkey -e
# Enable Ctrl-x-e to edit command line
autoload -U edit-command-line
# Emacs style
zle -N edit-command-line
bindkey '^xe' edit-command-line
bindkey '^x^e' edit-command-line


# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias tmux="TERM=screen-256color-bce tmux"
alias cls='printf "\033c"'
alias todo=~/bin/todo.txt_cli-2.10/todo.sh
alias ssh_unsafe='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no '

# Virtualenv wrapper
# export WORKON_HOME=~/.virtualenvs
# . /usr/local/bin/virtualenvwrapper.sh

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

function run_cov {
    coverage run --source "$1" -m py.test && coverage report
}

function clone_bitbucket {
    git clone git@bitbucket.org:${BITBUCKET_ORG}/$1.git
}

function clone_github {
    git clone git@github.com:${GITHUB_ORG}/$1.git
}

function clone_gitlab {
    git clone git@gitlab.com:${GITLAB_ORG}/$1.git
}


function sshagent {
    eval `ssh-agent -s`
    if [ -f ~/.ssh/id_rsa ]; then
        ssh-add ~/.ssh/id_rsa
    fi
}
function binpath {
    export PATH=$(pwd)/bin:$PATH
}

function ef()
{
  # -c creates a new frame
  # -a= fires a new emacs server if none is running
  emacsclient -c -a= $*
}

# Git settings - depends on having a .zshenv on the host
if [ ! -z "$GIT_USER_NAME" ]; then
	git config --global user.name "${GIT_USER_NAME}"
fi
if [ ! -z "$GIT_EMAIL" ]; then
	git config --global user.email "${GIT_EMAIL}"
fi
# If you want to use a different email for biz git then run the alias by "git biz" - per repo
if [ ! -z "$GIT_BIZ_EMAIL" ]; then
	git config --global alias.biz 'config user.email "${GIT_BIZ_EMAIL}"'
fi

git config --global url.ssh://git@bitbucket.org/.insteadOf https://bitbucket.org/
git config --global url.ssh://git@github.com/.insteadOf https://github.com/
git config --global push.default simple



bindkey '^R' history-incremental-search-backward
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line

sshagent > /dev/null

# Start tmux if not already running
if command -v tmux>/dev/null; then
  [[ ! $TERM =~ screen ]] && [ -z $TMUX ] && exec tmux
fi

figlet -f slant $(hostname)
fortune
