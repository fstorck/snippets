::Creates a Symbolic link in execution directory with foldername 
::from path given

@if not exist "%1" (

@echo ERROR: "%1" is not a valid path or does not exist.
@goto END
)

for %%* in (%1) do @set CurrDirName=%%~nx*
::echo %CurrDirName%

@echo Creating Symlink : 

mklink /D "%CurrDirName%" "%1" 

:END
pause
