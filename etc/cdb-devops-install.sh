#!/bin/bash
# Example script for deploying a Kitchen using this project.
# Prepare the environment

wget https://raw.github.com/dkinzer/heavens-kitchen/master/heavens-kitchen.sh && source heavens-kitchen.sh

# Create a project direcotory.
if [ ! -d ~/projects ]; then
  mkdir ~/projects
fi

# Clone and start up a kitchen project.
if [ ! -d ~/projects/cdb-devops ]; then
  # Clone the cdb-devops project.
  cd ~/projects
  git clone git@github.com:jenkinslaw/cdb-devops.git
    
  # Start up the project.
  cd cdb-devops
  if [ ! -f solo.rb ]; then
    knife solo init .
  fi
  vagrant up
  prepare
  cook

  # Clean-up
  cd ../../
  rm heavens-kitchen.sh
  rm cdb-devops-install.sh

fi


