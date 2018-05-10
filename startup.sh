#!/usr/bin/env bash

defaults write com.apple.finder AppleShowAllFiles YES; # show hidden files
defaults write com.apple.dock persistent-apps -array; # remove icons in Dock
defaults write com.apple.dock tilesize -int 36; # smaller icon sizes in Dock
defaults write com.apple.dock autohide -bool true; # turn Dock auto-hidng on
defaults write com.apple.dock autohide-delay -float 0; # remove Dock show delay
defaults write com.apple.dock autohide-time-modifier -float 0; # remove Dock show delay
defaults write NSGlobalDomain AppleShowAllExtensions -bool true; # show all file extensions
chflags nohidden ~/Library/

echo "Installing commandline tools...";
# Get and install Xcode CLI tools
# https://github.com/timsutton/osx-vm-templates/blob/ce8df8a7468faa7c5312444ece1b977c1b2f77a4/scripts/xcode-cli-tools.sh
OSX_VERS=$(sw_vers -productVersion | awk -F "." '{print $2}');
 
# on 10.9+, we can leverage SUS to get the latest CLI tools
if [ "$OSX_VERS" -ge 9 ]; then
    # create the placeholder file that's checked by CLI updates' .dist code 
    # in Apple's SUS catalog
    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    # find the CLI Tools update
    PROD=$(softwareupdate -l | grep "\*.*Command Line" | head -n 1 | awk -F"*" '{print $2}' | sed -e 's/^ *//' | tr -d '\n')
    # install it
    softwareupdate -i "$PROD" -v
 
# on 10.7/10.8, we instead download from public download URLs, which can be found in
# the dvtdownloadableindex:
# https://devimages.apple.com.edgekey.net/downloads/xcode/simulators/index-3905972D-B609-49CE-8D06-51ADC78E07BC.dvtdownloadableindex
else
    [ "$OSX_VERS" -eq 7 ] && DMGURL=http://devimages.apple.com.edgekey.net/downloads/xcode/command_line_tools_for_xcode_os_x_lion_april_2013.dmg
    [ "$OSX_VERS" -eq 8 ] && DMGURL=http://devimages.apple.com.edgekey.net/downloads/xcode/command_line_tools_for_osx_mountain_lion_april_2014.dmg

    TOOLS=clitools.dmg
    curl "$DMGURL" -o "$TOOLS"
    TMPMOUNT=`/usr/bin/mktemp -d /tmp/clitools.XXXX`
    hdiutil attach "$TOOLS" -mountpoint "$TMPMOUNT"
    installer -pkg "$(find $TMPMOUNT -name '*.mpkg')" -target /
    hdiutil detach "$TMPMOUNT"
    rm -rf "$TMPMOUNT"
    rm "$TOOLS"
    exit
fi

echo "Installing homebrew...";
cd ~ && mkdir homebrew && curl -L https://github.com/Homebrew/homebrew/tarball/master | tar xz --strip 1 -C homebrew
brew install \
  bash-completion \
  git \
  go \
  python \
  python@2 \
  readline \
  watch \
;

echo "Installing applications...";
brew cask install \
  disk-inventory-x \
  dropbox \
  firefox \
  flux \
  google-chrome \
  iterm2 \
  spectacle \
  the-unarchiver \
  transmission \
  veracrypt \
  virtualbox \
  visual-studio-code \
  vlc \
;

echo "Configuring git..."
git config --global user.name "Jon Simpson"
git config --global user.email simpson.jon@gmail.com
git config --global push.default simple;
git config --global core.editor vim

# Install shell startup scripts
cd ~ && mkdir .shellrc && cd .shellrc && export https://github.com/simpsonjon/dotfiles/trunk/shellrc/bashrc.d/
mv ./bashrc.d/bashrc ~/.bashrc 