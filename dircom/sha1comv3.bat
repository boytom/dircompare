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

set TEMPDIR=TEMPSHA1\
rd /Q /S %TEMPDIR% 1>NUL 2>NUL
md %TEMPDIR%
set shaone=sha1v3.txt
set count=0
echo 请稍候……
echo 正在比较 %dira% 和 %dirb% 中共同存在的文件的 sha1 值 > %shaone%
set list_fn_sha=%TEMPDIR%list_fn_sha
set list_fn_nsha=%TEMPDIR%list_fn_nsha
set list_fn_oa=%TEMPDIR%list_fn_oa
set list_fn_ob=%TEMPDIR%list_fn_ob
set list_all_sha=%TEMPDIR%list_all_sha
set sha_count=0
for %%a in (%dira%\*) do (
        set fn=%%~nxa
        for /f "tokens=1 delims= " %%A in ('sha1sum "%%a"') do set shaa=%%A
        if "!shaa:~0,1!" == "\" set shaa=!shaa:~1,1024!
        rem 以 !shaa! 为文件名，记录 sha1 为 !shaa! 的文件
        call :ADDMDFN "%TEMPDIR%!shaa!" "%dira%\!fn!"
        rem 把 sha1 值记录到文件里，保证不重复
        call :ADDMDLIST !shaa!
        if exist "%dirb%\!fn!" (
            for /f "tokens=1 delims= " %%A in ('sha1sum "%dirb%\!fn!"') do set shab=%%A
            call :ADDMDFN "%TEMPDIR%!shab!" "%dirb%\!fn!"
            if "!shab:~0,1!" == "\" set shab=!shab:~1,1024!
            if "!shaa!" == "!shab!" (
                rem 记录文件名相同并且 sha1 相同的文件
                echo !shaa! !shab! !fn! >> "!list_fn_sha!"
            ) else (
                rem 记录文件名相同但 sha1 不相同的文件
                echo !shaa! !shab! !fn! >> "!list_fn_nsha!"
                call :ADDMDLIST !shab!
            )
        ) else (
            rem 记录只在 %dira% 中出现的文件
            echo !shaa! !fn! >> "!list_fn_oa!"
        )
        call :PROGRESS !count!
        set /a count=!count!+1
)
for %%a in (%dirb%\*) do (
        set fn=%%~nxa
        if not exist "%dira%\!fn!" (
            for /f "tokens=1 delims= " %%A in ('sha1sum "%%a"') do set shab=%%A
            if "!shab:~0,1!" == "\" set shab=!shab:~1,1024!
            rem 记录只在 %dirb% 中出现的文件
            echo !shab! !fn! >> "!list_fn_ob!"
            rem 把 sha1 值记录到文件里，保证不重复
            call :ADDMDLIST !shab!
            call :ADDMDFN "%TEMPDIR%!shab!" "%dirb%\!fn!"
        )
        call :PROGRESS !count!
        set /a count=!count!+1
)
echo 统计：>>%shaone%
echo 左：%dira% >> %shaone%
echo 右：%dirb% >> %shaone%
echo 两个目录中都存在且 sha1 相同的文件：>> %shaone%
call :OUTPUTLIST "%list_fn_sha%"
echo ===============================================================================================>> %shaone%
echo 两个目录中都存在但 sha1 不相同的文件：>> %shaone%
call :OUTPUTLIST "%list_fn_nsha%"
echo ===============================================================================================>> %shaone%
echo 只在目录 %dira% 中存在的文件：>> %shaone%
call :OUTPUTLIST "%list_fn_oa%"
echo ===============================================================================================>> %shaone%
echo 只在目录 %dirb% 中存在的文件：>> %shaone%
call :OUTPUTLIST "%list_fn_ob%"
echo ===============================================================================================>> %shaone%
echo 以 sha1 汇总的文件列表：>> %shaone%
call :OUTPUTLIST_MD "%list_all_sha%"
echo 共计 %sha_count% 个 sha1 值。>> %shaone%

goto ALLDONE

rem 参数 %1 必须加双引号
:OUTPUTLIST
if %1 == "" goto :EOF
if not exist %1 goto :EOF
for /f "tokens=1* delims= " %%a in (%~1) do (
    echo %%a %%b >> %shaone%
)
goto :EOF

rem 参数 %1 必须加双引号
:OUTPUTLIST_MD
if %1 == "" goto :EOF
if not exist %1 goto :EOF
for /f "tokens=1* delims= " %%a in (%~1) do (
    echo %%a >> %shaone%
    for /f "tokens=1* delims= " %%A in (!TEMPDIR!%%a) do (
        echo %%A %%B >> %shaone%
    )
    set /a sha_count+=1
    echo. >> %shaone%
)
goto :EOF

rem 函数：把 sha1 值保存到一个名为 !list_all_sha! 的文件里，
rem 并保证不保存重复的 sha1 值
:ADDMDLIST
if %1 == "" goto :EOF
if exist "!list_all_sha!" (
        rem 这里的 delims 要么删除，要么做成像下面这行的样子，在等号后面加个空格
        rem for /f "tokens=1 delims= " %%a in (!list_all_sha!) do (
        for /f "tokens=1 " %%a in (!list_all_sha!) do (
            if "%%a" == "%1" goto :EOF
        )
)
echo %1 >> "!list_all_sha!"
goto :EOF

rem 函数：以 %1 为文件名，保存 %2
rem %1：在这个应用里是 sha1 值
rem %2：sha1 值为 %1 的文件
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
echo 起始时间：%startH%:%startM%:%startS%>>%shaone%
echo 结束时间：%endH%:%endM%:%endS%>>%shaone%
echo 共用时 %totalTime% 秒。>>%shaone%
endlocal
@echo on
