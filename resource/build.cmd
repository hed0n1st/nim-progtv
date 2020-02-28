@echo off
%NIMPATH%\dist\mingw32\bin\windres -O coff progtv.rc -o progtv32.res
%NIMPATH%\dist\mingw64\bin\windres -O coff progtv.rc -o progtv64.res
