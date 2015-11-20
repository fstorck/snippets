:: performs a hot backup on all repositories in the given root dirctory
:: usage svn_backup [DUMPTYPE] [RepoSrcDir] [BackupDir]

@setlocal

@echo Running with arguments: 
@echo [Arg1] : %1
@echo [Arg2] : %2
@echo [Arg3] : %3

@set CURRENTTIME=%TIME%
@set EXECDIR=%~dp0%

:: Zusammensetzung Archivname
@set TIMESTAMP=%DATE:~6,4%%DATE:~3,2%%DATE:~0,2%
@set LOGFILE=%EXECDIR%_log\%TIMESTAMP%_svnbackup.log 

@if not exist %EXECDIR%_log mkdir %EXECDIR%_log

@set _REPOS=%2
::@set _REBUP=%3\%DATE%.%1
@set _REBUP=%3.%1
@set _RELST=%3.%1\svnrepos.txt

@if not exist %_REBUP% (
@echo [%TIME%] Creating Backupdirectory %_REBUP% ...
mkdir %_REBUP%
)

@echo [%TIME%] SVN Repository Backup to %_REPUP%

@dir %_REPOS% /b /ad  > %_RELST%

@if "%1" == "SVNDUMP" GOTO SVNDUMP
@if "%1" == "HOTCOPY" GOTO HOTCOPY

@echo [%TIME%] Unknown Option %1 >> %LOGFILE%

@goto CLEANUP

:SVNDUMP
:: performing a svndump in flatfiles
:: iterating directories

@echo [%TIME%] Running SVNDUMP...

@set _BUPRC=%~dp0svn_backup.svndump.bat

@for /F %%x in (%_RELST%) DO (
  @echo [%TIME%] Running %_BUPRC% %%x %_REPOS% %_REBUP% ...
  @call %_BUPRC% %%x %_REPOS% %_REBUP% >> %LOGFILE%
)

@GOTO CLEANUP

:HOTCOPY
:: performing a hotcopy of svn repositories
:: iterating directories

@echo [%TIME%] Running HOTCOPY...

@set _BUPRC=%~dp0svn_backup.hotcopy.bat

@for /F %%x in (%_RELST%) DO (
  @echo [%TIME%] Running %_BUPRC% %%x %_REPOS% %_REBUP% ...
  @call %_BUPRC% %%x %_REPOS% %_REBUP% >> %LOGFILE%
)
@GOTO CLEANUP

:CLEANUP
@DEL %_RELST%
@endlocal


