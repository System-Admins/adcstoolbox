function Get-CADatabaseSize
{
    <#
    .SYNOPSIS
        Get the certificate authority database size.
    .DESCRIPTION
        Return object with the size.
    .EXAMPLE
        Get-CADatabaseSize;
    #>
    [cmdletbinding()]
    [OutputType([pscustomobject])]
    param
    (
    )

    BEGIN
    {
        # Write to log.
        $customProgress = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Getting CertSvc database size';

        # Object to store sizes.
        [pscustomobject]$sizes = [pscustomobject]@{
            Data  = 0;
            Log   = 0;
            Total = 0;
            TotalGb = 0;
        };

        # Get the database paths.
        [pscustomobject]$paths = Get-CADatabasePath;
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

        # If size is over 25 GB.
        if ($sizes.TotalGb -ge 25)
        {
            # Write to event log.
            Write-CustomEventLog -EventId 7 -AdditionalMessage ('Database size is {0} GB' -f $sizes.TotalGb);
        }
        # Else under.
        else
        {
            # Write to event log.
            Write-CustomEventLog -EventId 13 -AdditionalMessage ('Database size is {0} GB' -f $sizes.TotalGb);
        }
    }
    END
    {
        # Write to log.
        Write-CustomProgress @customProgress;

        # Return sizes.
        return $sizes;
    }
}