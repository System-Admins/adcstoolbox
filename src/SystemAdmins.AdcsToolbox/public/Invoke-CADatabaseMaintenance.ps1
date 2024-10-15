function Invoke-CADatabaseMaintenance
{
    <#
    .SYNOPSIS
        Start AD CS database cleanup.
    .DESCRIPTION
        Return nothing.
    .PARAMETER CertificateRemovalDate
        Date to remove expired, denied, failed and revoked certificates/requests from.
    .PARAMETER BackupFolderPath
        Path to the backup folder.
    .PARAMETER Confirm
        Confirm the action.
    .EXAMPLE
        Invoke-CADatabaseMaintenance -CertificateRemovalDate (Get-Date).AddMonths(-3) -BackupFolderPath 'C:\ADCSBackup' -Confirm;
    #>
    [cmdletbinding()]
    [OutputType([void])]
    param
    (
        # Date to remove expired and revoked certificates from.
        [Parameter(Mandatory = $false)]
        [ValidateScript({ $_ -le (Get-Date) })]
        [DateTime]$CertificateRemovalDate = (Get-Date).AddMonths(-3),

        # Path to the backup folder.
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$BackupFolderPath = $script:ModuleBackupFolder,

        # Confirm the action.
        [Parameter(Mandatory = $false)]
        [switch]$Confirm = $true
    )

    BEGIN
    {
        # Write to log.
        $customProgress = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Certificate authority database cleanup';

        # Ask user to confirm.
        if ($true -eq $Confirm)
        {
            # Get user input.
            $userInput = Get-UserInput -Question 'Do you want to continue with expired/revoked certificate removal, AD CS service restart, temporary extend CRL? (Answer: Yes or No)' -Options 'Yes', 'No';

            # If the user input is not 'Yes'.
            if ($userInput -ne 'Yes')
            {
                # Write to log.
                Write-CustomLog -Message 'User did not confirm the action' -Level Verbose;

                # Exit script.
                exit 1;
            }
        }

        # Write to event log.
        Write-CustomEventLog

        # Create the backup folder.
        $null = New-Item -Path $BackupFolderPath -ItemType Directory -Force -ErrorAction Stop;

        # File path for original CRL configuration.
        $originalCrlConfigFilePath = ('{0}\crlconfig.xml' -f $BackupFolderPath);
    }
    PROCESS
    {
        # Backup the database.
        $null = Backup-CADatabase -Path ('{0}\Database' -f $BackupFolderPath) -PrivateKey;

        # Get the AD CS service status.
        $serviceStatus = Get-CAService;

        # If the service is running.
        if ($serviceStatus -eq 'Running')
        {
            # Get current CRL configuraiton.
            $originalCrlConfig = Get-CACrlConfig;

            # If the CRL config file path dont exist.
            if (-not (Test-Path -Path $originalCrlConfigFilePath -PathType Leaf))
            {
                # Write to log.
                Write-CustomLog -Message ('Original (backup) CRL configuration file does not exist. Creating file at path {0}' -f $originalCrlConfigFilePath) -Level Verbose;

                # Save the original CRL configuration to a file.
                $null = $originalCrlConfig | Export-Clixml -Path $originalCrlConfigFilePath -Force;
            }

            # Stop the service.
            Stop-CAService;

            # Temporary extend the CRL.
            Set-CACrlConfig `
                -OverlapUnits 0 `
                -PeriodUnits 2 `
                -Period Weeks `
                -DeltaOverlapUnits 0 `
                -DeltaPeriodUnits 0;

            # Start the service.
            Start-CAService;

            # Wait a few seconds.
            Start-Sleep -Seconds 5;

            # Publish the CRL.
            $null = Publish-CACrl;
        }

        # Remove expired, denied, failed and revoked certificates/requests.
        $null = Remove-CACertificate -Date $CertificateRemovalDate -State Failed;
        $null = Remove-CACertificate -Date $CertificateRemovalDate -State Denied;
        $null = Remove-CACertificate -Date $CertificateRemovalDate -State Expired;
        $null = Remove-CACertificate -Date $CertificateRemovalDate -State Revoked;

        # Stop the service.
        Stop-CAService;

        # Defrag the database.
        Invoke-CADatabaseDefragmentation;

        # Restore original CRL configuration.
        Set-CACrlConfig `
            -OverlapUnits $originalCrlConfig.OverlapUnits `
            -Period $originalCrlConfig.Period `
            -PeriodUnits $originalCrlConfig.PeriodUnits `
            -DeltaOverlapUnits $originalCrlConfig.DeltaOverlapUnits `
            -DeltaPeriodUnits $originalCrlConfig.DeltaOverlapUnits;

        # If the service was running.
        if ($serviceStatus -eq 'Running')
        {
            # Start the service.
            Start-CAService;

            # Wait a few seconds.
            Start-Sleep -Seconds 5;

            # Publish the CRL.
            $null = Publish-CACrl;
        }
    }
    END
    {
        # Write to log.
        Write-CustomProgress @customProgress;
    }
}