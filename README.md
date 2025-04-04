# Powershell-General
A collection of general purpose Powershell code with no particular theme.

## ConvertTo/From-Base64  
Simple functions for converting Base64 back and forth

## ConvertTo-SarcasmFont
This is a silly function I wrote in the middle of an awful meeting to make a coworker laugh.

```Powershell
PS> ConvertTo-SarcasmFont "I'm really interested in what you have to say"
```
Now it's on your clipboard, paste and enjoy
```
i'm rEaLlY InTeReStEd iN WhAt yOu hAvE To sAy
```
Or pass the "-output" parameter to have it output to the console instead of going to the clipboard.

## Get-AppExecHistory  
Retrieves entries from the UserAssist registry key containing information about GUI-Based application executions.  
```Powershell
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
```
  
## Get-ExplorerHistory  
Function to parse the WordWheelQuery registry key for entries related to searches performed in Explorer.  
```Powershell
PS> Get-ExplorerHistory
    User              Order Name SearchTerm
    ----              ----- ---- ----------
    Contoso\J.Smith     0    0   password vault
    Contoso\J.Smith     1   88   waffles
    Contoso\J.Smith     2   87   bodettc
    Contoso\J.Smith     3   86   uninstall
    Contoso\J.Smith     4   48   treesize
    Contoso\J.Smith     5   57   password
```  
  
## Show-SecureString
A quick function to convert a SecureString object in to plaintext
```Powershell
PS> $securestring = Read-Host -Prompt "type some text" -AsSecureString
PS> Show-SecureString $securestring
secrettext
```
## Get-Connection
Shows a table of all active connections, the owning process, and running user
```Powershell
    PS> Get-Connection
    
    LocalAddress  LocalPort RemoteAddress   RemotePort       State Process                        User
    ------------  --------- -------------   ----------       ----- -------                        ----
    0.0.0.0           49665 0.0.0.0                  0      Listen wininit
    0.0.0.0           49666 0.0.0.0                  0      Listen svchost                        NT AUTHORITY\SYSTEM
    0.0.0.0           49667 0.0.0.0                  0      Listen svchost                        NT AUTHORITY\LOCAL
    ...

    PS> Get-Connection -LocalPort 9395

    LocalAddress LocalPort RemoteAddress RemotePort       State Process                User
    ------------ --------- ------------- ----------       ----- -------                ----
    0.0.0.0           9395 0.0.0.0                0      Listen Veeam.EndPoint.Service NT AUTHORITY\SYSTEM
    127.0.0.1         9395 127.0.0.1          49719 Established Veeam.EndPoint.Service NT AUTHORITY\SYSTEM
```  
accompanying GetConnection.ps1xml file can be used to maintain the output formatting seen above.  
```Powershell
PS> Update-FormatData 'C:\Path\To\GetConnection.ps1xml'

```
  
## Get-LockEvent  
Retrieve logs from Windows Events pertaining to computer lock and unlock.  Accompanying LockEvent.ps1xml file can be used to pretty up the PSObject output.  

## Get-PatchTuesday  
a simple function to return a datetime object representing Microsoft's Patch Tuesday.  If ran with no arguments it will return the current month's Patch Tuesday date.  The -Month parameter excepts month names and will return a Patch Tuesday date for that month.  
Beyond specifically returning Patch Tuesday dates you can also request a date time object for other things like the 2nd Wednesday of a given month.  
```Powershell
# assuming it's currently April 2025 at 12:51pm
PS> Get-PatchTuesday

Tuesday, April 8, 2025 12:51:05 PM
PS> Get-PatchTuesday -Month May

Tuesday, May 13, 2025 12:51:28 PM
PS> Get-PatchTuesday -Month May -WeekDay Wednesday -FindNthDay 2

Wednesday, May 14, 2025 12:52:24 PM
```  
  
## Get-RunDialogHistory  
Another function for parsing the registry. This inspects users RunMRU registry key an returns a list of in-order execution history.
```Powershell
PS> Get-RunDialogHistory  

User        Order Name Execution
----        ----- ---- ---------
Contoso\J.Smith     0    a runas /user:dev\J.Smith mmc.exe\1
Contoso\J.Smith     1    v services.msc\1
Contoso\J.Smith     2    u ms-settings:privacy-location\1
Contoso\J.Smith     3    t runas /netonly /user:J.Smith@dev.res mmc\1
Contoso\J.Smith     4    f mmc\1
```
## Get-ComputerUpTime  
Only tested in one Active Directory environment and a personal machine.  Function returns the current, or remote, computer's uptime as well as some other information.  
  
```Powershell  
PS> Get-ComputerUpTime  
  
Computer    : Win10-05ERJJ4
Windows     : Microsoft Windows 10 Pro
Version     : 10.0.19044
LastBoot    : 6/30/2022 2:11:13 PM
Uptime      : 00D:04H:56M:20S
InstallDate : 3/6/2021 8:00:56 PM  
```  
  
## Invoke-Quser  
A Powershell wrapper for quser to provide object output.  
  
```Powershell
PS> Invoke-Quser  
  
ComputerName : Localhost
Username     : John Doe
SessionID    : 1
SessionName  : console
State        : Active
IdleTime     : none
LogonTime    : 7/7/2022 9:03:00 AM  
  
PS> Invoke-Quser -ComputerName ContosoPC1  
  
ComputerName : ContosoPC1
Username     : CerealKiller
SessionID    : 2
SessionName  : rdp-tcp#90
State        : Active
IdleTime     : none
LogonTime    : 7/6/2022 9:03:00 PM  
  
```  
## Get-GeoLocation  
A function wrapper for the .NET GeoCoordinateWatcher class.  Returns GPS coordinates derived from the Location Services of the computer.  
Remote computer inspection leverages Invoke-Command and requires WinRM to be working. 
```Powershell
PS> Get-GeoLocation 
  
Computer Location               NetAdapter
-------- --------               ----------
Gibson   37.232885, -115.806122 Ethernet 2 
  
PS> Get-GeoLocation  -ComputerName ContosoPC1  
  
Computer   Location               NetAdapter
--------   --------               ----------
ContosoPC1 38.871138, -77.057071  Wi-Fi
  
```  
## Start-Explorer  
A function for launching Windows Explorer from the current location or a specified location.  
  
## Test-PSPass  
function tests a PSCredential object against an Active Directory domain to see if it's valid. Returns true/false.  
  
## Test-Password  
function for testing a provided password against the HaveIBeenPwned API to test for credential leakage.
  
## Test-Port  
a simple wrapper for Test-NetConnection to simplify use and output
  
## Test-HostsFile  
function for testing a Windows' Hosts file to see if it's been altered from its default state.  

## Get-ASRRules.ps1  
script for returning a human readable version of the machine's current Defender ASR rule state

