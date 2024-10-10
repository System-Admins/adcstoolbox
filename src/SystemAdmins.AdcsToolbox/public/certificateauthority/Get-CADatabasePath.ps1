function Get-CADatabasePath
{
    <#
    .SYNOPSIS
        Get the path for CertSvc database.
    .DESCRIPTION
        Return object with paths.
    .EXAMPLE
        Get-CADatabasePath;
    #>
    [cmdletbinding()]
    [OutputType([pscustomobject])]
    param
    (
    )

    BEGIN
    {
        # Write to log.
        $progressId = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Getting CertSvc database paths' -Type 'Begin';

        # Get the registry path.
        [pscustomobject]$registryPath = Get-CARegistryPath;

        # Object to store paths.
        [pscustomobject]$paths = [pscustomobject]@{
            Data   = $null;
            Log    = $null;
            System = $null;
            Temp   = $null;
        };
    }
    PROCESS
    {
        # Get the database directory.
        $paths.Data = (Get-ItemPropertyValue -Path $registryPath.Configuration -Name 'DBDirectory');

        # Get the database log directory.
        $paths.Log = (Get-ItemPropertyValue -Path $registryPath.Configuration -Name 'DBLogDirectory');

        # Get the database system directory.
        $paths.System = (Get-ItemPropertyValue -Path $registryPath.Configuration -Name 'DBSystemDirectory');

        # Get the database temp directory.
        $paths.Temp = (Get-ItemPropertyValue -Path $registryPath.Configuration -Name 'DBTempDirectory');
    }
    END
    {
        # Write to log.
        Write-CustomProgress -ProgressId $progressId -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Getting CertSvc database paths' -Type 'End';

        # Return paths.
        return $paths;
    }
}