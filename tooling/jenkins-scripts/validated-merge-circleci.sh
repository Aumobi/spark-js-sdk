#!/bin/bash

# Actions to orchestrate running a validated-merge build on Circle CI

set -e
set -o pipefail

echo "Begin validated-merge-circleci.sh"

REMOTE=ghc
BRANCH=validated-merge
USERNAME=ciscospark
PROJECT=spark-js-sdk

rm -rf ./reports
rm -f CIRCLE_BUILD_NUMBER

echo "no" > 503

# Ensure there are no builds running/enqueued for the validated merge branch
# (jenkins should be handling the queuing, not circle)
./tooling/circle --auth ${CIRCLECI_AUTH_TOKEN} \
  --username ${USERNAME} \
  --project ${PROJECT} \
  --branch ${BRANCH} \
  verify-no-builds-on-branch

echo "Pushing validated-merge result to GitHub validated-merge branch"
git push -f ${REMOTE} HEAD:validated-merge

echo "Validating validated-merge result using Circle CI"
./tooling/circle --auth ${CIRCLECI_AUTH_TOKEN} \
  --username ${USERNAME} \
  --project ${PROJECT} \
  --branch ${BRANCH} \
  trigger-build

echo "Complete validated-merge-circleci.sh"
