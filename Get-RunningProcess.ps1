<#
.Synopsis
Script for inspecting a host, or hosts, for a given process
.Description
Uses the RemoteRegistry service to check for processes running on a host by a given name
.Parameter Process
the -process parameter is required and defines what process to search for
.Parameter Computer
the -computer defaults to localhost but can also refer to a remote host

#>

[cmdletbinding()]
param(
    [parameter(
        Position=0,
        Mandatory=$true,
        ValuefromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)
    ]
    [string[]]$computer='localhost',
    [parameter(
        Mandatory=$true)]
    [string[]]$process
    )

$results = @()
$RE1 = '^((\d{1,3}\.){3}\d{1,3})'

foreach ($pc in $computer) { #beginning of work
    if (Test-Connection -count 1 -computername $pc -Quiet) {
        $wasdisabled = @()
        $service = get-service -name RemoteRegistry -ComputerName $pc
        $state = Get-WMIObject win32_service -filter "name='RemoteRegistry'" -computer $pc -Property * | select -expand startMode
        # If RemoteRegistry is "Running", move on.
        if ($service.Status -ne "stopped" ) {
            #do nothing
            }
        # if RemoteRegistry is "stopped", start RemoteRegistry
            else {
        # record the startup state of the service so we can put it back later if need be
                if ($state -eq "disabled") {
                    Set-Service $service.name -computername $pc -StartupType "manual"
                    $wasdisabled = "true"
                    }
                    else {
                    $wasdisabled = "false"
                    }
                (Get-WmiObject -computer $pc Win32_service -filter "Name='RemoteRegistry'").invokemethod("StartService",$null) | Out-Null
            }

        # let's start the actual inspection
        $p = (Get-Process -ComputerName $pc -name $process -ErrorAction 'silentlycontinue').count
            if ($pc -match $RE1) {
            $ipv4 = $pc
            $hostname = (Resolve-DnsName $pc).namehost.split('.')[0]
            }
            else {
            $hostname = $pc
            $ipv4 = (test-connection -computername $pc -count 1).IPV4Address.ipaddresstostring
            }
        $hostinfo = New-Object PSObject -Property @{
            "IP" = $ipv4
            "Hostname" = $hostname
            "Count of $process" = $p
            "User" = (get-wmiobject -computer $pc -class win32_computersystem).username.split("\")[1]
            }
            $results += $hostinfo
            if ($wasdisabled -eq "true") {
                Set-Service $service.name -computername $pc -StartupType "Disabled"
                }
    }
    else {
        Write-Host "$pc is down. skipping"
        }


} #end of work

$results | select IP,Hostname,"Count of $process",User