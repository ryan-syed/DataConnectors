<#
       .SYNOPSIS
       Script: RunPQSDKTestSuites.ps1
       Runs the pre-built PQ/PQOut format tests in Power Query SDK Test Framework using pqtest.exe compare command.

       .DESCRIPTION
       This script will execute the PQ SDK PQ/PQOut tests present under Sanity, Standard & DataSourceSpecific folders.
       RunPQSDKTestSuitesSettings.json file is used provide configurations need to this script. Please review the template RunPQSDKTestSuitesSettingsTemplate.json for more info.
       Pre-Requisite: Ensure the credentials are setup for your connector following the instructions here: https://learn.microsoft.com/power-query/power-query-sdk-vs-code#set-credential

       .LINK
       General pqtest.md: https://learn.microsoft.com/power-query/sdk-tools/pqtest-overview
       Compare command specific pqtest.md : https://learn.microsoft.com/power-query/sdk-tools/pqtest-commands-options

       .PARAMETER PQTestExePath
       Provide the path to PQTest.exe. Ex: 'C:\\Users\\ContosoUser\\.vscode\\extensions\\powerquery.vscode-powerquery-sdk-0.2.3-win32-x64\\.nuget\\Microsoft.PowerQuery.SdkTools.2.114.4\\tools\\PQTest.exe'

       .PARAMETER ExtensionPath
       Provide the path to extension .mez or .pqx file. Ex: 'C:\\dev\\ConnectorName\\ConnectorName.mez'

       .PARAMETER TestSettingsDirectoryPath
       Provide the path to TestSettingsDirectory folder. Ex: 'C:\\dev\\DataConnectors\\testframework\\tests\\ConnectorConfigs\\ConnectorName\\Settings'

       .PARAMETER TestSettingsList
       Provide the list of settings file needed to initialize the Test Result Object. Ex: SanitySettings.json StandardSettings.json

       .PARAMETER ValidateQueryFolding
       Optional parameter to specify if query folding needs to be verified as part of the test run

       .PARAMETER DetailedResults
       Optional parameter to specify if detailed results are needed along with summary results

       .PARAMETER JSONResults
       Optional parameter to specify if detailed results are needed along with summary results

       .PARAMETER Silent
       Optional parameter to run the script silently without interactive prompts and confirmations

       .EXAMPLE
       PS> .\RunPQSDKTestSuites.ps1

       .EXAMPLE
       PS> .\RunPQSDKTestSuites.ps1 -DetailedResults

       .EXAMPLE
       PS> .\RunPQSDKTestSuites.ps1 -JSONResults

       .EXAMPLE
       PS> .\RunPQSDKTestSuites.ps1 -Silent
#>

param(
    [string]$PQTestExePath,
    [string]$ExtensionPath,
    [string]$TestSettingsDirectoryPath,
    [string[]]$TestSettingsList,
    [switch]$ValidateQueryFolding,
    [switch]$DetailedResults,
    [switch]$JSONResults,
    [switch]$Silent
)

# Pre-Requisite:
# Ensure the credentials are setup for your connector following the instructions here: https://learn.microsoft.com/power-query/power-query-sdk-vs-code#set-credential

# Retrieving the settings for running the TestSuites from the JSON settings file
$RunPQSDKTestSuitesSettings = Get-Content -Path (Join-Path $PSScriptRoot "RunPQSDKTestSuitesSettings.json") | ConvertFrom-Json

# Setting the PQTestExePath from settings object if not passed as an argument
if (!$PQTestExePath){ $PQTestExePath = $RunPQSDKTestSuitesSettings.PQTestExePath }
if (!(Test-Path -Path $PQTestExePath)){
    Write-Output("PQTestExe path is not correctly set. Either set it in RunPQSDKTestSuitesSettings.json or pass it as an argument. " +  $PQTestExePath)
    exit
}

