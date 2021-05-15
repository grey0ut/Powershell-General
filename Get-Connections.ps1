Function Get-Connections {
    <# 
    .Synopsis
    Shows a table of all active connections, the owning process, and running user
    .Description
    An expansion of the Get-NetTCPConnection cmdlet that includes the owning process and user
    .Parameter Sort
    By default the output is sorted by State, but you can use this parameter to sort by any of the displayed properties. Use 'Tab' to cycle through the list of acceptable values for Sort
    .Parameter LocalAddress
    Same as Get-NetTCPConnection. Specify the LocalAddress you want to restrict the cmdlet to
    .Parameter LocalPort
    Same as Get-NetTCPConnection. Specify the LocalPort you want to restrict the cmdlet to
    .Parameter RemoteAddress
    Same as Get-NetTCPConnection. Specify the RemoteAddress you want to restrict the cmdlet to
    .Parameter RemotePort
    Same as Get-NetTCPConnection. Specify the RemotePort you want to restrict the cmdlet to
    .Parameter State
    Same as Get-NetTCPConnection. Specify the State you want to restrict the cmdlet to
    .Example
    PS C:\>Get-Connections
    
    This command returns all of the current TCP connections, the owning process, and user
    .Example
    PS C:\>Get-Connections -LocalPort 3389
    
    This command returns only current TCP connections using the local port 3389
    .Example
    PS C:\>Get-Connections -LocalPort 445 -State Listen
    
    This command returns current TCP connections on local port 445 and in a listening state
    .NOTES
        Version:    1.4
        Author:     C. Bodett
        Creation Date: 9/17/19
    #>
    #requires -RunasAdministrator
    
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false)]
        [ValidateSet("LocalAddress","LocalPort","RemoteAddress","RemotePort","State","Process","User")]
        $Sort = "State",
        [Parameter(ParameterSetName = "Filter", Mandatory=$false)]
        $LocalAddress = $null,
        [Parameter(ParameterSetName = "Filter", Mandatory=$false)]
        $LocalPort = $null,
        [Parameter(ParameterSetName = "Filter", Mandatory=$false)]
        $RemoteAddress = $null,
        [Parameter(ParameterSetName = "Filter", Mandatory=$false)]
        $RemotePort = $null,
        [Parameter(ParameterSetName = "Filter", Mandatory=$false)]
        [ValidateSet("Listen","Bound","Established","CloseWait","Timewait")]
        $State = $null
    )
    
    Begin {
        $GNTCArgs = [ordered]@{}
        
        If ($PSCmdlet.ParameterSetName -eq "Filter"){
            Switch ($PSCmdlet.MyInvocation.BoundParameters.keys) {
                'LocalAddress' {$GNTCArgs.Add('LocalAddress',$LocalAddress)}
                'LocalPort' {$GNTCArgs.Add('LocalPort',$LocalPort)}
                'RemoteAddress' {$GNTCArgs.Add('RemoteAddress',$RemoteAddress)}
                'RemotePort' {$GNTCArgs.Add('RemotePort',$RemotePort)}
                'State' {$GNTCArgs.Add('State',$State)}
            }
        }
        
        $SelObjArgs = [ordered]@{
            Property = @("Local*",
                        "Remote*",
                        "State",
                        @{Name="Process";Expression={(Get-Process -Id $_.OwningProcess).ProcessName}},
                        @{Name="User";Expression={(Get-Process -Id $_.owningprocess -IncludeUserName).Username}}
            )
        }
    }
    
    Process {
        $Results = Try {
            Get-NetTCPConnection @GNTCArgs -ErrorAction Stop | Select-Object @SelObjArgs
            } Catch [Microsoft.PowerShell.Cmdletization.Cim.CimJobException] {
                Throw "Could not find any states matching that parameter"
            } Catch {
                $Error[0].Exception
            }
        $Results | Sort-Object -Property $Sort | Format-Table -AutoSize -Wrap
    }
    
    End {}
    } 