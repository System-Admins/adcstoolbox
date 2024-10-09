function Get-CertSvcDatabaseSize
{
    <#
    .SYNOPSIS
        Return database size for CertSvc.
    .DESCRIPTION
        Return object sizes.
    .EXAMPLE
        Get-CertSvcDatabaseSize;
    #>
    [cmdletbinding()]
    [OutputType([pscustomobject])]
    param
    (
    )

    BEGIN
    {
        # Write to log.
        $progressId = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Getting CertSvc database size' -Type 'Begin';

        # Object to store sizes.
        [pscustomobject]$sizes = [pscustomobject]@{
            Data  = 0;
            Log   = 0;
            Total = 0;
            TotalGb = 0;
        };

        # Get the database paths.
        [pscustomobject]$paths = Get-CertSvcDatabasePath;
    }
    PROCESS
    {
        # Get size of the data folder.
        $sizes.Data = (Get-FolderSize -Path $paths.Data -FileTypeInclude @('.edb')).Bytes;

        # Get size of the log folder.
        $sizes.Log = (Get-FolderSize -Path $paths.Log -FileTypeInclude @('.log')).Bytes;

        # Calculate total size.
        $sizes.Total = $sizes.Data + $sizes.Log;

        # Calculate total size in GB.
        $sizes.TotalGb = [math]::Round($sizes.Total / 1GB, 2);
    }
    END
    {
        # Write to log.
        Write-CustomProgress -ProgressId $progressId -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Getting CertSvc database size' -Type 'End';

        # Return sizes.
        return $sizes;
    }
}