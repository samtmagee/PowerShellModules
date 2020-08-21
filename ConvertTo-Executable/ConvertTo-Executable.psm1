<#
.SYNOPSIS
    Converts a powershell scriptblock into an exe by packaging
    a script file into an iexpress.exe self-extracting exe
.DESCRIPTION
    This cmdlet uses iexpress.exe to create a self-extracting
    "installer" which contains a powershell script file
    which is extracted to a temp folder, run, and then deleted.
    The stdout of the powershell process is not captured so
    the scriptblock should have side effects or use
    Start-Transcript if output is desired and write to a file.

    This (probably) has a high chance of tripping anti-malware or
    intrusion detection systems as this is a common path for
    malware and viruses to take.

    The working directory of the script is wherever iexpress
    decided to extract the content so use Set-Location in
    the script to change it.
.EXAMPLE
    Convertto-Executable -ScriptBlock { "Hello, world!" | Out-File "C:\world.txt" } -Path C:\hello.exe
    Run the exe and a text file should appear in C: (assuming permissions are sufficient)
#>
function Convertto-Executable {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$false,
                   ValueFromPipeline=$false,
                   Position=0)]
        [string]$Path,

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   Position=1)]
        [scriptblock]$ScriptBlock
    )

    $sedContent = @'
[Version]
Class=IEXPRESS
SEDVersion=3
[Options]
PackagePurpose=InstallApp
ShowInstallProgramWindow=0
HideExtractAnimation=1
UseLongFileName=0
InsideCompressed=0
CAB_FixedSize=0
CAB_ResvCodeSigning=0
RebootMode=N
InstallPrompt=%InstallPrompt%
DisplayLicense=%DisplayLicense%
FinishMessage=%FinishMessage%
TargetName=%TargetName%
FriendlyName=%FriendlyName%
AppLaunched=%AppLaunched%
PostInstallCmd=%PostInstallCmd%
AdminQuietInstCmd=%AdminQuietInstCmd%
UserQuietInstCmd=%UserQuietInstCmd%
SourceFiles=SourceFiles
[Strings]
InstallPrompt=
DisplayLicense=
FinishMessage=
TargetName={{tempDir}}\out.exe
FriendlyName=
AppLaunched=powershell.exe -WindowStyle Hidden -ExecutionPolicy ByPass -File script.ps1
PostInstallCmd=<None>
AdminQuietInstCmd=
UserQuietInstCmd=
FILE0="script.ps1"
[SourceFiles]
SourceFiles0={{tempDir}}
[SourceFiles0]
%FILE0%=
'@

    try {
        # create a new temporary directory
        $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ([guid]::NewGuid())
        New-Item -Path $tempDir -ItemType Directory -ErrorAction Stop

        ([string]$ScriptBlock) | Out-File -FilePath "$tempDir\script.ps1" -ErrorAction Stop
        $sedContent.Replace('{{tempDir}}', $tempDir) | Out-File -FilePath "$tempDir\output.sed" -ErrorAction Stop

        Start-Process -Wait -FilePath 'C:\WINDOWS\system32\iexpress.exe' -ArgumentList '/N','/Q','/M',"$tempDir\output.sed" -ErrorAction Stop

        Move-Item -Path "$tempDir\out.exe" -Destination $Path -Force -ErrorAction Stop
    }
    finally {
        Remove-Item -Recurse $tempDir -Force
    }
}
