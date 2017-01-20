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
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)";
brew install \
  ack \
  bash-completion \
  caskroom/cask/brew-cask \
  delve \
  docker \
  docker-compose \
  docker-machine \
  ffmpeg \
  git \
  go \
  lame \
  libpng \
  libsamplerate \
  libxml2 \
  libyaml \
  nvm \
  python \
  rancher-compose \
  readline \
  sqlite \
  terraform \
  watch \
  x264 \
  xvid \
;

echo "Installing applications...";
brew tap caskroom/cask;
brew tap caskroom/versions;
brew cask install \
  chefdk \
  disk-inventory-x \
  dropbox \
  firefox \
  flux \
  google-chrome \
  iterm2 \
  sequel-pro \
  spectacle \
  spotify \
  sublime-text \
  the-unarchiver \
  transmission \
  vagrant \
  veracrypt \
  virtualbox \
  visual-studio-code \
  vlc \
  webstorm \
;

echo "Configuring git..."
git config --global user.name "Jon Simpson"
git config --global user.email simpson.jon@gmail.com
git config --global push.default simple;
git config --global core.editor nano

echo "Configuring #bash_profile..."
# Following is the .bash_profile from this repo converted to base64
base64 --decode <<< 'CmV4cG9ydCBOVk1fRElSPX4vLm52bQpzb3VyY2UgJChicmV3IC0tcHJlZml4IG52bSkvbnZtLnNoCgpleHBvcnQgUEFUSD0vdXNyL2xvY2FsL2JpbjokUEFUSApleHBvcnQgUEFUSD0kUEFUSDovdXNyL2xvY2FsL29wdC9nby9saWJleGVjL2JpbgpleHBvcnQgR09QQVRIPSRIT01FL2dvbGFuZwpleHBvcnQgR09ST09UPS91c3IvbG9jYWwvb3B0L2dvL2xpYmV4ZWMKZXhwb3J0IFBBVEg9JFBBVEg6JEdPUEFUSC9iaW4KZXhwb3J0IFBBVEg9JFBBVEg6JEdPUk9PVC9iaW4KCiMgICBDaGFuZ2UgUHJvbXB0CiMgICAtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KICAgIGV4cG9ydCBQUzE9InwgXHcgQCBcaCAoXHUpIFxufCA9PiAiCiAgICBleHBvcnQgUFMyPSJ8ID0+ICIKClBST01QVF9DT01NQU5EPSJwcmludGYgJ1xlJSpzXG4nICIke0NPTFVNTlM6LSQodHB1dCBjb2xzKX0iICcnIHwgdHIgJyAnIF87cHJpbnRmICdcZVsnIgoKIyBGb3IgYW4gQVdTIGF1dG9zY2FsaW5nIGdyb3VwIHdpdGggZGVzaXJlZC1jYXBpY3R5IDAsIG1vdmVzIHVwIDEgb3IgZG93biAxLiBVc2VkIGZvciBSYW5jaGVyIEFnZW50cwphbGlhcyBhZ2VudHVwPSdhd3MgYXV0b3NjYWxpbmcgc2V0LWRlc2lyZWQtY2FwYWNpdHkgLS1kZXNpcmVkLWNhcGFjaXR5ICQoKCAkKGF3cyBhdXRvc2NhbGluZyBkZXNjcmliZS1hdXRvLXNjYWxpbmctZ3JvdXBzIC0tYXV0by1zY2FsaW5nLWdyb3VwLW5hbWVzIFJhbmNoZXJBZ2VudHNOYW5vR3JvdXAgLS1xdWVyeSBBdXRvU2NhbGluZ0dyb3Vwc1swXS5EZXNpcmVkQ2FwYWNpdHkpKzEpKSAtLWF1dG8tc2NhbGluZy1ncm91cC1uYW1lIFJhbmNoZXJBZ2VudHNHcm91cCcKYWxpYXMgYWdlbnRkb3duPSdhd3MgYXV0b3NjYWxpbmcgc2V0LWRlc2lyZWQtY2FwYWNpdHkgLS1kZXNpcmVkLWNhcGFjaXR5ICQoKCAkKGF3cyBhdXRvc2NhbGluZyBkZXNjcmliZS1hdXRvLXNjYWxpbmctZ3JvdXBzIC0tYXV0by1zY2FsaW5nLWdyb3VwLW5hbWVzIFJhbmNoZXJBZ2VudHNOYW5vR3JvdXAgLS1xdWVyeSBBdXRvU2NhbGluZ0dyb3Vwc1swXS5EZXNpcmVkQ2FwYWNpdHkpLTEpKSAtLWF1dG8tc2NhbGluZy1ncm91cC1uYW1lIFJhbmNoZXJBZ2VudHNHcm91cCcKCiMgUmVtb3ZlIHVudGFnZ2VkIGltYWdlcywgcmVtb3ZlIHN0b3BwZWQgY29udGFpbmVycywgcmVtb3ZlIG9ycGhhbmVkIHZvbHVtZXMKYWxpYXMgZG9ja2VyUlVJPSdkb2NrZXIgcm1pICQoZG9ja2VyIGltYWdlcyB8IGdyZXAgIl48bm9uZT4iIHwgYXdrICJ7cHJpbnQgJDN9IiknOwphbGlhcyBkb2NrZXJSQz0nZG9ja2VyIHJtIC12ICQoZG9ja2VyIHBzIC1hIC1xIC1mIHN0YXR1cz1leGl0ZWQpJzsKYWxpYXMgZG9ja2VyUkRWPSdkb2NrZXIgdm9sdW1lIHJtICQoZG9ja2VyIHZvbHVtZSBscyAtcSAtZiBkYW5nbGluZz10cnVlKScKYWxpYXMgZG09J2RvY2tlci1tYWNoaW5lJzsKYWxpYXMgZG1lPSdkb2NrZXItbWFjaGluZSBlbnYnOwoKYWxpYXMgcmViYXNoPSdzb3VyY2Ugfi8uYmFzaF9wcm9maWxlJwphbGlhcyBsPSdscyAtQ0YnCmFsaWFzIGxsPSdscyAtRkdsQWhwJwphbGlhcyBta2Rpcj0nbWtkaXIgLXB2JwphbGlhcyBjcD0nY3AgLWl2JwphbGlhcyBtdj0nbXYgLWl2JwphbGlhcyBnb2Rldj0nY2Qgfi9EZXZlbG9wbWVudCcKYWxpYXMgZ29sZWFybj0nY2Qgfi9yZWxlYXJuJwptY2QgKCkgeyBta2RpciAtcCAiJDEiICYmIGNkICIkMSI7IH0gICNNa2RpciBhbmQgY2QgaW50byBpdAoKYWxpYXMgY2QuLj0nY2QgLi4vJwphbGlhcyAuLj0nY2QgLi4vJwphbGlhcyAuLi49J2NkIC4uLy4uLycKYWxpYXMgLjM9J2NkIC4uLy4uLy4uLycKYWxpYXMgLjQ9J2NkIC4uLy4uLy4uLy4uLycKCmFsaWFzIGVkaXQ9J3N1YmwnICMgT3BlbnMgaW4gc3VibGltZQphbGlhcyBmPSdvcGVuIC1hIEZpbmRlciAuLycKYWxpYXMgfj0nY2QgficKYWxpYXMgYz0nY2xlYXInCmFsaWFzIG15aXA9J2N1cmwgaXAuYXBwc3BvdC5jb20nCgojICAgQ29sb3IgbWFuIHBhZ2VzCiMgICAtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KbWFuKCkgewogIGVudiBcCiAgTEVTU19URVJNQ0FQX21iPSQocHJpbnRmICJcZVsxOzMxbSIpIFwKICBMRVNTX1RFUk1DQVBfbWQ9JChwcmludGYgIlxlWzE7MzFtIikgXAogIExFU1NfVEVSTUNBUF9tZT0kKHByaW50ZiAiXGVbMG0iKSBcCiAgTEVTU19URVJNQ0FQX3NlPSQocHJpbnRmICJcZVswbSIpIFwKICBMRVNTX1RFUk1DQVBfc289JChwcmludGYgIlxlWzE7NDQ7MzNtIikgXAogIExFU1NfVEVSTUNBUF91ZT0kKHByaW50ZiAiXGVbMG0iKSBcCiAgTEVTU19URVJNQ0FQX3VzPSQocHJpbnRmICJcZVsxOzMybSIpIFwKICBtYW4gIiRAIgp9CgojICAgY2RmOiAgJ0NkJ3MgdG8gZnJvbnRtb3N0IHdpbmRvdyBvZiBNYWNPUyBGaW5kZXIKIyAgIC0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQpjZGYgKCkgewogIGN1cnJGb2xkZXJQYXRoPSQoIC91c3IvYmluL29zYXNjcmlwdCA8PEVPVAogICAgdGVsbCBhcHBsaWNhdGlvbiAiRmluZGVyIgogICAgICB0cnkKICAgICAgICBzZXQgY3VyckZvbGRlciB0byAoZm9sZGVyIG9mIHRoZSBmcm9udCB3aW5kb3cgYXMgYWxpYXMpCiAgICAgICAgICBvbiBlcnJvcgogICAgICAgIHNldCBjdXJyRm9sZGVyIHRvIChwYXRoIHRvIGRlc2t0b3AgZm9sZGVyIGFzIGFsaWFzKQogICAgICBlbmQgdHJ5CiAgICAgIFBPU0lYIHBhdGggb2YgY3VyckZvbGRlcgogICAgZW5kIHRlbGwKRU9UCiAgKQogIGVjaG8gImNkIHRvIFwiJGN1cnJGb2xkZXJQYXRoXCIiCiAgY2QgIiRjdXJyRm9sZGVyUGF0aCIKfQoKIyAgIGlpOiAgZGlzcGxheSB1c2VmdWwgaG9zdCByZWxhdGVkIGluZm9ybWF0b24KIyAgIC0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KaWkoKSB7CiAgZWNobyAtZSAiXG5Zb3UgYXJlIGxvZ2dlZCBvbiAke1JFRH0kSE9TVCIKICBlY2hvIC1lICJcbkFkZGl0aW9ubmFsIGluZm9ybWF0aW9uOiROQyAiIDsgdW5hbWUgLWEKICBlY2hvIC1lICJcbiR7UkVEfVVzZXJzIGxvZ2dlZCBvbjokTkMgIiA7IHcgLWgKICBlY2hvIC1lICJcbiR7UkVEfUN1cnJlbnQgZGF0ZSA6JE5DICIgOyBkYXRlCiAgZWNobyAtZSAiXG4ke1JFRH1NYWNoaW5lIHN0YXRzIDokTkMgIiA7IHVwdGltZQogIGVjaG8gLWUgIlxuJHtSRUR9Q3VycmVudCBuZXR3b3JrIGxvY2F0aW9uIDokTkMgIiA7IHNjc2VsZWN0CiAgZWNobyAtZSAiXG4ke1JFRH1QdWJsaWMgZmFjaW5nIElQIEFkZHJlc3MgOiROQyAiIDtteWlwCiAgZWNobwp9Cg==' > ~/.bash_profile