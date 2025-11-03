function Convert-Rot13 {
    <#
    .SYNOPSIS
    Leverages the ROT13 cipher on provided string text.  
    .DESCRIPTION
    ROT13 cipher is a simple substitution cipher that replaces every letter with the 13th letter after it. Any alphabet character will be rotated while any non-alphabet character will be kept the same.
    .PARAMETER String
    The string to apply the ROT13 cipher on. Since the cipher works for encoding and decoding you can pass an encoded string or plaintext string to this parameter. 
    #>
    [CmdletBinding()]
    [OutputType([String])]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [String]$String
    )

    process {
        $CharArray = $String.ToCharArray()

        $RotArray = foreach ($Char in $CharArray) {
            $CharNumber = [Int32]$Char
            $RotNumber = switch -regex ($Char) {
                '[A-Ma-m]' { 13 }
                '[N-Zn-z]' { -13 }
                default { 0 }
            }
            [Char]$RotChar = $CharNumber + $RotNumber
            $RotChar
        }

        $RotArray -join ''
    }
}