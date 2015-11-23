@if "%DEBUG%" == "" @echo off
@rem ##########################################################################
@rem
@rem  aurora-scheduler startup script for Windows
@rem
@rem ##########################################################################

@rem Set local scope for the variables with windows NT shell
if "%OS%"=="Windows_NT" setlocal

@rem Add default JVM options here. You can also use JAVA_OPTS and AURORA_SCHEDULER_OPTS to pass JVM options to this script.
set DEFAULT_JVM_OPTS=

set DIRNAME=%~dp0
if "%DIRNAME%" == "" set DIRNAME=.
set APP_BASE_NAME=%~n0
set APP_HOME=%DIRNAME%..

@rem Find java.exe
if defined JAVA_HOME goto findJavaFromJavaHome

set JAVA_EXE=java.exe
%JAVA_EXE% -version >NUL 2>&1
if "%ERRORLEVEL%" == "0" goto init

echo.
echo ERROR: JAVA_HOME is not set and no 'java' command could be found in your PATH.
echo.
echo Please set the JAVA_HOME variable in your environment to match the
echo location of your Java installation.

goto fail

:findJavaFromJavaHome
set JAVA_HOME=%JAVA_HOME:"=%
set JAVA_EXE=%JAVA_HOME%/bin/java.exe

if exist "%JAVA_EXE%" goto init

echo.
echo ERROR: JAVA_HOME is set to an invalid directory: %JAVA_HOME%
echo.
echo Please set the JAVA_HOME variable in your environment to match the
echo location of your Java installation.

goto fail

:init
@rem Get command-line arguments, handling Windowz variants

if not "%OS%" == "Windows_NT" goto win9xME_args
if "%@eval[2+2]" == "4" goto 4NT_args

:win9xME_args
@rem Slurp the command line arguments.
set CMD_LINE_ARGS=
set _SKIP=2

:win9xME_args_slurp
if "x%~1" == "x" goto execute

set CMD_LINE_ARGS=%*
goto execute

:4NT_args
@rem Get arguments from the 4NT Shell from JP Software
set CMD_LINE_ARGS=%$

:execute
@rem Setup the command line

