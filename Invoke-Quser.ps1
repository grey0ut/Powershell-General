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

    Username     : John123
    SessionID    : 1
    SessionName  : Console
    State        : Active
    Idletime     : 00:00:00
    LogonTime    : 2/17/2022 8:27:00 AM
    ComputerName : computer123
    .EXAMPLE
    PS C:\> Invoke-Quser -ComputerName Server1

    Username     : jsmith
    SessionID    : 1
    SessionName  : rdp-tcp#0
    State        : Active
    IdleTime     : 02:49:00
    LogonTime    : 3/17/2025 1:27:00 AM
    ComputerName : Server1
    .Notes
    Version:        2.0
    Author:         C. Bodett
    Creation Date:  10/28/2026
    Purpose/Change: complete rewrite with new quser parsing method, idle time conversion and general cleanup
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
        $Results = $_.Exception.Message
    }

    if ($LASTEXITCODE -eq 0) {
        $Header = @(
            "Username",
            "SessionName",
            "SessionID",
            "State",
            "IdleTime",
            "LogonTime",
            "ComputerName"
        )
        $QuserObjs = $Results -split "\n" -replace '\s{2,}', ';' -replace '>', '' | Select-Object -Skip 1 | ConvertFrom-Csv -Delimiter ';' -Header $Header
        Foreach ($Result in $QuserObjs) {
            $IdleTime = if ($Result.IdleTime -eq "none" -or $Result.IdleTime -eq '.') {
                    [timespan]::zero
                } else {
                    switch -regex ($Result.IdleTime) {
                        '^(?<d>\d+)\+(?<h>\d+):(?<m>\d+)$' {
                            # Format: D+H:MM -- e.g., "1+08:15"
                            [TimeSpan]::new([int]$Matches['d'], [int]$Matches['h'], [int]$Matches['m'], 0)
                        }
                        '^(?<h>\d+):(?<m>\d+)$' {
                            # Format: H:MM -- e.g., "8:05"
                            [TimeSpan]::new([int]$Matches['h'], [int]$Matches['m'], 0)
                        }
                        '^\d+$' {
                            # Format: minutes only -- e.g., "5"
                            [TimeSpan]::FromMinutes([int]$Result.IdleTime)
                        }
                    }
                }
            $Result.IdleTime = $IdleTime
            $Result.LogonTime = Get-Date $Result.LogonTime
            $Result.ComputerName = $ComputerName
            $Result.SessionID = [Int]$Result.SessionID
            $Result
        }
    } else {
        foreach ($ResultError in $Results.Exception.Message) {
            if ($ResultError -ne '') {
                Write-Warning $ResultError
            }
        }
    }
}
