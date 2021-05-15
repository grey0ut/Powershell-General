Function Start-Countdown {
    param(
    [parameter(mandatory=$true,HelpMessage="Enter number of seconds to countdown from")]
    [int]$sec
    )

$numbers = 1..$sec
$array = @()
$numbers | % {if ($_ -le "9") {
    $result = "0"+$_
    $array += $result
    }
    else {
    $array += $_
    }}
[array]::reverse($array)

$array | % {
    If ($_ -le "03") {
        write-host "`r$_" -nonewline -ForegroundColor Red; start-sleep -s 1
    } Else {
            write-host "`r$_     " -nonewline -ForegroundColor Yellow; start-sleep -s 1
        }
    }
write-host "`r00" -NoNewline -ForegroundColor Red -BackgroundColor DarkYellow
} 