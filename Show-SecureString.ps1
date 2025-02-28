function Show-SecureString {
    <#
    .Synopsis
    Converts a SecureString object in to readable plain text
    .Description
    Uses the built-in .NET methods to convert a securestring object back in to readable plaintext
    .Example
    $test = get-credential contoso\admin

    Show-SecureString $test.password
    .NOTES
    Version:        1.1
    Author:         C. Bodett
    Creation Date:  5/5/2022
    Purpose/Change: Reformatted help. Added object cast for parameter and try/catch block for process. Restructured Process/End block to accomodate pipline input of multiple objects.
    #>
    [cmdletbinding()]
    param(
        [Parameter(Position=0,HelpMessage="Must provide a SecureString object",ValueFromPipeline)]
        [ValidateNotNull()]
        [System.Security.SecureString]$StringObj
        )
    process {
        try {
            $BSTR = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($StringObj)
            $PlainText = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($BSTR)
            $PlainText
        } catch {
            throw $_
        }
    }
    end {
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
    }
} 
