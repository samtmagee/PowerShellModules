<#
.Synopsis
    Gets the OS name and version.
.DESCRIPTION
    Gets the OS name and version for a local or remote machine Windows 10 gets the Windows Product name (Windows 10 Pro), current build number, and monthly UBR as well as the ReleaseId.
.EXAMPLE
    Get-WinVer
    Get the Windows Version for the localhost.
.EXAMPLE
    Get-WinVer -ComputerName fresco-pc
    Get the following details for the remote computer fresco-pc.

    computername     : fresco-PC
    major            : 10
    version          : 1809
    build            : 17763
    release          : 379
    edition          : Education
    installationtype : Client
    WinVer           : Windows 10 Education (OS Build 17763.379)
    PSComputerName   : fresco-pc
    RunspaceId       : <id>
#>


function Get-WinVer
{
    [CmdletBinding()]
    Param
    (
        # ComputerName or names.  Default is localhost
        [string[]]
        $ComputerName = "localhost",

        [pscredential]
        $Credential
    )
    Invoke-Command -Credential $Credential -ComputerName $ComputerName -ScriptBlock {
        $CurrentComputerName = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName").ComputerName
        $major = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").CurrentMajorVersionNumber
        $version = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ReleaseId
        $build = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").CurrentBuildNumber
        $release = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").UBR
        $edition = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").EditionID
        $installationtype = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").InstallationType
        $productname = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ProductName

        $WinVer = if ($installationtype -eq "Server") {
            "$productname (OS Build $build.$release)"
        } elseif ($installationtype -eq "Client") {
            "Windows $major $edition (OS Build $build.$release)"
        } else {
            "Not Windows Server or Client OS."
        }

        return [pscustomobject]@{
            'ComputerName' = $CurrentComputerName
            'Major' = $major
            'Version' = $version
            'Build' = $build
            'Release' = $release
            'Edition' = $edition
            'InstallationType' = $installationtype
            'ProductName' = $productname
            'WinVer' = $WinVer
        }
    } | Select-Object -Property ComputerName, Major, Version, Build, Release, Edition, InstallationType, ProductName, WinVer
}
