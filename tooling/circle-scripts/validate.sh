#!/bin/bash

set -e

if [ "${CIRCLE_BRANCH}" = "release" ]; then
  echo "Build running on release branch; choosing to exit rather than running test suite a second time"
  exit 0
fi

echo "Building all modules"
npm run grunt:circle -- build

# Reminder: checkdep must come after build because it looks at ./dist/index.js
echo "Checking for undeclared dependencies"
npm run checkdep

echo "Connecting to Sauce Labs"
npm run sauce:start

set +e
npm run sauce:run -- npm run grunt:circle -- static-analysis test coverage
EXIT_CODE=$?
set -e

echo "Disconnecting from Sauce Labs"
npm run sauce:stop

exit ${EXIT_CODE}
