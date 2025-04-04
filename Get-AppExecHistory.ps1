function Get-AppExecHistory {
    <#
    .SYNOPSIS
    Queries the registry UserAssist key for records about GUI-Based application executions
    .DESCRIPTION
    UserAssist is a registry key containin records about GUI-Based application executions. It includes last run time, run count, and a path to the item executed.
    This function removes obfuscation and converts as much as possible to human readable data. E.g. rot13, converting SIDs to usernames, converting variables to paths etc.
    .PARAMETER UserSID
    Optional parameter to starget a specific user's SID instead of the default output of all users
    .EXAMPLE
    PS> Get-AppExecHistory
    User           : Contoso\J.Smith
    ExecutionType  : Direct
    ItemName       : C:\Program Files\F5 VPN\f5fpclientW.exe
    RunCount       : 0
    LastRun        :

    User           : Contoso\J.Smith
    ExecutionType  : Direct
    ItemName       : C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe
    RunCount       : 0
    LastRun        :

    User           : Contoso\J.Smith
    ExecutionType  : Direct
    ItemName       : C:\WINDOWS\system32\mspaint.exe
    RunCount       : 2
    LastRun        : 4/12/2024 1:19:41 PM

    # this can go on for quite a while. The objects can be captured in a variable or piped to other cmdlets like Export-Csv
    .NOTES
    Version:        1.0
    Author:         C. Bodett
    Creation Date:  4/4/2024
    Purpose/Change: initial version
    #>
    #Requires -RunAsAdministrator
    [CmdletBinding()]
    param (
        [String]$UserSID
    )

    function Convert-Rot13 {
        <#
        .SYNOPSIS
        Leverages the ROT13 cipher on provided string text.  
        .DESCRIPTION
        ROT13 cipher is a simple substitution cipher that replaces every letter with the 13th letter after it. Any alphabet character will be rotated while any non-alphabet character will be kept the same.
        .PARAMETER String
        The string to apply the ROT13 cipher on. Since the cipher works for encoding and decoding you can pass an encoded string or plaintext string to this parameter. 
        #>
        [CmdletBinding()]
        [OutputType([String])]
        param (
            [Parameter(Mandatory,ValueFromPipeline)]
            [String]$String
        )

        process {
            $CharArray = $String.ToCharArray()

            $RotArray = foreach ($Char in $CharArray) {
                $CharNumber = [Int32]$Char
                $RotNumber = switch -regex ($Char) {
                    '[A-Ma-m]' { 13 }
                    '[N-Zn-z]' { -13 }
                    default { 0 }
                }
                [Char]$RotChar = $CharNumber + $RotNumber
                $RotChar
            }

            $RotArray -join ''
        }
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

    function Get-ExecutionType {
        param ([string]$GuidKey)
        switch ($GuidKey) {
            "{CEBFF5CD-ACE2-4F4F-9178-9926F41749EA}" { "Direct" }
            "{F4E57C4B-2036-45F0-A9AB-443BCFE33D9F}" { "Shortcut" }
            default { "-" }
        }
    }

    function Expand-GUID {
        param(
            [string]$Path
        )

        # https://learn.microsoft.com/en-us/windows/win32/shell/knownfolderid
        $knownFolders = @{
            '{7C5A40EF-A0FB-4BFC-874A-C0F2E0B9FA8E}' = '%SystemDrive%\Program Files'
            '{6365D5A7-0F0D-45E5-87F6-0DA56B6A4F7D}' = '%ProgramFiles%\Common Files'
            '{DE974D24-D9C6-4D3E-BF91-F4455120B917}' = '%ProgramFiles%\Common Files'
            '{DFDF76A2-C82A-4D63-906A-5644AC457385}' = '%SystemDrive%\Users\Public'
            '{C4AA340D-F20F-4863-AFEF-F87EF2E6BA25}' = '%PUBLIC%\Desktop'
            '{ED4824AF-DCE4-45A8-81E2-FC7965083634}' = '%PUBLIC%\Documents'
            '{D65231B0-B2F1-4857-A4CE-A8E7C6EA7D27}' = '%windir%\system32'
            '{0139D44E-6AFE-49F2-8690-3DAFCAE6FFB8}' = '%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs'
            '{9E3995AB-1F9C-4F13-B827-48B24B6C7174}' = '%APPDATA%\Microsoft\Internet Explorer\Quick Launch\User Pinned'
            '{A77F5D77-2E2B-44C3-A6A2-ABA601054A51}' = '%APPDATA%\Microsoft\Windows\Start Menu\Programs'
            '{6D809377-6AF0-444B-8957-A3773F02200E}' = '%SystemDrive%\Program Files'
            '{F38BF404-1D43-42F2-9305-67DE0B28FC23}' = '%windir%'
            '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}' = '%windir%\system32'
        }

        foreach ($guid in $knownFolders.Keys) {
            if ($Path -match $guid) {
                $Path = $Path -replace [regex]::Escape($guid), $knownFolders[$guid]
                break
            }
        }
        return $Path
    }

    function Expand-EnvironmentVariables {
        param(
            [Parameter(Mandatory = $true)][string]$Path,
            [Parameter(Mandatory = $true)][string]$UserProfilePath
        )

        # https://learn.microsoft.com/en-us/windows/win32/shell/knownfolderid
        $variables = @{
            '%SystemRoot%' = [Environment]::GetEnvironmentVariable('SystemRoot')
            '%windir%' = [Environment]::GetEnvironmentVariable('windir')
            '%ProgramFiles%' = [Environment]::GetEnvironmentVariable('ProgramFiles')
            '%ProgramFiles(x86)%' = [Environment]::GetEnvironmentVariable('ProgramFiles(x86)')
            '%SystemDrive%' = [Environment]::GetEnvironmentVariable('SystemDrive')
            '%UserProfile%' = $UserProfilePath
            '%AppData%' = Join-Path -Path $UserProfilePath -ChildPath 'AppData\Roaming'
            '%LocalAppData%' = Join-Path -Path $UserProfilePath -ChildPath 'AppData\Local'
            '%ALLUSERSPROFILE%' = [Environment]::GetEnvironmentVariable('ProgramData')
        }

        foreach ($key in $variables.Keys) {
            if ($Path -like "*$key*") {
                $Path = $Path -replace [regex]::Escape($key), $variables[$key]
            }
        }
        return $Path
    }

    if ($UserSID) {
        $SIDs = $UserSID
        $RegRoot = "Registry::HKU\"
    } else {
        $SIDs = Get-ChildItem -Path "Registry::HKU\" | Where-Object {
            $_.PSChildName -match '^S-1-5-((32-\d*)|(21-\d*-\d*-\d*-\d*))$'
        } | Select-Object -ExpandProperty PSChildName
        $RegRoot = "Registry::HKU\"
    }

    foreach ($SID in $SIDs) {
        $UserAssistPath = Join-Path -Path $RegRoot -ChildPath $($SID + "\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\UserAssist\")
        $GUIDKeys = Get-ChildItem -Path $UserAssistPath
        $UserName = Get-UsernameFromSID -SID $SID
        $UserProfilePath = (Get-CimInstance -Class Win32_UserProfile | Where-Object {$_.SID -eq $SID}).LocalPath
        foreach ($GUIDKey in $GUIDKeys) {
            $GUIDName = Split-Path -Leaf $GUIDKey.Name
            $CountPath = Join-Path -Path $GUIDKey.PSPath -ChildPath "Count"
            if (Test-Path $CountPath) {
                $Entries = Get-ItemProperty -Path $CountPath
                foreach ($Entry in $Entries.PSObject.Properties) {
                    if ($Entry.Name -notmatch '^PS') {
                        $DecodedName = Convert-Rot13 -String $Entry.Name

                        if ($Entry.Value -is [Byte[]]) {
                            $FileTime = switch ($Entry.Value.Count) {
                                        8 { $null }
                                        16 { [BitConverter]::ToInt64($Entry.Value, 8) }
                                        default { [BitConverter]::ToInt64($Entry.Value, 60) }
                                    }
                            if ($FileTime -gt 0) {
                                $LastRun = [DateTime]::FromFileTime($FileTime)
                            } else {
                                $LastRun = $null
                            }
                            $RunCount = [BitConverter]::ToInt32($Entry.Value, 4)
                        }
                    }
                    $ResolvedGUID = Expand-GUID -Path $DecodedName
                    $FinalPath = Expand-EnvironmentVariables -Path $ResolvedGUID -UserProfilePath $UserProfilePath


                    [PSCustomObject]@{
                        User = $UserName
                        ExecutionType = Get-ExecutionType -GuidKey $GUIDName
                        ItemName = $FinalPath
                        RunCount = $RunCount
                        LastRun = $LastRun
                    }
                }
            }
        }
    }
}