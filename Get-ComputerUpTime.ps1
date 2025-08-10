function Get-ComputerUpTime {
    <#
    .Synopsis
    Returns the computer's uptime, lastboot datestamp and install datestamp
    .Description
    Using CimInstance this function retrieves the Windows version, computer name, last bootup time and install date and calculates the uptime
    .Parameter ComputerName
    Can specify a remote computer to run the function against
    .Parameter Credential
    Can pass a PSCredential object to allow for authenticating as a different user against a target ComputerName
    .EXAMPLE
    PS> Get-ComputerUpTime

    Computer    : ContosoPC01
    Windows     : Microsoft Windows 10 Enterprise
    Version     : 10.0.19042
    LastBoot    : 6/30/2022 7:22:15 AM
    Uptime      : 00D:03H:51M:56S
    InstallDate : 4/15/2022 2:33:21 PM

    Running the function will return information about the current PC

    .EXAMPLE
    PS> Get-ComputerUpTime -ComputerName "ContosoPC02"

    Computer    : ContosoPC02
    Windows     : Microsoft Windows 10 Enterprise
    Version     : 10.0.18363
    LastBoot    : 6/29/2022 11:10:54 PM
    Uptime      : 00D:12H:02M:31S
    InstallDate : 9/24/2021 5:16:29 PM

    Specifying a computer name will run the function against a remote computer.  

    .NOTES
    Version:        1.2
    Author:         C. Bodett
    Creation Date:  9/26/2022
    Purpose/Change: Added in support for if the WinRM service isn't running on a remote computer
    #>
    [Cmdletbinding(DefaultParameterSetName="none")]
    param (
        [Parameter(ParameterSetName="Remote",Mandatory=$true,ValueFromPipeline=$true,Position=0)]
        [String]$ComputerName,
        [Parameter(ParameterSetName="Remote",Mandatory=$false,Position=1)]
        [pscredential]$Credential
    )

    begin {
        $CimInstanceArgs = @{
            ClassName = "Win32_OperatingSystem"
            Property = @("InstallDate","LastBootupTime","Caption","Version","CSName")
        }
        $CimSessionOption = New-CimSessionOption -Protocol Dcom
    }

    process {
        $CimSessionArgs = @{
            SessionOption = $CimSessionOption
        }
        Write-Verbose "Protocol dcom"
        Write-Verbose $ComputerName

        if ($ComputerName -and ($ComputerName.ToLower() -ne ([Net.Dns]::GetHostName()).ToLower())) {
            $CimSessionArgs.Add('ComputerName',$ComputerName)
        }

        if ($Credential) {
            [Void]$CimSessionArgs.Add('Credential',$Credential)
        }
        try {
            if ($c -eq 2) {
                Write-Verbose "trying to connect to $ComputerName via CIM one last time."
            }
            $CimSession = New-CimSession @CimSessionArgs -ErrorAction Stop
            $OSInfo = Get-CimInstance @CimInstanceArgs -CimSession $CimSession -ErrorAction Stop
            [PSCustomObject]@{
                Computer = $OSInfo.CSName
                Windows = $OSInfo.Caption
                Version = $OSInfo.Version
                LastBoot = $OSInfo.LastBootUpTime
                Uptime = '{0:dd}D:{0:hh}H:{0:mm}M:{0:ss}S' -f $((Get-Date) - $OSinfo.LastBootUpTime)
                InstallDate = $OSInfo.InstallDate
            }
        } catch [Microsoft.Management.Infrastructure.CimException] {
            Write-Warning "WinRM not reachable on $ComputerName"
        } catch {
            Write-Error $_
        }

        try {
            Remove-CimSession -CimSession $CimSession -ErrorAction Stop
        } catch {
            # suppress error output
        }
    }
}
