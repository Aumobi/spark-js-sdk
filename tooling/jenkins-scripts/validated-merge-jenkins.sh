#!/bin/bash

# Actions to orchestrate running a validated-merge build internally via Jenkins

set -e
set -o pipefail

echo "Begin validated-merge-jenkins.sh"

export COVERAGE=true
export NODE_ENV=test
export XUNIT=true

LOG_FILE="$(pwd)/test.log"
rm -f "${LOG_FILE}"

# INSTALL
echo "Installing legacy SDK dependencies"
npm install

echo "Installing modular SDK dependencies"
npm run bootstrap

# BUILD
echo "Cleaning legacy directories"
npm run grunt -- --no-color --stack clean

echo "Cleaning modular directories"
npm run grunt:concurrent -- --no-color --stack clean

echo "Building modules"
npm run grunt:circle -- build

# Reminder: checkdep must come after build because it looks at ./dist/index.js
echo "Checking for undeclared dependencies"
npm run checkdep

# TEST
echo "Connecting to Sauce Labs..."
npm run sauce:start
echo "Connected to Sauce Labs"

mkdir -p reports

echo "Running all tests and writing output to ${LOG_FILE}"
set +e
npm run sauce:run -- npm run grunt:circle -- static-analysis test coverage 2>&1> "${LOG_FILE}"
EXIT_CODE=$?
set -e

echo "Disconnecting from Sauce Labs..."
npm run sauce:stop
echo "Disconnected from Sauce Labs"

exit $EXIT_CODE

echo "Complete validated-merge-jenkins.sh"
