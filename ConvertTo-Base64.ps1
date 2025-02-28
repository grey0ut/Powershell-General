function ConvertTo-Base64{
    <#
    .Synopsis
    Converts a plaintext string in to Base64.
    .Description
    Takes a plaintext string as a parameter, either directly or from the pipeline, and converts it in to Base64.
    .Parameter TextString
    The plaintext string. Can come from the pipeline.
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
                [System.Convert]::ToBase64String([System.Text.Encoding]::$Encoding.GetBytes($String))
            } catch {
                Write-Error $_
            }
        }
    }

}
