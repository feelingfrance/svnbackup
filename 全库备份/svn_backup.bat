@echo off&setlocal enabledelayedexpansion

rem  ================================================
rem  ������Ϊwinrar,���ݺ��Ժ�����rarѹ��,����ɾ��Դ�ļ�
rem  ˵������������ʱ����Ҫ����������������
rem    1��SVN_HOME        ָ��svn�İ�װĿ¼
rem    2��SVN_ROOT        ָ����Ŀ��ĸ�Ŀ¼(���ģʽ)
rem    3��TP              ָ��������һ�ΰ汾�ŵ�Ŀ¼
rem    4��BACKUP_SVN_ROOT ָ�����ݵĴ��Ŀ¼
rem    5��EXM_LOG         ָ��������־ģ���·��������
rem    6��RAR_CMD         ָ��RAR������ѹ����������Ŀ¼
rem    7��REPO_LOG_PATH   ָ��ÿ������־�ļ����Ŀ¼,Ĭ����SVN_ROOT��,��־��Ϊ:����_log.txt
rem    8��SVNERR_LOG_PATH ָ��SVN������־�ļ����Ŀ¼,Ĭ����REPO_LOG_PATH��,��־��Ϊ:svnerr_log.txt
rem  ���⣬�����Ҫ��ر��ݣ�����ָ��Ϊ����ӳ��Z��

rem ============��Ҫ�޸ĵĻ�������=========================

@call var_me.bat

rem =============�޸Ļ�����������Ϊֹ======================

if not "%1"=="winrar" (

set RAR_CMD=""

)

rem ��Ŀ¼��ⱸ�ݽű�
rem �˽ű����Լ���windows �ƻ�����,���ܻ��߰��½����Զ�����
rem ��ȡ��Ŀ���б��ļ�projectlist.conf������������;��ͷ����
rem ����projectlist.conf�������,��ȡ��Ҫȫ�ⱸ�ݵĿ�����
set CHK=0

FOR /f "eol=;" %%C IN (projectlist.conf) DO  (

@call repo_hotcopy.bat %%C

if not !ERRORLEVEL! equ 0 (
	echo %0�������д���,�������!ERRORLEVEL!,����
        echo !D! %0�������д���,%%C��hotcopy����,�������!ERRORLEVEL!>>%SVNERR_LOG_PATH%
        :repeat
        msg /SERVER:localhost * "hotcopy���ִ���,����"
        timeout /T 65
        goto repeat
	exit /b
  )


set CHK=1


)
if %CHK% equ 0 (
    echo projectlist.conf �ļ���û��ָ��Ҫ���ݵĿ�
    exit /b
)





