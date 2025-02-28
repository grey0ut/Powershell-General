function Test-Password {
    <#
    .Synopsis
    Tests a SecureString of a password against the HaveIBeenPwned database
    .Description
    This function takes a SecureString, hashes it, then sends part of that hash to HIBP, returning all matches. Then it looks for the remainder of the original hash in the returned results. It outputs a number of how many breaches the password has been in. 0 means it was not found.
    .Parameter Password
    The Password paramter. Object needs to be a SecureString
    .NOTES
    Version:        1.0
    Author:         Dr. Tobias Weltner
    Source:         https://powershell.one/code/3.html
    Purpose/Change: Modified by Courtney Bodett
    Version:        1.2
    Author:         C. Bodett
    Creation Date:  1/29/2024
    Purpose/Change: Removed WriteLog integration
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=0)]
        [System.Security.SecureString]
        $Password
    )
      
    # take securestring and get the entered plain text password
    # we are using a securestring only to get a masked input box:
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
    $plain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
      
    # hash the password:
    $bytes = [Text.Encoding]::UTF8.GetBytes($plain)
    $stream = [IO.MemoryStream]::new($bytes)
    $hash = Get-FileHash -Algorithm 'SHA1' -InputStream $stream
    $stream.Close()
    $stream.Dispose()

    # separate the first 5 hash characters from the rest:
    $first5hashChars,$remainingHashChars = $hash.Hash -split '(?<=^.{5})'

    # send the first 5 hash characters to the webservice:
    $url = "https://api.pwnedpasswords.com/range/$first5hashChars"
    [Net.ServicePointManager]::SecurityProtocol = 'Tls12'
    $response = Invoke-RestMethod -Uri $url -UseBasicParsing

    # split result into individual lines...
    $lines = $response -split '\r\n'
    # ...and get the line where the returned hash matches your
    # remainder of the hash that you kept private:
    $filteredLines = $lines -like "$remainingHashChars*"
    if ($filteredLines){
      Write-Warning "Compromised!"
      Write-Output "Password has been seen in $([int]($filteredLines -split ':')[-1]) breaches"
    } else {
      Write-Output "No compromises found"
    }
}
