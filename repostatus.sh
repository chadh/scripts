#!/bin/bash

GREEN='\033[32m'
BLUE='\033[34m'
RED='\033[00;31m'
NONE='\033[0m'

function on_gtgithub() {
  for server in $(git remote -v | sed 's/^[^ 	]\+[ 	]\+[^:]\+:\/\/\([^/]\+\)\/.*$/\1/')
  do
    if [[ $server =~ github\.gatech\.edu ]]
    then
      return 0
    fi
  done
  return 1
}

function on_gitso() {
  for server in $(git remote -v | sed 's/^[^ 	]\+[ 	]\+[^:]\+:\/\/\([^/]\+\)\/.*$/\1/')
  do
    if [[ $server =~ gitso\.?.* || $server =~ raejuusto\.?.* ]]
    then
      return 0
    fi
  done
  return 1
}

status=''
function process_dir() {
#if on_gitso
if on_gtgithub
then
  if [ -z "$(git status -s)" ]
  then
    git fetch > /dev/null 2>&1
    if [ $? -ne 0 ];
    then
      echo "git fetch failed in $1"
      return 1
    fi
    head=$(git branch -v | grep '^*' | awk '{ print $3; }')
    match=no
    for i in $(git branch -av | grep -v '^*' | awk '{ print $2; }')
    do
      if [ $head == $i ]
      then
        match=yes
      fi
    done
    if [ $match == "yes" ]
    then
      echo -e "${GREEN}$s${NONE}"
    else
      echo -e "${RED}$s${NONE}"
      echo "  Current branch not in sync with remotes"
    fi
  else
    echo -e "${RED}$s${NONE}"
    git status -s
  fi
else
  echo -e "${BLUE}$s${NONE}"
fi
}

echo
echo "Scanning for git repos..."
echo
for i in $(find . -type d -not -path '*/\.*')
do
  pushd $i > /dev/null 2>&1 || echo "Unable to change directory to $i"
  if [ -d .git ]
  then
    s=$(echo $i | sed 's/.\/\(.*\)/\1/')
#    printf "%-50s " $s
    process_dir $s
#    echo -e "${s}${NONE}"
  fi
  popd > /dev/null 2>&1 || echo "Unable to pop!"
done

