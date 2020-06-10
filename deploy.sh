#!/bin/bash
[[ "$1" == "" ]] && MSG=update || MSG=$1

cp -rf ./public/* ../roy4801.github.io/
pushd ../roy4801.github.io/ > /dev/null

git add .
git commit -m "$(date +"%Y/%m/%d %H:%M:%S") $1"
git push origin master

popd > /dev/null
