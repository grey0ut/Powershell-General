function Get-Connection {
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
    Version:        2.1
    Author:         C. Bodett
    Creation Date:  7/17/2024
    Purpose/Change: Formatting, dropped plural from name, added Typename for formatting.
    #>
    #Requires -RunasAdministrator
    [CmdletBinding(DefaultParameterSetName = "Filter")]
    Param(
        [Parameter(Mandatory=$false)]
        [ValidateSet("LocalAddress","LocalPort","RemoteAddress","RemotePort","State","Process","User")]
        [String]$Sort = "State",
        [Parameter(ParameterSetName = "Filter", Mandatory=$false)]
        [String]$LocalAddress,
        [Parameter(ParameterSetName = "Filter", Mandatory=$false)]
        [Int32]$LocalPort,
        [Parameter(ParameterSetName = "Filter", Mandatory=$false)]
        [String]$RemoteAddress,
        [Parameter(ParameterSetName = "Filter", Mandatory=$false)]
        [Int32]$RemotePort,
        [Parameter(ParameterSetName = "Filter", Mandatory=$false)]
        [String]$Process,
        [Parameter(ParameterSetName = "Filter", Mandatory=$false)]
        [String]$User,
        [Parameter(ParameterSetName = "Filter", Mandatory=$false)]
        [ValidateSet("Listen","Bound","Established","CloseWait","Timewait")]
        [String]$State
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
        
        $SelObjArgs = [ordered]@{
            Property = @(
                "Local*",
                "Remote*",
                "State",
                @{Name="Process";Expression={(Get-Process -Id $_.OwningProcess).ProcessName}},
                @{Name="User";Expression={(Get-Process -Id $_.owningprocess -IncludeUserName).Username}}
            )
        }
    }

    Process {
        $GNTCOutput = try {
            Get-NetTCPConnection @GNTCArgs -ErrorAction Stop | Select-Object @SelObjArgs
            } catch [Microsoft.PowerShell.Cmdletization.Cim.CimJobException] {
                Write-Warning "Could not find any states matching that parameter"
            } catch {
                Write-Error $_
            }
        If ($WhereString) {
            $Results = $GNTCOutput | Where-Object $WhereBlock
        } Else {
            $Results = $GNTCOutput
        }
        Foreach ($Result in $Results) {
            $Result.PSObject.Typenames.insert(0,"GetConnection")
        }
        $Results | Sort-Object -Property $Sort
    }

    End {
    }
}
