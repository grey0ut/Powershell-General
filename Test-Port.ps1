Function Test-Port {
    <#
    .Synopsis
    Check to see if a TCP port is open or closed
    .Description
    USing the Test-NetConnection cmdlet to check if a TCP port is open or closed on a remote host. Supports passing multiple ports in the parameter in a quoted comma separated list
    .Parameter Port
    The numeric port to check. Also accepts multiple input, i.e.  135,137,80,443
    .Parameter Target
    The name or IP of the target computer you wish to check.
    Accept pipeline input.
    .Example
    Test-Port -port 80 -target Computer123

    Port State
    ---- -----
    80   Closed

    This example checks to see if TCP port 80 is open on Computer123. The result returns that it is closed
    .Example
    Test-Port -port 135,445,3389,443 -target Computer123

    Port State
    ---- -----
    135  Open
    445  Open
    3389 Open
    443  Closed

    This example checks for a list of ports and returns all the results in one table
    .Example
    Test-Port 445 Computer123

    Port State
    ---- -----
    445  Open

    Same as first example but utilizes the parameter positions rather than calling them by name
    .NOTES
    Version:        3.1
    Author:         C. Bodett
    Creation Date:  9/15/2022
    Purpose/Change: Added support for passing multiple computernames at the same time too.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [Alias('Port')]
        [Int[]]$Ports,
        [Parameter(Position = 1, Mandatory = $true, ValueFromPipeline = $true)]
        [Alias('Host','Computer','Target')]
        [String[]]$ComputerName
    )
    
    begin {
        $Results= [System.Collections.Generic.List[PSCustomObject]]::New()
    }
    
    process {
        Foreach ($Port in $Ports) {
            Foreach ($Computer in $ComputerName) {
                $HostTest = Test-Connection $Computer -Count 1 -Quiet
                $PortTest = Test-NetConnection $Computer -Port $Port -WarningAction SilentlyContinue -InformationLevel Quiet
                $Results.Add([PSCustomObject]@{
                    'Host'      = $Computer
                    'Pingable'  = $HostTest
                    'Port'      = $Port
                    'State'     = if ($PortTest){'Open'}Else{'Closed'}
                })
            }
        }
    }

    end {
        $Results
    }
}
