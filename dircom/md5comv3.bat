@echo off
setlocal enableextensions enabledelayedexpansion
rem 作者：rubble@126.com
rem 17:55 2009-4-14 版本：0.3
if "%1" == "" (
        echo 使用说明：请在命令行参数上指明两个目录，或在这里按提示输入。
        echo 命令行参数格式：批处理名 ^<目录1^> ^<目录2^>
        set /p dira=请输入第一个目录的名字（可拖放并输入回车）：
)
if "%2" == "" (
        set /p dirb=请输入第二个目录的名字（可拖放并输入回车）：
)
set dira=%1
set dirb=%2
if "%dira%" == "" exit /b
if "%dirb%" == "" exit /b
for /F "delims=. tokens=1" %%A in ("%TIME%") do set startTime=%%A
for /F "delims=: tokens=1,2,3" %%A in ("%startTime%") do (
        set startH=%%A
        set startM=%%B
        set startS=%%C
)

set TEMPDIR=TEMPMD5\
rd /Q /S %TEMPDIR% 1>NUL 2>NUL
md %TEMPDIR%
set mdfive=md5v3.txt
set count=0
echo 请稍候……
echo 正在比较 %dira% 和 %dirb% 中共同存在的文件的 md5 值 > %mdfive%
set list_fn_md=%TEMPDIR%list_fn_md
set list_fn_nmd=%TEMPDIR%list_fn_nmd
set list_fn_oa=%TEMPDIR%list_fn_oa
set list_fn_ob=%TEMPDIR%list_fn_ob
set list_all_md=%TEMPDIR%list_all_md
set md_count=0
for %%a in (%dira%\*) do (
        set fn=%%~nxa
        for /f "tokens=1 delims= " %%A in ('md5sum "%%a"') do set mda=%%A
        if "!mda:~0,1!" == "\" set mda=!mda:~1,1024!
        rem 以 !mda! 为文件名，记录 md5 为 !mda! 的文件
        call :ADDMDFN "%TEMPDIR%!mda!" "%dira%\!fn!"
        rem 把 md5 值记录到文件里，保证不重复
        call :ADDMDLIST !mda!
        if exist "%dirb%\!fn!" (
            for /f "tokens=1 delims= " %%A in ('md5sum "%dirb%\!fn!"') do set mdb=%%A
            call :ADDMDFN "%TEMPDIR%!mdb!" "%dirb%\!fn!"
            if "!mdb:~0,1!" == "\" set mdb=!mdb:~1,1024!
            if "!mda!" == "!mdb!" (
                rem 记录文件名相同并且 md5 相同的文件
                echo !mda! !mdb! !fn! >> "!list_fn_md!"
            ) else (
                rem 记录文件名相同但 md5 不相同的文件
                echo !mda! !mdb! !fn! >> "!list_fn_nmd!"
                call :ADDMDLIST !mdb!
            )
        ) else (
            rem 记录只在 %dira% 中出现的文件
            echo !mda! !fn! >> "!list_fn_oa!"
        )
        call :PROGRESS !count!
        set /a count=!count!+1
)
for %%a in (%dirb%\*) do (
        set fn=%%~nxa
        if not exist "%dira%\!fn!" (
            for /f "tokens=1 delims= " %%A in ('md5sum "%%a"') do set mdb=%%A
            if "!mdb:~0,1!" == "\" set mdb=!mdb:~1,1024!
            rem 记录只在 %dirb% 中出现的文件
            echo !mdb! !fn! >> "!list_fn_ob!"
            rem 把 md5 值记录到文件里，保证不重复
            call :ADDMDLIST !mdb!
            call :ADDMDFN "%TEMPDIR%!mdb!" "%dirb%\!fn!"
        )
        call :PROGRESS !count!
        set /a count=!count!+1
)
echo 统计：>>%mdfive%
echo 左：%dira% >> %mdfive%
echo 右：%dirb% >> %mdfive%
echo 两个目录中都存在且 md5 相同的文件：>> %mdfive%
call :OUTPUTLIST "%list_fn_md%"
echo ===============================================================================================>> %mdfive%
echo 两个目录中都存在但 md5 不相同的文件：>> %mdfive%
call :OUTPUTLIST "%list_fn_nmd%"
echo ===============================================================================================>> %mdfive%
echo 只在目录 %dira% 中存在的文件：>> %mdfive%
call :OUTPUTLIST "%list_fn_oa%"
echo ===============================================================================================>> %mdfive%
echo 只在目录 %dirb% 中存在的文件：>> %mdfive%
call :OUTPUTLIST "%list_fn_ob%"
echo ===============================================================================================>> %mdfive%
echo 以 md5 汇总的文件列表：>> %mdfive%
call :OUTPUTLIST_MD "%list_all_md%"
echo 共计 %md_count% 个 md5 值。>> %mdfive%

