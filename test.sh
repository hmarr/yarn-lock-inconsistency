#!/bin/bash
set -euo pipefail

# Clean up
[ -d project ] && rm -r project
[ -d isolated-upgrade ] && rm -r isolated-upgrade

initial_version="0.9.5"
new_version="1.0.6"

# Create project with react-scripts at initial version
mkdir project
cp original-files/{package.json,yarn.lock} project/
cd project
yarn install
cd ..

# Upgrade project to new version of react-scripts in an isolated directory
cp -r project isolated-upgrade
cd isolated-upgrade
yarn add --dev "react-scripts@${new_version}"
cd ..

# Update the original project using the new package.json and yarn.lock
cp isolated-upgrade/{package.json,yarn.lock} project/
cd project
yarn install
cd ..

# Check if the yarn.lock files match
if diff isolated-upgrade/yarn.lock project/yarn.lock > /dev/null; then
  echo " ✔︎ Project yarn.lock and isolated upgrade yarn.lock files match"
else
  echo " ✘ Project yarn.lock and isolated upgrade yarn.lock files don't match"
fi
