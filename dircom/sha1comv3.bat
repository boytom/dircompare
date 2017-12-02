@echo off
setlocal enableextensions enabledelayedexpansion
rem ���ߣ�rubble@126.com
rem 17:55 2009-4-14 �汾��0.3
if "%1" == "" (
        echo ʹ��˵�������������в�����ָ������Ŀ¼���������ﰴ��ʾ���롣
        echo �����в�����ʽ���������� ^<Ŀ¼1^> ^<Ŀ¼2^>
        set /p dira=�������һ��Ŀ¼�����֣����ϷŲ�����س�����
)
if "%2" == "" (
        set /p dirb=������ڶ���Ŀ¼�����֣����ϷŲ�����س�����
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
echo ���Ժ򡭡�
echo ���ڱȽ� %dira% �� %dirb% �й�ͬ���ڵ��ļ��� sha1 ֵ > %shaone%
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
        rem �� !shaa! Ϊ�ļ�������¼ sha1 Ϊ !shaa! ���ļ�
        call :ADDMDFN "%TEMPDIR%!shaa!" "%dira%\!fn!"
        rem �� sha1 ֵ��¼���ļ����֤���ظ�
        call :ADDMDLIST !shaa!
        if exist "%dirb%\!fn!" (
            for /f "tokens=1 delims= " %%A in ('sha1sum "%dirb%\!fn!"') do set shab=%%A
            call :ADDMDFN "%TEMPDIR%!shab!" "%dirb%\!fn!"
            if "!shab:~0,1!" == "\" set shab=!shab:~1,1024!
            if "!shaa!" == "!shab!" (
                rem ��¼�ļ�����ͬ���� sha1 ��ͬ���ļ�
                echo !shaa! !shab! !fn! >> "!list_fn_sha!"
            ) else (
                rem ��¼�ļ�����ͬ�� sha1 ����ͬ���ļ�
                echo !shaa! !shab! !fn! >> "!list_fn_nsha!"
                call :ADDMDLIST !shab!
            )
        ) else (
            rem ��¼ֻ�� %dira% �г��ֵ��ļ�
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
            rem ��¼ֻ�� %dirb% �г��ֵ��ļ�
            echo !shab! !fn! >> "!list_fn_ob!"
            rem �� sha1 ֵ��¼���ļ����֤���ظ�
            call :ADDMDLIST !shab!
            call :ADDMDFN "%TEMPDIR%!shab!" "%dirb%\!fn!"
        )
        call :PROGRESS !count!
        set /a count=!count!+1
)
echo ͳ�ƣ�>>%shaone%
echo ��%dira% >> %shaone%
echo �ң�%dirb% >> %shaone%
echo ����Ŀ¼�ж������� sha1 ��ͬ���ļ���>> %shaone%
call :OUTPUTLIST "%list_fn_sha%"
echo ===============================================================================================>> %shaone%
echo ����Ŀ¼�ж����ڵ� sha1 ����ͬ���ļ���>> %shaone%
call :OUTPUTLIST "%list_fn_nsha%"
echo ===============================================================================================>> %shaone%
echo ֻ��Ŀ¼ %dira% �д��ڵ��ļ���>> %shaone%
call :OUTPUTLIST "%list_fn_oa%"
echo ===============================================================================================>> %shaone%
echo ֻ��Ŀ¼ %dirb% �д��ڵ��ļ���>> %shaone%
call :OUTPUTLIST "%list_fn_ob%"
echo ===============================================================================================>> %shaone%
echo �� sha1 ���ܵ��ļ��б�>> %shaone%
call :OUTPUTLIST_MD "%list_all_sha%"
echo ���� %sha_count% �� sha1 ֵ��>> %shaone%

goto ALLDONE

rem ���� %1 �����˫����
:OUTPUTLIST
if %1 == "" goto :EOF
if not exist %1 goto :EOF
for /f "tokens=1* delims= " %%a in (%~1) do (
    echo %%a %%b >> %shaone%
)
goto :EOF

rem ���� %1 �����˫����
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

rem �������� sha1 ֵ���浽һ����Ϊ !list_all_sha! ���ļ��
rem ����֤�������ظ��� sha1 ֵ
:ADDMDLIST
if %1 == "" goto :EOF
if exist "!list_all_sha!" (
        rem ����� delims Ҫôɾ����Ҫô�������������е����ӣ��ڵȺź���Ӹ��ո�
        rem for /f "tokens=1 delims= " %%a in (!list_all_sha!) do (
        for /f "tokens=1 " %%a in (!list_all_sha!) do (
            if "%%a" == "%1" goto :EOF
        )
)
echo %1 >> "!list_all_sha!"
goto :EOF

rem �������� %1 Ϊ�ļ��������� %2
rem %1�������Ӧ������ sha1 ֵ
rem %2��sha1 ֵΪ %1 ���ļ�
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
rem rem if %index% EQU 0 set /p=��<NUL
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
echo ����ʱ %totalTime% �롣
echo ��ʼʱ�䣺%startH%:%startM%:%startS%>>%shaone%
echo ����ʱ�䣺%endH%:%endM%:%endS%>>%shaone%
echo ����ʱ %totalTime% �롣>>%shaone%
endlocal
@echo on
