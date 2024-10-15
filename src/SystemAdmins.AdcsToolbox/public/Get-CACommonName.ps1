function Get-CACommonName
{
    <#
    .SYNOPSIS
        Get certificate authority common name.
    .DESCRIPTION
        Return string with certificate authority common name.
    .EXAMPLE
        Get-CACommonName;
    #>
    [cmdletbinding()]
    [OutputType([string])]
    param
    (
    )

    BEGIN
    {
        # Write to log.
        $customProgress = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Getting certificate authority common name';

        # Get the registry path.
        [pscustomobject]$registryPath = Get-CARegistryPath;

        # Common Name.
        [string]$commonName = '';
    }
    PROCESS
    {
        # Get the common name.
        $commonName = (Get-ItemPropertyValue -Path $registryPath.ActiveConfiguration -Name 'CommonName');
    }
    END
    {
        # Write to log.
        Write-CustomProgress @customProgress;

        # Return common name.
        return $commonName;
    }
}