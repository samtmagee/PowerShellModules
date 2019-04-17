$cred = Get-Credential 'ISLEWORTHSYON\Administrator';

Invoke-Command -Credential $cred -ComputerName 3020-03 {
    try {
        Import-Module PSWindowsUpdate -ErrorAction Stop;
    } catch {
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Confirm:$false;
        Install-Module -Name pswindowsupdate -Repository PSGallery -Force -RequiredVersion 2.1.1.2 -Scope AllUsers -ErrorAction Stop -Confirm:$false;
    }
    try {
        Import-Module PSWindowsUpdate -ErrorAction Stop;
        Enable-WURemoting -Verbose -ErrorAction Stop;
    } catch {
    }
}
