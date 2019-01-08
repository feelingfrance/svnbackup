
@echo off

rem 运行格式 : 程序名 + 项目库名


set dd=%time:~0,2%
if "%dd%" lss "10" (
    set D=%DATE:~0,11%%TIME:~1,1%h%TIME:~3,2%
) else (
    set D=%DATE:~0,11%%TIME:~0,2%h%TIME:~3,2%
)


rem 输入需要备份的库目录名称,注意不要有空格在最后

if "%1"=="" goto no_args

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
set TMP="%TP%\%SVN_NREP%_svn_id.txt"


if not exist "%SVN_ROOT%\%SVN_NREP%" (

	echo 需要备份的库文件%SVN_ROOT%\%SVN_NREP%不存在

	goto end
)

rem if exist "%BACKUP_DIRECTORY%" goto checkBack

rem echo 建立备份目录%BACKUP_DIRECTORY%>>%SVN_ROOT%\backup.log

rem mkdir "%BACKUP_DIRECTORY%"


rem 如果svnlook目录和工作目录不在同一个盘符,就需要切换
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
	echo 热备份命令hotcoy错误,请检查错误重新备份
        echo %D%>>%REPO_LOG_PATH%\%SVN_NREP%_log.txt
        echo -- 失败,hotcopy错误,添加热备份文件夹到%BACKUP_DIRECTORY%\%D%_%YOUNG%>>%REPO_LOG_PATH%\%SVN_NREP%_log.txt
	exit /b 1  
)

rem 如果svnlook目录和工作目录不在同一个盘符,就需要切换
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
  echo %SVN_DIR%热备份出错,youngest 版本号对不上,请检查
  echo %D%>>%REPO_LOG_PATH%\%SVN_NREP%_log.txt
  echo -- 失败,youngest版本号对不上,添加热备份文件夹到%BACKUP_DIRECTORY%\%D%_%YOUNG%>>%REPO_LOG_PATH%\%SVN_NREP%_log.txt
  exit /b 5
)

echo %SVN_DIR%热备份成功,备份到%BACKUP_DIRECTORY%\%D%_%YOUNG%

rem %SVN_HOME%\bin\svnlook youngest "%BACKUP_DIRECTORY%" > %TMP%
>%TMP% echo %YOUNG%

rem 建立备份日志
if not exist "%REPO_LOG_PATH%\%SVN_NREP%_log.txt" @copy %EXM_LOG% %REPO_LOG_PATH%\%SVN_NREP%_log.txt >nul

echo %D%>>%REPO_LOG_PATH%\%SVN_NREP%_log.txt

echo -- 添加热备份文件夹到%BACKUP_DIRECTORY%\%D%_%YOUNG%>>%REPO_LOG_PATH%\%SVN_NREP%_log.txt



rem 下面代码可以压缩备份的文件,或者上传备份的文件到其他远程环境
if %RAR_CMD%=="" goto end


rem 如果WINRAR压缩目录和工作目录不在同一个盘符,就需要切换
set PWD=%cd%
for %%a in (%PWD%) do set old_disk=%%~da
for %%b in (%BACKUP_DIRECTORY%) do set winrar_disk=%%~db

%winrar_disk%

cd %BACKUP_DIRECTORY%

%RAR_CMD% a -df %D%_%YOUNG%.rar %D%_%YOUNG%

%old_disk%

cd %PWD%

if not %errorlevel% equ 0 (
   echo -- 失败WINRAR压缩为文件%BACKUP_DIRECTORY%\%D%_%YOUNG%.rar>>%REPO_LOG_PATH%\%SVN_NREP%_log.txt

) else (

   echo ---------- 压缩为文件%BACKUP_DIRECTORY%\%D%_%YOUNG%.rar>>%REPO_LOG_PATH%\%SVN_NREP%_log.txt
)


rem 下面一行用于拷贝备份文件到映射的驱动器上
rem copy %SVN_NREP%_%NUM1%_%NUM2%.rar z:\%SVN_NREP%



goto end

  :checkBack
    echo 热备份目录%BACKUP_DIRECTORY%\%D%_%YOUNG%已经存在，请清空。
    goto end
  :checkBackRar
    echo 热备份压缩文件%BACKUP_DIRECTORY%\%D%_%YOUNG%.rar已经存在，请清空。
    goto end
  :no_args
   echo 正确的调用方法: 程序 + 项目库名
   exit /b

  :end
