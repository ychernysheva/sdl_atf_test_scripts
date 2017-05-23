#!/bin/bash
for FILE in "$@"
do
# FILE=$($NUM)
COMMIT=$(git log -n 1 --pretty=format:%h -- $FILE)
#COMMIT=$?
DATE=$(git show -s --format=%ci $COMMIT)
# DATE=$?
echo $FILE"	"$COMMIT"	"$DATE
done
exit 0