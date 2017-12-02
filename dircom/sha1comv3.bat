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

set TEMPDIR=TEMPSHA1\
rd /Q /S %TEMPDIR% 1>NUL 2>NUL
md %TEMPDIR%
set shaone=sha1v3.txt
set count=0
echo ÇëÉÔºò¡­¡­
echo ÕıÔÚ±È½Ï %dira% ºÍ %dirb% ÖĞ¹²Í¬´æÔÚµÄÎÄ¼şµÄ sha1 Öµ > %shaone%
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
        rem ÒÔ !shaa! ÎªÎÄ¼şÃû£¬¼ÇÂ¼ sha1 Îª !shaa! µÄÎÄ¼ş
        call :ADDMDFN "%TEMPDIR%!shaa!" "%dira%\!fn!"
        rem °Ñ sha1 Öµ¼ÇÂ¼µ½ÎÄ¼şÀï£¬±£Ö¤²»ÖØ¸´
        call :ADDMDLIST !shaa!
        if exist "%dirb%\!fn!" (
            for /f "tokens=1 delims= " %%A in ('sha1sum "%dirb%\!fn!"') do set shab=%%A
            call :ADDMDFN "%TEMPDIR%!shab!" "%dirb%\!fn!"
            if "!shab:~0,1!" == "\" set shab=!shab:~1,1024!
            if "!shaa!" == "!shab!" (
                rem ¼ÇÂ¼ÎÄ¼şÃûÏàÍ¬²¢ÇÒ sha1 ÏàÍ¬µÄÎÄ¼ş
                echo !shaa! !shab! !fn! >> "!list_fn_sha!"
            ) else (
                rem ¼ÇÂ¼ÎÄ¼şÃûÏàÍ¬µ« sha1 ²»ÏàÍ¬µÄÎÄ¼ş
                echo !shaa! !shab! !fn! >> "!list_fn_nsha!"
                call :ADDMDLIST !shab!
            )
        ) else (
            rem ¼ÇÂ¼Ö»ÔÚ %dira% ÖĞ³öÏÖµÄÎÄ¼ş
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
            rem ¼ÇÂ¼Ö»ÔÚ %dirb% ÖĞ³öÏÖµÄÎÄ¼ş
            echo !shab! !fn! >> "!list_fn_ob!"
            rem °Ñ sha1 Öµ¼ÇÂ¼µ½ÎÄ¼şÀï£¬±£Ö¤²»ÖØ¸´
            call :ADDMDLIST !shab!
            call :ADDMDFN "%TEMPDIR%!shab!" "%dirb%\!fn!"
        )
        call :PROGRESS !count!
        set /a count=!count!+1
)
echo Í³¼Æ£º>>%shaone%
echo ×ó£º%dira% >> %shaone%
echo ÓÒ£º%dirb% >> %shaone%
echo Á½¸öÄ¿Â¼ÖĞ¶¼´æÔÚÇÒ sha1 ÏàÍ¬µÄÎÄ¼ş£º>> %shaone%
call :OUTPUTLIST "%list_fn_sha%"
echo ===============================================================================================>> %shaone%
echo Á½¸öÄ¿Â¼ÖĞ¶¼´æÔÚµ« sha1 ²»ÏàÍ¬µÄÎÄ¼ş£º>> %shaone%
call :OUTPUTLIST "%list_fn_nsha%"
echo ===============================================================================================>> %shaone%
echo Ö»ÔÚÄ¿Â¼ %dira% ÖĞ´æÔÚµÄÎÄ¼ş£º>> %shaone%
call :OUTPUTLIST "%list_fn_oa%"
echo ===============================================================================================>> %shaone%
echo Ö»ÔÚÄ¿Â¼ %dirb% ÖĞ´æÔÚµÄÎÄ¼ş£º>> %shaone%
call :OUTPUTLIST "%list_fn_ob%"
echo ===============================================================================================>> %shaone%
echo ÒÔ sha1 »ã×ÜµÄÎÄ¼şÁĞ±í£º>> %shaone%
call :OUTPUTLIST_MD "%list_all_sha%"
echo ¹²¼Æ %sha_count% ¸ö sha1 Öµ¡£>> %shaone%

goto ALLDONE

rem ²ÎÊı %1 ±ØĞë¼ÓË«ÒıºÅ
:OUTPUTLIST
if %1 == "" goto :EOF
if not exist %1 goto :EOF
for /f "tokens=1* delims= " %%a in (%~1) do (
    echo %%a %%b >> %shaone%
)
goto :EOF

rem ²ÎÊı %1 ±ØĞë¼ÓË«ÒıºÅ
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

rem º¯Êı£º°Ñ sha1 Öµ±£´æµ½Ò»¸öÃûÎª !list_all_sha! µÄÎÄ¼şÀï£¬
rem ²¢±£Ö¤²»±£´æÖØ¸´µÄ sha1 Öµ
:ADDMDLIST
if %1 == "" goto :EOF
if exist "!list_all_sha!" (
        rem ÕâÀïµÄ delims ÒªÃ´É¾³ı£¬ÒªÃ´×ö³ÉÏñÏÂÃæÕâĞĞµÄÑù×Ó£¬ÔÚµÈºÅºóÃæ¼Ó¸ö¿Õ¸ñ
        rem for /f "tokens=1 delims= " %%a in (!list_all_sha!) do (
        for /f "tokens=1 " %%a in (!list_all_sha!) do (
            if "%%a" == "%1" goto :EOF
        )
)
echo %1 >> "!list_all_sha!"
goto :EOF

rem º¯Êı£ºÒÔ %1 ÎªÎÄ¼şÃû£¬±£´æ %2
rem %1£ºÔÚÕâ¸öÓ¦ÓÃÀïÊÇ sha1 Öµ
rem %2£ºsha1 ÖµÎª %1 µÄÎÄ¼ş
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
echo ÆğÊ¼Ê±¼ä£º%startH%:%startM%:%startS%>>%shaone%
echo ½áÊøÊ±¼ä£º%endH%:%endM%:%endS%>>%shaone%
echo ¹²ÓÃÊ± %totalTime% Ãë¡£>>%shaone%
endlocal
@echo on
