function ConvertFrom-Base64 {
    <#
    .Synopsis
    Converts a Base64 string in to plaintext.
    .Description
    Takes a Base64 string as a parameter, either directly or from the pipeline, and converts it in to plaintext.
    .Parameter TextString
    The Base64 string. Can come from the pipeline.
    .Parameter Encoding
    Default encoding is UTF8
    .NOTES
    Version:        1.5
    Author:         C. Bodett
    Creation Date:  4/16/2024
    Purpose/Change: fixed to actually support pipeline input and array input
    #>
    [cmdletbinding()]
    param(
        [Parameter(ValueFromPipeline=$true,Position=0,Mandatory=$true)]
        [String[]]$Textstring,
        [Parameter(Position=1)]
        [ValidateSet('UTF8','Unicode','ASCII')]
        [string]$Encoding = 'UTF8'
    )

    Process {
        Foreach ($String in $TextString) {
            try {
                [System.Text.Encoding]::$Encoding.Getstring([System.Convert]::FromBase64String($String))
            } catch {
                Write-Error $_
            }
        }
    }

}
