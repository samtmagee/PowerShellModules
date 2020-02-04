function Get-BIOSInfo {
    [cmdletbinding()]
    param (
    [string[]]$ComputerName = "localhost"
    )
    Get-CimInstance 'Win32_bios' -Property '*' -ComputerName $ComputerName |
        Select-Object -Property 'PSComputerName', 'Manufacturer', 'SMBIOSBIOSVersion', 'SerialNumber' |
        Sort-Object PSComputerName
}
