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

set TEMPDIR=TEMPMD5\
rd /Q /S %TEMPDIR% 1>NUL 2>NUL
md %TEMPDIR%
set mdfive=md5v3.txt
set count=0
echo ���Ժ򡭡�
echo ���ڱȽ� %dira% �� %dirb% �й�ͬ���ڵ��ļ��� md5 ֵ > %mdfive%
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
        rem �� !mda! Ϊ�ļ�������¼ md5 Ϊ !mda! ���ļ�
        call :ADDMDFN "%TEMPDIR%!mda!" "%dira%\!fn!"
        rem �� md5 ֵ��¼���ļ����֤���ظ�
        call :ADDMDLIST !mda!
        if exist "%dirb%\!fn!" (
            for /f "tokens=1 delims= " %%A in ('md5sum "%dirb%\!fn!"') do set mdb=%%A
            call :ADDMDFN "%TEMPDIR%!mdb!" "%dirb%\!fn!"
            if "!mdb:~0,1!" == "\" set mdb=!mdb:~1,1024!
            if "!mda!" == "!mdb!" (
                rem ��¼�ļ�����ͬ���� md5 ��ͬ���ļ�
                echo !mda! !mdb! !fn! >> "!list_fn_md!"
            ) else (
                rem ��¼�ļ�����ͬ�� md5 ����ͬ���ļ�
                echo !mda! !mdb! !fn! >> "!list_fn_nmd!"
                call :ADDMDLIST !mdb!
            )
        ) else (
            rem ��¼ֻ�� %dira% �г��ֵ��ļ�
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
            rem ��¼ֻ�� %dirb% �г��ֵ��ļ�
            echo !mdb! !fn! >> "!list_fn_ob!"
            rem �� md5 ֵ��¼���ļ����֤���ظ�
            call :ADDMDLIST !mdb!
            call :ADDMDFN "%TEMPDIR%!mdb!" "%dirb%\!fn!"
        )
        call :PROGRESS !count!
        set /a count=!count!+1
)
echo ͳ�ƣ�>>%mdfive%
echo ��%dira% >> %mdfive%
echo �ң�%dirb% >> %mdfive%
echo ����Ŀ¼�ж������� md5 ��ͬ���ļ���>> %mdfive%
call :OUTPUTLIST "%list_fn_md%"
echo ===============================================================================================>> %mdfive%
echo ����Ŀ¼�ж����ڵ� md5 ����ͬ���ļ���>> %mdfive%
call :OUTPUTLIST "%list_fn_nmd%"
echo ===============================================================================================>> %mdfive%
echo ֻ��Ŀ¼ %dira% �д��ڵ��ļ���>> %mdfive%
call :OUTPUTLIST "%list_fn_oa%"
echo ===============================================================================================>> %mdfive%
echo ֻ��Ŀ¼ %dirb% �д��ڵ��ļ���>> %mdfive%
call :OUTPUTLIST "%list_fn_ob%"
echo ===============================================================================================>> %mdfive%
echo �� md5 ���ܵ��ļ��б�>> %mdfive%
call :OUTPUTLIST_MD "%list_all_md%"
echo ���� %md_count% �� md5 ֵ��>> %mdfive%

goto ALLDONE

rem ���� %1 �����˫����
:OUTPUTLIST
if %1 == "" goto :EOF
if not exist %1 goto :EOF
for /f "tokens=1* delims= " %%a in (%~1) do (
    echo %%a %%b >> %mdfive%
)
goto :EOF

rem ���� %1 �����˫����
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

rem �������� md5 ֵ���浽һ����Ϊ !list_all_md! ���ļ��
rem ����֤�������ظ��� md5 ֵ
:ADDMDLIST
if %1 == "" goto :EOF
if exist "!list_all_md!" (
        rem ����� delims Ҫôɾ����Ҫô�������������е����ӣ��ڵȺź���Ӹ��ո�
        rem for /f "tokens=1 delims= " %%a in (!list_all_md!) do (
        for /f "tokens=1 " %%a in (!list_all_md!) do (
            if "%%a" == "%1" goto :EOF
        )
)
echo %1 >> "!list_all_md!"
goto :EOF

rem �������� %1 Ϊ�ļ��������� %2
rem %1�������Ӧ������ md5 ֵ
rem %2��md5 ֵΪ %1 ���ļ�
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
echo ��ʼʱ�䣺%startH%:%startM%:%startS%>>%mdfive%
echo ����ʱ�䣺%endH%:%endM%:%endS%>>%mdfive%
echo ����ʱ %totalTime% �롣>>%mdfive%
endlocal
@echo on
