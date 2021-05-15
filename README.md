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

