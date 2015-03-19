:: removes temp files, usually created by Visual Studio and other IDEs

echo Cleanup : "%1"
if not "%1"=="" cd "%1"

del /S *.ncb *.pdb *.obj *.o *.pyc *.pch 
pause