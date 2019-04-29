<#
.Synopsis
   Updates our custom powershell modules by fetching the master branch from github.com
.DESCRIPTION
   Long description
.EXAMPLE
   Update-PowershellModules
#>
function Update-PowershellModules
{
    [CmdletBinding()]
    [OutputType([void])]
    Param()

    $moddir = 'C:\Program Files\WindowsPowerShell\Modules';

    if ( -not ($env:PSModulePath).Contains($moddir) ) {
        Write-Error 'PSModulePath does not include the module directory?';
        return;
    }

    # new temp file and temp directory
    $tempFile = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), [guid]::NewGuid().toString() + '.zip');
    $tempDir = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), [guid]::NewGuid().toString());
    New-Item -Path $tempDir -ItemType Directory -ErrorAction Stop;

    # download master zip from github.com
    Invoke-RestMethod -Method Get -UseBasicParsing -Uri 'https://github.com/samtmagee/PowerShellModules/archive/master.zip' -MaximumRedirection 2 -OutFile $tempFile;

    # unzip into temp dir
    Expand-Archive -Path $tempFile -DestinationPath $tempDir;

    # copy from temp dir into new module dir
    Get-ChildItem -Directory -Path ([System.IO.Path]::Combine($tempDir, 'PowerShellModules-master')) |
        Copy-Item -Destination $moddir -Recurse -Force;

    Remove-Item -Path $tempFile -Recurse -Confirm:$false;
    Remove-Item -Path $tempDir -Recurse -Confirm:$false;
}
