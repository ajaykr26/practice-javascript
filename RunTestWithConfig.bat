@echo OFF
setlocal enableDelayedExpansion
CALL :GetCertArg
CALL :GetPathToEnvironmentConfig
CALL :GetPathToEnvironmentConfigTarget
CALL :GetPathToTestSuites
CALL :GetPathToTestRunners
CALL :GetList0fFilesAsChoiceList %envDirectory% -properties securetext
CALL :GetPathToTechStacks
CALL :GetList0fFilesAsChoiceList %techStackDir% .json
CALL:ConfigVsManual
ALL :EnvChoose
EXIT /B 0
:Validation



set /a Valid=0
for /L %%G IN (1,1,%4) DO (
if [%1]==[%%G] (SET /a Valid=1)
)

if [%Valid%]==[1] (CALL :%2) ELSE (CALL :%3)

EXIT /B 0
:ValidPath
set /a Valid=0
for /L %G IN (1,1,%4) DO (
if [%1]==[C:!ListOfPossiblePath[%%G]!!ListOfPossibleFile[%%G]!] (SET /a Valid=1)
)
cls
if [%Valid%]==[1] (set cmdDriverPathOption=-Dcukes.driverPath="%1")
if [%Valid%]==[1] (CALL :%2) ELSE (CALL :%3)
EXIT/B 0
:ListIsEmpty
ECHO There isn't any options in list to choose from, at %~1 %~2. ..
PAUSE
EXIT

:RecommendationPath
echo.
echo Here is some possible executive pathways :
for /L %%G IN (1,1,%IndexListPath%) DO (
echo C:!ListOfPossiblePath[%%G]!!ListOfPossibleFile[%%G]!
)

echo.
CALL :UserDeterminedPath
EXIT /B 0

:ConfigVsManual
cls
set option[1]=Yes
set option[2]=No
cls

for /1 %%n in (1,1,2) do (
echo [%%n] - !option[%%n]!
)

set /p UserInputRunMode=Do you want to run with existing test configuration:
if [UserInputRunMode%]==[1] (CALL :ConfigRun)
if [UserInputRunMode%]==[2] (CALL :EnvChoose)
EXIT /B 0

