:: Merge changes from Github trunk into svn
:: ----------------------------------------
::
:: Now going the other direction. This is a bit more 
:: complicated than pulling in from svn, but make 
:: sure you follow all the steps or you will get 
:: nasty errors with the sync. Keep in mind the 
:: –no-ff on the merge is very important to include. 
:: We also want to make sure everything is fully updated from 
:: both Github and the svn server before performing the push to svn.
::  Source: http://ben.lobaugh.net/blog/147853/creating-a-two-way-sync-between-a-github-repository-and-subversion

git checkout master
git pull origin master
git checkout svnsync
git svn rebase
git merge --no-ff master
git commit
git svn dcommit