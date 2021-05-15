Function ConvertFrom-Garbage {
<#
.Synopsis
Function to decode 'garbage' text produce by companion ConvertTo-Garbage function
.Description
Provide message text that was previously 'encoded' by ConvertTo-Garbage and this function will 'decode' it
.Parameter Message
The text to be decoded. Can be passed as a string variable, a quoted string, or can be ommitted and supplied after execution where it will be collected as a string
.Example
ConvertFrom-Garbage
Message: 104vYE!plt97vYE!plt99g;*107vYE!plt32g;*116g;*104g;*101vYE!plt32vYE!plt112g;*108g;*97g;*110g;*101g;*116g;*

hack the planet

# executing the function without a parameter immediately requires it afterwards. paste in your encoded text and it will spit out the decoded text

.Notes
    Version 1.3
    Author: C. Bodett
    Creation Date: 6/23/2020
#>
    Param(
      [Parameter(Position = 0,Mandatory = $true,ValueFromPipeline,HelpMessage = "Provide the text you want to decode")]
      [String]$Message
    )
    $GetNum = ([regex]'(\d{5,6})').Matches($Message)
    $Numbers = ($GetNum.Groups | Where-Object {$_.Name -eq 1}).Value
    $CharArray = $Numbers | ForEach-Object {[int]$_ / 7877}
    return [System.Text.Encoding]::UTF8.GetString($CharArray)
  }