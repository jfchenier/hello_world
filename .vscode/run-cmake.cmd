#!/bin/bash
:<<BATCH
    @REM # This can be run as a batch or a bash script. It enable the virtual environment before calling cmake.
    @REM # This is a workaround because vscode cannot run cmake inside the virtual environment.
    @REM # source https://github.com/microsoft/vscode-cmake-tools/issues/2301

    @echo off
    set SOURCE=%~dp0
    set NO_BANNER=""
    call %SOURCE%..\activate.bat
    @echo on
    call cmake %*
    @echo off
    exit /b
BATCH

SOURCE=$( realpath $( dirname -- "${BASH_SOURCE[0]}"; ); )
source $SOURCE/activate.sh
cmake "$@"
