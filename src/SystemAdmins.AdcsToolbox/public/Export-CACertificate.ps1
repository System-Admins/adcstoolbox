function Export-CACertificate
{
    <#
    .SYNOPSIS
        Export the certificate authority certificate.
    .DESCRIPTION
        Returns path to certificate file.
    .PARAMETER  Path
        Backup folder path.
    .EXAMPLE
        Export-CACertificate;
    #>
    [cmdletbinding()]
    [OutputType([string])]
    param
    (
        # Backup path.
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ $_ -match '^[a-zA-Z]:\\' })]
        [ValidateScript({ Test-Path $_ -PathType 'Container' -IsValid })]
        [string]$FolderPath = $script:ModuleBackupFolder
    )

    BEGIN
    {
        # Write to log.
        $customProgress = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Exporting CA certificate';

        # If the path does not exist.
        if (-not (Test-Path -Path $FolderPath))
        {
            # Write to log.
            Write-CustomLog -Message ("Creating backup folder '{0}'" -f $FolderPath) -Level Verbose;

            # Create the path.
            $null = New-Item -Path $FolderPath -ItemType 'Directory' -Force;
        }

        # Get the CertSvc service status.
        $serviceStatus = Get-CAService;

        # If the service is not running.
        if ($serviceStatus -ne 'Running')
        {
            # Throw exception.
            throw ('The CertSvc service is not running. The service must be running to export the CA certificate');
        }

        # Get the common name of the certificate authority.
        $commonName = Get-CACommonName;

        # Export path.
        [string]$exportPath = ('{0}\{1}.cer' -f $FolderPath, $commonName);
    }
    PROCESS
    {
        # If the certificate file already exists.
        if (Test-Path -Path $exportPath)
        {
            # Write to log.
            Write-CustomLog -Message ("Certificate file '{0}' already exists, removing it" -f $exportPath) -Level Verbose;

            # Remove the file.
            $null = Remove-Item -Path $exportPath -Force;
        }
        # Arguments to pass to the certutil utility.
        [string]$arguments = ('-ca.cert "{0}"' -f $exportPath);

        # Try to run certutil.exe with arguments.
        try
        {
            # Write to log.
            Write-CustomLog -Message ("Trying to export the certificate authortiy certificate to '{0}'" -f $exportPath) -Level Verbose;

            # Run certutil.exe with arguments.
            $null = Invoke-CertUtil -Arguments $arguments -ErrorAction Stop;

            # Write to log.
            Write-CustomLog -Message ('Successfully export certificate authortiy certificate') -Level Verbose;
        }
        # Something went wrong.
        catch
        {
            # Throw exception.
            throw ('Failed export certificate authortiy certificate. {0}' -f $_.Exception.Message);
        }
    }
    END
    {
        # Write to log.
        Write-CustomProgress @customProgress;

        # Return path.
        return $exportPath;
    }
}