#!/bin/sh

git filter-repo --force --commit-callback '
  old_email = b"jess.bowers@disneystreaming.com"
  correct_name = b"Jess Bowers"
  correct_email = b"jessbowers@me.com"

  if commit.committer_email == old_email :
    commit.committer_name = correct_name
    commit.committer_email = correct_email

  if commit.author_email == old_email :
    commit.author_name = correct_name
    commit.author_email = correct_email
  '
