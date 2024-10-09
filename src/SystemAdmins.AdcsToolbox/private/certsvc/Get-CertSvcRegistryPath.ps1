function Get-CertSvcRegistryPath
{
    <#
    .SYNOPSIS
        Get the registry path for CertSvc.
    .DESCRIPTION
        Return object with registry paths.
    .EXAMPLE
        Get-CertSvcRegistryPath;
    #>
    [cmdletbinding()]
    [OutputType([pscustomobject])]
    param
    (
    )

    BEGIN
    {
        # Write to log.
        $progressId = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Getting CertSvc registry paths' -Type 'Begin';

        # Configuration registry path.
        [string]$configurationRegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\CertSvc\Configuration';

        # Object to store paths.
        [pscustomobject]$paths = [pscustomobject]@{
            Configuration       = $configurationRegistryPath;
            ActiveConfiguration = $null;
        };
    }
    PROCESS
    {
        # If the configuration registry path dont exist.
        if (-not (Test-Path -Path $configurationRegistryPath))
        {
            # Throw execption.
            throw ('The CertSvc configuration registry path "{0}" does not exist' -f $configurationRegistryPath);
        }

        # Try to get the active configuration.
        try
        {
            # Get the active configuration.
            $activeConfig = Get-ItemPropertyValue -Path $configurationRegistryPath -Name 'Active';
        }
        # Something went wrong.
        catch
        {
            # Throw execption.
            throw ('Something went wrong while getting the active CertSvc configuration, the execption is:`r`n{0}' -f $_);
        }

        # Construct active configuration registry path.
        $activeConfigurationRegistryPath = ('HKLM:\SYSTEM\CurrentControlSet\Services\CertSvc\Configuration\{0}' -f $activeConfig);

        # If the active configuration registry path dont exist.
        if (-not (Test-Path -Path $activeConfigurationRegistryPath))
        {
            # Throw execption.
            throw ('The active CertSvc configuration registry path "{0}" does not exist' -f $activeConfigurationRegistryPath);
        }

        # Write to log.
        Write-CustomLog -Message ('The active CertSvc configuration registry path is "{0}"' -f $activeConfigurationRegistryPath) -Level Verbose;

        # Add the active configuration registry path to the object.
        $paths.ActiveConfiguration = $activeConfigurationRegistryPath;
    }
    END
    {
        # Write to log.
        Write-CustomProgress -ProgressId $progressId -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Getting CertSvc registry paths' -Type 'End';

        # Return paths.
        return $paths;
    }
}