@echo off
@REM Advanced Firewall Rule Manager Script v1.0 for Windows
@REM Author: USTA

chcp 1254 >nul
setlocal enabledelayedexpansion

:check_admin
cls
echo.
echo                  Firewall Operations
echo    Advanced Firewall Rule Manager Script v1.0 for Windows
echo    Author: USTA
echo.
echo    ======================================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo  [INFO] Admin Required, Wait!
    echo.
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:menu
cls
echo.
echo                  Firewall Operations
echo    Advanced Firewall Rule Manager Script v1.0 for Windows
echo    Author: USTA
echo.
echo    ======================================================
echo.
echo  [1] SEARCH exe files
echo  [2] CREATE new firewall rules
echo  [3] EXIT
echo.
set /p menu_choice=">> Select option [1/2/3]: "

if /i "%menu_choice%"=="1" goto search
if /i "%menu_choice%"=="2" goto create
if /i "%menu_choice%"=="3" goto exit
goto menu

:search
cls
echo.
echo                  Firewall Operations
echo    Advanced Firewall Rule Manager Script v1.0 for Windows
echo    Author: USTA
echo.
echo    ======================================================
echo.
echo                  Search exe files
echo.
echo  [1] Main Menu
echo  [2] Next
echo.
set /p search_choice=">> Select option [1/2]: "
if /i "%search_choice%"=="1" goto menu
if /i "%search_choice%"=="2" goto next
goto search

:next
cls
echo.
echo                  Firewall Operations
echo    Advanced Firewall Rule Manager Script v1.0 for Windows
echo    Author: USTA
echo.
echo    ======================================================
echo.
echo                  Search exe files
echo.
set /p folder_path="> Folder Path (e.g., 'C:\Program Files\Adobe'): "

if not exist "!folder_path!" (
    echo.
    echo  [ERROR] Folder not found!
    echo.
    echo  [1] Main Menu
    echo  [2] Try Again
    echo.
    set /p next_choice=">> Select option [1/2]: "
    if /i "!next_choice!"=="1" goto menu
    goto next
)

set "block_list=%USERPROFILE%\Desktop\block_list.txt"
> "%block_list%" (
    for /r "%folder_path%" %%x in (*.exe) do (
        echo %%x
    )
)

set /a total_exe=0
for /f "usebackq tokens=*" %%a in (`type "%block_list%"`) do set /a total_exe+=1
if %total_exe% equ 0 (
    echo.
    echo  [WARNING] exe file not found in the folder path!
    echo.
    echo  [1] Main Menu
    echo  [2] Try Again
    echo.
    set /p next_choice=">> Select option [1/2]: "
    if /i "!next_choice!"=="1" goto menu
    goto next
)

echo.
echo  [INFO] %total_exe% exe file(s) written in
echo  %block_list%
echo.
echo  [1] Main Menu
echo  [2] Create Firewall Rules from block_list.txt
echo.
set /p next_choice=">> Select option [1/2]: "
if /i "%next_choice%"=="2" goto create
goto menu

:create
cls
echo.
echo                  Firewall Operations
echo    Advanced Firewall Rule Manager Script v1.0 for Windows
echo    Author: USTA
echo.
echo    ======================================================
echo.
echo          Create Firewall Rules from block_list.txt
echo.
echo  [1] Main Menu
echo  [2] Continue
echo.
set /p create_choice=">> Select option [1/2]: "
if /i "%create_choice%"=="1" goto menu
if /i "%create_choice%"=="2" goto continue
goto create

:continue
cls
echo.
echo                  Firewall Operations
echo    Advanced Firewall Rule Manager Script v1.0 for Windows
echo    Author: USTA
echo.
echo    ======================================================
echo.
echo          Create Firewall Rules from block_list.txt
echo.

set "block_list=%USERPROFILE%\Desktop\block_list.txt"
if not exist "%block_list%" (
    echo  [ERROR] Block List not found!
    echo  Block List: %block_list%
    echo.
    echo  [1] Main Menu
    echo  [2] Try Again
    echo.
    set /p continue_choice=">> Select option [1/2]: "
    if /i "!continue_choice!"=="1" goto menu
    goto continue
)

set /a total_to_block=0
for /f "usebackq tokens=*" %%a in (`type "%block_list%"`) do set /a total_to_block+=1

if %total_to_block% equ 0 (
    echo  [WARNING] Block List empty!
    echo  Block List: %block_list%
    echo.
    echo  [1] Main Menu
    echo  [2] Try Again
    echo.
    set /p continue_choice=">> Select option [1/2]: "
    if /i "!continue_choice!"=="1" goto menu
    goto continue
)

set /a out_created=0
set /a in_created=0
set /a error_count=0

set "timestamp=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "timestamp=%timestamp: =0%"
set "log_file=%USERPROFILE%\Desktop\log_%timestamp%.txt"

for /f "usebackq tokens=* delims=" %%a in (`type "%block_list%"`) do (
    set "exe_path=%%a"
    for /f "tokens=*" %%i in ("!exe_path!") do set "exe_path=%%i"
    for %%i in ("!exe_path!") do set "exe_name=block_%%~ni"

    netsh advfirewall firewall add rule name="!exe_name!_OUT" dir=out program="!exe_path!" action=block >nul 2>&1
    if !errorlevel! equ 0 (
        echo [Created] !exe_name!_OUT !date! !time! >> "%log_file%"
        set /a out_created+=1
        echo [Created] !exe_name!_OUT
    ) else (
        echo  [Failed] !exe_name!_OUT !date! !time! >> "%log_file%"
        set /a error_count+=1
        echo  [Failed] !exe_name!_OUT
    )

    netsh advfirewall firewall add rule name="!exe_name!_IN" dir=in program="!exe_path!" action=block >nul 2>&1
    if !errorlevel! equ 0 (
        echo [Created] !exe_name!_IN !date! !time! >> "%log_file%"
        set /a in_created+=1
        echo [Created] !exe_name!_IN
    ) else (
        echo  [Failed] !exe_name!_IN !date! !time! >> "%log_file%"
        set /a error_count+=1
        echo  [Failed] !exe_name!_IN
    )
)

set /a total_created=out_created+in_created
echo.
echo  [Created] %total_created% Total Rule(s) = %out_created% Outbound + %in_created% Inbound
echo   [Failed] %error_count% Total Rule(s)
echo.
echo  [1] Main Menu
echo  [2] Exit
echo.
set /p continue_choice=">> Select option [1/2]: "
if /i "%continue_choice%"=="2" goto exit
goto menu

:exit
echo.
echo  [INFO] Firewall Operations v1.0 Exiting...
echo.
timeout /t 2 >nul
endlocal
exit
