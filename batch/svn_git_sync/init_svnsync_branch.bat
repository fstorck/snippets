set SVN_URL=%1

git branch --no-track svnsync
git svn init --no-minimize-url -s %SVN_URL%
git svn fetch
git reset --hard remotes/origin/trunk