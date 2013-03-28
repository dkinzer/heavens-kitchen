#!/bin/bash

apps='curl git virtualbox vim exuberant-ctags libxslt1-dev libxml2-dev zlib1g-dev'
gems='vagrant knife-solo librarian foodcritic'
has_rvm=$(which rvm)
ruby_version='1.9.3'

for app in $apps
do
  sudo apt-get -y install $app
done

if [ -z $has_rvm ];
then 
  curl -L https://get.rvm.io | bash -s stable --ruby=$ruby_version
else
  rvm get stable  
fi

source ~/.rvm/scripts/rvm

# Install gems into our specified ruby.
rvm use $ruby_version
for gem in $gems
do
  gem install $gem --no-rdoc --no-ri
done 

# Sometimes rvm doesn't install properly becuase of dependency issues.
check_rvm_install=$(ruby -ropenssl -e "puts :OK")
if [ $check_rvm_install != "OK" ];
then
  rvm requirements run force
  rvm reinstall all --force 
fi

# Add some kitchen related aliases.
curl https://raw.github.com/dkinzer/heavens-kitchen/master/.bash_hk -o ~/.bash_hk
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

# Git configurations
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
curl https://raw.github.com/seebi/dircolors-solarized/master/dircolors.ansi-dark -o ~/.dircolors
eval `dircolors ~/.dircolors`
gconftool-2 --set "/apps/gnome-terminal/profiles/Default/use_theme_background" --type bool false
gconftool-2 --set "/apps/gnome-terminal/profiles/Default/use_theme_colors" --type bool false
gconftool-2 --set "/apps/gnome-terminal/profiles/Default/palette" --type string "#070736364242:#D3D301010202:#858599990000:#B5B589890000:#26268B8BD2D2:#D3D336368282:#2A2AA1A19898:#EEEEE8E8D5D5:#00002B2B3636:#CBCB4B4B1616:#58586E6E7575:#65657B7B8383:#838394949696:#6C6C7171C4C4:#9393A1A1A1A1:#FDFDF6F6E3E3"
gconftool-2 --set "/apps/gnome-terminal/profiles/Default/background_color" --type string "#00002B2B3636"
gconftool-2 --set "/apps/gnome-terminal/profiles/Default/foreground_color" --type string "#65657B7B8383"