goto ALLDONE

rem 参数 %1 必须加双引号
:OUTPUTLIST
if %1 == "" goto :EOF
if not exist %1 goto :EOF
for /f "tokens=1* delims= " %%a in (%~1) do (
    echo %%a %%b >> %mdfive%
)
goto :EOF

rem 参数 %1 必须加双引号
:OUTPUTLIST_MD
if %1 == "" goto :EOF
if not exist %1 goto :EOF
for /f "tokens=1* delims= " %%a in (%~1) do (
    echo %%a >> %mdfive%
    for /f "tokens=1* delims= " %%A in (!TEMPDIR!%%a) do (
        echo %%A %%B >> %mdfive%
    )
    set /a md_count+=1
    echo. >> %mdfive%
)
goto :EOF

rem 函数：把 md5 值保存到一个名为 !list_all_md! 的文件里，
rem 并保证不保存重复的 md5 值
:ADDMDLIST
if %1 == "" goto :EOF
if exist "!list_all_md!" (
        rem 这里的 delims 要么删除，要么做成像下面这行的样子，在等号后面加个空格
        rem for /f "tokens=1 delims= " %%a in (!list_all_md!) do (
        for /f "tokens=1 " %%a in (!list_all_md!) do (
            if "%%a" == "%1" goto :EOF
        )
)
echo %1 >> "!list_all_md!"
goto :EOF

rem 函数：以 %1 为文件名，保存 %2
rem %1：在这个应用里是 md5 值
rem %2：md5 值为 %1 的文件
:ADDMDFN
if %1 == "" goto :EOF
if %2 == "" goto :EOF
echo %2 >> %1
goto :EOF

rem :PROGRESS
rem set tips=/-\ /-\ **
rem set backspace=
rem set /a index=%1%%10
rem set /a char=%index%%%4
rem rem if %index% EQU 0 set /p=▌<NUL
rem if %char% EQU 3 (set /p=^|<NUL) else (set /p=!tips:~%index%,1!<NUL)
rem set /p=%backspace%<NUL
rem goto :EOF

:PROGRESS
set tips=
set backspace=
set /a char=%1%%7
set /p=!tips:~%char%,1!<NUL
set /p=%backspace%<NUL
goto :EOF

:ALLDONE

rd /Q /S %TEMPDIR% 1>NUL 2>NUL
for /F "delims=. tokens=1" %%A in ("%TIME%") do set endTime=%%A
for /F "delims=: tokens=1,2,3" %%A in ("%endTime%") do (
        set endH=%%A
        set endM=%%B
        set endS=%%C
)
if "%endM:~0,1%" == "0" set endM=%endM:~1,1%
if "%endS:~0,1%"=="0" set endS=%endS:~1,1%
for /F "delims=: tokens=1,2,3" %%A in ("%startTime%") do (
        set startH=%%A
        set startM=%%B
        set startS=%%C
)
if "%startM:~0,1%"=="0" set startM=%startM:~1,1%
if "%startS:~0,1%"=="0" set startS=%startS:~1,1%
set /A totalTime=%endH%*3600+%endM%*60+%endS%-(%startH%*3600+%startM%*60+%startS%)
echo 共用时 %totalTime% 秒。
echo 起始时间：%startH%:%startM%:%startS%>>%mdfive%
echo 结束时间：%endH%:%endM%:%endS%>>%mdfive%
echo 共用时 %totalTime% 秒。>>%mdfive%
endlocal
@echo on
