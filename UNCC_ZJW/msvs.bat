echo off
REM \author Zachary Wartell <zwartell@uncc.edu>
REM 
REM Run this script from Boost\UNCC_ZJW
REM
REM msvs.bat MSVS_ARCH MSVS_VERSION
REM
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

if %1=="/?" (
	echo msvs.bat MSVS_ARCH MSVS_VERSION
	echo 
	echo  MSVS_ARCH = (32 | 64)
	echo      determines whether compilation result is for 32 or 64 architecture
	echo  MSVS_VERSION = (2010 | 2015)
	echo      determines what version of MSVS is used to compile boost. 

	exit /b
)

set MSVS_ARCH=%1
set MSVS_VERSION=%2

set TPL_DIR=..

REM Follow MSVS convention for directory name (Platform MSVS macro)
if %MSVS_ARCH%=="64" (
	set INSTALL_DIR=%TPL_DIR%\install\MSVS_%MSVS_VERSION%\x64\
) else if %MSVS_ARCH%=="32" (
	set INSTALL_DIR=%TPL_DIR%\install\MSVS_%MSVS_VERSION%\win32\
) else (
	echo MSVS_ARCH %MSVS_ARCH% , illegal value!
	echo For help type: $0 /? 
	exit /b
)

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

if %MSVS_VERSION%=="2010" (
    REM Setup MSVS 2010 Compiler Settings
    pushd "%VS100COMNTOOLS%\..\..\VC"
    REM dir
    REM popd
    REM goto exit_popd
    call vcvarsall.bat %MSVS_ARCH% 
    popd
    TOOLSET=msvc-10.0

) ELSE IF %MSVS_VERSION%="2015" (
    REM Setup MSVS 2010 Compiler Settings
    pushd "%VS140COMNTOOLS%\..\..\VC"
    REM dir
    REM popd
    REM goto exit_popd
    call vcvarsall.bat %MSVS_ARCH% 
    popd

    TOOLSET=msvc-14.0
ELSE (
    echo MSVS_VERSION %MSVS_VERSION% not yet supported by this script...
    exit /b
)

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
.\b2 --layout=versioned --prefix=%INSTALL_DIR% --libdir=%INSTALL_LIB_DIR% toolset=%TOOLSET% runtime-debugging=on runtime-link=shared link=shared threading=multi address-model=64 --with-system --with-filesystem install 
echo off
:exit_popd

popd
