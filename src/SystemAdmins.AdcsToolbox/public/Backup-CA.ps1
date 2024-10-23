function Backup-CA
{
    <#
    .SYNOPSIS
        Backup certificate authority with or without the private key.
    .DESCRIPTION
        Creates a folder and backup the Active Directory Certificate Services database to the folder.
    .PARAMETER Path
        Backup path.
    .PARAMETER PrivateKey
        Backup private key.
    .EXAMPLE
        Backup-CA -Path 'C:\Backup';
    .EXAMPLE
        Backup-CA -Path 'C:\Backup' -PrivateKey;
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
        [string]$Path = $script:ModuleBackupFolder,

        # Private key backup.
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [switch]$PrivateKey,

        # Password for the backup.
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string]$Password
    )

    BEGIN
    {
        # Write to log.
        $customProgress = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Backup ADCS database';

        # Get disk space.
        $disksSpace = Get-DiskSpace;

        # Get database size.
        $databaseSize = Get-CADatabaseSize;

        # Get drive letter.
        $driveLetter = $Path.Substring(0, 2);

        # Get disk space for drive.
        $diskSpace = $disksSpace | Where-Object { $_.DriveLetter -eq $driveLetter };

        # If disk space is less than database size.
        if ($diskSpace.FreeSpace -lt $databaseSize.Total)
        {
            # Write to event log.
            Write-CustomEventLog -EventId 1 -AdditionalMessage ('Free space is {0} GB, required space is {1} GB' -f $diskSpace.FreeSpaceInGB, $databaseSize.TotalGb);

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
        if (-not (Test-Path -Path $Path))
        {
            # Write to log.
            Write-CustomLog -Message ("Creating backup folder '{0}'" -f $Path) -Level Verbose;

            # Create the path.
            $null = New-Item -Path $Path -ItemType 'Directory' -Force;
        }

        # Get the CertSvc service status.
        $serviceStatus = Get-CAService;

        # If the service is not running.
        if ($serviceStatus -ne 'Running')
        {
            # Write to event log.
            Write-CustomEventLog -EventId 2;

            # Throw exception.
            throw ('The CertSvc service is not running. The service must be running to backup the database');
        }

        # Get the common name of the certificate authority.
        $commonName = Get-CACommonName;

        # Splatting for the backup.
        $backupSplat = @{
            Path        = $Path;
            ErrorAction = 'Stop';
        };

        # If the password is set.
        if (-not [string]::IsNullOrEmpty($Password))
        {
            # Write to log.
            Write-CustomLog -Message 'Backup will be password protected' -Level Verbose;

            # Convert the password to a secure string.
            $securePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force;

            # Add password to the splat.
            $null = $backupSplat.Add('Password', $securePassword);
        }

        # Object to return.
        [pscustomobject]$result = [pscustomobject]@{
            DatabasePath   = ('{0}\DataBase' -f $Path);
            PrivateKeyPath = $null;
        };
    }
    PROCESS
    {
        # Export CA certificate.
        $null = Export-CACertificate -FolderPath $Path;

        # If private key backup is requested.
        if ($true -eq $PrivateKey)
        {
            # Write to event log.
            Write-CustomEventLog -EventId 12;

            # If Entrust Security World is installed.
            if ($true -eq (Test-EntrustSecurityWorldInstalled))
            {
                # Backup Entrust Security World.
                $entrustSecurityWorld = Backup-EntrustSecurityWorld -Path $Path;

                # Add member to result.
                $null = Add-Member -InputObject $result -MemberType NoteProperty -Name 'EntrustSecurityWorldPath' -Value $entrustSecurityWorld.BackupFolderPath -Force;
            }

            # Try to backup the private key.
            try
            {
                # Write to log.
                Write-CustomLog -Message ("Trying to backup the database with private key to the directory '{0}'" -f $Path) -Level Verbose;

                # Backup the database.
                Backup-CARoleService @backupSplat;

                # Write to log.
                Write-CustomLog -Message ("Successfully made a backup of the database including the private key to the directory '{0}'" -f $Path) -Level Verbose;

                # Set private key path.
                $result.PrivateKeyPath = ('{0}\{1}.p12' -f $Path, $commonName);

                # Write to event log.
                Write-CustomEventLog -EventId 5;
            }
            # Something went wrong.
            catch
            {
                # Write to log.
                Write-CustomLog -Message ("Failed to backup the database including the private key to the directory '{0}'. Will try without the private key" -f $Path) -Level Warning;

                # Write to event log.
                Write-CustomEventLog -EventId 3;

                # Backup without private key.
                $null = Backup-CA -Path $Path;
            }
        }
        # Else backup without private key.
        else
        {
            # Write to event log.
            Write-CustomEventLog -EventId 11;

            # Try to backup the database.
            try
            {
                # Write to log.
                Write-CustomLog -Message ("Trying to backup the database without the private key to the directory '{0}'" -f $Path) -Level Verbose;

                # Backup the database.
                Backup-CARoleService -DatabaseOnly @backupSplat;

                # Write to log.
                Write-CustomLog -Message ("Successfully made a backup of the database without the private key to the directory '{0}'" -f $Path) -Level Verbose;

                # Write to event log.
                Write-CustomEventLog -EventId 6;
            }
            # Something went wrong.
            catch
            {
                # Write to event log.
                Write-CustomEventLog -EventId 4;

                # Throw exception.
                throw ('Failed to backup the database. {0}' -f $_.Exception.Message);
            }
        }
    }
    END
    {
        # Write to log.
        Write-CustomProgress @customProgress;

        # Return result.
        return $result;
    }
}