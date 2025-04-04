function Get-ExplorerHistory {
    <#
    .SYNOPSIS
    Retrieves and translates the contents of the WordWheelQuery registry key
    .DESCRIPTION
    Requires admin priveleges.  Will use the HKUsers registry hive to retrieve WordWheelQuery history for either the provided SID, or all user SIDs found.
    .PARAMETER UserSID
    The specific user SID to query
    .EXAMPLE
    PS> Get-ExplorerHistory
    User              Order Name SearchTerm
    ----              ----- ---- ----------
    Contoso\J.Smith     0    0   password vault
    Contoso\J.Smith     1   88   waffles
    Contoso\J.Smith     2   87   bodettc
    Contoso\J.Smith     3   86   uninstall
    Contoso\J.Smith     4   48   treesize
    Contoso\J.Smith     5   57   password

    returns objects representing the username for the history, the order of occurence (0 being most recent) the original "Name" of the entry in the registry and the search term
    .NOTES
    Version:        1.0
    Author:         C. Bodett
    Creation Date:  4/4/2025
    Purpose/Change: initial version
    #>
    #Requires -RunAsAdministrator
    [CmdletBinding()]
    param (
        [String]$UserSID
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
        $WordWheelPath = Join-Path -Path $RegRoot -ChildPath $($SID + "\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\WordWheelQuery")
        if (Test-Path $WordWheelPath) {
            $Reg = Get-ItemProperty -Path $WordWheelPath
            $i = 0
            $MruOrder = while ($i -le $Reg.MRUListEx.Count) {
                $Reg.MRUListEx[$i]
                $i += 4
            }
            $FinalOrder = $MruOrder | Select-Object -First $($MruOrder.Count - 2)
            $Order = 0
            foreach ($Entry in $FinalOrder) {
                $Data = $Reg.$Entry
                $String = [System.Text.Encoding]::Unicode.GetString($Data)
                [PSCustomObject]@{
                    User = $UserName
                    Order = $Order
                    Name = $Entry
                    SearchTerm = $String
                }
                $Order++
            }
        } else {
            Write-Warning "No Explorer History for $UserName"
        }
    }
}