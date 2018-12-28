#!/bin/bash
#
# build zammad chart and upload to zammad.github.io
#

set -ex

REPO_ROOT="$(git rev-parse --show-toplevel)"
CHART_SOURCE="https://github.com/zammad/helm.git"
CHART_REPO="https://zammad.github.io"
DIR_NAME="zammad"

# remove zammad dir if exist
test -d ${REPO_ROOT}/${DIR_NAME} && rm -rf ${REPO_ROOT:=?}/${DIR_NAME:=?}

# get chart source
git clone ${CHART_SOURCE} ${DIR_NAME}
rm -rf ${REPO_ROOT:=?}/${DIR_NAME:=?}/.git

# get chart version
CHART_VERSION="$(grep version: ${REPO_ROOT}/${DIR_NAME}/Chart.yaml | sed 's/version: //')"

# build helm dependencies
cd ${DIR_NAME}
helm dependency build
cd ..

# build chart
helm package ${DIR_NAME}

# create repo index
helm repo index --merge index.yaml --url https://zammad.github.io .

# push changes to github
if [ "${TRAVIS}" == 'true' ]; then
  git config --global user.email "travis@travis-ci.org"
  git config --global user.name "Travis CI"
  git remote add origin git@github.com:zammad/zammad.github.io.git
  git add --all .
  git commit -m "push zammad chart version ${CHART_VERSION}"
  git push --set-upstream origin
fi
