#!/bin/bash

set -e
set -o pipefail

echo "Begin publish.sh"

echo "Installing Tooling and legacy node_modules"
npm install

REMOTE=ghc
BRANCH=release
USERNAME=ciscospark
PROJECT=spark-js-sdk

# Ensure there are no builds running/enqueued for the branch
./tooling/circle --auth ${CIRCLECI_AUTH_TOKEN} \
  --username ${USERNAME} \
  --project ${PROJECT} \
  --branch ${BRANCH} \
  verify-no-builds-on-branch

# We're currently on a detached head; name it so we can merge back to it when
# the build succeeds
echo "Naming branch to leave detached-head state"
git checkout -b ${BUILD_NUMBER}
echo "Pushing validated merge result to GitHub release branch"
git push -f ${REMOTE} ${BUILD_NUMBER}:refs/heads/${BRANCH}

echo "Publishing validated-merge result via Circle CI"
./tooling/circle --auth ${CIRCLECI_AUTH_TOKEN} \
  --username ${USERNAME} \
  --project ${PROJECT} \
  --branch ${BRANCH} \
  --no-artifacts \
  trigger-build

CIRCLE_BUILD_NUMBER=`cat CIRCLE_BUILD_NUMBER`
CIRCLE_BUILD_STATUS=`./tooling/circle get-build \
  --auth=${CIRCLECI_AUTH_TOKEN} \
  --username=${USERNAME} \
  --project=${PROJECT} \
  --build_num=${CIRCLE_BUILD_NUMBER} -j | jq .status | sed -e 's/^"//'  -e 's/"$//'`

echo "Circle CI build #${CIRCLE_BUILD_NUMBER} completed with status ${CIRCLE_BUILD_STATUS}"

if [ "${CIRCLE_BUILD_STATUS}" = "success" ]; then
  # Merge the new package versions from Circle CI
  echo "Fetching publication result from GitHub.com"
  git fetch ghc

  echo "Merging publication result into validated-merge branch"
  git merge ghc/master

  # TODO publish to internal registry

  echo "Recording SHA of validated-merge result"
  git rev-parse HEAD > .promotion-sha
else
  echo "Publication failed, validated merge continuing"
  # TODO fire webhook
fi

echo "Complete publish.sh"
