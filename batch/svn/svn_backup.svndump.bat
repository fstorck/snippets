:: performs a hotcopy on a given svn repository
@setlocal
:: repository name
@set _REPOS=%~nx1
:: source repository path 
@set _SRC=%2
:: destination path
@set _DST=%3

@echo [%TIME%] SVNDUMP: %_REPOS%

@svnadmin verify  %_SRC%\%_REPOS% --quiet

@echo [%TIME%] Verifying : %_SRC%\%_REPOS%

@if errorlevel 1 (
@echo [%TIME%] Error verifying repository: %_SRC%\%_REPOS%
@exit /B 1
)

@echo [%TIME%] Backing up : %_SRC%\%_REPOS%

@svnadmin dump --quiet --memory-cache-size 512 --incremental --deltas %_SRC%\%_REPOS% > %_DST%\%_REPOS%.svndump

@echo [%TIME%] Finished.

@endlocal
@exit /B 0
