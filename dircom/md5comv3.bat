@echo off
setlocal enableextensions enabledelayedexpansion
rem ×÷Õß£ºrubble@126.com
rem 17:55 2009-4-14 °æ±¾£º0.3
if "%1" == "" (
        echo Ê¹ÓÃËµÃ÷£ºÇëÔÚÃüÁîĞĞ²ÎÊıÉÏÖ¸Ã÷Á½¸öÄ¿Â¼£¬»òÔÚÕâÀï°´ÌáÊ¾ÊäÈë¡£
        echo ÃüÁîĞĞ²ÎÊı¸ñÊ½£ºÅú´¦ÀíÃû ^<Ä¿Â¼1^> ^<Ä¿Â¼2^>
        set /p dira=ÇëÊäÈëµÚÒ»¸öÄ¿Â¼µÄÃû×Ö£¨¿ÉÍÏ·Å²¢ÊäÈë»Ø³µ£©£º
)
if "%2" == "" (
        set /p dirb=ÇëÊäÈëµÚ¶ş¸öÄ¿Â¼µÄÃû×Ö£¨¿ÉÍÏ·Å²¢ÊäÈë»Ø³µ£©£º
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
echo ÇëÉÔºò¡­¡­
echo ÕıÔÚ±È½Ï %dira% ºÍ %dirb% ÖĞ¹²Í¬´æÔÚµÄÎÄ¼şµÄ md5 Öµ > %mdfive%
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
        rem ÒÔ !mda! ÎªÎÄ¼şÃû£¬¼ÇÂ¼ md5 Îª !mda! µÄÎÄ¼ş
        call :ADDMDFN "%TEMPDIR%!mda!" "%dira%\!fn!"
        rem °Ñ md5 Öµ¼ÇÂ¼µ½ÎÄ¼şÀï£¬±£Ö¤²»ÖØ¸´
        call :ADDMDLIST !mda!
        if exist "%dirb%\!fn!" (
            for /f "tokens=1 delims= " %%A in ('md5sum "%dirb%\!fn!"') do set mdb=%%A
            call :ADDMDFN "%TEMPDIR%!mdb!" "%dirb%\!fn!"
            if "!mdb:~0,1!" == "\" set mdb=!mdb:~1,1024!
            if "!mda!" == "!mdb!" (
                rem ¼ÇÂ¼ÎÄ¼şÃûÏàÍ¬²¢ÇÒ md5 ÏàÍ¬µÄÎÄ¼ş
                echo !mda! !mdb! !fn! >> "!list_fn_md!"
            ) else (
                rem ¼ÇÂ¼ÎÄ¼şÃûÏàÍ¬µ« md5 ²»ÏàÍ¬µÄÎÄ¼ş
                echo !mda! !mdb! !fn! >> "!list_fn_nmd!"
                call :ADDMDLIST !mdb!
            )
        ) else (
            rem ¼ÇÂ¼Ö»ÔÚ %dira% ÖĞ³öÏÖµÄÎÄ¼ş
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
            rem ¼ÇÂ¼Ö»ÔÚ %dirb% ÖĞ³öÏÖµÄÎÄ¼ş
            echo !mdb! !fn! >> "!list_fn_ob!"
            rem °Ñ md5 Öµ¼ÇÂ¼µ½ÎÄ¼şÀï£¬±£Ö¤²»ÖØ¸´
            call :ADDMDLIST !mdb!
            call :ADDMDFN "%TEMPDIR%!mdb!" "%dirb%\!fn!"
        )
        call :PROGRESS !count!
        set /a count=!count!+1
)
echo Í³¼Æ£º>>%mdfive%
echo ×ó£º%dira% >> %mdfive%
echo ÓÒ£º%dirb% >> %mdfive%
echo Á½¸öÄ¿Â¼ÖĞ¶¼´æÔÚÇÒ md5 ÏàÍ¬µÄÎÄ¼ş£º>> %mdfive%
call :OUTPUTLIST "%list_fn_md%"
echo ===============================================================================================>> %mdfive%
echo Á½¸öÄ¿Â¼ÖĞ¶¼´æÔÚµ« md5 ²»ÏàÍ¬µÄÎÄ¼ş£º>> %mdfive%
call :OUTPUTLIST "%list_fn_nmd%"
echo ===============================================================================================>> %mdfive%
echo Ö»ÔÚÄ¿Â¼ %dira% ÖĞ´æÔÚµÄÎÄ¼ş£º>> %mdfive%
call :OUTPUTLIST "%list_fn_oa%"
echo ===============================================================================================>> %mdfive%
echo Ö»ÔÚÄ¿Â¼ %dirb% ÖĞ´æÔÚµÄÎÄ¼ş£º>> %mdfive%
call :OUTPUTLIST "%list_fn_ob%"
echo ===============================================================================================>> %mdfive%
echo ÒÔ md5 »ã×ÜµÄÎÄ¼şÁĞ±í£º>> %mdfive%
call :OUTPUTLIST_MD "%list_all_md%"
echo ¹²¼Æ %md_count% ¸ö md5 Öµ¡£>> %mdfive%

goto ALLDONE

rem ²ÎÊı %1 ±ØĞë¼ÓË«ÒıºÅ
:OUTPUTLIST
if %1 == "" goto :EOF
if not exist %1 goto :EOF
for /f "tokens=1* delims= " %%a in (%~1) do (
    echo %%a %%b >> %mdfive%
)
goto :EOF

rem ²ÎÊı %1 ±ØĞë¼ÓË«ÒıºÅ
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

rem º¯Êı£º°Ñ md5 Öµ±£´æµ½Ò»¸öÃûÎª !list_all_md! µÄÎÄ¼şÀï£¬
rem ²¢±£Ö¤²»±£´æÖØ¸´µÄ md5 Öµ
:ADDMDLIST
if %1 == "" goto :EOF
if exist "!list_all_md!" (
        rem ÕâÀïµÄ delims ÒªÃ´É¾³ı£¬ÒªÃ´×ö³ÉÏñÏÂÃæÕâĞĞµÄÑù×Ó£¬ÔÚµÈºÅºóÃæ¼Ó¸ö¿Õ¸ñ
        rem for /f "tokens=1 delims= " %%a in (!list_all_md!) do (
        for /f "tokens=1 " %%a in (!list_all_md!) do (
            if "%%a" == "%1" goto :EOF
        )
)
echo %1 >> "!list_all_md!"
goto :EOF

rem º¯Êı£ºÒÔ %1 ÎªÎÄ¼şÃû£¬±£´æ %2
rem %1£ºÔÚÕâ¸öÓ¦ÓÃÀïÊÇ md5 Öµ
rem %2£ºmd5 ÖµÎª %1 µÄÎÄ¼ş
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
rem rem if %index% EQU 0 set /p=¨„<NUL
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
echo ¹²ÓÃÊ± %totalTime% Ãë¡£
echo ÆğÊ¼Ê±¼ä£º%startH%:%startM%:%startS%>>%mdfive%
echo ½áÊøÊ±¼ä£º%endH%:%endM%:%endS%>>%mdfive%
echo ¹²ÓÃÊ± %totalTime% Ãë¡£>>%mdfive%
endlocal
@echo on
