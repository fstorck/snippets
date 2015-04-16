:: performs a hotcopy on a given svn repository

:: repository name
@set _REPOS=%~nx1
:: source repository path 
@set _SRC=%2
:: destination path
@set _DST=%3

@echo SVNDUMP: %_REPOS%
:: @echo %_DST%\%_REPOS%.svndump
@svnadmin dump %_SRC%\%_REPOS% > %_DST%\%_REPOS%.svndump
