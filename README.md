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

