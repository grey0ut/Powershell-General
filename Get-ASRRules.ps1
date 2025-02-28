<#
.Synopsis
Script to return the local computer's Attack Surface Reduction Rules and configuration.
.NOTES
Version:        1.0
Author:         C. Bodett
Creation Date:  2/2/2024
Purpose/Change: Initial version created
#>

$RuleHash = @{
    "56a863a9-875e-4185-98a7-b882c64b5ce5" = "Block abuse of exploited vulnerable signed drivers"
    "7674ba52-37eb-4a4f-a9a1-f0f9a1619a2c" = "Block Adobe Reader from creating child processes"
    "d4f940ab-401b-4efc-aadc-ad5f3c50688a" = "Block all Office applications from creating child processes"
    "9e6c4e1f-7d60-472f-ba1a-a39ef669e4b2" = "Block credential stealing from the Windows local security authority subsystem (lsass.exe)"
    "be9ba2d9-53ea-4cdc-84e5-9b1eeee46550" = "Block executable content from email client and webmail"
    "01443614-cd74-433a-b99e-2ecdc07bfc25" = "Block executable files from running unless they meet a prevalence, age, or trusted list criterion"
    "5beb7efe-fd9a-4556-801d-275e5ffc04cc" = "Block execution of potentially obfuscated scripts"
    "d3e037e1-3eb8-44c8-a917-57927947596d" = "Block JavaScript or VBScript from launching downloaded executable content"
    "3b576869-a4ec-4529-8536-b80a7769e899" = "Block Office applications from creating executable content"
    "75668c1f-73b5-4cf0-bb93-3ecf5cb7cc84" = "Block Office applications from injecting code into other processes"
    "26190899-1602-49e8-8b27-eb1d0a1ce869" = "Block Office communication application from creating child processes"
    "e6db77e5-3df2-4cf1-b95a-636979351e5b" = "Block persistence through WMI event subscription"
    "d1e49aac-8f56-4280-b9ba-993a6d77406c" = "Block process creations originating from PSExec and WMI commands"
    "b2b3f03d-6a65-4f7b-a9c7-1c7ef74a9ba4" = "Block untrusted and unsigned processes that run from USB"
    "92e97fa1-2edf-4476-bdd6-9dd0b4dddc7b" = "Block Win32 API calls from Office macros"
    "c1db55ab-c21a-4637-bb3f-a12568109d35" = "Use advanced protection against ransomware"
}

# Get current Defender for Endpoint configuration
$MpPrefs = Get-MpPreference
$Count = $MpPrefs.AttackSurfaceReductionRules_Ids.count -1
Function Get-RuleMode {
    Param (
        [Int32]$ActionValue
    )

    switch ($ActionValue) {
        1 {"Block"}
        2 {"Audit"}
        0 {"NotConfigured"}
        6 {"Warn"}
    }
}

$ASRRules = Foreach ($RuleGUID in $RuleHash.Keys) {
    $Index = $MpPrefs.AttackSurfaceReductionRules_Ids.IndexOf($RuleGUID)
    if ($Index -eq -1) {
        # rule not found
        $RuleModeValue = 0
    } else {
        $RuleModeValue = $MpPrefs.AttackSurfaceReductionRules_Actions[$Index]
    }
    [PSCustomObject]@{
        RuleGUID = $RuleGUID
        RuleName = $RuleHash[$RuleGUID]
        RuleMode = $RuleModeValue
        RuleModeH = Get-RuleMode $RuleModeValue
    }
}

return $ASRRules
