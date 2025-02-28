function Test-PSPass {
    <#
    .SYNOPSIS
    Validates provided credentials against the Domain
    .Description
    Checks provided credentials against the Domain and returns True/False for its validity 
    .Example
    $savedcreds = Get-PSPass
    Test-PSPass $savedcreds
    True

    Takes retrieved saved credentials and tests them
    .Example
    Test-PSPass Contoso\User

    Will prompt for a password, then check and return True/False
    .NOTES
    Version:        2.3
    Author:         C. Bodett
    Creation Date:  4/28/2023
    Purpose/Change: Added the "Negotiate" to the ValidateCredentials method.
    #>
    #Requires -RunAsAdministrator
    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$True)]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        [Alias('credential','credentials')]
        $ValidateObj
    )
    
    Add-Type -AssemblyName System.DirectoryServices.AccountManagement
    # current domain
    $UserDomain = $ValidateObj.username.split('\')[0]
    # separate the username and password in to unique variables
    $Username = $ValidateObj.UserName.split('\')[1]
    $Passwd = $ValidateObj.GetNetworkCredential().password
    # create our AccountManagement objet for validation
    $PC = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Domain, $UserDomain)
    # validate
    $Result = ($PC.ValidateCredentials($Username,$Passwd,[System.DirectoryServices.AccountManagement.ContextOptions]::Negotiate))
    Write-Verbose "The credentials for $Username are:"
    return $Result
}
