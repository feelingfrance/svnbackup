
@echo off

rem ���и�ʽ : ������ + ��Ŀ����


set dd=%time:~0,2%
if "%dd%" lss "10" (
    set D=%DATE:~0,11%%TIME:~1,1%h%TIME:~3,2%
) else (
    set D=%DATE:~0,11%%TIME:~0,2%h%TIME:~3,2%
)


rem ������Ҫ���ݵĿ�Ŀ¼����,ע�ⲻҪ�пո������

if "%1"=="" goto no_args

set SVN_NREP=%1

rem set SVN_HOME="C:\Program Files\VisualSVN Server"
 
rem set SVN_ROOT=C:\Repositories

set SVN_DIR=%SVN_ROOT%\%SVN_NREP%
rem set BACKUP_SVN_ROOT=C:\svnrootbak
set BACKUP_DIRECTORY=%BACKUP_SVN_ROOT%\%SVN_NREP%
rem ������һ�ΰ汾���ļ���Ŀ¼
rem set TP=C:\tmp



if not exist "%EXM_LOG%" ( 
   echo ������־:>%EXM_LOG%
   rem echo %EXM_LOG% �ļ�������,��ȷ�ϴ��ļ�
   rem exit /b
)


rem ָ��һ����ʱ�ļ����ڴ�����һ�α��ݵİ汾��
set TMP="%TP%\%SVN_NREP%_svn_id.txt"


if not exist "%SVN_ROOT%\%SVN_NREP%" (

	echo ��Ҫ���ݵĿ��ļ�%SVN_ROOT%\%SVN_NREP%������

	goto end
)

rem if exist "%BACKUP_DIRECTORY%" goto checkBack

rem echo ��������Ŀ¼%BACKUP_DIRECTORY%>>%SVN_ROOT%\backup.log

rem mkdir "%BACKUP_DIRECTORY%"


rem ���svnlookĿ¼�͹���Ŀ¼����ͬһ���̷�,����Ҫ�л�
set PWD=%cd%
for %%a in (%PWD%) do set old_disk=%%~da
for %%b in (%SVN_HOME%) do set svnlook_disk=%%~db

%svnlook_disk%

cd %SVN_HOME%\bin


for /f %%i in ('svnlook youngest %SVN_DIR%') do (
  set YOUNG=%%i
)
%old_disk%

cd %PWD%


if exist "%BACKUP_DIRECTORY%\%D%_%YOUNG%" goto checkBack
if exist "%BACKUP_DIRECTORY%\%D%_%YOUNG%.rar" goto checkBackRar

mkdir "%BACKUP_DIRECTORY%\%D%_%YOUNG%"

%SVN_HOME%\bin\svnadmin hotcopy "%SVN_DIR%" "%BACKUP_DIRECTORY%\%D%_%YOUNG%"
if not %ERRORLEVEL% equ 0 (
	echo �ȱ�������hotcoy����,����������±���
        echo %D%>>%REPO_LOG_PATH%\%SVN_NREP%_log.txt
        echo -- ʧ��,hotcopy����,����ȱ����ļ��е�%BACKUP_DIRECTORY%\%D%_%YOUNG%>>%REPO_LOG_PATH%\%SVN_NREP%_log.txt
	exit /b 1  
)

rem ���svnlookĿ¼�͹���Ŀ¼����ͬһ���̷�,����Ҫ�л�
set PWD=%cd%
for %%a in (%PWD%) do set old_disk=%%~da
for %%b in (%SVN_HOME%) do set svnlook_disk=%%~db

%svnlook_disk%

cd %SVN_HOME%\bin
for /f %%i in ('svnlook youngest %BACKUP_DIRECTORY%\%D%_%YOUNG%') do (
  set CHECKID=%%i
)
%old_disk%

cd %PWD%


if not %CHECKID% equ %YOUNG% (
  echo %SVN_DIR%�ȱ��ݳ���,youngest �汾�ŶԲ���,����
  echo %D%>>%REPO_LOG_PATH%\%SVN_NREP%_log.txt
  echo -- ʧ��,youngest�汾�ŶԲ���,����ȱ����ļ��е�%BACKUP_DIRECTORY%\%D%_%YOUNG%>>%REPO_LOG_PATH%\%SVN_NREP%_log.txt
  exit /b 5
)

echo %SVN_DIR%�ȱ��ݳɹ�,���ݵ�%BACKUP_DIRECTORY%\%D%_%YOUNG%

rem %SVN_HOME%\bin\svnlook youngest "%BACKUP_DIRECTORY%" > %TMP%
>%TMP% echo %YOUNG%

rem ����������־
if not exist "%REPO_LOG_PATH%\%SVN_NREP%_log.txt" @copy %EXM_LOG% %REPO_LOG_PATH%\%SVN_NREP%_log.txt >nul

echo %D%>>%REPO_LOG_PATH%\%SVN_NREP%_log.txt

echo -- ����ȱ����ļ��е�%BACKUP_DIRECTORY%\%D%_%YOUNG%>>%REPO_LOG_PATH%\%SVN_NREP%_log.txt



rem ����������ѹ�����ݵ��ļ�,�����ϴ����ݵ��ļ�������Զ�̻���
if %RAR_CMD%=="" goto end


rem ���WINRARѹ��Ŀ¼�͹���Ŀ¼����ͬһ���̷�,����Ҫ�л�
set PWD=%cd%
for %%a in (%PWD%) do set old_disk=%%~da
for %%b in (%BACKUP_DIRECTORY%) do set winrar_disk=%%~db

%winrar_disk%

cd %BACKUP_DIRECTORY%

%RAR_CMD% a -df %D%_%YOUNG%.rar %D%_%YOUNG%

%old_disk%

cd %PWD%

if not %errorlevel% equ 0 (
   echo -- ʧ��WINRARѹ��Ϊ�ļ�%BACKUP_DIRECTORY%\%D%_%YOUNG%.rar>>%REPO_LOG_PATH%\%SVN_NREP%_log.txt

) else (

   echo ---------- ѹ��Ϊ�ļ�%BACKUP_DIRECTORY%\%D%_%YOUNG%.rar>>%REPO_LOG_PATH%\%SVN_NREP%_log.txt
)


rem ����һ�����ڿ��������ļ���ӳ�����������
rem copy %SVN_NREP%_%NUM1%_%NUM2%.rar z:\%SVN_NREP%



goto end

  :checkBack
    echo �ȱ���Ŀ¼%BACKUP_DIRECTORY%\%D%_%YOUNG%�Ѿ����ڣ�����ա�
    goto end
  :checkBackRar
    echo �ȱ���ѹ���ļ�%BACKUP_DIRECTORY%\%D%_%YOUNG%.rar�Ѿ����ڣ�����ա�
    goto end
  :no_args
   echo ��ȷ�ĵ��÷���: ���� + ��Ŀ����
   exit /b

  :end
