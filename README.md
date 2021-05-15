# Powershell-General
A collection of general purpose Powershell code with no particular theme.

# Show-SecureString
A quick function to convert a SecureString object in to plaintext
```Powershell
    PS$> $securestring = Read-Host -Prompt "type some text" -AsSecureString
    PS$> Show-SecureString $securestring
    secrettext
```

