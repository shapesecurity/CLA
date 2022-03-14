#!/bin/bash
set -e

CLA_URL="https://github.com/shapesecurity/CLA"
if [ $# -gt 0 ]; then
  CLA_CSV_URL="$1"
  CSV_DATA=`cat "$1" | tail -n +2`
else
  CLA_CSV_URL="https://raw.githubusercontent.com/shapesecurity/CLA/HEAD/CONTRIBUTORS.csv"
  CSV_DATA=`curl "$CLA_CSV_URL" 2>/dev/null | tail -n +2`
fi

if [ -z "$COMMIT_RANGE" ]; then
  echo "COMMIT_RANGE must be provided"
  exit 1
fi

echo "CLA_CSV_URL: $CLA_CSV_URL"
echo "COMMIT_RANGE: $COMMIT_RANGE"
echo

CONTRIBUTORS=(`echo "$CSV_DATA" | awk -F, '/,/{gsub(/ /, "", $0); print $2 "@users.noreply.github.com"; print $4}'`)
CONTRIBUTORS=" ${CONTRIBUTORS[*]} "


AUTHORS=(`git log --pretty=format:"%ae" $COMMIT_RANGE | sort -u`)
echo "Authors in this range: ${AUTHORS[@]}"

for item in ${AUTHORS[@]}; do
  if [[ ! ("$item" == *"@shapesecurity.com" || "$item" == *"@f5.com" || "$item" == *"+dependabot[bot]@users.noreply.github.com" || "$CONTRIBUTORS" =~ " $item ") ]]; then
    echo
    echo "ERROR: Author $item has not signed the CLA"
    echo
    result+=($item)
  fi
done


COMMITTERS=(`git log --pretty=format:"%ce" $COMMIT_RANGE | sort -u`)
echo "Committers in this range: ${COMMITTERS[@]}"

for item in ${COMMITTERS[@]}; do
  if [[ ! ("$item" == "noreply@github.com" || "$item" == *"@shapesecurity.com" || "$item" == *"@f5.com" || "$CONTRIBUTORS" =~ " $item ") ]]; then
    echo
    echo "ERROR: Committer $item has not signed the CLA"
    echo
    result+=($item)
  fi
done


echo

if [ ${#result[@]} -gt 0 ]; then
  echo "Please submit a PR to the CLA located at $CLA_URL"
  echo
  echo "Debug info:"
  git log -1 --format="Commit: %H%nParents: %P%nSubject: %s%nAuthor: %an <%ae>%nAuthor Date: %ad%nCommitter: %cn <%ce>%nCommitter Date: %cd"
  exit 1
fi

echo "CLA check succeeded"
