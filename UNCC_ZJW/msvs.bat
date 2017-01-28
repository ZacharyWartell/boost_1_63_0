echo off
REM \author Zachary Wartell <zwartell@uncc.edu>
REM 
REM \brief
REM 
REM
REM This script is an attempt to automate the instructions in 

REM    http://www.boost.org/doc/libs/1_63_0/more/getting_started/windows.html
REM       
REM The compiler settings and directory paths are based my needs and conventions for compiling the suite
REM of open source code described here: 
REM
REM     https://cci-git.uncc.edu/UNCC_Graphics_Third_Party_Libraries/AMVR-Third_Party_Libraries.git 
REM

REM set DEBUG_EXIT1=1
REM set DEBUG_EXIT2=1

REM 
REM USAGE
REM
if "%1"=="/?" (
	echo Run this script from directory Boost\UNCC_ZJW
	echo. 
	echo msvs.bat MSVS_BITS MSVS_VERSION
	echo. 
	echo MSVS_BITS = 32 or 64 
	echo      determines whether compilation result is for 32 or 64 architecture
	echo. 
	echo MSVS_VERSION = 2010 or 2015
	echo      determines what version of MSVS is used to compile boost. 
	echo. 
	echo Currently only boost_system and boost_filesystem are compiled.
	echo.
	echo Installation directory is:
	echo.
	echo       Boost\..\install\MSVS_%%MSVS_VERSION%%\x64\
	echo. 
	echo    OR
	echo. 
	echo       Boost\..\install\MSVS_%%MSVS_VERSION%%\win32\

	exit /b
)

set MSVS_BITS=%1
set MSVS_VERSION=%2

REM Boost terms
set ADDRESS_MODEL=%MSVS_BITS%

set TPL_DIR=..

REM Follow MSVS convention for directory name (Platform MSVS macro)
if "%MSVS_BITS%"=="64" (
	set INSTALL_DIR=%TPL_DIR%\install\MSVS_%MSVS_VERSION%\x64\
	set MSVS_ARCH=amd64
) else if "%MSVS_BITS%"=="32" (
	set INSTALL_DIR=%TPL_DIR%\install\MSVS_%MSVS_VERSION%\win32\
	set MSVS_ARCH=x86
) else (
	echo MSVS_BITS %MSVS_BITS% is illegal value!
	echo For help type: %0 /? 
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

REM \todo generalize this line other architectures?
if "%MSVS_VERSION%"=="2010" (
    REM Setup MSVS 2010 Compiler Settings
    pushd "%VS100COMNTOOLS%\..\..\VC"
    REM dir
    REM popd
    REM goto exit_popd
    call vcvarsall.bat %MSVS_ARCH% 
    popd
    set TOOLSET=msvc-10.0

) ELSE IF "%MSVS_VERSION%"=="2015" (
    REM Setup MSVS 2015 Compiler Settings
    pushd "%VS140COMNTOOLS%\..\..\VC"
    REM dir
    REM popd
    REM goto exit_popd
    call vcvarsall.bat %MSVS_ARCH%  
    popd

    set TOOLSET=msvc-14.0
) ELSE (
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

REM .\b2 --clean
REM .\b2 --layout=versioned toolset="msvc-10.0" runtime-debugging=on runtime-link=shared link=shared threading=multi address-model=64 --with-system --with-filesystem install 
if DEFINED DEBUG_EXIT2 (
	echo .\b2 --layout=versioned --prefix=%INSTALL_DIR% --libdir=%INSTALL_LIB_DIR% toolset=%TOOLSET% runtime-debugging=on runtime-link=shared link=shared threading=multi address-model=%ADDRESS_MODEL% --with-system --with-filesystem install 
) else (
	.\b2 --layout=versioned --prefix=%INSTALL_DIR% --libdir=%INSTALL_LIB_DIR% toolset=%TOOLSET% runtime-debugging=on runtime-link=shared link=shared threading=multi address-model=%ADDRESS_MODEL% --with-system --with-filesystem install 
)
echo off
:exit_popd

popd
