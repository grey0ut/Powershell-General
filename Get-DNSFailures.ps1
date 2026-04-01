function Get-DNSFailures {
    <#
    .SYNOPSIS
    Pull DNS time out records from Event Viewer
    .DESCRIPTION
    Easier to remember wrapper for Get-WinEvent and a filterhashtable for getting event ID 1014 out of System log.
    .PARAMETER ComputerName
    Can specify a remote computer to pull logs from
    .PARAMETER OutputType
    By default EventLogRecord objects are returned from Get-WinEvent.  You can specify PSObject for output type and the event records will be converted to XML, and then turned in
    to Powershell objects from there for easier reading/exporting/filtering.
    .PARAMETER TimeFrame
    By default it will filter for events occuring today. You can specify "All", "Today" or "LastHour" and Get-WinEvent will filter accordingly.
    .NOTES
        Version:    1.3
        Author:     C. Bodett
        Creation Date: 3/26/2026
        Purpose/Change: fixed issue with datetime output on psobject
    #>
    [cmdletbinding()]
    param (
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
                LogName = "System"
                ProviderName = "Microsoft-Windows-DNS-Client"
                Id      = 1014
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
                foreach ($EventLog in $Events) {
                    $Xml = [xml]$EventLog.ToXml()
                    $DataTable = @{}

                    foreach ($Data in $Xml.Event.EventData.Data) {
                        $DataTable[$Data.Name] = $Data.'#text'
                    }
                    $EventLogProperties = [PSCustomObject]$DataTable

                    [PSCustomObject]@{
                        DateTime    = Get-Date $EventLog.TimeCreated -Format 'MM/dd/yy HH:mm:ss'
                        QueryName   = $EventLogProperties.QueryName
                        ClientPID   = $EventLogProperties.ClientPID
                    }
                }
            }
        }
    } catch {
        Write-Warning $_
    }
}