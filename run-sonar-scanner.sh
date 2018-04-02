#!/bin/bash

set -eu

if [ -n "${SONAR_TOKEN:-}" ]; then
  SONAR_OPTS="${SONAR_OPTS} -D sonar.login=${SONAR_TOKEN}"
fi

if [ -n "${SONAR_HOST:-}" ]; then
  SONAR_OPTS="${SONAR_OPTS} -D sonar.host.url=${SONAR_HOST}"
fi

if [ -n "${CIRCLE_SHA1:-}" ]; then
  SONAR_OPTS="${SONAR_OPTS} -D sonar.projectVersion=${CIRCLE_SHA1}"
fi

if [ -n "${CIRCLE_PR_NUMBER:-}" ]; then
  SONAR_OPTS="${SONAR_OPTS} -D sonar.analysis.mode=preview -D sonar.github.pullRequest=${CIRCLE_PR_NUMBER}"

  if [ -n "${GITHUB_TOKEN:-}" ]; then
    SONAR_OPTS="${SONAR_OPTS} -D sonar.github.oauth=${GITHUB_TOKEN}"
  fi
fi

if [ -n "${CIRCLE_REPOSITORY_URL:-}" ]; then
  SONAR_OPTS="${SONAR_OPTS} -D sonar.links.scm=${CIRCLE_REPOSITORY_URL}"
fi

if [ -n "${CIRCLE_PROJECT_USERNAME:-}" ] && [ -n "${CIRCLE_PROJECT_REPONAME:-}" ]; then
  SONAR_OPTS="${SONAR_OPTS} -D sonar.github.repository=${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}"
fi

if [ -f 'package.json' ]; then
  NAME=$(cat package.json | grep \"name\": | head -1 | awk -F: '{ print $2 }' | sed 's/[",]//g' | tr -d '[[:space:]]')
  NAME="${NAME/@/}"
  NAME="${NAME/\//_}"
  SONAR_OPTS="${SONAR_OPTS} -D sonar.projectKey=${NAME}"
fi

if [ -n "${SONAR_OPTS:-}" ]; then
  sonar-scanner $SONAR_OPTS
else
  sonar-scanner
fi
