Function Start-SleepUntil {
    <#
    .Synopsis
    Allows you to "Start-Sleep" until a given time
    .Description
    A simple manipulation of start-sleep to allow sleeping until a given time. 
    .Parameter Time
    The only parameter required is the time you would like to sleep the process until. Accepts pipeline input. Can be any "datetime" format. i.e. 11:00am, 16:00, 2:00am 3/7/2020 etc
    .Example
    Sleep-Until 14:00
    Sleep-Until 2:00pm
    Sleep-Until 8:00pm; Shutdown /a
    Sleep-Until 4:00pm; copy-item c:\temp\scriptyscipt.ps1 c:\scripts\script.ps1;Sleep-Until 4:15pm;& c:\scripts\script.ps1
    .NOTES
    Version:    1.0
    Author:     C. Bodett
    Creation Date: 3/6/2020
    #>
        Param(
        [Parameter(Mandatory=$true,Position=0,HelpMessage="Enter a time/date in just about any format. Pass -verbose to confirm how long it's sleeping")]
        [Alias('EndTime','Stop')]
        [datetime]$Time    
        )
    
    $CurrentTime = get-date
    $Duration = ($Time - $CurrentTime).TotalSeconds
    Write-Verbose "Sleeping until $($Time.toshorttimestring()) $($Time.ToShortDateString())"
    Write-Verbose "$($Duration.ToString().Split('.')[0]) total seconds"
    $Duration | Start-Sleep
    } 