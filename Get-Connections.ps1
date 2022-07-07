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
.Parameter Process
    Filters the results by process (exe) name
.Parameter User
    Filters the results by the username associated with the process
.Parameter ComputerName
    Connections to a remote computer to obtain the results
.Parameter Credential
    To be used in conjunction with ComputerName if specifying different credentials than current user for authentication to remote host(s)
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
    Version:        1.7
    Author:         C. Bodett
    Creation Date:  12/10/2021
    Purpose/Change: first attempt at adding in the ability to execute this against remote computers.
#>
#Requires -RunasAdministrator
[CmdletBinding(DefaultParameterSetName = "Filter")]
Param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("LocalAddress","LocalPort","RemoteAddress","RemotePort","State","Process","User")]
    $Sort = "State",
    [Parameter(ParameterSetName = "Filter", Mandatory = $false)]
    $LocalAddress = $null,
    [Parameter(ParameterSetName = "Filter", Mandatory = $false)]
    $LocalPort = $null,
    [Parameter(ParameterSetName = "Filter", Mandatory = $false)]
    $RemoteAddress = $null,
    [Parameter(ParameterSetName = "Filter", Mandatory = $false)]
    $RemotePort = $null,
    [Parameter(ParameterSetName = "Filter", Mandatory = $false)]
    $Process = $null,
    [Parameter(ParameterSetName = "Filter", Mandatory = $false)]
    $User = $null,
    [Parameter(ParameterSetName = "Filter", Mandatory = $false)]
    [ValidateSet("Listen","Bound","Established","CloseWait","Timewait")]
    $State = $null,
    [Parameter(Mandatory = $false)]
    $ComputerName,
    [Parameter(Mandatory = $false)]
    [System.Management.Automation.PSCredential]
    [System.Management.Automation.Credential()]
    $Credential = [System.Management.Automation.PSCredential]::Empty
)

    Begin {
        $GNTCArgs = [ordered]@{}
        $WhereArray = [System.Collections.ArrayList]@()

        If ($PSCmdlet.ParameterSetName -eq "Filter") {
            Switch ($PSBoundParameters.Keys) {
                'LocalAddress' {$GNTCArgs.Add('LocalAddress',$LocalAddress)}
                'LocalPort' {$GNTCArgs.Add('LocalPort',$LocalPort)}
                'RemoteAddress' {$GNTCArgs.Add('RemoteAddress',$RemoteAddress)}
                'RemotePort' {$GNTCArgs.Add('RemotePort',$RemotePort)}
                'State' {$GNTCArgs.Add('State',$State)}
                'Process' {[void]$WhereArray.Add('$_.Process -match $Process')}
                'User' {[void]$WhereArray.Add('$_.User -match $User')}
            }
        }

        $WhereString = $WhereArray -join " -and "
        $WhereBlock = [ScriptBlock]::Create($WhereString)

        $SelObjArgs = @("Local*",
                        "Remote*",
                        "State",
                        @{Name="Process";Expression={(Get-Process -Id $_.OwningProcess).ProcessName}},
                        @{Name="User";Expression={(Get-Process -Id $_.owningprocess -IncludeUserName).Username}}
            )

        $GNTCScriptBlock = {
            Try {
                Get-NetTCPConnection @Using:GNTCArgs -ErrorAction Stop | Foreach-Object {
                [PSCustomObject]@{
                    LocalAddress = $_.LocalAddress
                    LocalPort = $_.LocalPort
                    RemoteAddress = $_.RemoteAddress
                    RemotePort = $_.RemotePort
                    State = $_.State
                    Process = (Get-Process -Id $_.OwningProcess).ProcessName
                    User = (Get-Process -Id $_.Owningprocess -IncludeUserName).Username
                }
            }
        } Catch [Microsoft.PowerShell.Cmdletization.Cim.CimJobException] {
            Write-Warning "Could not find any states matching that parameter"
        } Catch {
            $Error[0]
        }
        }
    }

    Process {
        $GNTCOutput = If ($ComputerName) {
                        Try {
                            Invoke-Command -ComputerName $ComputerName -ScriptBlock $GNTCScriptBlock -Credential $Credential -ErrorAction Stop
                            } Catch {
                                Write-Host "Could not retrieve results from $ComputerName" -ForegroundColor Red
                            }
                        } Else {
                            Try { 
                                Get-NetTCPConnection @GNTCArgs -ErrorAction Stop | Foreach-Object {
                                [PSCustomObject]@{
                                    LocalAddress = $_.LocalAddress
                                    LocalPort = $_.LocalPort
                                    RemoteAddress = $_.RemoteAddress
                                    RemotePort = $_.RemotePort
                                    State = $_.State
                                    Process = (Get-Process -Id $_.OwningProcess).ProcessName
                                    User = (Get-Process -Id $_.Owningprocess -IncludeUserName).Username
                                }
                            }} Catch [Microsoft.PowerShell.Cmdletization.Cim.CimJobException] {
                                Write-Warning "Could not find any states matching that parameter"
                            } Catch {
                                Write-Error $Error[0]
                            }
                        }
                 
        If ($WhereString) {
            $Results = $GNTCOutput | Where-Object $WhereBlock
        } Else {
            $Results = $GNTCOutput
        }
    }


    End {
    $Results | Sort-Object -Property $Sort | Format-Table -Autosize -Wrap
    }

}