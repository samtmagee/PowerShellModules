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
    [Alias()]
    [OutputType([int])]
    Param
    (
        # The mac address of the computer to wake
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]$address,

        # The broadcast address for the subnet
        [string]$broadcast = "10.136.135.255"
    )

    Begin
    {
    }
    Process
    {
        # parse
        $_broadcast = [Net.IPAddress]::Parse($broadcast);
        $_MAC = [System.Net.NetworkInformation.PhysicalAddress]::Parse($address);
        
        # create the WOL magic packet
        # 255 255 255 255 255 255 [16 copies of mac address]
        [byte[]]$_packet = (255, 255, 255, 255, 255, 255) + ( $_MAC.GetAddressBytes() * 16 );
        
        # data, length, ip address, port
        [System.Net.Sockets.UdpClient]::new().Send($_packet, 102, $_broadcast, 9);
    }
    End
    {
    }
}