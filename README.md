# Powershell-General
A collection of general purpose Powershell code with no particular theme.

# Show-SecureString
A quick function to convert a SecureString object in to plaintext
```Powershell
    PS$> $securestring = Read-Host -Prompt "type some text" -AsSecureString
    PS$> Show-SecureString $securestring
    secrettext
```
# Get-Connections
Shows a table of all active connections, the owning process, and running user
```Powershell
    PS$> Get-Connections
    
    LocalAddress  LocalPort RemoteAddress   RemotePort       State Process                        User
    ------------  --------- -------------   ----------       ----- -------                        ----
    0.0.0.0           49665 0.0.0.0                  0      Listen wininit
    0.0.0.0           49666 0.0.0.0                  0      Listen svchost                        NT AUTHORITY\SYSTEM
    0.0.0.0           49667 0.0.0.0                  0      Listen svchost                        NT AUTHORITY\LOCAL
    ...

    PS$> Get-Connections -LocalPort 9395

    LocalAddress LocalPort RemoteAddress RemotePort       State Process                User
    ------------ --------- ------------- ----------       ----- -------                ----
    0.0.0.0           9395 0.0.0.0                0      Listen Veeam.EndPoint.Service NT AUTHORITY\SYSTEM
    127.0.0.1         9395 127.0.0.1          49719 Established Veeam.EndPoint.Service NT AUTHORITY\SYSTEM
```
# Start-SleepUntil
A simple modification of the Start-Sleep cmdlet to allow sleeping an action until a desired time. AKA without having to do math.

```Powershell
PS$> Sleep-Until 8:00pm; Shutdown /a
```

# ConvertTo-SarcasmFont
This is a silly function I wrote in the middle of an awful meeting to make a coworker laugh.

```Powershell
PS$> ConvertTo-SarcasmFont "I'm really interested in what you have to say"
```
Now it's on your clipboard, paste and enjoy
```
i'm rEaLlY InTeReStEd iN WhAt yOu hAvE To sAy
```
Or pass the "-output" parameter to have it output to the console instead of going to the clipboard.

# Start-Countdown
A silly little function that counts down seconds on the console with a little color for flair. Add it in to a script loop that you want to stall for a bit and it gives you something to look at.

# Convert To/From Garbage Functions
This started off as an exercise to see how easy it would be to obfuscate a bunch of text, possibly code, to bypass detection from host based antivirus.  I was playing around with just converting text in to its Unicode character number representation and then deliminating it with random text and that worked pretty well. Then I thought it might be a little too obvious looking that the numbers represented Unicode characters so I decided to multiply each one by a high prime digit.  
All said and done I'm not sure if this is considered encoding or encryption, but suffice to say without having these functions available (to see the prime number) it would likely take a very long time to reverse this.

## ConvertTo-Garbage
You can either type a string you want to convert, or you can pipe something to this function.
```
PS$> ConvertTo-Garbage "hack the planet"
819208fc764069$q:'779823PD!<>E842839HRleb<jz252064xrJo913732bPx819208H795577X/QE252064l>J$sk882224=;"GNL850716RHGKb;tmN764069HRleb<jz866470G/LTY+X795577fc913732i$jI)!

PS$> $ENV:Username | ConvertTo-Garbage
527759%E&@P;w874347#SyT$>V:*921609?K897978/MXKsZ#h913732Ond866470tv;YM795577?K953117mp:j252064t!UQ519882'AzQy+*874347BMj!787700TIm"795577wop"j(uMb913732lzfIY=913732'AzQy+*
```
## ConvertFrom-Garbage
The companion function to the ConvertTo-Garbage function that reverses the process to turn "garbage" back in to a human readable string.

```
PS$> $text = @'
819208fc764069$q:'779823PD!<>E842839HRleb<jz252064xrJo913732bPx819208H795577X/QE252064l>J$sk882224=;"GNL850716RHGKb;tmN764069HRleb<jz866470G/LTY+X795577fc913732i$jI)!
'@
PS$> ConvertFrom-Garbage $text
hack the planet


PS$> $text = @'
527759%E&@P;w874347#SyT$>V:*921609?K897978/MXKsZ#h913732Ond866470tv;YM795577?K953117mp:j252064t!UQ519882'AzQy+*874347BMj!787700TIm"795577wop"j(uMb913732lzfIY=913732'AzQy+*
'@
PS$> ConvertFrom-Garbage $text
Courtney Bodett
```
The use of "here-strings" (@'  '@) is required on the "garbage" as it employs special characters that Powershell will try to interpret instead of taking it as a string value.

I'm often using these functions when storing sensitive data in property values, sometimes even before exporting to CSV. This means I'm usually able to call the garbage text by its property name like
```Powershell
PS$> $CSV = Import-Csv c:\temp\data.csv
PS$> $CSV[0].Password | ConvertFrom-Garbage
Super Secret Password
```
These are fairly hacky functions and I know there's more error handling that could be put in.  Take them at face value.  
  
# Get-ComputerUpTime  
Only tested in one Active Directory environment and a personal machine.  Function returns the current, or remote, computer's uptime as well as some other information.  
  
```  
PS$> Get-ComputerUpTime  
  
Computer    : Win10-05ERJJ4
Windows     : Microsoft Windows 10 Pro
Version     : 10.0.19044
LastBoot    : 6/30/2022 2:11:13 PM
Uptime      : 00D:04H:56M:20S
InstallDate : 3/6/2021 8:00:56 PM  
```  
