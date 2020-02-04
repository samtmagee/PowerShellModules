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
    # Get the html page
    $response = Invoke-WebRequest -Uri 'https://winreleaseinfoprod.blob.core.windows.net/winreleaseinfoprod/en-US.html'
    # Get the html out of it
    $html = $response | Select-Object -ExpandProperty ParsedHtml
    # Select the first table in the document
    $table = $html.getElementsByTagName('table') | Select-Object -First 1
    # Find the first row that has the highlight class
    # <tr class="highlight">
    $row = $table.getElementsByTagName('tr') | Where-Object { $_.className -eq 'highlight' } | Select-Object -First 1
    
    # Get the first table data (td) and extract the innerText
    $version = $row.getElementsByTagName('td') | Select-Object -First 1 -ExpandProperty innerText

    # Get the 4th column, split on a dot
    $osbuild = $row.getElementsByTagName('td') | Select-Object -Skip 3 -First 1 -ExpandProperty innerText
    $build = $osbuild.Split('.')[0]
    $release = $osbuild.Split('.')[1]

    return [PSCustomObject]@{
        Version = $version
        Build = $build
        Release = $release
    }
}
