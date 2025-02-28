function Get-PatchTuesday {
    <#
    .Synopsis
    Returns the Date Time of when Patch Tuesday occurs
    .Description
    When ran with no parameters the function returns a DateTime object representing the occurrence of Patch Tuesday in the current month. There are parameters for specifying other days of the week,
    other months, years, or even occurrence number. I.e. if you want the 3rd Thursday of the month of February.
    .EXAMPLE
    PS> Get-PatchTuesday

    Tuesday, December 12, 2023 12:00:00 AM
    # this returns a DateTime object of when Patch Tuesday occurs for the current month
    .EXAMPLE
    PS> Get-PatchTuesday -Month November

    Tuesday, November 14, 2023 1:23:36 PM
    # this returns the DateTime of Patch Tuesday for November of the current year
    .EXAMPLE
    PS> Get-PatchTuesday -WeekDay monday -FindNthDay 2 -month 1 -year 2024

    Monday, January 15, 2024 1:22:30 PM
    # this returns the third Monday in January 2024

    .NOTES
    Version:        1.0
    Author:         C. Bodett
    Creation Date:  12/29/2023
    Purpose/Change: Initial function development
    #> 
    [CmdletBinding()]
    Param (
        [Parameter(position = 0)]
        [ValidateSet("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday")]
        [String]$WeekDay = "Tuesday",
        [Parameter(position = 1)]
        [ValidateSet("January","February","March","April","May","June","July","August","September","October","November","December",1,2,3,4,5,6,7,8,9,10,11,12)]
        [String]$Month = $(Get-Date -UFormat %B),
        [Parameter(position = 2)]
        [ValidateRange(1960,2200)]
        [String]$Year = (Get-Date).Year,
        [ValidateRange(1, 5)]
        [Parameter(position = 3)]
        [int]$FindNthDay = 2
    )

    if ($Month -match '\d') {
        # month supplied numerically
        [Int32]$Month = $Month
    } else  {
        # convert from string to numeric month
        [Int32]$Month = [Array]::IndexOf([CultureInfo]::CurrentCulture.DateTimeFormat.MonthNames, $Month) + 1
    }
    # Get the first day of the month
    $StartOfMonth = Get-Date -Day 1 -Month $Month -Year $Year
    Write-Verbose "First day of the month is $($StartOfMonth.DayOfWeek) $($StartOfMonth.ToShortDateString())"
    Write-Verbose "Finding occurrence number $FindNthDay of $((Get-Culture).TextInfo.ToTitleCase($WeekDay)) in month $Month"
    while ($StartOfMonth.DayofWeek -ine $WeekDay ) {
        $StartOfMonth = $StartOfMonth.AddDays(1)
    }
    $FirstWeekDay = $StartOfMonth
  
    # Identify and calculate the day offset
    if ($FindNthDay -eq 1) {
      $DayOffset = 0
    } else {
      $DayOffset = ($FindNthDay - 1) * 7
    }
    
    # Return date of the day/instance specified
    $TargetDateTime = $FirstWeekDay.AddDays($DayOffset) 
    return $TargetDateTime
}
