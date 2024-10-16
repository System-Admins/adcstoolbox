function Invoke-CADatabaseDefragmentation
{
    <#
    .SYNOPSIS
        Defragment the Active Directory Certificate Services database.
    .DESCRIPTION
        Use esentutl to defragment the ADCS database.
    .EXAMPLE
        Invoke-CADatabaseDefragmentation;
    #>
    [cmdletbinding()]
    [OutputType([void])]
    param
    (
    )

    BEGIN
    {
        # Write to log.
        $customProgress = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Starting to defragmenting the ADCS database';

        # Get the CertSvc service status.
        $serviceStatus = Get-CAService;

        # If the service is running.
        if ($serviceStatus -eq 'Running')
        {
            # Throw exception.
            throw ('The CertSvc service cant be running. The service must be stopped to do a defragmentation of the database');
        }

        # Get the common name of the certificate authority.
        $commonName = Get-CACommonName;

        # Get the database path.
        $databasePath = Get-CADatabasePath;

        # Construct the path to the database.
        $databaseFilePath = ('{0}\{1}.edb' -f $databasePath.Data, $commonName);

        # Test if the database exists.
        if (-not (Test-Path -Path $databaseFilePath -PathType Leaf))
        {
            # Throw exception.
            throw ('The database does not exist at path {0}' -f $databasePath);
        }

        # Construct arguments.
        [string]$arguments = ('/d "{0}"' -f $databaseFilePath);
    }
    PROCESS
    {
        # Try to defragment the database.
        try
        {
            # Write to log.
            Write-CustomLog -Message ("Trying to defragment the ADCS database '{0}'" -f $databaseFilePath) -Level Verbose;

            # Write to event log.
            Write-CustomEventLog -EventId 10;

            # Defragment the database.
            $null = Invoke-EsentUtl -Arguments $arguments;

            # Write to log.
            Write-CustomLog -Message ('Successfully defragmented the ADCS database') -Level Verbose;

            # Write to event log.
            Write-CustomEventLog -EventId 9;
        }
        # Something went wrong.
        catch
        {
            # Write to event log.
            Write-CustomEventLog -EventId 8;

            # Throw execption.
            throw ('Failed to defragment the ADCS database. {0}' -f $_.Exception.Message);
        }
    }
    END
    {
        # Write to log.
        Write-CustomProgress @customProgress;
    }
}