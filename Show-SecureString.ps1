Function Show-SecureString {
    <#
    .SYNOPSIS
    A quick function to convert a SecureString object in to plaintext
    .DESCRIPTION
    This function takes a SecureString as input and converts it back to plain text so it can be read. 
    .PARAMETER String
    The SecureString you would like descrypted back in to a plain text string
    .EXAMPLE
    PS$> $securestring = Read-Host -Prompt "type some text" -AsSecureString
    PS$> Show-SecureString $securestring
    secrettext
    .NOTES
        Version:    1.0
        Author:     C. Bodett
        Creation Date: 3/6/2020
    #>
    [CmdletBinding()]
    param(
        [parameter(Position=0,HelpMessage="Enter a SecureString",
        ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [ValidateNotNull()]$String
        )
    Begin {}    
    Process {
    [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($String))
    }
    End {}
} 