@echo off&setlocal enabledelayedexpansion

rem ��Ŀ¼���ָ��ű�

rem ��ȡ��Ŀ���б��ļ�projectload.conf������������;��ͷ����
rem conf�ļ���ʽΪ ��Ŀ��@��ȫ��ַ


rem =======================================================
rem  ˵������������ʱ����Ҫ���û�������
rem    1��SVN_HOME        ָ��svn�İ�װĿ¼
rem    2��SVN_ROOT        ָ����Ŀ��Ļָ���Ŀ¼(���ģʽ)
rem    3��SVNERR_LOG_PATH ָ��SVN������־�ļ����Ŀ¼,Ĭ����SVN_ROOT��,��־��Ϊ:svnerr_log.txt
rem =======================================================

rem ============��Ҫ�޸ĵĻ�������=========================
@call var_me.bat
rem =============�޸Ļ�����������Ϊֹ======================

rem ��ȡ��Ŀ���б��ļ�������������;��ͷ����
set dd=%time:~0,2%
if "%dd%" lss "10" (
    set D=%DATE:~0,11%%TIME:~1,1%h%TIME:~3,2%
) else (
    set D=%DATE:~0,11%%TIME:~0,2%h%TIME:~3,2%
)


set CHK=0
FOR /f "eol=; tokens=1,2 delims=@ " %%i IN (projectload.conf) DO  (

@call repo_load.bat %%i %%j
if not !errorlevel! equ 0 (
   echo ����,�ָ���%%iʧ��,�������!errorlevel!
   echo !D! ʧ��,%0�������,�ָ���%%iʧ��,�������!errorlevel!>>%SVNERR_LOG_PATH%
   :repeat
   msg /SERVER:localhost * "svn load �ָ����ִ���,����"
   timeout /T 65
   goto repeat
   exit /b
)
echo ======�ָ���%%i��%%j�ɹ�======

set CHK=1


)
if %CHK% equ 0 (
    echo projectload.conf �ļ���û��ָ��Ҫ�ָ��Ŀ�
    exit /b
)



:end
