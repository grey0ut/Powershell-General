function Get-LockEvent {
    <#
    .SYNOPSIS
    Retrieve logs from Windows Events pertaining to computer lock and unlock.
    .DESCRIPTION
    Easier to remember wrapper for Get-WinEvent and a filterhashtable for getting event ID 4800 and 4801 from the Windows Security log.
    .PARAMETER ComputerName
    Can specify a remote computer to pull logs from
    .PARAMETER OutputType
    By default EventLogRecord objects are returned from Get-WinEvent.  You can specify PSObject for output type and the event records will be converted to XML, and then turned in
    to Powershell objects from there for easier reading/exporting/filtering.
    .PARAMETER TimeFrame
    By default it will filter for events occuring today. You can specify "All", "Today" or "LastHour" and Get-WinEvent will filter accordingly. 
    .NOTES
        Version:    1.0
        Author:     C. Bodett
        Creation Date: 11/21/2024
        Purpose/Change: Initial function development
    #>
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory=$false,Position=0)]
        [String]$ComputerName,
        [Parameter(Mandatory=$false,Position=1)]
        [ValidateSet("Default","PSObject")]
        [String]$OutputType = "Default",
        [Parameter(Mandatory=$false,Position=2)]
        [ValidateSet("All","Today","LastHour")]
        [String]$TimeFrame = "Today"
    )

    $StartTime = switch ($TimeFrame) {
        "Today" { Get-Date $((Get-Date).ToShortDateString()) }
        "All"   { $false }
        "LastHour" { (Get-Date).AddHours(-1) }
    }

    $EventHT = @{
        FilterHashTable = @{
                LogName = "Security"
                Id      = 4800,4801
        }
        ErrorAction     = "Stop"
    }

    if ($StartTime) {
        $EventHT.FilterHashTable.Add("StartTime",$StartTime)
    }

    if ($ComputerName) {
        $EventHT.Add("ComputerName",$ComputerName)
    }

    try {
        switch ($OutputType) {
            "Default" {
                Get-WinEvent @EventHT
            }
            "PSObject" {
                $Events = Get-WinEvent @EventHT
                Foreach ($Event in $Events) {
                    $XmlEvent = [xml]$Event.ToXml()
                    $EventType = switch ($XmlEvent.Event.System.EventID) {
                        "4800" {"Locked"}
                        "4801" {"Unlocked"}
                    }
                    [PSCustomObject]@{
                        PSTypeName       = "LockEvent"
                        DateTime         = Get-Date $XmlEvent.event.System.timecreated.systemtime -Format 'MM/dd/yy HH:mm:ss'
                        EventID          = $XmlEvent.Event.System.EventID
                        EventType        = $EventType
                        TargetUserSID    = $XmlEvent.Event.EventData.Data.'#text'[0]
                        TargetUserName   = $XmlEvent.Event.EventData.Data.'#text'[1]
                        TargetDomainName = $XmlEvent.Event.EventData.Data.'#text'[2]
                        SessionId        = $XmlEvent.Event.EventData.Data.'#text'[4]
                    }
                }
            }
        } 
    } catch {
        Write-Warning $_
    }
}
