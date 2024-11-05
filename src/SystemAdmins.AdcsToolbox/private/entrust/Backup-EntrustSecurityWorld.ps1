function Backup-EntrustSecurityWorld
{
    <#
    .SYNOPSIS
        Backup Entrust Security World files.
    .DESCRIPTION
        Creates a folder and backup the Entrust Security World files to the folder.
    .PARAMETER Path
        Backup path.
    .EXAMPLE
        Backup-EntrustSecurityWorld -Path 'C:\Backup';
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
        [string]$Path = $script:ModuleBackupFolder
    )

    BEGIN
    {
        # Write to log.
        $customProgress = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Backup Entrust Security World';

        # Get if the software is installed.
        $isInstalled = Test-EntrustSecurityWorldInstalled;

        # Construct the backup folder.
        $backupFolderPath = Join-Path -Path $Path -ChildPath 'EntrustSecurityWorld';

        # Security World data folder.
        $securityWorldDataFolderPath = Join-Path -Path $env:NFAST_KMDATA -ChildPath 'local';

        # Result object.
        $result = [pscustomobject]@{
            BackupFolderPath            = $backupFolderPath;
            SecurityWorldDataFolderPath = $securityWorldDataFolderPath;
        };
    }
    PROCESS
    {
        # If the software is not installed.
        if ($true -eq $isInstalled)
        {
            # If the backup path does not exist.
            if (-not (Test-Path -Path $backupFolderPath))
            {
                # Write to log.
                Write-CustomLog -Message ("Creating backup folder '{0}'" -f $backupFolderPath) -Level Verbose;

                # Create the path.
                $null = New-Item -Path $backupFolderPath -ItemType 'Directory' -Force;
            }

            # If the Security World folder does not exist.
            if (-not (Test-Path -Path $securityWorldDataFolderPath))
            {
                # Write to log.
                Write-CustomLog -Message ("Security World data folder '{0}' does not exist, skipping backup" -f $securityWorldDataFolderPath) -Level Verbose;
            }
            # Else the Security World folder exist.
            else
            {
                # Write to log.
                Write-CustomLog -Message ("Copying all files from '{0}' to '{1}'" -f $securityWorldDataFolderPath, $backupFolderPath) -Level Verbose;

                # Copy the files from the folder.
                $null = Copy-Item -Path ($securityWorldDataFolderPath + '\*') -Destination $backupFolderPath -Recurse -Force;

                # Write to event log.
                Write-CustomEventLog -EventId 152 -AdditionalMessage ('Backup folder is {0}' -f $backupFolderPath);
            }
        }
    }
    END
    {
        # Write to log.
        Write-CustomProgress @customProgress;

        # If the software is installed.
        if ($true -eq $isInstalled)
        {
            # Return result.
            return $result;
        }
    }
}