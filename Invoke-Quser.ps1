Function Invoke-Quser {
    <#
    .SYNOPSIS
    A wrapper for Quser.exe to return Powershell objects
    .DESCRIPTION
    Executes Quser locally or against a remote computer and returns the results as Powershell objects
    .PARAMETER ComputerName
    Remote  computername for use with "/SERVER" parameter within Quser.exe
    .PARAMETER UserorSession
    If you know the username, sessionID number, or Session type you can pass that to this parameter.
    .EXAMPLE
    PS C:\> Invoke-Quser

    Username    : John123
    SessionID   : 1
    SessionName : Console
    State       : Active
    LogonTime   : 2/17/2022 8:27:00 AM
    .Notes
    Version:        1.0
    Author:         C. Bodett
    Creation Date:  2/8/2022
    Purpose/Change: Initial function development
    Version:        1.1
    Author:         C. Bodett
    Creation Date:  2/17/2022
    Purpose/Change: Added the "State" property
    Version:        1.2
    Author:         C. Bodett
    Creation Date:  4/4/2022
    Purpose/Change: Changed the logon date array index to start from the end.
    Version:        1.3
    Author:         C. Bodett
    Creation Date:  5/11/2022
    Purpose/Change: Changed the split method on the user info row to be more like github.com/UNT-CAS/QuserObject implementation. Borrowed a lot of their methodology from that module and used it here.
    #>
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory = $false, Position = 0)]
        [String]$ComputerName = "Localhost",
        [Parameter(Mandatory = $false)]
        [String]$UserorSession
    )

    if ($ComputerName -eq "Localhost") {
        $Qcmd = '{0} {1}'
    } else {
        $Qcmd = '{0} {1} /SERVER:{2}'
    }

    $Quser = $Qcmd -f 'quser.exe', $UserorSession, $ComputerName

    try {
        $Results = (Invoke-Expression $Quser) 2>&1
    } catch {
        $Results = $Error[0].Exception.Message
    }

    if ($LASTEXITCODE -eq 0) {
        $QUserOutput = Foreach ($Result in ($Results | Select-Object -Skip 1)) {
                        #$ParsedLine = $Result.Split(" ",[System.StringSplitOptions]::RemoveEmptyEntries)
                        $ParsedLine = $Result -split '\s{2,}'
                        [System.Collections.Generic.List[String]]$SessionInfo = $ParsedLine | Select-Object -Skip 1
                        if ($SessionInfo.Count -eq 4) {
                            # session name is blank. adding a blank entry to the array
                            $SessionInfo.Insert(0,'')
                        }
                        $IdleTime = if ($SessionInfo[3] -eq "none" -or $SessionInfo[3] -eq '.') {
                            "none"
                        } else {
                            If ($SessionInfo[3] -as [Int]) {
                                $SessionInfo[3] = "0:$($SessionInfo[3])"
                            }
                            [Timespan]$QuserIdle = $SessionInfo[3].Replace('+','.')
                            #(Get-Date).Subtract($QuserIdle)
                            $QuserIdle
                        }
                        $UserInfo = [PSCustomObject]@{
                            ComputerName = $ComputerName
                            Username = $ParsedLine[0].TrimStart('>').Trim()
                            SessionID = [Int]$SessionInfo[1]
                            SessionName = $SessionInfo[0]
                            State = $SessionInfo[2]
                            IdleTime = $IdleTime
                            LogonTime = Get-Date $SessionInfo[4]
                        }
                        $UserInfo
                    }
        return $QUserOutput
    } else {
        Write-Host $Results.Exception.message -ForegroundColor Red
    }
}