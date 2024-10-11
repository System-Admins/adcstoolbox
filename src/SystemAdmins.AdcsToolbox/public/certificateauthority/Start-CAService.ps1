function Start-CAService
{
    <#
    .SYNOPSIS
        Start the CertSvc service.
    .DESCRIPTION
        Returns nothing.
    .EXAMPLE
        Start-CAService;
    #>
    [cmdletbinding()]
    [OutputType([void])]
    param
    (
    )

    BEGIN
    {
        # Write to log.
        $progressId = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Starting CertSvc service' -Type 'Begin';

        # Service name.
        [string]$serviceName = 'CertSvc';
    }
    PROCESS
    {
        # Try to get the service.
        try
        {
            # Get the service.
            [System.ServiceProcess.ServiceController]$service = Get-Service -Name $serviceName -ErrorAction Stop;

            # If service is running.
            if ($service.Status -eq 'Running')
            {
                # Write to log.
                Write-CustomLog -Message ("Service '{0}' is already running" -f $serviceName) -Level Verbose;
            }
            # Else service is not running.
            else
            {
                # Try to stop the service.
                try
                {
                    # Write to event log.
                    Write-CustomEventLog -EventId 32;

                    # Stop the service.
                    $null = Start-Service -Name $serviceName -ErrorAction Stop;

                    # Write to log.
                    Write-CustomLog -Message ("Service '{0}' started" -f $serviceName) -Level Verbose;
                }
                # Something went wrong.
                catch
                {
                    # Write to event log.
                    Write-CustomEventLog -EventId 33;

                    # Throw execption.
                    throw ("Failed to start service '{0}'. {1}" -f $serviceName, $_.Exception.Message);
                }
            }
        }
        # Something went wrong.
        catch
        {
            # Write to event log.
            Write-CustomEventLog -EventId 33;

            throw ("Something went wrong while starting the service '{0}'. {1}" -f $serviceName, $_.Exception.Message);
        }
    }
    END
    {
        # Write to log.
        Write-CustomProgress -ProgressId $progressId -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Starting CertSvc service' -Type 'End';
    }
}