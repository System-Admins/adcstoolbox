function Get-OperatingSystem
{
    <#
    .SYNOPSIS
        Get operating system type.
    .DESCRIPTION
        Return either Windows, macOS, Linux, FreeBSD or Unknown.
    .EXAMPLE
        Get-OperatingSystem;
    #>
    [cmdletbinding()]
    [OutputType([string])]
    param
    (
    )

    BEGIN
    {
        # Write to log.
        $progressId = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Getting operating system type' -Type 'Start';

        # Operating system type.
        [string]$operatingSystemType = $null;
    }
    PROCESS
    {
        # If operating system is Windows.
        if ([System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Windows))
        {
            $operatingSystemType = 'Windows';
        }
        # Else if operating system is Linux.
        elseif ([System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Linux))
        {
            $operatingSystemType = 'Linux';
        }
        # Else if operating system is macOS.
        elseif ([System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::OSX))
        {
            $operatingSystemType = 'macOS';
        }
        # Else if operating system is FreeBSD.
        elseif ([System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::FreeBSD))
        {
            $operatingSystemType = 'FreeBSD';
        }
        # Else if operating system is unknown.
        else
        {
            $operatingSystemType = 'Unknown';
        }

        # Write to log.
        Write-CustomLog -Message ('The operating system type is "{0}"' -f $operatingSystemType) -Level Verbose;
    }
    END
    {
        # Write to log.
        Write-CustomProgress -Id $progressId -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Getting operating system type' -Type 'End';

        # Return operating system.
        return $operatingSystemType;
    }
}