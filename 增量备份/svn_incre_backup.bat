@echo off&setlocal enabledelayedexpansion

rem ��Ŀ¼����������ݽű�  

rem ��ȡ��Ŀ�������б��ļ�project_incre_list.conf������������;��ͷ����
rem  ������Ϊwinrar,���ݺ��Ժ�����rarѹ��,����ɾ��Դ�ļ�
rem ������ӽű���windows�ƻ����� ÿ������һ��
rem  ================================================
rem  ˵������������ʱ����Ҫ����������������
rem    1��SVN_HOME        ָ��svn�İ�װĿ¼
rem    2��SVN_ROOT        ָ����Ŀ��ĸ�Ŀ¼(���ģʽ)
rem    3��BACKUP_SVN_ROOT ָ�����ݵĴ��Ŀ¼
rem    4��TP              ָ��������һ�ΰ汾�ŵ�Ŀ¼
rem    5��EXM_LOG         ָ��������־ģ���·��������
rem    6��RAR_CMD         ָ��RAR������ѹ����������Ŀ¼
rem    7��REPO_LOG_PATH   ָ����־�ļ����Ŀ¼,Ĭ����SVN_ROOT��,��־��Ϊ:����_log.txt
rem    8��SVNERR_LOG_PATH ָ��SVN������־�ļ����Ŀ¼,Ĭ����REPO_LOG_PATH��,��־��Ϊ:svnerr_log.txt
rem  ���⣬�����Ҫ��ر��ݣ�����ָ��Ϊ����ӳ��Z��

rem ============��Ҫ�޸ĵĻ�������=========================

@call var_me.bat

rem =============�޸Ļ�����������Ϊֹ======================

if not "%1"=="winrar" (

set RAR_CMD=""

)


set CHECK=0


FOR /f "eol=;" %%C IN (project_incre_list.conf) DO  (

set CHECK=1
@call repo_incre.bat %%C
if not !ERRORLEVEL! equ 0 (
	echo %0�������д���,�������!ERRORLEVEL!,����
        echo !D! %0�������д���,%%C������dump����,�������!ERRORLEVEL!>>%SVNERR_LOG_PATH%
        :repeat
        msg /SERVER:localhost * "svn dump�������ִ���,����"
        timeout /T 65
        goto repeat
	exit /b
  )



)



if "%CHECK%"=="0" (
   echo project_incre_list.conf û��Ҫ���ݵ�������,���޸�project_incre_list.conf�ļ�����
   exit /b
)


