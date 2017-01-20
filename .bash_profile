
export NVM_DIR=~/.nvm
source $(brew --prefix nvm)/nvm.sh

export PATH=/usr/local/bin:$PATH
export PATH=$PATH:/usr/local/opt/go/libexec/bin
export GOPATH=$HOME/golang
export GOROOT=/usr/local/opt/go/libexec
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$GOROOT/bin

#   Change Prompt
#   ------------------------------------------------------------
    export PS1="| \w @ \h (\u) \n| => "
    export PS2="| => "

PROMPT_COMMAND="printf '\e%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' _;printf '\e['"

# For an AWS autoscaling group with desired-capicty 0, moves up 1 or down 1. Used for Rancher Agents
alias agentup='aws autoscaling set-desired-capacity --desired-capacity $(( $(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names RancherAgentsNanoGroup --query AutoScalingGroups[0].DesiredCapacity)+1)) --auto-scaling-group-name RancherAgentsGroup'
alias agentdown='aws autoscaling set-desired-capacity --desired-capacity $(( $(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names RancherAgentsNanoGroup --query AutoScalingGroups[0].DesiredCapacity)-1)) --auto-scaling-group-name RancherAgentsGroup'

# Remove untagged images, remove stopped containers, remove orphaned volumes
alias dockerRUI='docker rmi $(docker images | grep "^<none>" | awk "{print $3}")';
alias dockerRC='docker rm -v $(docker ps -a -q -f status=exited)';
alias dockerRDV='docker volume rm $(docker volume ls -q -f dangling=true)'
alias dm='docker-machine';
alias dme='docker-machine env';

alias rebash='source ~/.bash_profile'
alias l='ls -CF'
alias ll='ls -FGlAhp'
alias mkdir='mkdir -pv'
alias cp='cp -iv'
alias mv='mv -iv'
alias godev='cd ~/Development'
alias golearn='cd ~/relearn'
mcd () { mkdir -p "$1" && cd "$1"; }  #Mkdir and cd into it

alias cd..='cd ../'
alias ..='cd ../'
alias ...='cd ../../'
alias .3='cd ../../../'
alias .4='cd ../../../../'

alias edit='subl' # Opens in sublime
alias f='open -a Finder ./'
alias ~='cd ~'
alias c='clear'
alias myip='curl ip.appspot.com'

#   Color man pages
#   ------------------------------------------------------
man() {
  env \
  LESS_TERMCAP_mb=$(printf "\e[1;31m") \
  LESS_TERMCAP_md=$(printf "\e[1;31m") \
  LESS_TERMCAP_me=$(printf "\e[0m") \
  LESS_TERMCAP_se=$(printf "\e[0m") \
  LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
  LESS_TERMCAP_ue=$(printf "\e[0m") \
  LESS_TERMCAP_us=$(printf "\e[1;32m") \
  man "$@"
}

#   cdf:  'Cd's to frontmost window of MacOS Finder
#   ------------------------------------------------------
cdf () {
  currFolderPath=$( /usr/bin/osascript <<EOT
    tell application "Finder"
      try
        set currFolder to (folder of the front window as alias)
          on error
        set currFolder to (path to desktop folder as alias)
      end try
      POSIX path of currFolder
    end tell
EOT
  )
  echo "cd to \"$currFolderPath\""
  cd "$currFolderPath"
}

#   ii:  display useful host related informaton
#   -------------------------------------------------------------------
ii() {
  echo -e "\nYou are logged on ${RED}$HOST"
  echo -e "\nAdditionnal information:$NC " ; uname -a
  echo -e "\n${RED}Users logged on:$NC " ; w -h
  echo -e "\n${RED}Current date :$NC " ; date
  echo -e "\n${RED}Machine stats :$NC " ; uptime
  echo -e "\n${RED}Current network location :$NC " ; scselect
  echo -e "\n${RED}Public facing IP Address :$NC " ;myip
  echo
}
