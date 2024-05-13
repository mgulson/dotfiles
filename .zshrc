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
# under VCS as zfty. This makes repository status check for large repositories
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


export ZSH_DISABLE_COMPFIX=true

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
  if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

    autoload -Uz compinit
    compinit
  fi

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
      nvm use default
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

### don't set context if 3rd argument is nocon

## Sets context
## ex: gkube production-inventory

## does not set context
## ex: gkube production nocon

alias sz='source ~/.zshrc'
alias k="kubectl"

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
#   kexecpod web bundle exec rails c
function kn() {
  k exec -it $(kgetpod) -- node
}

# Usage:
#   kbash web-deployment-688b76c4cc-9lxhk
#   can use this to get into node apps
function kbash() {
  if [[ -z $1 ]]; then
    k exec -it $(kgetpod) -- bash
  else
    k exec -it $1 -- bash
  fi
}

function ksh() {
  k exec -it $(kgetpod) -- sh
}

# Usage:
#   for simplicity use in same directory as local file
# steps to kcp
# copy file to tmp directory
# mv file to ~/
# run command using sudo user
#   kcp pod_name file_name 
#  put it in /tmp folder on local

# ex: sudo kubectl cp TS-22147-unit-ids.csv one-shots-7955754459-sv49d:app/
function kcp() {
  if [[ -z $2 ]]; then
    k cp $1 "$(kgetpod):/app/"
  else
    k cp $1 "$2:/"
  fi
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
  NO_COVERAGE=true bundle exec rspec -fp $1 --no-profile
}

function ebase64 {
  echo "$1" | base64
}

## Git checkout file

function gchd {
  g checkout develop -- $1
}

function opticsb {
  if [[ -z $1 ]]; then
    echo "needs 1 argument for optics project"
  else 
    npx gulp build -c $1
  fi
}

function opticsw {
  if [[ -z $1 ]]; then
    echo "needs 1 argument for optics project"
  else 
    npx gulp build -w $1
  fi
}

function dsworkers {
  workers=( template_removal_worker slot_creation_worker template_priority_update_worker template_creation_worker template_assignment_cleanup_worker container_update_worker container_movement_worker )

  for i in "${workers[@]}"
  do
      echo "starting worker $i"
      bundle exec industrious start $i &
  done
}

function wmworkers {
  workers=( metrics_aggregation_backfill_worker metrics_aggregator_worker metrics_processor_worker metrics_recorder_worker metrics_user_aggregator_worker warehouse_aggregate_worker warehouse_reset_worker weekly_warehouse_aggregate_worker )

  for i in "${workers[@]}"
  do
      echo "starting worker $i"
      bundle exec industrious start $i &
  done
}

function gtag {
  git tag -a $1 -m ''
}

function grebase {
  if [[ -z $1 ]]; then
    git rebase -i develop
  else
    git rebase -i $1
  fi
}

function gbrename {
  BRANCH=$(git rev-parse --abbrev-ref HEAD)
  git branch -m $1
  gbranchdelete "$BRANCH"
}

alias gsup='git branch --set-upstream-to=origin/$(git branch --show-current)'

function kport {
  kill $(lsof -t -i:8080)
}

function invworkers {
  if [[ -z $1 ]]; then
    QUEUE=low_priority bundle exec rake resque:work
  else
    QUEUE=$1 bundle exec rake resque:work
  fi
}

function restartpostgres {
  rm /usr/local/var/postgres/postmaster.pid
  brew services restart postgresql
}

function gsquash {
  commit=$(git log -1 --skip 1 --pretty=%B)
  if [[ -z $1 ]]; then
    git reset --soft HEAD~2 && git commit --edit -m"$commit"
  else
    git reset --soft HEAD~$1 && git commit
  fi
}

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/mgulson/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/mgulson/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/mgulson/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/mgulson/google-cloud-sdk/completion.zsh.inc'; fi
export PATH="/usr/local/opt/mysql@5.7/bin:$PATH"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.


# VS Code Terminal

[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"

[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh" 



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
alias gpush='git push'
alias stubauth='git checkout HARDCODE-WT-3876-auth -- app/controllers/auth_client_controller.rb'
alias unstubauth='git checkout  -- app/controllers/auth_client_controller.rb'
alias be='bundle exec'
alias rubdiff='bundle exec rake test:diff'
alias auth='INTERNAL_API_KEY=not_real_key_123 rs'
alias rdb='bundle exec rails db'
alias rmigrate='bundle exec rake db:migrate'
alias oneshot='bundle exec rails r'
alias gbranchd='gbranchdelete'
alias gbranchr='git branch -m'
alias gclone='git clone'
alias rub='rubocop -a'
alias py='python3'
alias keditsecret='k edit secret pgcluster-secret'
alias kes='k edit secret pgcluster-secret'
alias gstash='g stash'
alias n='node'
alias ns='npm run start'

#This is dangerously close to kgetpod which is a function maybe delete later
alias kgetpods='k get pods'
alias killindustrious='pkill -f industrious'
alias greset='g reset --hard HEAD~1'
alias rtvseeds='CLIENT_ID=1 WAREHOUSE_ID=22 CLOSED_CONTAINERS=true bundle exec rake db:seeds:load\[rtv/create_rtv_units\]'
alias rubocoptodo='rubocop --auto-gen-config --exclude-limit 10000 '
alias stagingrelease='bin/make-staging-release'
alias ob='opticsb'
alias gdiff='git diff'
alias gd='git diff'
alias ds='rs -p 3042'
alias gpf='git push -f'
alias gpushf='git push -f'
alias gpusht='git push --tags'
alias catalogs='rs -p 3018'
alias bi='bundle install'
alias gclean='git reset --hard'
alias warehousemetrics='rs -p 3011'
alias killall='killall5 -9'
alias rtv='rs -p 3033'
alias gdiffd='git diff develop'
alias nd='npm run dev'
alias gpull='git pull'
alias nl='npm run lint'
alias nf='npm run format'
alias nt='npm run test:unit'
alias nts='npm run type-check'
alias nocc='npm run build:dev && npm run preview:dev'

## note
## for personal github use git clone git@github.com-personal:<repository>


export HOMEBREW_NO_AUTO_UPDATE=1

alias gdifffile='git diff --name-only'
alias gdifff='git diff --name-only'

export HELM_REGISTRY_CONFIG="$HOME/.docker/config.json"
export HELM_EXPERIMENTAL_OCI=1
