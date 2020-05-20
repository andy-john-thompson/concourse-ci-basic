#!/bin/sh

echo "show git info.."
echo "git commiter:"
cat "git_scm_resource/.git/committer"
echo ""

echo "git Version reference detected and checked out:"
cat "git_scm_resource/.git/ref"
echo ""


echo "git short Version reference detected and checked out:"
cat "git_scm_resource/.git/short_ref"
echo ""

echo "git commit_message:"
cat "git_scm_resource/.git/commit_message"
echo ""
