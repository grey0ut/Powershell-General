Function Test-TCPPort {
    <#
    .Synopsis
    Check to see if a TCP port is open or closed
    .Description
    Using the .NET classes to check if a TCP port is open or closed on a remote host. Supports passing multiple ports in the parameter in a quoted comma separated list
    .Parameter Port
    The numeric port to check. Also accepts multiple input, i.e.  135,137,80,443
    .Parameter Target
    The name or IP of the target computer you wish to check.
    Accept pipeline input.
    .Example
    Test-TCPPort -port 80 -target Computer123

    Host        Pingable Port State
    ----        -------- ---- -----
    Computer123     true   80 Closed

    This example checks to see if TCP port 80 is open on Computer123. The result returns that it is closed
    .Example
    Test-TCPPort -port 135,445,3389,443 -target Computer123

    Host        Pingable Port State
    ----        -------- ---- -----
    Computer123     true  135 Open
    Computer123     true  445 Open
    Computer123     true 3389 Open
    Computer123     true  443 Closed

    This example checks for a list of ports and returns all the results in one table
    .NOTES
    Version:        4.0
    Author:         C. Bodett
    Creation Date:  10/22/2025
    Purpose/Change: updated help to match function output
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Position = 0, Mandatory = $true)]
        [Alias('Port')]
        [Int[]]$Ports,
        [Parameter(Position = 1, Mandatory = $true, ValueFromPipeline = $true)]
        [Alias('Host','Computer','Target')]
        [String[]]$ComputerName
    )

    process {
        Foreach ($Computer in $ComputerName) {
            Foreach ($Port in $Ports) {
                # quick ping test
                $HostTest = Test-Connection $Computer -Count 1 -Quiet
                # Create a Net.Sockets.TcpClient object to use for
                $Socket = [Net.Sockets.TcpClient]::new()

                # Suppress error messages
                $ErrorActionPreference = 'SilentlyContinue'

                # Try to connect
                if ($Socket.ConnectAsync($Computer, $Port).Wait(100)) {
                    $State = "Open"
                } else {
                    $State = "Closed"
                }

                # Make error messages visible again
                $ErrorActionPreference = 'Continue'

                $Socket.Dispose()
                $Socket = $null

                [PSCustomObject]@{
                    'Host'      = $Computer
                    'Pingable'  = $HostTest
                    'Port'      = $Port
                    'State'     = $State
                }
            }
        }
    }
}