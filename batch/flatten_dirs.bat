echo Src: %1
echo Dst: %2

for /r "%1" %%f in (*) do @copy "%%f" "%2"
