net stop wuauserv
rmdir C:\Windows\SoftwareDistribution /S /Q
wuauclt /detectnow


