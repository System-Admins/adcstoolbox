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
        $progressId = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Getting certificate authority common name' -Type 'Begin';

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
        Write-CustomProgress -ProgressId $progressId -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Getting certificate authority common name' -Type 'End';

        # Return common name.
        return $commonName;
    }
}