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
    $HTML = Invoke-WebRequest -Uri “https://winreleaseinfoprod.blob.core.windows.net/winreleaseinfoprod/en-US.html“
    $suggested = ($HTML.ParsedHtml.getElementsByTagName(‘tr’) | Where {$_.className -eq ‘highlight’ }).innerHTML
    $lines = $suggested.Split([Environment]::NewLine)
    $linehtml = $lines | select -First 7 | select -Last 1
    $linehtml = $linehtml -replace "<td>","" -replace "</td>",""
    return $linehtml
}
