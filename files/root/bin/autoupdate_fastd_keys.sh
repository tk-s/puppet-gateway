#!/bin/bash
# Simple script to update fastd peers from git upstream
# and only send HUP to fastd when changes happend.

# CONFIGURE THIS TO YOUR PEER DIRECTORY
FASTD_ROOT=/etc/fastd/

function getCurrentVersion() {
  # Get hash from latest revision
  git log --format=format:%H -1
}


for $FASTD_PEER in $(find ${FASTD_ROOT} -type d -name peers);
do

  cd $FASTD_PEER

  # Get current version hash
  GIT_REVISION=$(getCurrentVersion)

  # Automagically commit local changes
  # This preserves local changes
  git commit -m "CRON: auto commit"

  # Pull latest changes from upstream
  git fetch
  git merge origin/master -m "Auto Merge"

  # Get new version hash
  GIT_NEW_REVISION=$(getCurrentVersion)

  if [ $GIT_REVISION != $GIT_NEW_REVISION ]
  then
    # Version has changed we need to update
    echo "Reload fastd peers"
    kill -HUP $(pidof fastd)
  fi
done
