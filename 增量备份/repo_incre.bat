@echo off
rem ���и�ʽ: ������+������Ŀ����

if "%1"=="" goto no_args



set dd=%time:~0,2%
if "%dd%" lss "10" (
    set D=%DATE:~0,11%%TIME:~1,1%h%TIME:~3,2%
) else (
    set D=%DATE:~0,11%%TIME:~0,2%h%TIME:~3,2%
)


rem ������Ҫ���ݵĿ�Ŀ¼����,ע�ⲻҪ�пո������
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
set TMP=%TP%\%SVN_NREP%_svn_id.txt

if not exist "%SVN_DIR%" (

echo ��Ҫ���ݵĿ��ļ�%SVN_DIR%������

goto end
)

rem ��ʼ�� �汾�� 0
set NUM1=0

if exist "%BACKUP_DIRECTORY%" goto NEXT

     rem �����dump��0��ʼ����,��Ҫ�����ﴴ��Ŀ¼ dump all
     rem mkdir %BACKUP_DIRECTORY%
     echo ����Ŀ¼%BACKUP_DIRECTORY%������,����������ȫ�ⱸ�ݳ���
     goto end

:NEXT


if not exist "%TMP%" goto lable


rem ���һ�α��ݵİ汾��

for /f %%d in (%TMP%) do (
  set NUM1=%%d
)


:lable

rem ����ű�ȫ�ⱸ����Hotcopy����,����������dump����.��������ȫ�ⱸ��hotcotyһ��,Ȼ����dump��������
rem ��Щ�ű�ȫ����dump��������,��һ�δӰ汾��0��ʼ
rem ��������dump ��0��ʼ����,ֻ��Ҫע�͵������if dump all

if %NUM1% equ 0 (
   echo %SVN_NREP% �汾��Ϊ0,����Ҫ����
   goto end  
)


rem ��� NUM1 > 0 �ͼ�1,����,�ʹ�0��ʼ

if %NUM1% gtr 0 set /a NUM1=%NUM1%+1


rem ���svnlookĿ¼�͹���Ŀ¼����ͬһ���̷�,����Ҫ�л�
set PWD=%cd%
for %%a in (%PWD%) do set old_disk=%%~da
for %%b in (%SVN_HOME%) do set svnlook_disk=%%~db

%svnlook_disk%

cd %SVN_HOME%\bin
for /f %%i in ('svnlook youngest %SVN_DIR%') do (
  set NUM2=%%i
)
%old_disk%

cd %PWD%





if %NUM1% gtr %NUM2% (
	echo %SVN_NREP%�����������ݿ�,���°汾��%NUM2%
	goto end
)


if exist "%BACKUP_DIRECTORY%\%NUM1%_%NUM2%.dmp" goto checkBack
if exist "%BACKUP_DIRECTORY%\%NUM1%_%NUM2%.dmp.rar" goto checkBackRar



rem %SVN_HOME%\bin\svnadmin dump %SVN_DIR% -r %NUM1%:head --incremental > "%BACKUP_DIRECTORY%\%D%" ��ʱ�����������ļ�
%SVN_HOME%\bin\svnadmin dump %SVN_DIR% -r %NUM1%:head --incremental > "%BACKUP_DIRECTORY%\%NUM1%_%NUM2%.dmp"



if %ERRORLEVEL% equ 0 (
                       >%TMP% echo %NUM2%

		       echo �������ݿ�%SVN_NREP%�Ѿ�����Ϊ�ļ�%BACKUP_DIRECTORY%\%NUM1%_%NUM2%.dmp		
		) else (echo ��������dumpʧ��,�����±���
                        echo %D%>>%REPO_LOG_PATH%\%SVN_NREP%_log.txt

                        echo -- ʧ��dump,������������ļ���%BACKUP_DIRECTORY%\%NUM1%_%NUM2%.dmp>>%REPO_LOG_PATH%\%SVN_NREP%_log.txt
                        exit /b 2

                          )

rem ����������־
if not exist "%REPO_LOG_PATH%\%SVN_NREP%_log.txt" @copy %EXM_LOG% %REPO_LOG_PATH%\%SVN_NREP%_log.txt >nul

echo %D%>>%REPO_LOG_PATH%\%SVN_NREP%_log.txt

echo -- ������������ļ���%BACKUP_DIRECTORY%\%NUM1%_%NUM2%.dmp>>%REPO_LOG_PATH%\%SVN_NREP%_log.txt

goto complete

 :complete
rem ����������ѹ�����ݵ��ļ�,�����ϴ����ݵ��ļ�������Զ�̻���
if %RAR_CMD%=="" goto end
rem ���WINRARѹ��Ŀ¼�͹���Ŀ¼����ͬһ���̷�,����Ҫ�л�
set PWD=%cd%
for %%a in (%PWD%) do set old_disk=%%~da
for %%b in (%BACKUP_DIRECTORY%) do set winrar_disk=%%~db

%winrar_disk%

cd %BACKUP_DIRECTORY%
%RAR_CMD% a -df %NUM1%_%NUM2%.dmp.rar %NUM1%_%NUM2%.dmp

%old_disk%
cd %PWD%

if not %errorlevel% equ 0 (
   echo -- ʧ��WINRARѹ�������ļ�%BACKUP_DIRECTORY%\%NUM1%_%NUM2%.dmp.rar>>%REPO_LOG_PATH%\%SVN_NREP%_log.txt

) else (

   echo -----  ѹ�������ļ�Ϊ%BACKUP_DIRECTORY%\%NUM1%_%NUM2%.dmp.rar>>%REPO_LOG_PATH%\%SVN_NREP%_log.txt
)


rem ����һ�����ڿ��������ļ���ӳ�����������
rem copy %SVN_NREP%_%NUM1%_%NUM2%.rar z:\%SVN_NREP%


 goto end



 :checkBack
    echo ���ݿ��ļ�%BACKUP_DIRECTORY%\%NUM1%_%NUM2%.dmp�Ѿ����ڣ�����Ҫ���ݡ�
    goto end

  :checkBackRar
    echo ���ݿ�ѹ���ļ�%BACKUP_DIRECTORY%\%NUM1%_%NUM2%.dmp.rar�Ѿ����ڣ�����ա�
    goto end

 :no_args
   echo ��ȷ�ĵ��÷���: ���� + ������Ŀ����
   exit /b



:end


