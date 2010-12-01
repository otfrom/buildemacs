#!/usr/bin/env bash

# this script is quite specific to my particular environment.
# it's an easy way to build the latest version of emacs from
# the bzr repo.
#
# You are expected to clone the emacs bzr repository yourself.
# For basic guidelines, see:
# http://www.emacswiki.org/emacs/BzrForEmacsDevs
#
# I further customize my bazaar repo by making a buildbranch.
# Since I'm tracking the emacs-23 branch, I branch the local
# emacs-23 branch into a buildbranch.
# 
# Software Requirements: 
# OS X Developer Tools
# Bazaar VCS (with the bzr executable in your path)

EMACS_DIR="${HOME}/Documents/development/emacs"
OLD_EMACS_DIR="${HOME}/emacssaved"
TRUNK="trunk"
CURR_BRANCH="emacs-23"
BUILD_BRANCH="buildbranch"
TRUNK_DIR="${EMACS_DIR}/${TRUNK}"
CURR_BRANCH_DIR="${EMACS_DIR}/${CURR_BRANCH}"
BUILD_DIR="${EMACS_DIR}/${BUILD_BRANCH}"
COMP_OPT="-pipe -march=core2"

# string returned when no new code has been added to the bzr branch
NO_REV="No revisions to pull."

# update trunk, which we currently don't use for the build
echo "Updating emacs ${TRUNK} in ${TRUNK_DIR}"
cd $TRUNK_DIR
bzr pull

# update the emacs23 branch, which is used for the build
echo "Updating emacs ${CURR_BRANCH} in ${CURR_BRANCH_DIR}"
cd ${CURR_BRANCH_DIR}
UPD_OUT=$(bzr pull | tr -d '\n')

# check to see if any revisions were added to CURR_BRANCH.
# The embedded awk script returns a value > 0 if we are current.
# If 0, then we have added revisions.
UPD_STAT=$(awk -v upd_out="${UPD_OUT}" -v no_rev="${NO_REV}" 'BEGIN { print index(upd_out, no_rev) }')

if [ $UPD_STAT -gt 0 ]; then
    echo "Not building since we already have the most current ${CURR_BRANCH}."
else
    echo "Building the most current ${CURR_BRANCH} for your computing pleasure."
    cd $BUILD_DIR
    export CFLAGS=${COMP_OPT}
    make clean
    bzr pull
    ./configure --with-ns
    make bootstrap
    make install
    open /Applications/
    open ${BUILD_DIR}/nextstep
    open ${OLD_EMACS_DIR}
fi
