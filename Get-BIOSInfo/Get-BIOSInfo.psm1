function Get-BIOSInfo {
    [cmdletbinding()]
    param (
    [string[]]$ComputerName = "localhost"
    )
        Get-CimInstance Win32_bios -Property * -ComputerName $ComputerName | sort PSComputerName | ft -AutoSize PSComputerName,Manufacturer,SMBIOSBIOSVersion,SerialNumber
}