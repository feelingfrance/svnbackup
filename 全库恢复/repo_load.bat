@echo off


if "%1"=="" goto no_args
if "%2"=="" goto no_args
set SVN_NREP=%1
set LOAD_PATH=%2

rem 输入需要恢复的库目录名称,注意不要有空格在最后


rem 输入加载的恢复库目录的地址


rem set SVN_HOME="C:\Program Files\VisualSVN Server"
rem set SVN_ROOT=C:\Repositories
set SVN_DIR=%SVN_ROOT%\%SVN_NREP%

 


if not exist "%LOAD_PATH%" (
            echo %LOAD_PATH% 目录不存在,请确定恢复目录地址和名称
            rem goto end
            exit /b 1
            )

REM 判断是文件还是目录
for %%i in ("%LOAD_PATH%") do set FileAttrib=%%~ai

if not %FileAttrib:~0,1%==d (
   rem 增量文件
   rem echo 需要输入文件夹而不是文件
   goto INCRE
)

if exist "%SVN_DIR%" (
           echo %SVN_DIR% 库目录已经存在,不需要恢复
           rem goto end
           exit /b 2
)

rem 第一步,先hotcopy全库恢复
%SVN_HOME%\bin\svnadmin hotcopy "%LOAD_PATH%" %SVN_DIR%
if %ERRORLEVEL% equ 0 (
			echo 全库文件已经恢复到%SVN_DIR%
		     
		) else (echo 恢复全库文件失败,请重新备份
			rem goto end	
                        exit /b 3
)

rem echo 请先确认全库恢复是否正确,如果错误,请按ctrl+c退出程序
rem 测试热恢复后的文件是否成功,比较最新的版本号
rem 如果svnlook目录和工作目录不在同一个盘符,就需要切换
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
  echo %LOAD_PATH%全库热恢复出错,请检查
  exit /b 4
)


rem pause

goto end

:INCRE

if not exist "%SVN_DIR%" (
           echo %SVN_DIR% 库目录不存在,需要先恢复全库备份,然后进行增量恢复.请确定conf文件配置是否正确
           rem goto end
           exit /b 5
)

rem  进行增量备份
rem if not exist %ADD1% (
rem	echo 增量文件不存在,退出增量备份程序
rem	goto end
rem	)
rem 需要输入所有增量文件
%SVN_HOME%\bin\svnadmin load %SVN_DIR% < "%LOAD_PATH%"
rem %SVN_HOME%\bin\svnadmin load %SVN_DIR% < %ADD2%
if not %ERRORLEVEL% equ 0 (
				echo 增量恢复错误,请检查
				rem goto end
                                exit /b 6
 
)
goto end

   :no_args
   echo 正确的调用方法: 程序 + 项目库名 + 项目库完整路径
   exit /b 

   :end




