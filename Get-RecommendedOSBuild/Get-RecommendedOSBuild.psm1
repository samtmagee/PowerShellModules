<#
.Synopsis
   Get the current recommended build version for Windows 10.
.DESCRIPTION
   Get the current recommended build version for Windows 10 from the following website
   https://docs.microsoft.com/en-us/windows/windows-10/release-information
.EXAMPLE
   Get-RecommendedOSBuild
#>
function Get-RecommendedOSBuild
{
    [CmdletBinding()]
    $html    = Invoke-WebRequest -Uri 'https://winreleaseinfoprod.blob.core.windows.net/winreleaseinfoprod/en-US.html' | Select-Object -ExpandProperty ParsedHtml
    $table   = $html.getElementsByTagName('table') | Select-Object -Skip 0 -First 1
    $row     = $table.getElementsByTagName('tr')   | Select-Object -Skip 1 -First 1
    $version = $row.getElementsByTagName('td')     | Select-Object -Skip 0 -First 1 -ExpandProperty innerText
    return $version
}
