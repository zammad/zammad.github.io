#!/bin/bash
#
# build zammad chart and upload to zammad.github.io
#

set -ex

REPO_ROOT="$(git rev-parse --show-toplevel)"
CHART_SOURCE="https://github.com/zammad/helm.git"
CHART_REPO="git@github.com:zammad/zammad.github.io.git"
DIR_NAME="chart"

# remove zammad dir if exist
test -d ${REPO_ROOT}/${DIR_NAME} && rm -rf ${REPO_ROOT:=?}/${DIR_NAME:=?}

# get chart source
git clone ${CHART_SOURCE} ${DIR_NAME}

rm -rf ${REPO_ROOT}/${DIR_NAME}/zammad/.git

# get chart version
CHART_VERSION="$(grep version: ${REPO_ROOT}/${DIR_NAME}/zammad/Chart.yaml | sed 's/version: //')"

# build helm dependencies
cd ${DIR_NAME}/zammad
helm dependency build
cd ..

# build chart
helm package zammad

test -f ${REPO_ROOT}/index.yaml && cp ${REPO_ROOT}/index.yaml ${REPO_ROOT}/${DIR_NAME}/index.yaml

# create repo index
helm repo index --merge index.yaml --url https://zammad.github.io .

cp ${REPO_ROOT}/${DIR_NAME}/index.yaml ${REPO_ROOT}/index.yaml
cp ${REPO_ROOT}/${DIR_NAME}/*.tgz ${REPO_ROOT}

# push changes to github
if [ "${TRAVIS}" == 'true' ]; then
  git config --global user.email "travis@travis-ci.org"
  git config --global user.name "Travis CI"
  git remote remove origin
  git remote add origin ${CHART_REPO}
  git checkout master
  git add --all .
  git commit -m "push zammad chart version ${CHART_VERSION} via travis build nr: ${TRAVIS_BUILD_NUMBER} - [skip travis-ci]"
  git pull -X ours
  git push --set-upstream origin master
fi
