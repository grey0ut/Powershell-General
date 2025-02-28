Function Get-GeoLocation {
    <#
    .Synopsis
    Returns GPS coordinates returned from the .NET GeoCoordinateWatcher
    .Description
    Microsoft's Location Services will attempt to determine an accurate location of the device based on available sensors. Worst case scenario is a geo-ip lookup on the apparent public IP.
    .Parameter ComputerName
    A remote computer you wish to execute the function against. The WinRM service must be running.
    .Example
    PS> Get-GeoLocation
    37.232885, -115.806122

    All the function returns are GPS coordinates that can be pasted in to a map
    .Example
    PS> Get-GeoLocation -Verbose
    VERBOSE: Local machine allows for location services
    VERBOSE: Starting GeoCoordinateWatcher    
    VERBOSE: [0] Waiting 2 seconds for results
    VERBOSE: [1] Waiting 2 seconds for results
    VERBOSE: [2] Waiting 2 seconds for results
    VERBOSE: [3] Waiting 2 seconds for results
    37.232885, -115.806122
    .Example
    PS> Get-GeoLocation -ComputerName PC_2044
    37.232885, -115.806122

    Same thing as executing locally. Returns GPS coordinates. 
    .NOTES
    Author: C. Bodett
    Date: 10/20/2022
    Version: 1.0
    #>
    [Cmdletbinding()]
    Param (
        [Parameter(Mandatory = $false, Position = 0)]
        [String]$ComputerName
    )

    Begin {
        $GeoCode = {
            [cmdletbinding()]
            Param(
                $VerbosePreference
            )
            $IsAdmin = (Get-LocalGroupMember -Group "Administrators").SID.Value -contains ([Security.Principal.WindowsIdentity]::GetCurrent().User.Value)
            $RegPath = "Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location\"
            $CompValue = Get-ItemProperty ("HKLM:\" + $RegPath) -Name "Value" | Select-Object -ExpandProperty Value

            if ($CompValue -ne "Allow" -and $IsAdmin) {
                Write-Verbose "Admin rights present. Editing registry to allow location services"
                Set-ItemProperty ("HKLM:\" + $RegPath) -Name "Value" -Value "Allow"
                $ChangedHKLM = $true
                $Continue = $true
            } elseif ($CompValue -eq "Allow") {
                Write-Verbose "Local machine allows for location services"
                $Continue = $true
            } else {
                Write-Verbose "No admin rights and location services denied at machine level"
                $Location = "Permission"
                $Continue = $false
            }

            if ($Continue) {
                $UserValue = Get-ItemProperty ("HKCU:\" + $RegPath) -Name "Value" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Value
                if ($UserValue -eq "Deny") {
                    Write-Verbose "User config: location services denied"
                    Write-Verbose "Updating registry for current user to allow location services"
                    Set-ItemProperty ("HKCU:\" + $RegPath) -Name "Value" -Value "Allow"
                }
                Add-Type -AssemblyName System.Device
                $GeoWatcher = New-Object System.Device.Location.GeoCoordinateWatcher(1)
                Write-Verbose "Starting GeoCoordinateWatcher"
                $GeoWatcher.Start()
                $C = 0
                while (($GeoWatcher.Status -ne 'Ready') -and ($Geowatcher.Permission -ne 'Denied') -and ($C -le 15)) {
                    Write-Verbose "[$C] Waiting 2 seconds for results"
                    Start-Sleep -Seconds 2
                    $C++
                }
                # need to wait a little longer to allow for more accurate data. 
                Start-Sleep -Seconds 2
                $Location = ($GeoWatcher.Position.Location).ToString()
                $GeoWatcher.Dispose()
                if ($UserValue -eq "Deny") {
                    Write-Verbose "Updating registry for current user to revert changes"
                    Set-ItemProperty ("HKCU:\" + $RegPath) -Name "Value" -Value "Deny"
                }
            }
            if ($ChangedHKLM) {
                Write-Verbose "Updating registry for local machine to revert changes"
                Set-ItemProperty ("HKLM:\" + $RegPath) -Name "Value" -Value "Deny"
            }
            [PSCustomObject]@{
                Computer = $Env:COMPUTERNAME
                Location = $Location
                NetAdapter = (Get-NetAdapter -Physical | Where-Object {$_.Status -eq "Up"} | Select-Object -ExpandProperty Name) -Join ','
            }
        }
    }

    Process {
        if ($ComputerName) {
            Invoke-Command -ComputerName $ComputerName -ScriptBlock $GeoCode -ArgumentList $VerbosePreference | Select-Object -Property Computer,Location,NetAdapter
        } else {
            Invoke-Command -ScriptBlock $GeoCode
        }
    }
}

