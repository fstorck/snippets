# Merge changes back from svn into Github trunk
# ----------------------------------------
#
# First all changes from svn are going to be 
# merged locally and staged to be pushed out 
# to the Github repository.
#
# Source: http://ben.lobaugh.net/blog/147853/creating-a-two-way-sync-between-a-github-repository-and-subversion


git checkout svnsync
git svn rebase
git checkout master
git merge svnsync
git push origin master