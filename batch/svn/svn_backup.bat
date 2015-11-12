:: performs a hot backup on all repositories in the given root dirctory
:: usage svn_backup [DUMPTYPE] [RepoSrcDir] [BackupDir]

@setlocal

@set _REPOS=%2
@set _REBUP=%3\%DATE%.%1
@set _RELST=%3\svnrepos.txt

@echo SVN Repository Backup

@dir %_REPOS% /b /ad  > %_RELST%

if "%1%" == "SVNDUMP" GOTO SVNDUMP
if "%1%" == "HOTCOPY" GOTO HOTCOPY

:SVNDUMP
:: performing a svndump in flatfiles
:: iterating directories
@set _BUPRC=%~dp0svn_backup.svndump.bat
if not exist %_REBUP% mkdir %_REBUP%

@for /F %%x in (%_RELST%) DO @call %_BUPRC% %%x %_REPOS% %_REBUP%
GOTO CLEANUP

:HOTCOPY
:: performing a hotcopy of svn repositories
:: iterating directories
@set _BUPRC=%~dp0svn_backup.hotcopy.bat
if not exist %_REBUP% mkdir %_REBUP%

@for /F %%x in (%_RELST%) DO @call %_BUPRC% %%x %_REPOS% %_REBUP%
GOTO CLEANUP

:CLEANUP
@DEL %_RELST%
@endlocal


