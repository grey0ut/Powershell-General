Function ConvertTo-Garbage {
  <#
.Synopsis
Function to encode text in to seemingly garbage
.Description
Function converts all characters of provided message to unicode numeric values and separates those values with random delimiters to obscure them. Can be decoded with 
companion function ConvertFrom-Garbage
.Parameter Message
The text to be encoded. Can be passed as a string variable, a quoted string, or can be ommitted and supplied after execution where it will be collected as a string
.Example
ConvertTo-Garbage "hack the planet"
104vYE!plt97vYE!plt99g;*107vYE!plt32g;*116g;*104g;*101vYE!plt32vYE!plt112g;*108g;*97g;*110g;*101g;*116g;*

.Notes
    Version 1.2
    Author: C. Bodett
    Creation Date: 6/23/2020
#>
    Param(
      [Parameter(Position = 0,Mandatory = $true,ValueFromPipeline,HelpMessage = "Provide the text you want to encode")]
      [String]$Message
    )
    $Enc = [system.Text.Encoding]::UTF8
    $UniArray = $Enc.GetBytes($Message) 

    $DelimChars = (33..43)+(45..47)+(58..64)+(65..90)+(97..122) | ForEach-Object {[char]$_}
    $Delims = @()
    foreach ($num in 1..(Get-Random -min 20 -max 50)){
        $Length = Get-Random -min 1 -max 10
        $Delims += -join ($Delimchars | get-random -count $Length)
    }

    $Bigstring = @()
    foreach ($Chunk in $UniArray){
      $Bigstring += ([int]$Chunk*7877).ToString() + $Delims[(get-random -min 0 -max ($Delims.count -1 ))]
    }
    -join $Bigstring
  }