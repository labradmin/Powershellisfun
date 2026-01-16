#Install WinGet, used https://learn.microsoft.com/en-us/windows/package-manager/winget/#install-winget-on-windows-sandbox
#https://powershellisfun.com/2024/08/02/creating-a-development-windows-sandbox-using-powershell-and-winget/ based on
Start-Transcript -Path "C:\users\wdagutilityaccount\desktop\Installing.txt" -Append
$progressPreference = 'silentlyContinue'
Write-Output "Starting script..."
$progressPreference = 'silentlyContinue'
Set-WinHomeLocation -GeoId  77 
Write-Host "Change Country or Region from World (default in Sandbox) to Finland due to error WinGet operation finished with exit code [0x8A15003B] (RESTAPI_INTERNAL_ERROR)"
Write-Host "Installing WinGet PowerShell module from PSGallery..."
Install-PackageProvider -Name NuGet -Force | Out-Null
Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery -Scope AllUsers #| Out-Null
Write-Host "Using Repair-WinGetPackageManager cmdlet to bootstrap WinGet..."
Repair-WinGetPackageManager -Force:$true -Latest -Verbose -AllUsers
Write-Host "Done."

#Install software
$SoftwareToInstall = "Notepad++.Notepad++", "Microsoft.Powershell"
foreach ($Software in $SoftwareToInstall) {
    WinGet.exe install $software --silent --force --accept-source-agreements --disable-interactivity --source winget
}
Write-Output "Script completed successfully."
Stop-Transcript
