function Get-CACommonName
{
    <#
    .SYNOPSIS
        Get certificate authority information common name.
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
        $progressId = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Getting certificate authority common name' -Type 'Start';

        # Get the registry path.
        [pscustomobject]$registryPath = Get-CertSvcRegistryPath;

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
        Write-CustomProgress -Id $progressId -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Getting certificate authority common name' -Type 'End';

        # Return common name.
        return $commonName;
    }
}