set CLASSPATH=%APP_HOME%\lib\aurora-0.10.0.jar;%APP_HOME%\lib\classes;%APP_HOME%\lib\dependency-cache;%APP_HOME%\lib\classes;%APP_HOME%\lib\classes;%APP_HOME%\lib\dependency-cache;%APP_HOME%\lib\aurora-api-0.10.0.jar;%APP_HOME%\lib\commons-0.10.0.jar;%APP_HOME%\lib\aopalliance-1.0.jar;%APP_HOME%\lib\jsr305-2.0.1.jar;%APP_HOME%\lib\guice-3.0.jar;%APP_HOME%\lib\guice-assistedinject-3.0.jar;%APP_HOME%\lib\protobuf-java-2.5.0.jar;%APP_HOME%\lib\h2-1.4.187.jar;%APP_HOME%\lib\jersey-core-1.18.1.jar;%APP_HOME%\lib\jersey-json-1.18.1.jar;%APP_HOME%\lib\jersey-server-1.18.1.jar;%APP_HOME%\lib\jersey-servlet-1.18.1.jar;%APP_HOME%\lib\jersey-guice-1.18.1.jar;%APP_HOME%\lib\javax.inject-1.jar;%APP_HOME%\lib\servlet-api-2.5.jar;%APP_HOME%\lib\log4j-1.2.17.jar;%APP_HOME%\lib\stringtemplate-3.2.1.jar;%APP_HOME%\lib\mesos-0.23.0.jar;%APP_HOME%\lib\shiro-guice-1.2.4.jar;%APP_HOME%\lib\shiro-web-1.2.4.jar;%APP_HOME%\lib\zookeeper-3.3.4.jar;%APP_HOME%\lib\jetty-rewrite-7.6.15.v20140411.jar;%APP_HOME%\lib\jetty-server-7.6.15.v20140411.jar;%APP_HOME%\lib\jetty-servlet-7.6.15.v20140411.jar;%APP_HOME%\lib\jetty-servlets-7.6.15.v20140411.jar;%APP_HOME%\lib\mybatis-3.3.0.jar;%APP_HOME%\lib\mybatis-guice-3.6.jar;%APP_HOME%\lib\quartz-2.2.1.jar;%APP_HOME%\lib\slf4j-jdk14-1.7.12.jar;%APP_HOME%\lib\libthrift-0.9.1.jar;%APP_HOME%\lib\gson-2.3.1.jar;%APP_HOME%\lib\guava-18.0.jar;%APP_HOME%\lib\commons-args-0.10.0.jar;%APP_HOME%\lib\guice-multibindings-3.0.jar;%APP_HOME%\lib\commons-lang-2.6.jar;%APP_HOME%\lib\joda-time-2.3.jar;%APP_HOME%\lib\easymock-3.2.jar;%APP_HOME%\lib\cglib-2.2.1-v20090111.jar;%APP_HOME%\lib\jettison-1.1.jar;%APP_HOME%\lib\jaxb-impl-2.2.3-1.jar;%APP_HOME%\lib\jackson-core-asl-1.9.2.jar;%APP_HOME%\lib\jackson-mapper-asl-1.9.2.jar;%APP_HOME%\lib\jackson-jaxrs-1.9.2.jar;%APP_HOME%\lib\jackson-xc-1.9.2.jar;%APP_HOME%\lib\guice-servlet-3.0.jar;%APP_HOME%\lib\antlr-2.7.7.jar;%APP_HOME%\lib\shiro-core-1.2.4.jar;%APP_HOME%\lib\jline-0.9.94.jar;%APP_HOME%\lib\jetty-client-7.6.15.v20140411.jar;%APP_HOME%\lib\javax.servlet-2.5.0.v201103041518.jar;%APP_HOME%\lib\jetty-continuation-7.6.15.v20140411.jar;%APP_HOME%\lib\jetty-http-7.6.15.v20140411.jar;%APP_HOME%\lib\jetty-security-7.6.15.v20140411.jar;%APP_HOME%\lib\jetty-util-7.6.15.v20140411.jar;%APP_HOME%\lib\c3p0-0.9.1.1.jar;%APP_HOME%\lib\commons-lang3-3.1.jar;%APP_HOME%\lib\httpclient-4.2.5.jar;%APP_HOME%\lib\httpcore-4.2.4.jar;%APP_HOME%\lib\cglib-nodep-2.2.2.jar;%APP_HOME%\lib\objenesis-1.3.jar;%APP_HOME%\lib\asm-3.1.jar;%APP_HOME%\lib\jaxb-api-2.2.2.jar;%APP_HOME%\lib\commons-beanutils-1.8.3.jar;%APP_HOME%\lib\junit-3.8.1.jar;%APP_HOME%\lib\jetty-io-7.6.15.v20140411.jar;%APP_HOME%\lib\commons-logging-1.1.1.jar;%APP_HOME%\lib\commons-codec-1.6.jar;%APP_HOME%\lib\stax-api-1.0-2.jar;%APP_HOME%\lib\activation-1.1.jar;%APP_HOME%\lib\slf4j-api-1.7.12.jar

@rem Execute aurora-scheduler
"%JAVA_EXE%" %DEFAULT_JVM_OPTS% %JAVA_OPTS% %AURORA_SCHEDULER_OPTS%  -classpath "%CLASSPATH%" org.apache.aurora.scheduler.app.SchedulerMain %CMD_LINE_ARGS%

:end
@rem End local scope for the variables with windows NT shell
if "%ERRORLEVEL%"=="0" goto mainEnd

:fail
rem Set variable AURORA_SCHEDULER_EXIT_CONSOLE if you need the _script_ return code instead of
rem the _cmd.exe /c_ return code!
if  not "" == "%AURORA_SCHEDULER_EXIT_CONSOLE%" exit 1
exit /b 1

:mainEnd
if "%OS%"=="Windows_NT" endlocal

:omega