# Setting the ExtensionPath from settings object if not passed as an argument
if (!$ExtensionPath){ $ExtensionPath = $RunPQSDKTestSuitesSettings.ExtensionPath }
if (!(Test-Path -Path $ExtensionPath)){
    Write-Output("Extension path is not correctly set. Either set it in RunPQSDKTestSuitesSettings.json or pass it as an argument. " + $ExtensionPath)
    exit
}

# Setting the TestSettingsDirectoryPath if not passed as an argument
if (!$TestSettingsDirectoryPath){
    if ($RunPQSDKTestSuitesSettings.TestSettingsDirectoryPath){
        $TestSettingsDirectoryPath = $RunPQSDKTestSuitesSettings.TestSettingsDirectoryPath
    }
    else
    {
        $GenericTestSettingsDirectoryPath  = Join-Path -Path (Get-Location) -ChildPath ("ConnectorConfigs\generic\Settings")
        $TestSettingsDirectoryPath = Join-Path -Path (Get-Location) -ChildPath ("ConnectorConfigs\" + (Get-Item $ExtensionPath).Basename + "\Settings")

        # Creating the test settings and parameter query file(s) automatically
        if (!(Test-Path $TestSettingsDirectoryPath)){
            $PSStyle.Foreground.Blue
            Write-Output("Performing the initial setup by creating the test settings and parameter query file(s) automatically...");
            $PSStyle.Reset
            Copy-Item -Path $GenericTestSettingsDirectoryPath -Destination $TestSettingsDirectoryPath -Recurse
            Write-Output("Successfully created test settings file(s) under the directory:`n" + $TestSettingsDirectoryPath);
        }
        $GenericParameterQueriesPath  = Join-Path -Path (Get-Location) -ChildPath ("ConnectorConfigs\generic\ParameterQueries")
        $ExtensionParameterQueriesPath = Join-Path -Path (Get-Location) -ChildPath ("ConnectorConfigs\" + (Get-Item $ExtensionPath).Basename + "\ParameterQueries")
        if (!(Test-Path $ExtensionParameterQueriesPath)){
            Copy-Item -Path $GenericParameterQueriesPath -Destination $ExtensionParameterQueriesPath -Recurse
            Rename-Item -Path (Join-Path -Path $ExtensionParameterQueriesPath -ChildPath "Generic.parameterquery.pq")  -NewName ((Get-Item $ExtensionPath).Basename +".parameterquery.pq")
            Write-Output("Successfully created the parameter query file(s) under the directory:`n" + $ExtensionParameterQueriesPath);
            $PSStyle.Reset

            # Updating the parameter query file(s) location in the test setting file
            foreach ($SettingsFile in (Get-ChildItem $TestSettingsDirectoryPath | ForEach-Object {$_.FullName})){
                $SettingsFileJson = Get-Content -Path $SettingsFile | ConvertFrom-Json
                $SettingsFileJson.ParameterQueryFilePath = $SettingsFileJson.ParameterQueryFilePath.ToLower().Replace("generic", (Get-Item $ExtensionPath).Basename)
                $SettingsFileJson | ConvertTo-Json -depth 100 |  Set-Content $SettingsFile
            }

            # Prompting the user to verify the parameter query file(s)
            if (!$Silent) {
                $PSStyle.Foreground.Magenta
                $parameterQueryUpdated = Read-Host ("Please update the parameter query file(s) generated by replacing with the M query to connect to your data source and retrieve the NycTaxiGreen & TaxiZoneLookup tables.`nAre File(s) updated? [y/n]")
                $PSStyle.Reset

                while($parameterQueryUpdated -ne "y")
                {
                    if ($parameterQueryUpdated -eq 'n') {
                        $PSStyle.Foreground.Red
                        Write-Host("Please update the parameter query file(s) generated by replacing with the M query to connect to your data source and retrieve the NycTaxiGreen & TaxiZoneLookup tables and rerun the script.")
                        $PSStyle.Reset
                        exit
                    }
                    $PSStyle.Foreground.Yellow
                    $parameterQueryUpdated = Read-Host "Please update the parameter query file(s) generated by replacing with the M query to connect to your data source and retrieve the NycTaxiGreen & TaxiZoneLookup tables.`nAre File(s) updated? [y/n]"
                    $PSStyle.Reset
                }
            }
    }
}
}
if (!(Test-Path -Path $TestSettingsDirectoryPath)){
    Write-Output("Test Settings Directory is not correctly set. Either set it in RunPQSDKTestSuitesSettings.json or pass it as an argument. " + $TestSettingsDirectoryPath)
    exit
}


#Setting the TestSettingsList if not passed as an argument

if (!$TestSettingsList){
    if ($RunPQSDKTestSuitesSettings.TestSettingsList){
        $TestSettingsList = $RunPQSDKTestSuitesSettings.TestSettingsList
    }
    else{
    $TestSettingsList = (Get-ChildItem -Path $TestSettingsDirectoryPath -Name)
    }
}

#Setting the ValidateQueryFolding if not passed as an argument
if (!$ValidateQueryFolding){
    if ($RunPQSDKTestSuitesSettings.ValidateQueryFolding -eq "True"){
         $ValidateQueryFolding = $true
    }
}

#Setting the DetailedResults if not passed as an argument
if (!$DetailedResults){
    if ($RunPQSDKTestSuitesSettings.DetailedResults -eq "True"){
        $DetailedResults = $true
    }
}

#Setting the JSONResults if not passed as an argument
if (!$JSONResults){
    if ($RunPQSDKTestSuitesSettings.JSONResults -eq "True"){
        $JSONResults = $true
    }
}

#Setting the Silent if not passed as an argument
if (!$Silent){
    if ($RunPQSDKTestSuitesSettings.Silent -eq "True"){
        $Silent = $true
    }
}

$PSStyle.Foreground.Blue
Write-Output("Below are settings for running the TestSuites:")
$PSStyle.Reset
Write-Output ("PQTestExePath: " + $PQTestExePath)
Write-Output ("ExtensionPath: " + $ExtensionPath)
Write-Output ("TestSettingsDirectoryPath: " + $TestSettingsDirectoryPath)
Write-Output ("TestSettingsList: " + $TestSettingsList)
Write-Output ("ValidateQueryFolding: " + $ValidateQueryFolding)
Write-Output ("DetailedResults: " + $DetailedResults)
Write-Output ("JSONResults: "+ $JSONResults)
Write-Output ("Silent: " + $Silent)

$ExtensionParameterQueriesPath = Join-Path -Path (Get-Location) -ChildPath ("ConnectorConfigs\" + (Get-Item $ExtensionPath).Basename + "\ParameterQueries")
$DiagnosticFolderPath = Join-Path -Path (Get-Location) -ChildPath ("Diagnostics\" + (Get-Item $ExtensionPath).Basename)

if (!$Silent) {
    $PSStyle.Foreground.Magenta
    Write-Output ("Note: Please verify the settings above and ensure the following:
1. Credentials are setup for the extension following the instructions here: https://learn.microsoft.com/power-query/power-query-sdk-vs-code#set-credential
2. Parameter query file(s) are updated with the M query to connect to your data source and retrieve the NycTaxiGreen & TaxiZoneLookup tables under:
$ExtensionParameterQueriesPath
3. If diagnostics folder path is not added in the test settings file then the following path will be used for query folding verfication:
$DiagnosticFolderPath"
    )

    $PSStyle.Reset

    $confirmation = Read-Host "Do you want to proceed? [y/n]"
    while($confirmation -ne "y")
    {
        if ($confirmation -eq 'n') {
            $PSStyle.Foreground.Yellow
            Write-Host("Please specify the correct settings in RunPQSDKTestSuitesSettings.json or pass them arguments and re-run the script.")
            $PSStyle.Reset
            exit
        }
        $confirmation = Read-Host "Do you want to proceed? [y/n]"
    }
}

# Creating the DiagnosticFolderPath if ValidateQueryFolding is set to true
if ($ValidateQueryFolding){
    $DiagnosticFolderPath = Join-Path -Path (Get-Location) -ChildPath ("Diagnostics\" + (Get-Item $ExtensionPath).Basename)
    if (!(Test-Path $DiagnosticFolderPath)){
        New-Item -ItemType Directory -Force -Path $DiagnosticFolderPath | Out-Null
    }
}

# Created a class to store and display test results
class TestResult {
    [string] $SettingsFile;
    [string] $TestFolder;
    [string] $TestName;
    [string] $OutputStatus;
    [string] $TestStatus;
    [string] $Duration;

    TestResult([string]$settingsFile, [string]$testFolder, [string]$testName, [string]$outputStatus, [string]$testStatus, [string]$duration){
        # Constructor to Initialize the Test Result Object
        $this.SettingsFile = $settingsFile;
        $this.TestFolder = $testFolder;
        $this.TestName = $testName;
        $this.OutputStatus = $outputStatus;
        $this.TestStatus = $testStatus;
        $this.Duration = $duration;
    }
}

# Variable to Initialize the Test Result Object
$TestCount = 0
$Passed = 0
$Failed = 0
$TestExecStartTime = Get-Date

$TestResults = @()
$RawTestResults = @()
$TestResultsObjects = @()

# Run the compare command for each of the TestSetttings Files
foreach ($TestSettings in $TestSettingsList){

    Write-Output("`r`nRunning the TestSuite for the TestSettings: " + $TestSettingsDirectoryPath + "\" + $TestSettings)
    $TestSuiteExecStartTime = Get-Date
    Write-Output("Started running the TestSuite at: " + $TestSuiteExecStartTime)

    # Retrieving the settings for running the TestSuites from the JSON settings file
    $TestSettingsContent = Get-Content -Path $TestSettingsDirectoryPath\$TestSettings | ConvertFrom-Json
    $TestSettingsDiagnosticsFolderPath = $TestSettingsContent.DiagnosticsFolderPath

    if ($ValidateQueryFolding -or $TestSettingsDiagnosticsFolderPath) {

        # Running with correct diagnostic folder path using the PQTestExe
        if (!$TestSettingsDiagnosticsFolderPath){
            Write-Output("Running the TestSuite with DiagnosticFolderPath: " + $DiagnosticFolderPath )
            $RawTestResult = & $PQTestExePath compare -p -e $ExtensionPath -sf $TestSettingsDirectoryPath\$TestSettings -dfp $DiagnosticFolderPath
        }
        else{
            Write-Output("Running the TestSuite with DiagnosticFolderPath: " + $TestSettingsDiagnosticsFolderPath)
            $RawTestResult = & $PQTestExePath compare -p -e $ExtensionPath -sf $TestSettingsDirectoryPath\$TestSettings -dfp $TestSettingsDiagnosticsFolderPath
        }
    }
    else {
        $RawTestResult = & $PQTestExePath compare -p -e $ExtensionPath -sf $TestSettingsDirectoryPath\$TestSettings
    }

    $TestSuiteExecEndTime = Get-Date
    Write-Output("Completed running the TestSuite at: " + $TestSuiteExecEndTime)
    Write-Output("Duration for the TestSuite: " + "{0:dd}d:{0:hh}h:{0:mm}m:{0:ss}s" -f (NEW-TIMESPAN -Start $TestSuiteExecStartTime  -End $TestSuiteExecEndTime))

    # The RawTestResult is already a valid JSON array, no need to join
    if ($RawTestResult -and $RawTestResult.Count -gt 0) {
        $TestResultsObject = $RawTestResult | ConvertFrom-Json
    } else {
        $TestResultsObject = @()
    }

    foreach($Result in $TestResultsObject){
           # Get the test folder from TestSettingsContent.QueryFilePath and remove "TestSuites/" prefix
           $testFolder = if ($TestSettingsContent.QueryFilePath) {
               $TestSettingsContent.QueryFilePath -replace '^TestSuites[/\\]', ''
           } else {
               "Unknown\Path"
           }

           # Handle case where Output might be null or empty
           if ($Result.Output -and $Result.Output.Count -gt 0) {
               $outputResult = $Result.Output[0]
               $TestResults += [TestResult]::new($TestSettings, $Result.Output.QueryFilePath.Split("\")[-4] + "\" + $Result.Output.QueryFilePath.Split("\")[-3] + "\" + $Result.Output.QueryFilePath.Split("\")[-2], $Result.Name.Split("\")[-1], $outputResult.Status, $Result.Status, (NEW-TIMESPAN -Start $Result.StartTime  -End $Result.EndTime))
           } else {
               # Handle tests that don't have output (e.g., failed tests)
               $TestResults += [TestResult]::new($TestSettings, $testFolder, $Result.Name.Split("\")[-1], "Failed", $Result.Status, (NEW-TIMESPAN -Start $Result.StartTime  -End $Result.EndTime))
           }
           $TestCount += 1
            if($Result.Status -eq "Passed"){
                $Passed++
            }
            else{
                $Failed++
            }
    }

    $RawTestResults += $RawTestResult
    $TestResultsObjects += $TestResultsObject
}

# Display the test results
$TestExecEndTime = Get-Date

if ($DetailedResults)
{
    Write-Output("`r`n------------------------------------------------------------------------------------------")
    Write-Output("PQ SDK Test Framework - Test Execution - Detailed Results for Extension: " + $ExtensionPath.Split("\")[-1] )
    Write-Output("------------------------------------------------------------------------------------------")
    $TestResultsObjects
}
if ($JSONResults)
{
    Write-Output("`r`n-----------------------------------------------------------------------------------")
    Write-Output("PQ SDK Test Framework - Test Execution - JSON Results for Extension: " + $ExtensionPath.Split("\")[-1] )
    Write-Output("-----------------------------------------------------------------------------------")
    $RawTestResults
}

Write-Output("`r`n----------------------------------------------------------------------------------------------")
Write-Output("PQ SDK Test Framework - Test Execution - Test Results Summary for Extension: " + $ExtensionPath.Split("\")[-1] )
Write-Output("----------------------------------------------------------------------------------------------")

$TestResults  | Format-Table -AutoSize -Property SettingsFile, TestFolder, TestName, @{
    Label = "OutputStatus"
    Expression=
    {
        switch ($_.OutputStatus) {
            { $_ -eq "Passed" } { $color = "$($PSStyle.Foreground.Green)"  }
            { $_ -eq "Output File Generated" } { $color = "$($PSStyle.Foreground.Green)"  }
            { $_ -eq "Failed" } { $color = "$($PSStyle.Foreground.Red)"    }
            { $_ -eq "Error"  } { $color = "$($PSStyle.Foreground.Yellow)" }
            default { $color = "" }
    }
    "$color$($_.OutputStatus)$($PSStyle.Reset)"
}
}, @{
    Label = "TestStatus"
    Expression=
    {
        switch ($_.TestStatus) {
            { $_ -eq "Passed" } { $color = "$($PSStyle.Foreground.Green)"  }
            { $_ -eq "Failed" } { $color = "$($PSStyle.Foreground.Red)"    }
            { $_ -eq "Error"  } { $color = "$($PSStyle.Foreground.Yellow)" }
    }
    "$color$($_.TestStatus)$($PSStyle.Reset)"
}
},
Duration

Write-Output("----------------------------------------------------------------------------------------------")
Write-Output("Total Tests: " + $TestCount + " | Passed: " + $Passed + " | Failed: " + $Failed +  " | Total Duration: " + "{0:dd}d:{0:hh}h:{0:mm}m:{0:ss}s" -f (NEW-TIMESPAN -Start $TestExecStartTime  -End $TestExecEndTime))
Write-Output("----------------------------------------------------------------------------------------------")