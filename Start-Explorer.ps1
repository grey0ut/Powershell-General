function Start-Explorer {
    <#
    .SYNOPSIS
    Simple function to launch explorer in the current location, or at a provided location/file with the file selected. 
    .DESCRIPTION
    A wrapper around explorer.exe and the /Select parameter for launching an explorer window with the provided object selected. If no argument is provided, opens explorer in the current directory.
    .PARAMETER Path
    Path to where you'd like explorer opened. This can be a file or a directory.
    .EXAMPLE
    PS> Start-Explorer

    # launches an explorer instance in the current directory

    PS> Start-Explorer -Path .\Textfile.txt

    # launches an explorer instance in the current directory with the file "Textfile.txt" selected
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position=0)]
        [ValidateScript({Test-Path $_})]
        [System.IO.FileInfo]$Path
    )

    if ($PSBoundParameters.Keys -contains "FilePath") {
        if (-not $Path.Exists) {
            # this means we were given a relative path. Resolve it to its full path
            $ResolvedPath = Resolve-Path -Path $Path | Select-Object -Expandproperty ProviderPath
            if ($ResolvedPath) {
                [System.IO.FileInfo]$Path = $ResolvedPath
            }
        }
    } else {
        $Path = Get-Location | Select-Object -ExpandProperty Path
    }
    if ($Path.Attributes -eq 'Directory') {
        $Path = Get-ChildItem -Path $Path.FullName -File | Select-Object -First 1
    }
    Write-Verbose "Opening Explorer to $($Path.FullName)"
    Start-Process -FilePath explorer.exe -ArgumentList "/select,$($Path.FullName)"
}
