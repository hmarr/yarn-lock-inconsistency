#!/bin/bash
set -euo pipefail

# Clean up
[ -d project ] && rm -r project
[ -d regular-upgrade ] && rm -r regular-upgrade
[ -d isolated-upgrade ] && rm -r isolated-upgrade

initial_version="0.9.5"
new_version="1.0.6"

# Create project with react-scripts at initial version
mkdir project
cp original-files/{package.json,yarn.lock} project/
cd project
yarn install
cd ..

# Copy the project and upgrade to new version of react-scripts
cp -r project regular-upgrade
cd regular-upgrade
yarn add --dev "react-scripts@${new_version}"
cd ..

# Upgrade project to new version of react-scripts in a clean directory
mkdir isolated-upgrade
cp project/{package.json,yarn.lock} isolated-upgrade/
cd isolated-upgrade
yarn add --dev "react-scripts@${new_version}"
cd ..

# Update the original project using the new package.json and yarn.lock
cp isolated-upgrade/{package.json,yarn.lock} project/
cd project
yarn install
cd ..

# Check if the yarn.lock files match
if diff regular-upgrade/yarn.lock isolated-upgrade/yarn.lock > /dev/null; then
  echo " ✔︎ Regular upgrade yarn.lock and isolated upgrade yarn.lock files match"
else
  echo " ✘ Regular upgrade yarn.lock and isolated upgrade yarn.lock files don't match"
fi

if diff isolated-upgrade/yarn.lock project/yarn.lock > /dev/null; then
  echo " ✔︎ Project yarn.lock and isolated upgrade yarn.lock files match"
else
  echo " ✘ Project yarn.lock and isolated upgrade yarn.lock files don't match"
fi

if diff regular-upgrade/yarn.lock project/yarn.lock > /dev/null; then
  echo " ✔︎ Project yarn.lock and regular upgrade yarn.lock files match"
else
  echo " ✘ Project yarn.lock and regular upgrade yarn.lock files don't match"
fi
