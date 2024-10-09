function Stop-CertSvcService
{
    <#
    .SYNOPSIS
        Stop the CertSvc service.
    .DESCRIPTION
        Returns nothing.
    .EXAMPLE
        Stop-CertSvcService;
    #>
    [cmdletbinding()]
    [OutputType([void])]
    param
    (
    )

    BEGIN
    {
        # Write to log.
        $progressId = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Stopping CertSvc service' -Type 'Begin';

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
                # Try to stop the service.
                try
                {
                    # Stop the service.
                    $null = Stop-Service -Name $serviceName -ErrorAction Stop;

                    # Write to log.
                    Write-CustomLog -Message ("Service '{0}' stopped" -f $serviceName) -Level Verbose;
                }
                # Something went wrong.
                catch
                {
                    # Throw execption.
                    throw ("Failed to stop service '{0}'. {1}" -f $serviceName, $_.Exception.Message);
                }
            }
            # Else service is not running.
            else
            {
                # Write to log.
                Write-CustomLog -Message ("Service '{0}' is already stopped" -f $serviceName) -Level Verbose;
            }
        }
        # Something went wrong.
        catch
        {
            # Throw execption.
            throw ("Something went wrong while trying to stop the service dont exist. {1}" -f $serviceName, $_.Exception.Message);
        }
    }
    END
    {
        # Write to log.
        Write-CustomProgress -ProgressId $progressId -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Stopping CertSvc service' -Type 'End';
    }
}