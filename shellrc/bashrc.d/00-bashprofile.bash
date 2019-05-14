# Make 'l' show columned output with dir/ names
alias l='ls -CF'
alias ll='ls -FGlAhp'
# Mkdir with path and verbose by default
alias mkdir='mkdir -pv'
# Make cp and move require confirmation on overwrites by default
alias cp='cp -iv'
alias mv='mv -iv'
# East aliases for directory movement
alias godev='cd ~/Development'

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
alias myip='curl ifconfig.co'

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