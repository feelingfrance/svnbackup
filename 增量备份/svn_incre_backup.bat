@echo off&setlocal enabledelayedexpansion

rem 根目录多库增量备份脚本  

rem 读取项目库增量列表文件project_incre_list.conf，并忽略其中;开头的行
rem  带参数为winrar,备份好以后启用rar压缩,并且删除源文件
rem 可以添加脚本到windows计划任务 每天运行一次
rem  ================================================
rem  说明：启动备份时，需要配置两个环境变量
rem    1、SVN_HOME        指定svn的安装目录
rem    2、SVN_ROOT        指定项目库的根目录(多库模式)
rem    3、BACKUP_SVN_ROOT 指定备份的存放目录
rem    4、TP              指定存放最近一次版本号的目录
rem    5、EXM_LOG         指定备份日志模板的路径和名称
rem    6、RAR_CMD         指定RAR命令行压缩工具所在目录
rem    7、REPO_LOG_PATH   指定日志文件存放目录,默认在SVN_ROOT下,日志名为:库名_log.txt
rem    8、SVNERR_LOG_PATH 指定SVN错误日志文件存放目录,默认在REPO_LOG_PATH下,日志名为:svnerr_log.txt
rem  另外，如果需要异地备份，可以指定为网络映射Z盘

rem ============需要修改的环境参数=========================

@call var_me.bat

rem =============修改环境参数到此为止======================

if not "%1"=="winrar" (

set RAR_CMD=""

)


set CHECK=0


FOR /f "eol=;" %%C IN (project_incre_list.conf) DO  (

set CHECK=1
@call repo_incre.bat %%C
if not !ERRORLEVEL! equ 0 (
	echo %0程序运行错误,错误代码!ERRORLEVEL!,请检查
        echo !D! %0程序运行错误,%%C库增量dump错误,错误代码!ERRORLEVEL!>>%SVNERR_LOG_PATH%
        :repeat
        msg /SERVER:localhost * "svn dump增量出现错误,请检查"
        timeout /T 65
        goto repeat
	exit /b
  )



)



if "%CHECK%"=="0" (
   echo project_incre_list.conf 没有要备份的增量库,请修改project_incre_list.conf文件内容
   exit /b
)


