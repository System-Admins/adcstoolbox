function Backup-CADatabase
{
    <#
    .SYNOPSIS
        Backup certificate authority.
    .DESCRIPTION
        Creates a folder and backup the Active Directory Certificate Services database to the folder.
    .EXAMPLE
        Backup-CADatabase -Path 'C:\Backup';
    .EXAMPLE
        Backup-CADatabase -Path 'C:\Backup' -PrivateKey;
    #>
    [cmdletbinding()]
    [OutputType([pscustomobject])]
    param
    (
        # Backup path.
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ $_ -match '^[a-zA-Z]:\\' })]
        [ValidateScript({ Test-Path $_ -PathType 'Container' -IsValid })]
        [string]$Path = ('{0}\ADCSBackup_{1}' -f $env:TEMP, (Get-Date -Format 'yyyyMMdd')),

        # Private key backup.
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [switch]$PrivateKey
    )

    BEGIN
    {
        # Write to log.
        $progressId = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Backup ADCS database' -Type 'Begin';

        # Get disk space.
        $disksSpace = Get-DiskSpace;

        # Get database size.
        $databaseSize = Get-CertSvcDatabaseSize;

        # Get drive letter.
        $driveLetter = $Path.Substring(0, 2);

        # Get disk space for drive.
        $diskSpace = $disksSpace | Where-Object { $_.DriveLetter -eq $driveLetter };

        # If disk space is less than database size.
        if ($diskSpace.FreeSpace -lt $databaseSize.Total)
        {
            # Throw exception.
            throw ('Not enough disk space, free space is {0} GB, required space is {1} GB' -f $diskSpace.FreeSpaceInGB, $databaseSize.TotalGb);
        }
        # Else the disk space is enough.
        else
        {
            # Write to log.
            Write-CustomLog -Message ('Disk space is enough, free space is {0} GB, required space is {1} GB' -f $diskSpace.FreeSpace, $databaseSize.TotalGb) -Level Verbose;
        }

        # If the path does not exist.
        if (-not (Test-Path $Path))
        {
            # Create the path.
            $null = New-Item -Path $Path -ItemType 'Directory' -Force;
        }

        # Get the CertSvc service status.
        $serviceStatus = Get-CertSvcService;

        # If the service is not running.
        if ($serviceStatus -ne 'Running')
        {
            # Throw exception.
            throw ('The CertSvc service is not running. The service must be running to backup the database');
        }

        # Get the common name of the certificate authority.
        $commonName = Get-CACommonName;

        # Object to return.
        [pscustomobject]$result = [pscustomobject]@{
            DatabasePath   = ('{0}\DataBase' -f $Path);
            PrivateKeyPath = $null;
        };
    }
    PROCESS
    {
        # If private key backup is requested.
        if ($true -eq $PrivateKey)
        {
            # Try to backup the private key.
            try
            {
                # Write to log.
                Write-CustomLog -Message ("Trying to backup the database with private key to the directory '{0}'" -f $Path) -Level Verbose;

                # Backup the database.
                Backup-CARoleService -Path $Path -KeepLog -Force -ErrorAction Stop;

                # Write to log.
                Write-CustomLog -Message ("Successfully made a backup of the database including the private key to the directory '{0}'" -f $Path) -Level Verbose;

                # Set private key path.
                $result.PrivateKeyPath = ('{0}\{1}.p12' -f $Path, $commonName);
            }
            # Something went wrong.
            catch
            {
                # Write to log.
                Write-CustomLog -Message ("Failed to backup the database including the private key to the directory '{0}'. Will try without the private key" -f $Path) -Level Warning;

                # Backup without private key.
                Backup-CA -Path $Path;
            }
        }
        # Else backup without private key.
        else
        {
            # Try to backup the database.
            try
            {
                # Write to log.
                Write-CustomLog -Message ("Trying to backup the database without the private key to the directory '{0}'" -f $Path) -Level Verbose;

                # Backup the database.
                Backup-CARoleService -Path $Path -DatabaseOnly -KeepLog -Force -ErrorAction Stop;

                # Write to log.
                Write-CustomLog -Message ("Successfully made a backup of the database without the private key to the directory '{0}'" -f $Path) -Level Verbose;
            }
            # Something went wrong.
            catch
            {
                # Throw exception.
                throw ('Failed to backup the database. {0}' -f $_.Exception.Message);
            }
        }
    }
    END
    {
        # Write to log.
        Write-CustomProgress -ProgressId $progressId -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Backup ADCS database' -Type 'End';

        # Return result.
        return $result;
    }
}