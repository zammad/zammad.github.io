#!/bin/bash
#
# build zammad chart and upload to zammad.github.io
#

set -ex

REPO_ROOT="$(git rev-parse --show-toplevel)"
CHART_SOURCE="https://github.com/zammad/helm.git"
CHART_REPO="https://zammad.github.io"
DIR_NAME="zammad"

test -d ${REPO_ROOT}/${DIR_NAME} && rm -rf ${REPO_ROOT:=?}/${DIR_NAME:=?}

git clone ${CHART_SOURCE} ${DIR_NAME}
rm -rf ${REPO_ROOT:=?}/${DIR_NAME:=?}/.git

CHART_VERSION="$(grep version: ${REPO_ROOT}/${DIR_NAME}/Chart.yaml | sed 's/version: //')"

cd ${DIR_NAME}
helm dependency build
cd ..

helm package ${DIR_NAME}

helm repo index --merge index.yaml --url https://zammad.github.io .

#git remote add
git add --all .
git commit -m "added zammad helm chart with version ${CHART_VERSION}"
git push
