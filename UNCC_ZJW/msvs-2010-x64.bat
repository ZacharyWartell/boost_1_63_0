echo off
REM \author Zachary Wartell <zwartell@uncc.edu>
REM 
REM *** UPDATE COMMENTS ***
REM Run this script from libxml2\UNCC_ZJW-build
REM
REM This script is an attempt to automate the instructions in libxml2\win32\Readme.txt
REM The compiler settings and directory paths are based my needs for compiling the suite
REM of open source code described here: 
REM
REM     https://cci-git.uncc.edu/UNCC_Graphics_Third_Party_Libraries/AMVR-Third_Party_Libraries.git 

REM \todo how to make this more flexible, will this generate code the fails on intel64 machines?

REM set DEBUG_EXIT1
REM set MSVS_ARCH=amd64
REM set MSVS_ARCH=x86_amd64

set MSVS_ARCH=amd64


set TPL_DIR=..
set INSTALL_DIR=%TPL_DIR%\install\MSVS_2010\x64\
set INSTALL_LIB_DIR=%INSTALL_DIR%lib\

REM set INSTALL_BASE_DIR=%TPL_DIR%\install
REM set INSTALL_BIN_DIR=%INSTALL_DIR%bin
REM set INSTALL_INC_DIR=%INSTALL_DIR%include

REM dir %INSTALL_BASE_DIR%
REM dir %INSTALL_INC_DIR%
REM dir %INSTALL_LIB_DIR%
REM
if DEFINED DEBUG_EXIT1 (
	echo on
	cd
	echo "%INSTALL_DIR%"
	dir "%INSTALL_DIR%"

	exit /b
)

REM \todo generalize this line 
REM other architectures?

REM Setup MSVS 2010 Compiler Settings
pushd "%VS100COMNTOOLS%\..\..\VC"
REM dir
REM popd
REM goto exit_popd
call vcvarsall.bat %MSVS_ARCH% 
popd

REM Run Boost booststrap

pushd ..
if NOT EXIST b2.exe (
	bootstrap
)
popd


pushd ..

echo on
echo --layout=versioned --prefix="%INSTALL_DIR%" --libdir="%INSTALL_LIB_DIR%" toolset=msvc-10.0 runtime-debugging=on runtime-link=shared link=shared threading=multi address-model=64 --with-system --with-filesystem install
REM .\b2 --clean
REM .\b2 --layout=versioned toolset="msvc-10.0" runtime-debugging=on runtime-link=shared link=shared threading=multi address-model=64 --with-system --with-filesystem install 
.\b2 --layout=versioned --prefix=%INSTALL_DIR% --libdir=%INSTALL_LIB_DIR% toolset=msvc-10.0 runtime-debugging=on runtime-link=shared link=shared threading=multi address-model=64 --with-system --with-filesystem install 
echo off
:exit_popd

popd
