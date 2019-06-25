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
        [string[]]$ComputerName = "localhost"
    )
    Invoke-Command -ComputerName $ComputerName -ScriptBlock {
        $CurrentComputerName = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName").ComputerName
        $major = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").CurrentMajorVersionNumber
        $version = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ReleaseId
        $build = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").CurrentBuildNumber
        $release = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").UBR
        $edition = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").EditionID
        $installationtype = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").InstallationType
        $productname = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ProductName
        
        if ($installationtype -eq "Server") {
            $WinVer = "$productname (OS Build $build.$release)"
        }
        if ($installationtype -eq "Client") {
            $WinVer = "Windows $major $edition (OS Build $build.$release)"
        }
        if ($installationtype -ne "Server" -and $installationtype -ne "Client") {
            $WinVer = "Not Windows Server or Client OS."
        }
        $arraytoexport = @()
        $arraytoexport +=[pscustomobject]@{
            'computername' = $CurrentComputerName
            'major' = $major
            'version' = $version
            'build' = $build
            'release' = $release
            'edition' = $edition
            'installationtype' = $installationtype
            'productname' = $productname
            'WinVer' = $WinVer
        }
        $arraytoexport = $arraytoexport | select computername,major,version,build,release,edition,installationtype,winver -ExcludeProperty RunspaceId
        return $arraytoexport
    }
}