:ConfigRun
cls
CALL :GetPathForConfig
if exist %PthForConfig% (
For /F "tokens=1,* delims==" %%i IN (%PathForConfig%) DO (
if [i]==[test] (
set cmd%%iOption=-D%i=%%j
)else(
set cmd%%iOption=-Dcukes.%%i-%%j
)
)
CALL:FinalStep
else (echo "File does not exist")
EXIT /B 0

:EnvChoose
cls
for /1 %%n in (1,1,%IDDoGetListOFFilesExclude%) do (
set /A count=%%n+1
echo [%%n] -!filenameExclude[%%n]!
)

if [%IDDoGetListOfFilesExclude%]==[0] (CALL:ListIsEmpty Environment Selection)
set /p UserInputEnv=Choose environment:
set cmdEnvOption= -Dcukes.env=!filename Exclude[%UserInputEnv%]!

Call :Validation %UserInputEnv% BroswerLoc EnvChoose %IDDoGetListOfFilesExclude%

EXIT /B 0
:BrowserLoc
cls
for /1 %%n in (1,1,%IDDOGetListOfFiles%) do (
echo [%%n] - !filename[%%n]!
)

if [%IDDoGetListOfFi1les%]==[0] (CALL :ListIsEmpty Browser Location)
set /p UserInputLoc=Choose run location and browser:

set cndTechStackOptions=-Dcukes.techstack=!filename[%UserInputLoc%]!
call :Validation %UserInputLoc% OptionsSpecifiedPath BrowserLoc %IDDoGetListOfFiles%

EXIT /B 0
:SetArgumentLOCALCH
CALL :GetPathForLocalCH
set cmdDriverPathOption=-Dcukes.driverPath-%PathLocalCH%
EXIT /B 0
:SetArgumentLOCALIE
CALL :GetPathForLocalIE
set cmdDriverPathOption=-Dcukes.driverPath-%PathLocalIE%
EXIT /B 0
:OptionsSpecifiedPath:
set runListFramework[1]=Select the driver from Citi default path
set runListFramework[2]=Select from Driver Framework
set runListFramework[3]=Specified the path by User
cls
for /1 %%n in (1,1,3) do (
echo [%%n] -!runListFramework[%%n]!
set /p OptionsAfterTestRunnerInput=Specify a path to the driver executable base on the selection :
cls
Call :Validation %OptionsAfterTestRunnerInput% AfterOptionsSpecifiedPath OptionsAfterTestRunner 3
EXIT /B 0

:AfterOptionsSpecifiedPath:
if [OptionsAfterTestRunnerInput]==[1] (CALL :DefaultCitiDriverPath)
if [OptionsAfterTestRunnerInput]==[2] (CALL :TestType)
if [OptionsAfterTestRunnerInput%]==[3] (CALL :UserDeterminedPath)
CALL :OptionsSpecifiedPth
EXIT /B 0

:DefaultCitiDriverPath
CALL :GetPathDefaultCitiPath
CALL :GetListDefaultPath
for /1 %%n in (1,1,%IndexListPathDefault%) do (
echo [%%n] - !ListOfPossibleFileDefault[%%n]!

if [%IndexListPathDefault%]==[0] (CALL :ListIsEmpty Framework Selection)
set /p FrameworkDefaultInput=Select the Citi Default Framework Driver:
set cmdDriverPathOption=-Dcukes.driverPath="C:!ListOfPossiblePathDefault[%FrameworkDefaultInput%]!!ListOfPossibleFileDefault[%FrameworkDefaultInput%]!"
Call :Validation %FrameworkDefaultInput% TestType DefaultCitiDriverPath %IndexListPathDefault%
EXIT /B 0

:GetListDefaultPath:
SET UserPath=C:\Program Files (x86)\Selenium Client\Selenium drivers
SET /a IndexListPathDefault=1
for /R "%UserPath%" %%G in (*.exe) do(
set ListOfPossiblePathDefault[!IndexListPathDefault!]=%%~pG
set ListOfPossiblePathDefault[!IndexListPathDefault!]=%%~nxG
set /a IndexListPathDefault+=1
)
set /a IndexListPathDefault-=1
EXIT /B 0

:UserDeterminedPath
echo.
echo (eg.: %CD% )
echo.
Set /p UserDriverPath=Input the path way where the Driver is:
FOR %%i in (%UserDriverPath%) do (
set FileDrive=%%~di
set filepath=%%~pi
set filename=%%~ni
set FileExtension=%%~xi
)
CALL :GetList0fPath %FileDrive%%filepath%

CALL :ValidPath %FileDrive:%filepath%%filename%%FileExtension% TestType RecommendationPath %IndexListPath%
EXIT /B 0




:GetList0fPath
SET UserPath=%1
SET /a IndexListPath=1
for /R "%UserPath% %%G in (*.exe) do (
set ListOfPossiblePath[!IndexListPath!]=%%~pG
set ListOfPossibleFile[!IndexListPath!]=%%~nxG
set /a IndexListPath+=1)
set /a IndexListPath-=1

if [%indexFolder%]==[0] (CALL :ListIsEmptyPath %UserPath%)
EXIT /B 0
:ListIsEmptyPath
CLS
ECHO There isn't any options in list from the choosen path (%1 ), exiting...
PAUSE
EXIT

:TestType
set runList[1]=Test Suite
set runList[2]=Test Runner
cls
for /1 %%n in (1,1,2) do (
echo [%%n] -!runList[%%n]!)
set /p UserInDutRun=What would vou like to run?

cls
Call :Validation %UserInputRun% DecisionTest TestType 2
EXIT /B 0

:DecisionTest
if [%UserInputRun%]==[1] (CALL :TestSuite)
if [%UserInputRun%]==[2] (CALL :TestRunner)
EXIT /B 0

:TestSuite
call :GetListOfFilesAsChoiceList %testSuiteDir% .xml
cls
for /1 %%n in (1,1,%IDDoGetListOfFiles%) do (
echo [%%n] - !filename[%%n]!)

if [%IDDoGetListOfFiles%]==[0] (CALL: ListIsEmpty Test Suite)
set /p TestSuiteSelection=Test Suites:
set cndTestOptions=-Dcukes.testsuite= !filename[%TestSuiteSelection%]!
call :Validation %TestSuiteSelection% FinalStep TestSuite %I0DoGetListOFFiles%
EXIT /B 0

:TestRunner
call :GetListOfFilesAsChoiceList %testRunnerDir% .java
cls
for /1 %%n in (1,1,%IDDOGetListOfFiles%) do (
echo [%%n] !filename[%%n]!)

if [%IDDoGetListOfFiles%]==[0] (CALL :ListIsEmpty Test Runner)
set /p TestRunnerSelection=Test Runners:
set cmdTestOption=-Dtest=!filename[%TestRunnerSelection%]!
Call :Validation %TestRunnerSelection% FunctionFeature TestRunner %IDDoGetListOfFiles%
EXIT /B 0

:FunctionFeature
set fun[1]=Yes
set fun[2]=No
cls
for /1 %%n in (1,1,2) do (
echo [%%n] - !fun[%%n]!)

set /p UserInputRunFeature=Do you want to run default function feature?
if [%UserInputRunFeature%]== [1] (FALL : FinalStep)
if [%UserInputRunFeature%]==[2] (CALL : FeatureChoose)

EXIT /B 0

:FeatureChoose
cls
set /p UserInputFunctionFeature=Enter valid function feature name?
set cmdCucumberOption=-Dcucumber.options="-tags %UserInputFunctionFeature%"
CALL :FinalStep
EXIT /B e

set finalRunCmd=mvn clean install %cmdTestOption% %cmdCucumberOption% %cmdEnvOption% %cmdTechStackOption% -Dorg.apache.logging.log4j.level-DEBUG
-Dcukes.leanft.defaultFindRetries=1 -Dcukes.selenium.defaultFindRetries=1 %cmdDriverPathOption% CertArg%




    :FinalStep
    cls
    echo finalRunCmd%
    CALL finalRunCmdx
    CALL :UploadAllureResultToALM
    CALL RunAllureReport
     PAUSE
     EXIT

     :UploadAllureResultToALM
     set uploadF lag=Yes
     set upload RunCmd=mvn test -Dtest-AllureUploadRunner CertArg%

    cls
    CALL :GetPathForConfig
    if exist *PathForConfig (
    For /F "tokens=1,* delims ==" *i IN (KPathForConfig%) DO (
    if [i]==[uploadAllureResultToALM] (
    set uploadFlag=**j
    if [%uploadFlag%]==[Yes] (
    echo "Checking if Allure results files should be uploaded to ALM.."
    echo uploadRunCmd%
    CALL uploadRunCmd%
    )else (
    echo "Skipping Allure results file upload"
    EXIT /B e
    : RunAllureReport
    echo Generating the Allure Report... I
    CALL mvn allure: report CertArg%

    start "chrome" "C: \Program Files (x86)\Google\Chrome\Application\chrome.exe" --disable-web-security - -user-data-dir-"C://ChromeDevSession "
    file://%cd:\=/%/RunReports/index.htm1"
    EXIT/B e
     CALL mvn allure: report XCertArg


    InValidPath
    cls
    echo The path that has been provided doesn't contain any driver
    call :UserDeterminedPath
    PAUSE
    .
    EXIT /B e
    :GetlistofFilesAsChoicelist
    SET workingDir=0%
    SET pathToFiles=workingDirz\%1**2
    if NOT [3]==[] (CALL :DoGetList0fFilesExclude pathToFiles% K»3) ELSE (CALL :DoGetListOfFiles %pathToFiles%)
    EXIT /B e
    :DoGetListoFFilesExclude
     SET excludeVal=-2
     SET pathToFiles=1
    for f "tokens=* in ("DIR -Path ZpathToFiles% /b /a-d 2>nut ^| find /i /v "securetext" 2*>nut | find /1 /v "ALM" 2^>nul ) do (
    set filenameExclude[!1DDoGetList0fFilesExclude!]=KnG

    set /a TDDoGetListOFFilesExclude+1


    set /a IDDoGetListofFilesExclude-=1
     EXIT /8 e
    : DoGetListofFiles
    set /a IDDoGetListOFFiles=1
    SET pathToFiles=-1
    for /f "tokens=*" 26 in ('DIR -Path %pathToFiles% /b la-d 2^>nul") do (
    set filename[ !IDDoGetList0FFiles ! ]=*%nG
    set /a IDDoGetList0FFiles+=1
    set /a IDDoGetListofFFiles - =1
     EXIT /B e
     :GetPathToEnvironmentConfig
    set fileSeparator=\
     set EXITenvbirectory=srcfileSeparator%tes /B t%61leSeparatorkresourcesKfileSeparatoriconfigfileSeparatorKenvironmentsKfileSeparatork

    EXIT /8e
    :GetPathToEnvironmentConfigTarget
    set fileSeparator=\
    set envDirectoryTarget=targetxfileSeparator%
    EXIT /B e
    :GetPathToTechStacks
    set fileSeparator=
    set techStackDir=srcfileSeparatortestXfileSeparator%resources%fileSeparator%config%fileSeparator%selenium%fileSeparator%stacks%fileSeparator%
    EXIT /B e
    :GetPathToTestSuites
    set fileseparator=\
    set testSuiteDir=src%fileSeparator%testXfileSeparator%resources%fileSeparatorKtestsuites%fileSeparator%
    EXIT /B e
    :GetPathToTestRunners
    set fileSeparator=\
    set testRunnerDir=srkfileSeparatortesthfileSeparator%java%fileSeparator%runners%fileSeparator%
    EXIT /B e
    I
    :GetPathForLocalCH

    set fileSeparator=\
    SET workingDir=%CD%
    set PathLocalCH=%workingDirk%fileSeparator*lib%fileSeparatorKdrivers%fileSeparator%windows%fileSeparatorchromeDriver.exe
     EXIT /B e
    :GetPathForLocalIE
    set fileSeparator=\
    SET workingDir=%CD%
    set PathLocalIE=%workingDir*%fileSeparator%lib%fileSeparatorKdrivers%fileSeparator%windows%fileSeparator%IEDriver.exe
    EXIT /B e
    :GetPathForFramework
    set fileSeparator=
    SET workingDir=%CD%
    set PathLocalFramework=workingDir2%fileSeparator%1ib%fileSeparator%drivers%fileSeparator%
    EXIT /B
     :GetPathDefaultCitiPath
    set fileSeparator=\ I
    set PathLocalFrameworkDefauktCiti=C:%fileSeparator%Program Files (x86)%fileSeparator%Seleniumm ClientafileSeparator*Selenium drivers
    EXIT /B e

    :GetPathForConfág
    set fileSeparator=\
    SET workingDir=XCD%
    set PathForConfig=workingDir%fileSeparatorRunBatchConfig. properties
    EXIT /B e

    set CertArg=-Djavax.net.ssl.trustStore-c:/certs/cacerts.jks -Djavax.net.ss1.trustStorePassword-changeit
    EXIT /B e
    :GetCertArg
     endloca1

