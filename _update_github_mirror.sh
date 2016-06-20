#!/bin/bash

git stash >/dev/null 2>&1
git checkout launchpad >/dev/null 2>&1
echo "git: Checked out launchpad branch. All Changes stashed!"

echo "bzr: Updating"
bzr update

# Extract fields from bzr log
LOG=$(bzr log -r-1)
revno=$(echo $LOG | perl -ne 'm/revno: (\d+)/; print $1')
author=$(echo $LOG | perl -ne 'm/committer: (.*?) branch/; print $1')
timestamp=$(echo $LOG | perl -ne 'm/timestamp: (.*) message/; print $1')
message=$(echo $LOG | perl -ne 'm/message: (.*)/; print $1')

# if "<" not in author:
if [[ ! $author == *"<"* ]]
then
  author="$author <>"
fi

echo "bzr: Pulled Revision $revno"

git add . >/dev/null 2>&1
git commit -m "$revno: $message" --date "$timestamp" --author "$author" > /dev/null 2>&1

echo "git: Changes Committed"

echo "git: Pushing to Github"
git push origin launchpad

git checkout master >/dev/null 2>&1
git stash pop >/dev/null 2>&1
echo "git: Back to master"
