#https://powershellisfun.com/2024/08/02/creating-a-development-windows-sandbox-using-powershell-and-winget/ based on
param(
    [parameter(Mandatory = $false)][string]$MappedFolder = 'D:\_Test',
	[parameter(Mandatory = $false)][string]$SandboxFolder = 'c:\_Packaging',
	[parameter(Mandatory = $false)][string]$ToolFolder = 'D:\_tools',
	[parameter(Mandatory = $false)][string]$SandBoxToolFolder = 'C:\_tools',
    [parameter(Mandatory = $false)][string]$LogonCommand = 'install-Winget-Sandbox.ps1',
	[parameter(Mandatory = $false)][string]$PSAPP = 'Invoke-AppDeployToolkit.ps1'
)

#Check if Windows Sandbox is already running. Exit if yes
if (Get-Process -Name 'WindowsSandbox' -ErrorAction SilentlyContinue) {
    Write-Warning ("Windows Sandbox is already running, exiting...")
    return
}

#Validate if $mappedfolder exists
if ($MappedFolder) {
    if (Test-Path $MappedFolder -ErrorAction SilentlyContinue) {
        Write-Host ("Specified {0} path exists, continuing..." -f $MappedFolder) -ForegroundColor Green
    }
    else {
        Write-Warning ("Specified {0} path doesn't exist, exiting..." -f $MappedFolder)
        return
    }
}

#Validate if $mappedfolder exists
if ($ToolFolder) {
    if (Test-Path $ToolFolder -ErrorAction SilentlyContinue) {
        Write-Host ("Specified {0} path exists, continuing..." -f $ToolFolder) -ForegroundColor Green
    }
    else {
        Write-Warning ("Specified {0} path doesn't exist, exiting..." -f $ToolFolder)
        return
    }
}

#Create .wsb config file, overwrite  existing file if present and check if specified logoncommand exist
$wsblocation = "$($ToolFolder)\WindowsSandbox.wsb"
if (-not (Test-Path "$($ToolFolder)\$($LogonCommand)")) {
    Write-Warning ("Specified LogonCommand {0} doesn't exist in {1}, exiting..." -f $ToolFolder, $LogonCommand)
    return
}

Tee-Object -FilePath $wsblocation -Append:$false

$wsb = @()
$wsb += "<Configuration>"
$wsb += "<MappedFolders>"
$wsb += "<MappedFolder>"
$wsb += "<HostFolder>$($MappedFolder)</HostFolder>"
$wsb += "<SandboxFolder>$($SandboxFolder)</SandboxFolder>"
$wsb += "<ReadOnly>true</ReadOnly>"
$wsb += "</MappedFolder>"

$wsb += "<MappedFolder>"
$wsb += "<HostFolder>$($ToolFolder)</HostFolder>"
$wsb += "<SandboxFolder>$($SandboxToolFolder)</SandboxFolder>"
$wsb += "<ReadOnly>true</ReadOnly>"
$wsb += "</MappedFolder>"
$wsb += "</MappedFolders>"

$LogonCommandFull = 'Powershell.exe -ExecutionPolicy bypass -File ' + '"C:\' + $(Get-childitem -Path $($wsblocation) -Directory).Directory.Name + '\' + $logoncommand + '"'
$LogonCommandScript = 'cmd.exe /c start PWSH.exe -ExecutionPolicy bypass -NoExit -File ' + '"' + $SandboxFolder + '\' + $PSAPP + '"'
$wsb += "<LogonCommand>"
$wsb += "<Command>xcopy `"$($SandboxToolFolder)\notepad.exe`" `"C:\Windows\System32\`" /Y</Command>"
$wsb += "<Command>xcopy `"$($SandboxToolFolder)\cmtrace.exe`" `"C:\Users\WDAGUtilityAccount\Desktop`"/Y</Command>"
$wsb += "<Command>$($LogonCommandFull)</Command>"
$wsb += "<Command>$($LogonCommandScript)</Command>"
$wsb += "</LogonCommand>"

$wsb += "</Configuration>"
    
#Create sandbox .wsb file in $mappedfolder and start Windows Sandbox using it
$wsb | Out-File $wsblocation -Force:$true
Write-Host ("Saved configuration in {0} and Starting Windows Sandbox..." -f $wsblocation) -ForegroundColor Green
Invoke-Item $wsblocation

Write-Host ("Done!") -ForegroundColor Green