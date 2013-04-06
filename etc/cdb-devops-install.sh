#!/bin/bash
# Example script for deploying a Kitchen using this project.
# Prepare the environment

function log {
  echo -e "\e[1;31m>> \e[1;34m$1\e[0m"
}

wget -qO - https://raw.github.com/dkinzer/heavens-kitchen/master/heavens-kitchen.sh |  bash

log "Create a project direcotory."
if [ ! -d ~/projects ]; then
  mkdir ~/projects
fi

# Clone and start up a kitchen project.
if [ ! -d ~/projects/cdb-devops ]; then
  log "Clone the cdb-devops project."
  cd ~/projects
  git clone git@github.com:jenkinslaw/cdb-devops.git
    
  log "Start up the project."
  cd cdb-devops
  if [ ! -f solo.rb ]; then
    knife solo init .
  fi
  vagrant up
  prepare && rake keys
  cook
fi


