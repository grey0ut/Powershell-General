Function ConvertTo-SarcasmFont {
    [cmdletbinding()]
    Param(
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
        [String]$InputText,
        [Switch]$Output
    )

    $StringArray = $Inputtext.ToCharArray()
    $Count = 0
    $Results = foreach ($character in $StringArray){
         $Count++
         [string]$c = $character
         if ($Count % 2 -eq 0){
         $c.toupper()
            }Else{
         $c.tolower()
         }}
    If ($Output){
        $Results -join ""
    }Else{
        $Results -join "" | clip
    }
}