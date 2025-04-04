function Get-RunDialogHistory {
    <#
    .SYNOPSIS
    retrieves the history of commands executed in the Run dialog
    .DESCRIPTION
    The RunMRU key in the registry for each user contains a list of all executions performed in the Run dialog. This function retrieves them and returns them in order of recent to oldest as PowerShell objects
    .PARAMETER UserSID
    The specific user SID to query
    #>
    [CmdletBinding()]
    param (
        [string]$UserSID
    )

    if ($UserSID) {
        $SIDs = $UserSID
        $RegRoot = "Registry::HKU\"
    } else {
        $SIDs = Get-ChildItem -Path "Registry::HKU\" | Where-Object {
            $_.PSChildName -match '^S-1-5-((32-\d*)|(21-\d*-\d*-\d*-\d*))$'
        } | Select-Object -ExpandProperty PSChildName
        $RegRoot = "Registry::HKU\"
    }

    function Get-UsernameFromSID {
        <#
        .SYNOPSIS
        Convert a provided SID to a username
        #>
        [CmdletBinding()]
        param (
            [Parameter(Mandatory,ValueFromPipeline)]
            [string[]]$SID
        )

        process {
            foreach ($ID in $SID) {
                try {
                    $SIDObj = [System.Security.Principal.SecurityIdentifier]::new($ID)
                    $NTAccount = $SIDObj.Translate([System.Security.Principal.NTAccount])
                    $NTAccount.Value
                } catch {
                    switch ($ID) {
                        "S-1-5-18" {  "SYSTEM" }
                        "S-1-5-19" {  "LOCAL SERVICE" }
                        "S-1-5-20" {  "NETWORK SERVICE" }
                        default { Write-Warning "Identity references could not be translated: $ID" }
                    }
                }
            }
        }
    }
    
    foreach ($SID in $SIDs) {
        $UserName = Get-UsernameFromSID -SID $SID
        $RunMRUPath = Join-Path -Path $RegRoot -ChildPath $($SID + "\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\RunMRU")
        if (Test-Path $RunMRUPath) {
            $Reg = Get-ItemProperty -Path $RunMRUPath
            $MruOrder = $Reg.MRUList.ToCharArray()
            $Order = 0
            foreach ($Entry in $MruOrder) {
                $Data = $Reg.$Entry
                [PSCustomObject]@{
                    User = $UserName
                    Order = $Order
                    Name = $Entry
                    Execution = $Data
                }
                $Order++
            }
        } else {
            Write-Warning "No Explorer History for $UserName"
        }
    }
}