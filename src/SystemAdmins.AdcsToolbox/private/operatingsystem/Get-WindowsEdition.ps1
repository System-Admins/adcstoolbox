function Get-WindowsEdition
{
    <#
    .SYNOPSIS
        Get Windows edition (Windows 11, Windows Server 2019 etc).
    .DESCRIPTION
        Return information about the Windows edition.
    .EXAMPLE
        Get-WindowsEdition;
    #>
    [cmdletbinding()]
    [OutputType([pscustomobject])]
    param
    (
    )

    BEGIN
    {
        # Write to log.
        $customProgress = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Getting operating system edition';

    }
    PROCESS
    {
        # Get operating system from WMI.
        $wmiObject = Get-WmiObject -Class Win32_OperatingSystem;

        # Object to return.
        [pscustomobject]$osEdition = [pscustomobject]@{
            Edition = $wmiObject.Caption;
            Version = $wmiObject.Version;
            Architecture = $wmiObject.OSArchitecture;
        };

        # Write to log.
        Write-CustomLog -Message ('The operating system is "{0}", version "{1}" running on "{2}"' -f $osEdition.Edition, $osEdition.Version, $osEdition.Architecture) -Level Verbose;
    }
    END
    {
        # Write to log.
        Write-CustomProgress @customProgress;

        # Return edition.
        return $osEdition;
    }
}