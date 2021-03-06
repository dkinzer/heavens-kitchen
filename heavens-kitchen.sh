#!/bin/bash

gem uninstall --quiet vagrant
has_vagrant=$(which vagrant)
if [ -z $has_vagrant ];
then
  wget -O /tmp/vagrant.deb https://dl.bintray.com/mitchellh/vagrant/vagrant_1.4.1_x86_64.deb
  sha256sum=$(sha256sum /tmp/vagrant.deb | cut -f 1 -d " ")
  sha256sum_expected='27748094f15ff708cd0d130e4a2e30e4722aecc562901a3f204e6e36dbe1013e'
  if [ "$sha256sum" -eq "$sha256sum_expected" ];
  then
    sudo dpkg -i /tmp/vagrant.deb
    rm /tmp/vagrant.deb
  fi
fi

# Add the rackspace vagrant plugin.
vagrant plugin install vagrant-rackspace
vagrant plugin install vagrant-omnibus

apps='curl git virtualbox vim exuberant-ctags build-essential bison openssl libreadline6 libreadline6-dev zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev'
gems='bundler knife-solo librarian foodcritic fog:1.8 veewee'

function log {
  echo -e "\e[1;31m>> \e[1;34m$1\e[0m"
}


has_rvm=$(which rvm)
ruby_version='1.9.3'

log "Install some dev pacakages..."
sudo apt-get -y install $apps

if [ -z $has_rvm ];
then 
  log "Install rvm..."
  curl -L https://get.rvm.io | bash -s stable --ruby=$ruby_version --autolibs=3
fi

source ~/.rvm/scripts/rvm
if [[ ! $(rvm list | grep -F $ruby_version) ]]; then
  log "Install ruby $ruby_version..."
  rvm install $ruby_version --autolibs=3
fi

# Install gems into our specified ruby.
rvm use $ruby_version
for gem in $gems
do
  IFS=':' read gem version <<< "$gem"
  if [ -n "$version" ];
  then
    has_gem=$(gem list $gem | grep $gem\.*$version | wc -l)
    if [ "$has_gem" -eq 0 ];
    then
      log "Install the $gem gem..."
      gem install $gem --version $version --no-rdoc --no-ri >/dev/null || return 1
    fi
  else
    has_gem=$(gem list $gem | grep $gem | wc -l)
    if [ "$has_gem" -eq 0 ];
    then
      log "Install the $gem gem..."
      gem install $gem --no-rdoc --no-ri >/dev/null || return 1
    fi

  fi
done 

# Sometimes rvm doesn't install properly becuase of dependency issues.
check_rvm_install=$(ruby -ropenssl -e "puts :OK")
if [ $check_rvm_install != "OK" ];
then
  log "Reinstalling rvm..."
  rvm requirements run force
  rvm reinstall all --force 
fi

log "Add kitchen related aliases..."
curl https://raw.github.com/dkinzer/heavens-kitchen/master/.bash_hk -o ~/.bash_hk || return 1
has_kitchen_aliases=$(grep '.bash_hk' ~/.bashrc | head -n 1)
if [ -z "$has_kitchen_aliases" ];
then 
  echo "
# Load Heaven's Kitchen Aliases
if [ -f ~/.bash_hk ];
 then
   source ~/.bash_hk
fi" >> ~/.bashrc 
fi
source ~/.bash_hk

log "Configure Git..."
git config --global core.editor "vim"
git config --global --add color.ui true

if [ -z $(git config user.name) ]; then
  echo "Enter your git username: "
  read username
  git config --global --add user.name "$username"
fi

if [ -z $(git config user.email) ]; then
  echo "Enter your email address: "
  read email
  git config --global --add user.email "$email"
fi


# Solarize the terminal.
log "Solarizing the terminal..."
curl https://raw.github.com/seebi/dircolors-solarized/master/dircolors.ansi-dark -o ~/.dircolors
eval `dircolors ~/.dircolors`
gconftool-2 --set "/apps/gnome-terminal/profiles/Default/use_theme_background" --type bool false
gconftool-2 --set "/apps/gnome-terminal/profiles/Default/use_theme_colors" --type bool false
gconftool-2 --set "/apps/gnome-terminal/profiles/Default/palette" --type string "#070736364242:#D3D301010202:#858599990000:#B5B589890000:#26268B8BD2D2:#D3D336368282:#2A2AA1A19898:#EEEEE8E8D5D5:#00002B2B3636:#CBCB4B4B1616:#58586E6E7575:#65657B7B8383:#838394949696:#6C6C7171C4C4:#9393A1A1A1A1:#FDFDF6F6E3E3"
gconftool-2 --set "/apps/gnome-terminal/profiles/Default/background_color" --type string "#00002B2B3636"
gconftool-2 --set "/apps/gnome-terminal/profiles/Default/foreground_color" --type string "#65657B7B8383"

