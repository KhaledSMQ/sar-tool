:Required Software
	:: Microsoft.NET v2.0						http://www.filehippo.com/download_dotnet_framework_2/
	:: Microsoft.NET v3.5						http://www.filehippo.com/download_dotnet_framework_3/
	:: TortoiseSVN (+command line tools)		http://www.filehippo.com/download_tortoisesvn/
	:: 7zip 32bit								http://www.filehippo.com/download_7zip_32/
	:: 7zip 64bit								http://www.filehippo.com/download_7-zip_64/
	:: SharpDevelop v4x							http://www.icsharpcode.net/OpenSource/SD/Download/#SharpDevelop4x

:Optional Software
	:: php										http://windows.php.net/download/

:DownloadLink
	:: GoogleCode: https://code.google.com/p/sar-tool/downloads/list
	:: SourceForge: http://sourceforge.net/projects/sartool/files/
	:: GitHub: https://github.com/kboronka/sar-tool/trunk

:BuildEnvironment
	@echo off
	setlocal
	pushd "%~dp0"
	set SOLUTION=sar.sln
	set REPO=https://github.com/kboronka/sar-tool
	set CONFIG=Release
	set BASEPATH=%~dp0

:Paths
	set SAR="release\sar.exe"
	set ZIP="%PROGRAMFILES%\7-Zip\7zG.exe" a -tzip

	
:Build
	%SAR% svn.GetAssemblyVersion https://github.com/kboronka/sar-tool/trunk/sar/Properties/AssemblyInfo.cs
	echo "VERSION.MAJOR.MINOR.BUILD".
	set /p VERSION="> "

	call UpdateExternals.bat
	
	svn cleanup
	svn update

	%SAR% -f.bsd \sar\*.cs "Kevin Boronka"
	%SAR% -f.bsd \sarTesting\*.cs "Kevin Boronka"
	%SAR% -assy.ver \sar\AssemblyInfo.* %VERSION%

	%SAR% -f.del sar\bin\%CONFIG%\*.* /q /svn
	
	echo building binaries
	%SAR% -b.net 3.5 %SOLUTION% /p:Configuration=%CONFIG% /p:Platform=\"x86\"
	if errorlevel 1 goto BuildFailed
	

:BuildComplete
	copy sar\bin\%CONFIG%\*.exe release\*.exe
	copy sar\bin\%CONFIG%\*.pdb release\*.pdb
	copy license.txt release\license.txt
	
	%ZIP% "sar %VERSION%.zip" .\release\*.*
	svn commit -m "sar version %VERSION%"
	svn copy %REPO%/trunk %REPO%/tags/%VERSION% -m "Tagging the %VERSION% version release of the project"
	svn update
	
	echo build completed
	popd
	exit /b 0

:BuildFailed
	echo build failed
	pause
	popd
	exit /b 1	
