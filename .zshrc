# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="agnoster"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

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

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

## git completion
zstyle ':completion:*:*:git:*' script ~/.zsh/git-completion.bash
fpath=(~/.zsh $fpath)

autoload -Uz compinit && compinit


# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

source $HOME/.rvm/scripts/rvm

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

## rvm use ##
FILERUBY=.ruby-version
if [ -f "$FILERUBY" ]; then
  rvm use
fi

## nvm use ##
## RAM="ON" to turn RAM on

# place this after nvm initialization!
autoload -U add-zsh-hook
load-nvmrc() {
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$(nvm version)" ]; then
      nvm use
    fi
  elif [ -n "$(PWD=$OLDPWD nvm_find_nvmrc)" ] && [ "$(nvm version)" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc
# ZSH - Use this when ZSH is your standard shell
function gkube() {
  if [[ -z $2 ]]; then
    export PPORT=8888
    echo "No proxy port specified. Defaulting to proxy port ${PPORT}."
  else
    export PPORT=$2
    echo "Setting proxy port from passed argument."
  fi
  if [ -z $1 ]
  then
    echo "Need a service namespace argument such as staging-bluq, sandbox-bluq, or production-bluq"
  else
    export GCPENV="${1%%-*}"
    unset HTTPS_PROXY
    gcloud container clusters get-credentials gke-cluster-optoro-$GCPENV-service --region us-central1 --project optoro-$GCPENV-service
    ps aux | grep localhost:${PPORT} | grep -v grep | awk '{print $2}' | xargs kill
    gcloud compute ssh bastion-optoro-$GCPENV-service --project optoro-$GCPENV-service --zone us-central1-a --tunnel-through-iap -- -L ${PPORT}:localhost:8888 -N -q -f
    # test if yq is installed. Must be yq (https://github.com/mikefarah/yq/) version 4.16.1 or higher
    command -v yq >/dev/null 2>&1 || { echo >&2 "yq is not installed or not in PATH.  Aborting."; kill -INT $$ }
    yq eval 'with(.clusters[] |select(.name == "gke_optoro-"+env(GCPENV)+"*"); .cluster.proxy-url = "http://localhost:"+env(PPORT))' -i ~/.kube/config
    kubectl config use-context gke_optoro-$GCPENV-service_us-central1_gke-cluster-optoro-$GCPENV-service
    echo "\U2705 Current context $1"
    kubectl config set-context --current --namespace=$1
  fi
}

alias sz='source ~/.zshrc'

#---k8s---

# kubectl functions
# Usage:
#   kgetpod web
#   kgetpod metrics
function kgetpod() {
  if [[ -z $1 ]]; then
    k get pods | grep web | head -n 1 | cut -c1-50 | xargs
  else
    k get pods | grep $1 | head -n 1 | cut -c1-50 | xargs
  fi
}

# Usage:
#   kexec web-deployment-688b76c4cc-9lxhk bundle exec rails c
function kexec() {
  k exec -it $1 -- ${@:2}
}

# Usage:
#   kexecpod web bundle exec rails c
function kexecpod() {
  k exec -it $(kgetpod $1) -- ${@:2}
}

# Usage:
#   kexecpod web bundle exec rails c
function kr() {
  k exec -it $(kgetpod) -- bundle exec rails c
}

# Usage:
#   kbash web-deployment-688b76c4cc-9lxhk
#   can use this to get into node apps
function kbash() {
  k exec -it $(kgetpod) -- sh
}

# Usage:
#   kcpfile web random_stuf.csv
#   kcpfile db hello.sql
function kcp() {
  k cp $1 "$(kgetpod):/app/$2"
}

# # Usage:
# #   kcpfile web random_stuf.csv
# #   kcpfile db hello.sql
# function kcpfilein() {
#   kcp "$(kgetpod $1):/app/$2" ./$2
# }

function kgetpodworker() {
  k get pods --selector=queue=low_priority_alt_channels_worker
}

# Usage:
#   kstartrtvworkersinwebpods web
#   kstartrtvworkersinwebpods app-worker
function kstartrtvworkersinwebpods() {
  k get pod -l service=$1 -o=name | cut -c5-100 | while read line
  do
    kexec $line bundle exec rake resque:work QUEUE=alt_channels_worker,low_priority &
  done
}

# sets production or non-prod for config
# or manually k config use-context "production-inventory" or something of the sort.
function kns() {
  if [[ $1 =~ ^production ]]; then
    kubectl config use-context prod
  else
    kubectl config use-context non-prod
  fi
  kubectl config set-context --current --namespace="$1"
}

# k get pods, get last, copy name, and use as $1 here
function krails() {
  k exec -it $1 -- bundle exec rails c
}

function kcon(){
  k config use-context $1
}

function kinit() {
  gke $1
  k config use-context $1-$2
}

## git functions
function gcoma() {
  g add .
  g commit -m "$1"
}

function gcom() {
  g commit -m "$1"
}

function gbranchdelete {
  git branch -D $1
  git push origin --delete $1
}

function rtest {
  rub
  rspec
}

function rsp {
  NO_COVERAGE=true be rspec -fp $1 --no-profile
}

function ebase64 {
  echo "$1" | base64
}

## Git checkout file

function gchf {
  g checkout develop -- $1
}

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/mgulson/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/mgulson/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/mgulson/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/mgulson/google-cloud-sdk/completion.zsh.inc'; fi
export PATH="/usr/local/opt/mysql@5.7/bin:$PATH"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# VS Code Terminal

[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"


## Aliases
alias ga='git add'
alias gchb='git checkout -b'
alias gch='git checkout'
alias kafka='zookeeper-server-start /usr/local/etc/kafka/zookeeper.properties & kafka-server-start /usr/local/etc/kafka/server.properties # start kafka and solves the connection error'
alias redis='redis-server'
alias memcache='brew services start memcached'
alias restart-sql='brew services restart mysql@5.7'
alias rs='bundle exec rails s'
alias rc='bundle exec rails c'
alias r='source ~/.zshrc'
alias pg_start="launchctl load ~/Library/LaunchAgents"
alias pg_stop="launchctl unload ~/Library/LaunchAgents"
alias k="kubectl"
alias gpush='git push'
alias gpull='git pull'
alias stubauth='git checkout HARDCODE-WT-3876-auth -- app/controllers/auth_client_controller.rb'
alias unstubauth='git checkout  -- app/controllers/auth_client_controller.rb'
alias be='bundle exec'
alias rubdiff='be rake test:diff'
alias auth='INTERNAL_API_KEY=not_real_key_123 rs'
alias rdb='bundle exec rails db'
alias rmigrate='be rake db:migrate'
alias oneshot='bundle exec rails r'
alias gbranchrename='git branch -m'
alias gbranchd='gbranchdelete'
alias gbranchr='git branch -m'
alias gclone='git clone'
alias rub='rubocop -a'
alias py='python3'
alias keditsecret='k edit secret pgcluster-secret'
alias kes='k edit secret pgcluster-secret'



#This is dangerously close to kgetpod which is a function maybe delete later
alias kgetpods='k get pods'
alias opticsw='npx gulp watch -c'
alias opticsb='npx gulp build -c'