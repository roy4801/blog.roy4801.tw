#!/bin/bash
[[ "$1" == "" ]] && MSG=update || MSG=$1

# cp -rf ./public/* ../roy4801.github.io/
cp -rf ./public/* .deploy_git/
pushd .deploy_git/ > /dev/null

git add .
git commit -m "$(date +"%Y/%m/%d %H:%M:%S") $1"
git push origin gh-pages

popd > /dev/null
