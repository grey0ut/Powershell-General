Function ConvertFrom-Base64 {
    <#
    .Synopsis
    Converts a Base64 string in to plaintext.
    .Description
    Takes a Base64 string as a parameter, either directly or from the pipeline, and converts it in to plaintext.
    .Parameter TextString
    The Base64 string. Can come from the pipeline.
    .Parameter Encoding
    Default encoding is UTF8, but this can be Unicode,ASCII or UTF8 if you're having problems.
    .Parameter OutputType
    Select whether to return the decoded value as a string or a byte array
    .NOTES
    Version:        1.0
    Author:         C. Bodett
    Creation Date:  9/14/2021
    Purpose/Change: Initial function development.
    #>
    [cmdletbinding()]
    Param (
        [Parameter(ValueFromPipeline = $true, Position = 0, Mandatory = $true)]
        [String]$TextString,
        [Parameter(Position = 1)]
        [ValidateSet('UTF8','Unicode','ASCII')]
        [String]$Encoding = 'UTF8',
        [Parameter(Position = 2)]
        [ValidateSet('Bytes','String')]
        [String]$OutputType = 'String'
    )

    if ($OutputType -eq 'String') {
        $Decoded = [System.Text.Encoding]::$Encoding.GetString([System.Convert]::FromBase64String($TextString))
    } else {
        $Decoded = [System.Convert]::FromBase64String($TextString)
    }
    $Decoded
}
