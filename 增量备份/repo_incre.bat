@echo off
rem 运行格式: 程序名+增量项目库名

if "%1"=="" goto no_args



set dd=%time:~0,2%
if "%dd%" lss "10" (
    set D=%DATE:~0,11%%TIME:~1,1%h%TIME:~3,2%
) else (
    set D=%DATE:~0,11%%TIME:~0,2%h%TIME:~3,2%
)


rem 输入需要备份的库目录名称,注意不要有空格在最后
set SVN_NREP=%1

rem set SVN_HOME="C:\Program Files\VisualSVN Server"
rem set SVN_ROOT=C:\Repositories
set SVN_DIR=%SVN_ROOT%\%SVN_NREP%
rem set BACKUP_SVN_ROOT=C:\svnrootbak
set BACKUP_DIRECTORY=%BACKUP_SVN_ROOT%\%SVN_NREP%

rem 存放最近一次版本号文件的目录
rem set TP=C:\tmp



if not exist "%EXM_LOG%" ( 
   echo 备份日志:>%EXM_LOG%
   rem echo %EXM_LOG% 文件不存在,请确认此文件
   rem exit /b
)

rem 指定一个临时文件用于存放最近一次备份的版本号
set TMP=%TP%\%SVN_NREP%_svn_id.txt

if not exist "%SVN_DIR%" (

echo 需要备份的库文件%SVN_DIR%不存在

goto end
)

rem 初始化 版本号 0
set NUM1=0

if exist "%BACKUP_DIRECTORY%" goto NEXT

     rem 如果用dump从0开始备份,需要在这里创建目录 dump all
     rem mkdir %BACKUP_DIRECTORY%
     echo 备份目录%BACKUP_DIRECTORY%不存在,请首先运行全库备份程序
     goto end

:NEXT


if not exist "%TMP%" goto lable


rem 最近一次备份的版本号

for /f %%d in (%TMP%) do (
  set NUM1=%%d
)


:lable

rem 这个脚本全库备份用Hotcopy命令,增量备份用dump备份.所以先用全库备份hotcoty一次,然后用dump增量备份
rem 有些脚本全程用dump增量备份,第一次从版本库0开始
rem 可是设置dump 从0开始备份,只需要注释掉下面的if dump all

if %NUM1% equ 0 (
   echo %SVN_NREP% 版本号为0,不需要备份
   goto end  
)


rem 如果 NUM1 > 0 就加1,不是,就从0开始

if %NUM1% gtr 0 set /a NUM1=%NUM1%+1


rem 如果svnlook目录和工作目录不在同一个盘符,就需要切换
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
	echo %SVN_NREP%无需增量备份库,最新版本号%NUM2%
	goto end
)


if exist "%BACKUP_DIRECTORY%\%NUM1%_%NUM2%.dmp" goto checkBack
if exist "%BACKUP_DIRECTORY%\%NUM1%_%NUM2%.dmp.rar" goto checkBackRar



rem %SVN_HOME%\bin\svnadmin dump %SVN_DIR% -r %NUM1%:head --incremental > "%BACKUP_DIRECTORY%\%D%" 按时间命名备份文件
%SVN_HOME%\bin\svnadmin dump %SVN_DIR% -r %NUM1%:head --incremental > "%BACKUP_DIRECTORY%\%NUM1%_%NUM2%.dmp"



if %ERRORLEVEL% equ 0 (
                       >%TMP% echo %NUM2%

		       echo 增量备份库%SVN_NREP%已经备份为文件%BACKUP_DIRECTORY%\%NUM1%_%NUM2%.dmp		
		) else (echo 增量备份dump失败,请重新备份
                        echo %D%>>%REPO_LOG_PATH%\%SVN_NREP%_log.txt

                        echo -- 失败dump,添加增量备份文件到%BACKUP_DIRECTORY%\%NUM1%_%NUM2%.dmp>>%REPO_LOG_PATH%\%SVN_NREP%_log.txt
                        exit /b 2

                          )

rem 建立备份日志
if not exist "%REPO_LOG_PATH%\%SVN_NREP%_log.txt" @copy %EXM_LOG% %REPO_LOG_PATH%\%SVN_NREP%_log.txt >nul

echo %D%>>%REPO_LOG_PATH%\%SVN_NREP%_log.txt

echo -- 添加增量备份文件到%BACKUP_DIRECTORY%\%NUM1%_%NUM2%.dmp>>%REPO_LOG_PATH%\%SVN_NREP%_log.txt

goto complete

 :complete
rem 下面代码可以压缩备份的文件,或者上传备份的文件到其他远程环境
if %RAR_CMD%=="" goto end
rem 如果WINRAR压缩目录和工作目录不在同一个盘符,就需要切换
set PWD=%cd%
for %%a in (%PWD%) do set old_disk=%%~da
for %%b in (%BACKUP_DIRECTORY%) do set winrar_disk=%%~db

%winrar_disk%

cd %BACKUP_DIRECTORY%
%RAR_CMD% a -df %NUM1%_%NUM2%.dmp.rar %NUM1%_%NUM2%.dmp

%old_disk%
cd %PWD%

if not %errorlevel% equ 0 (
   echo -- 失败WINRAR压缩增量文件%BACKUP_DIRECTORY%\%NUM1%_%NUM2%.dmp.rar>>%REPO_LOG_PATH%\%SVN_NREP%_log.txt

) else (

   echo -----  压缩增量文件为%BACKUP_DIRECTORY%\%NUM1%_%NUM2%.dmp.rar>>%REPO_LOG_PATH%\%SVN_NREP%_log.txt
)


rem 下面一行用于拷贝备份文件到映射的驱动器上
rem copy %SVN_NREP%_%NUM1%_%NUM2%.rar z:\%SVN_NREP%


 goto end



 :checkBack
    echo 备份库文件%BACKUP_DIRECTORY%\%NUM1%_%NUM2%.dmp已经存在，不需要备份。
    goto end

  :checkBackRar
    echo 备份库压缩文件%BACKUP_DIRECTORY%\%NUM1%_%NUM2%.dmp.rar已经存在，请清空。
    goto end

 :no_args
   echo 正确的调用方法: 程序 + 增量项目库名
   exit /b



:end


