#!/bin/bash

apps='curl git virtualbox vim libxslt1-dev libxml2-dev zlib1g-dev'
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

rvm use $ruby_version

for gem in $gems
do
  gem install $gem --no-rdoc --no-ri
done 


