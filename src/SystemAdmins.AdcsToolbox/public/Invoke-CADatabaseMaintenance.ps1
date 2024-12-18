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

        # Include private key in the backup.
        [Parameter(Mandatory = $false)]
        [bool]$PrivateKey = $true,

        # Password for the backup.
        [Parameter(Mandatory = $false)]
        [string]$Password,

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
            $userInput = Get-UserInput -Question 'Do you want to continue with expired/revoked certificate removal, AD CS service restart, temporary extend CRL? (Answer: "Yes" or "No")' -Options 'Yes', 'No';

            # If the user input is not 'Yes'.
            if ($userInput -ne 'Yes')
            {
                # Write to log.
                Write-CustomLog -Message 'User did not confirm the action' -Level Verbose;

                # Exit script.
                exit 1;
            }
        }

        # Create the backup folder.
        $null = New-Item -Path $BackupFolderPath -ItemType Directory -Force -ErrorAction Stop;

        # File path for original CRL configuration.
        $originalCrlConfigFilePath = ('{0}\crlconfig.xml' -f $BackupFolderPath);

        # Splatting for the backup.
        $backupSplat = @{
            Path = ('{0}\Database' -f $BackupFolderPath);
        };

        # If the password is set.
        if (-not [string]::IsNullOrEmpty($Password))
        {
            # Convert the password to a secure string.
            $securePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force;

            # Add password to the splat.
            $null = $backupSplat.Add('Password', $securePassword);
        }
    }
    PROCESS
    {
        # Backup the database (with private key if applicable).
        $null = Backup-CA @backupSplat -PrivateKey:$PrivateKey;

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

        # Get the AD CS service status.
        $serviceStatus = Get-CAService;

        # If the service is running.
        if ($serviceStatus -eq 'Running')
        {
            # Temporary extend the CRL.
            Set-CACrlConfig `
                -OverlapUnits 0 `
                -PeriodUnits 2 `
                -Period Weeks `
                -DeltaOverlapUnits 0 `
                -DeltaPeriodUnits 0;

            # Publish the CRL.
            $null = Publish-CACrl;
        }

        # Splatting for Remove-CACertificate.
        $removeCertificateSplat = @{
            Confirm = $false;
        };

        # If date is set.
        if ($true -eq $PSBoundParameters.ContainsKey('CertificateRemovalDate'))
        {
            # Add to the splat.
            $removeCertificateSplat.Add('Date', $CertificateRemovalDate);
        }

        # Remove expired, denied, failed and revoked certificates/requests.
        $null = Remove-CACertificate -State Failed @removeCertificateSplat;
        $null = Remove-CACertificate -State Denied @removeCertificateSplat;
        $null = Remove-CACertificate -State Expired @removeCertificateSplat;
        $null = Remove-CACertificate -State Revoked @removeCertificateSplat;

        # Stop the service.
        $null = Stop-CAService;

        # Wait until the service is stopped.
        $null = Wait-CAService -State Stopped;

        # Defrag the database.
        $null = Invoke-CADatabaseDefragmentation;

        # If the service was running.
        if ($serviceStatus -eq 'Running')
        {
            # Start the service.
            Start-CAService;

            # Wait until the service is running.
            $null = Wait-CAService -State Running;

            # Restore original CRL configuration.
            Set-CACrlConfig `
                -OverlapUnits $originalCrlConfig.OverlapUnits `
                -Period $originalCrlConfig.Period `
                -PeriodUnits $originalCrlConfig.PeriodUnits `
                -DeltaOverlapUnits $originalCrlConfig.DeltaOverlapUnits `
                -DeltaPeriodUnits $originalCrlConfig.DeltaPeriodUnits;

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