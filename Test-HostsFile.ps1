function Test-HostsFile {
    <#
    .Synopsis
    Function to check if a Windows hosts file has been modified beyond default
    .Description
    Function can check a local or remote computer and compare the contents of the hosts file against default text. Any differences found
    are returned as individual objects.
    .Parameter ComputerName
    Optionally provide the remote computername to run the function against
    .Parameter Credential
    Provide an alternate credential for use with the ComputerName parameter
    .Example
    PS C:\>Test-HostsFile

    # will return nothing if hosts file is in default state
    .Example
    PS C:\>Test-HostsFile -ComputerName ContosoWeb01 -Credential $Credentials
    WARNING: Failed to retrieve hosts file from UNC path. Attempting Invoke-Command
    hosts file has been modified. Default banner text does not match
    ContosoWeb01: non-default text found in hosts file

    Computer       HostsFileEntry                                CommentLine
    --------       --------------                                -----------
    ContosoWeb01  127.0.0.1       localhost                          False
    ContosoWeb01 #127.0.0.1 test-site.contoso.local                  True
    ContosoWeb01 #192.168.170.52 production-site.contoso.local        True

    # ran with a remote computername and a credential. Returned an array of objects showing the differences in the hosts file
    Version 1.0
    Author: C. Bodett
    Creation Date: 1/10/2024
    Purpose/Change: Initial version
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $false, Position = 0)]
        [String]$ComputerName,
        [Parameter(Mandatory = $false)]
        [ValidateSet("MD5","SHA1","SHA256")]
        [String]$Algorithm = "SHA256",
        [Parameter(Mandatory = $false)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    Begin {
        $HostsPath = "C:\Windows\System32\drivers\etc\hosts"
        $DefaultTextB64 = 'IyBDb3B5cmlnaHQgKGMpIDE5OTMtMjAwOSBNaWNyb3NvZnQgQ29ycC4NCiMNCiMgVGhpcyBpcyBhIHNhbXBsZSBIT1NUUyBmaWxlIHVz
        ZWQgYnkgTWljcm9zb2Z0IFRDUC9JUCBmb3IgV2luZG93cy4NCiMNCiMgVGhpcyBmaWxlIGNvbnRhaW5zIHRoZSBtYXBwaW5ncyBvZiBJUCBhZGRyZXNzZXMgdG8
        gaG9zdCBuYW1lcy4gRWFjaA0KIyBlbnRyeSBzaG91bGQgYmUga2VwdCBvbiBhbiBpbmRpdmlkdWFsIGxpbmUuIFRoZSBJUCBhZGRyZXNzIHNob3VsZA0KIyBiZS
        BwbGFjZWQgaW4gdGhlIGZpcnN0IGNvbHVtbiBmb2xsb3dlZCBieSB0aGUgY29ycmVzcG9uZGluZyBob3N0IG5hbWUuDQojIFRoZSBJUCBhZGRyZXNzIGFuZCB0a
        GUgaG9zdCBuYW1lIHNob3VsZCBiZSBzZXBhcmF0ZWQgYnkgYXQgbGVhc3Qgb25lDQojIHNwYWNlLg0KIw0KIyBBZGRpdGlvbmFsbHksIGNvbW1lbnRzIChzdWNo
        IGFzIHRoZXNlKSBtYXkgYmUgaW5zZXJ0ZWQgb24gaW5kaXZpZHVhbA0KIyBsaW5lcyBvciBmb2xsb3dpbmcgdGhlIG1hY2hpbmUgbmFtZSBkZW5vdGVkIGJ5IGE
        gJyMnIHN5bWJvbC4NCiMNCiMgRm9yIGV4YW1wbGU6DQojDQojICAgICAgMTAyLjU0Ljk0Ljk3ICAgICByaGluby5hY21lLmNvbSAgICAgICAgICAjIHNvdXJjZS
        BzZXJ2ZXINCiMgICAgICAgMzguMjUuNjMuMTAgICAgIHguYWNtZS5jb20gICAgICAgICAgICAgICMgeCBjbGllbnQgaG9zdA0KDQojIGxvY2FsaG9zdCBuYW1lI
        HJlc29sdXRpb24gaXMgaGFuZGxlZCB3aXRoaW4gRE5TIGl0c2VsZi4NCiMJMTI3LjAuMC4xICAgICAgIGxvY2FsaG9zdA0KIwk6OjEgICAgICAgICAgICAgbG9j
        YWxob3N0DQo='
        $DefaultText = [System.Text.Encoding]::UTF8.Getstring([System.Convert]::FromBase64String($DefaultTextB64))
        $DefaultTextArray = $DefaultText.Split("`n").TrimEnd("`r")
        $HashStrings = @{
            MD5     = '3688374325B992DEF12793500307566D'
            SHA1    = '4BED0823746A2A8577AB08AC8711B79770E48274'
            SHA256  = '2D6BDFB341BE3A6234B24742377F93AA7C7CFB0D9FD64EFA9282C87852E57085'
        }
        if (-not($ComputerName)) {
            $ComputerName = $ENV:COMPUTERNAME
        }

    }

    Process {
        # Get hosts file contents
        if ($PSBoundParameters.Keys -contains "ComputerName") {
                try {
                    Write-Verbose "Getting hosts file content via Invoke-Command for $ComputerName"
                    $HostsHash,$HostsContent = Invoke-Command -ComputerName $ComputerName -ScriptBlock {Get-FileHash -Path $Using:HostsPath -Algorithm $Using:Algorithm;Get-Content -Path $Using:HostsPath -Encoding UTF8} -Credential $Credential -ErrorAction Stop
                } catch {
                    throw $error[0]
                }
        } else {
            $HostsHash = Get-FileHash -Path $HostsPath -Algorithm $Algorithm
            $HostsContent = Get-Content $HostsPath -Encoding UTF8 -ErrorAction Stop
        }

        # Compare

        if ($HostsHash.Hash -eq $HashStrings[$Algorithm]) {
            Write-Verbose "$Algorithm file hash matches. Hosts file is default state"
        } else {
            $Comparison = Compare-Object -ReferenceObject $DefaultTextArray -DifferenceObject $HostsContent -IncludeEqual
            if ($Comparison.SideIndicator -contains '=>') {
                # non-default text found
                Write-Host "$ComputerName : non-default text found in hosts file" -ForegroundColor Yellow
                Foreach ($Difference in $($Comparison.Where({$_.SideIndicator -eq '=>'}).InputObject)) {
                    if ($Difference -ne "") {
                        if ($Difference -match '^#') {
                            $CommentLine = $true
                        } else {
                            $CommentLine = $false
                        }
                        [PSCustomObject]@{
                            Computer = $ComputerName
                            HostsFileEntry = $Difference
                            CommentLine = $CommentLine
                        }
                    }
                }
            } else {
                Write-Host "$ComputerName : non-default hosts file with no functional entries" -ForegroundColor Yellow
            }
        }
    }
}
