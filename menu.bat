@ECHO OFF
CLS
COLOR 0a

REM 根据本BAT文件路径确定gvim可执行文件路径
SET WORKING_DIR=%~dp0
SET GVIM_EXE_PATH=%WORKING_DIR%vim73\gvim.exe

ECHO.请为我:
ECHO        1.安装右键菜单
ECHO        2.移除右键菜单
ECHO        3.在桌面上放一个快捷方式
ECHO        4.批量为指定目录中的代码生成HTML副本
ECHO        5.批量打印指定目录中的代码
ECHO.
SET Choice=

:MAKECHOICE
SET /P Choice=请输入您的选择：
IF '%Choice%'=='' GOTO MAKECHOICE

IF /I '%Choice%'=='1' GOTO INSTALL
IF /I '%Choice%'=='2' GOTO UNINSTALL
IF /I '%Choice%'=='3' GOTO SHORTCUT
IF /I '%Choice%'=='4' GOTO CONVERTHTML 
IF /I '%Choice%'=='5' GOTO BATCHPRINT
GOTO END

:INSTALL
reg add "HKCR\*\shell\使用gVim打开\command" /f /ve /d "\"%GVIM_EXE_PATH%\" \"%%1\""
GOTO END

:SHORTCUT
SET SHORTCUT_PATH="%USERPROFILE%\Desktop\gVim.url"
ECHO [InternetShortcut] >> %SHORTCUT_PATH%
ECHO URL="%GVIM_EXE_PATH%" >> %SHORTCUT_PATH%
ECHO IconIndex=0 >> %SHORTCUT_PATH%
ECHO IconFile="%GVIM_EXE_PATH%" >> %SHORTCUT_PATH%
GOTO END

:UNINSTALL
reg delete "HKCR\*\shell\使用gVim打开" /f
GOTO END

:CONVERTHTML
REM 为代码创建HTML版本
SET DELETE_ORIGINAL_FILE=false
SET CONVERTED_FILE_PREFIX=gvim_convert_

CLS
ECHO ************************************************************************
ECHO **	为符合规则%FILE_PATTERN%的文件生成html文件副本
ECHO **	你还可以通过修改_vimrc_tohtml文件来改变html文件样式
ECHO ************************************************************************

:CONVERTHTML_ENTER_CONTENT_ROOT
REM 重置路径
SET CONVERT_ROOT=
SET /P CONVERT_ROOT=请输入要转换的目录路径:
IF '%CONVERT_ROOT%'=='' GOTO CONVERTHTML_ENTER_CONTENT_ROOT

:CONVERTHTML_ENTER_MATCH_PATTERN
REM 匹配规则
SET MATCH_PATTERN=
SET /P MATCH_PATTERN=请输入文件的匹配规则，如*.php，多个规则用空格隔开:
IF '%MATCH_PATTERN%'=='' GOTO CONVERTHTML_ENTER_MATCH_PATTERN

FOR /R %CONVERT_ROOT% %%i in (%MATCH_PATTERN%) do (
	if EXIST %%~di%%~pi%CONVERTED_FILE_PREFIX%%%~ni.html. ( 
		ECHO 跳过%%~ni%%~xi
	) ELSE (
    	ECHO 正在转换%%~ni%%~xi
    	%GVIM_EXE_PATH% %%i -u %WORKING_DIR%/_vimrc_tohtml -c ":TOhtml" -c ":wq! %CONVERTED_FILE_PREFIX%%%~ni.html" -c ":q!" 
		IF '%DELETE_ORIGINAL_FILE%' == 'true' DEL /F /Q %%i
	)
)
GOTO END

:BATCHPRINT
REM 打印代码
REM 匹配的文件规则,不同的扩展名用空格隔开
SET FILE_PATTERN=*.php

CLS
ECHO ************************************************************************
ECHO **	打印符合规则%FILE_PATTERN%的文件
ECHO **	你还可以通过修改_vimrc_print文件来改变打印结果的样式
ECHO ************************************************************************

:BATCHPRINT_ENTER_CONTENT_ROOT
SET CONVERT_ROOT=
SET /P CONVERT_ROOT=请输入要打印的目录路径:
IF '%CONVERT_ROOT%'=='' GOTO BATCHPRINT_ENTER_CONTENT_ROOT

:BATCHPRINT_ENTER_MATCH_PATTERN
REM 匹配规则
SET MATCH_PATTERN=
SET /P MATCH_PATTERN=请输入文件的匹配规则，如*.php，多个规则用空格隔开:
IF '%MATCH_PATTERN%'=='' GOTO BATCHPRINT_ENTER_MATCH_PATTERN

FOR /R %CONVERT_ROOT% %%i in (%MATCH_PATTERN%) do (
	ECHO 正在打印%%~ni%%~xi
	%GVIM_EXE_PATH% %%i -u %WORKING_DIR%/_vimrc_print -c ":hardcopy!" -c ":q!"
)
GOTO END

:END
ECHO.
ECHO 所选命令已完成
PAUSE
