@echo off


if "%1"=="" goto no_args
if "%2"=="" goto no_args
set SVN_NREP=%1
set LOAD_PATH=%2

rem ������Ҫ�ָ��Ŀ�Ŀ¼����,ע�ⲻҪ�пո������


rem ������صĻָ���Ŀ¼�ĵ�ַ


rem set SVN_HOME="C:\Program Files\VisualSVN Server"
rem set SVN_ROOT=C:\Repositories
set SVN_DIR=%SVN_ROOT%\%SVN_NREP%

 


if not exist "%LOAD_PATH%" (
            echo %LOAD_PATH% Ŀ¼������,��ȷ���ָ�Ŀ¼��ַ������
            rem goto end
            exit /b 1
            )

REM �ж����ļ�����Ŀ¼
for %%i in ("%LOAD_PATH%") do set FileAttrib=%%~ai

if not %FileAttrib:~0,1%==d (
   rem �����ļ�
   rem echo ��Ҫ�����ļ��ж������ļ�
   goto INCRE
)

if exist "%SVN_DIR%" (
           echo %SVN_DIR% ��Ŀ¼�Ѿ�����,����Ҫ�ָ�
           rem goto end
           exit /b 2
)

rem ��һ��,��hotcopyȫ��ָ�
%SVN_HOME%\bin\svnadmin hotcopy "%LOAD_PATH%" %SVN_DIR%
if %ERRORLEVEL% equ 0 (
			echo ȫ���ļ��Ѿ��ָ���%SVN_DIR%
		     
		) else (echo �ָ�ȫ���ļ�ʧ��,�����±���
			rem goto end	
                        exit /b 3
)

rem echo ����ȷ��ȫ��ָ��Ƿ���ȷ,�������,�밴ctrl+c�˳�����
rem �����Ȼָ�����ļ��Ƿ�ɹ�,�Ƚ����µİ汾��
rem ���svnlookĿ¼�͹���Ŀ¼����ͬһ���̷�,����Ҫ�л�
set PWD=%cd%
for %%a in (%PWD%) do set old_disk=%%~da
for %%b in (%SVN_HOME%) do set svnlook_disk=%%~db

%svnlook_disk%

cd %SVN_HOME%\bin


for /f %%i in ('svnlook youngest %LOAD_PATH%') do (
  set CHECKID1=%%i
)
for /f %%i in ('svnlook youngest %SVN_DIR%') do (
  set CHECKID2=%%i
)


%old_disk%

cd %PWD%



if not %CHECKID1% equ %CHECKID2% (
  echo %LOAD_PATH%ȫ���Ȼָ�����,����
  exit /b 4
)


rem pause

goto end

:INCRE

if not exist "%SVN_DIR%" (
           echo %SVN_DIR% ��Ŀ¼������,��Ҫ�Ȼָ�ȫ�ⱸ��,Ȼ����������ָ�.��ȷ��conf�ļ������Ƿ���ȷ
           rem goto end
           exit /b 5
)

rem  ������������
rem if not exist %ADD1% (
rem	echo �����ļ�������,�˳��������ݳ���
rem	goto end
rem	)
rem ��Ҫ�������������ļ�
%SVN_HOME%\bin\svnadmin load %SVN_DIR% < "%LOAD_PATH%"
rem %SVN_HOME%\bin\svnadmin load %SVN_DIR% < %ADD2%
if not %ERRORLEVEL% equ 0 (
				echo �����ָ�����,����
				rem goto end
                                exit /b 6
 
)
goto end

   :no_args
   echo ��ȷ�ĵ��÷���: ���� + ��Ŀ���� + ��Ŀ������·��
   exit /b 

   :end




