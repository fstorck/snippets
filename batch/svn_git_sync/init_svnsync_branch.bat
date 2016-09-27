set SVN_URL=%1

git branch --no-track svnsync
git svn init -s %SVN_URL%
git svn fetch
git reset --hard remotes/trunk