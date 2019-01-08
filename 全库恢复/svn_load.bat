@echo off&setlocal enabledelayedexpansion

rem 根目录多库恢复脚本

rem 读取项目库列表文件projectload.conf，并忽略其中;开头的行
rem conf文件格式为 项目名@完全地址


rem =======================================================
rem  说明：启动备份时，需要配置环境变量
rem    1、SVN_HOME        指定svn的安装目录
rem    2、SVN_ROOT        指定项目库的恢复根目录(多库模式)
rem    3、SVNERR_LOG_PATH 指定SVN错误日志文件存放目录,默认在SVN_ROOT下,日志名为:svnerr_log.txt
rem =======================================================

rem ============需要修改的环境参数=========================
@call var_me.bat
rem =============修改环境参数到此为止======================

rem 读取项目库列表文件，并忽略其中;开头的行
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
   echo 错误,恢复库%%i失败,错误代码!errorlevel!
   echo !D! 失败,%0程序错误,恢复库%%i失败,错误代码!errorlevel!>>%SVNERR_LOG_PATH%
   :repeat
   msg /SERVER:localhost * "svn load 恢复出现错误,请检查"
   timeout /T 65
   goto repeat
   exit /b
)
echo ======恢复库%%i到%%j成功======

set CHK=1


)
if %CHK% equ 0 (
    echo projectload.conf 文件里没有指定要恢复的库
    exit /b
)



:end
