<#
.Synopsis
   Sends a wake-on-lan packet to the specified computer
.DESCRIPTION
   Sends a wake-on-lan packet to the specified computer
.EXAMPLE
   Send-WOL -address AABBCCDDEEFF
.EXAMPLE
   Send-WOL -address AA-BB-CC-DD-EE-FF -broadcast 192.168.1.255
#>
function Send-WOL
{
    [CmdletBinding()]
    [OutputType([void])]
    Param
    (
        # The mac address of the computer to wake
        [Alias("streetAddress")]
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]$Address,

        # The broadcast address for the subnet
        [string]$Broadcast = "10.136.135.255"
    )

    # parse
    $_MAC = [System.Net.NetworkInformation.PhysicalAddress]::Parse($address);

    # create the WOL magic packet
    # 255 255 255 255 255 255 [16 copies of mac address]
    [byte[]]$_packet = (255, 255, 255, 255, 255, 255) + ( $_MAC.GetAddressBytes() * 16 );

    # data, length, ip address, port
    [void][System.Net.Sockets.UdpClient]::new().Send($_packet, 102, [ipaddress]$Broadcast, 9);
    Write-Verbose -Message "Send-WOL to $_MAC";
}