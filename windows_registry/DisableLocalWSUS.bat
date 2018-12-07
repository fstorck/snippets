net stop wuauserv
net stop bits
net stop dosvc

echo %~dp0
regedit /S "%~dp0DisableLocalWSUS.reg" 

net start wuauserv
net start bits
net start dosvc

pause