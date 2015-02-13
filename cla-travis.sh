#!/bin/bash

CLA_CSV_URL="https://raw.githubusercontent.com/shapesecurity/CLA/master/CONTRIBUTORS.csv"
CLA_URL="https://github.com/shapesecurity/CLA"

COMMITTERS=(`git log --silent --show-error --pretty=format:"%ae%n%ce" $TRAVIS_COMMIT_RANGE | sort -u`)

echo "Committers in this range: ${COMMITTERS[@]}"
echo

CONTRIBUTORS=(`curl $CLA_CSV_URL 2>/dev/null | awk -F, '/,/{gsub(/ /, "", $0); print $3}'`)

l2=" ${CONTRIBUTORS[*]} "
for item in ${COMMITTERS[@]}; do
  CONTRIBUTOR=false
  if [[ $l2 =~ " $item " ]] ; then
    CONTRIBUTOR=true
  fi
  if !($CONTRIBUTOR); then
    echo $item has not signed the CLA
    result+=($item)
  fi
done

if [ ${#result[@]} -gt 0 ]; then
  echo
  echo "ERROR: Committers found who have not added their name to $CLA_CSV_URL"
  echo "Please submit a PR to the CLA located at $CLA_URL"
  echo
  echo "Debug info:"
  git log -1 --format="Commit: %H%nParents: %P%nSubject: %s%nAuthor: %an <%ae>%nAuthor Date: %ad%nCommitter: %cn <%ce>%nCommitter Date: %cd"
  exit 1
fi
