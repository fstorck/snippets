:: performs a hotcopy on a given svn repository

:: repository name
@set _REPOS=%~nx1
:: source repository path 
@set _SRC=%2
:: destination path
@set _DST=%3

@echo HOTCOPY: %_REPOS%
@svnadmin hotcopy --clean-logs %_SRC%\%_REPOS% %_DST%\%_REPOS%
