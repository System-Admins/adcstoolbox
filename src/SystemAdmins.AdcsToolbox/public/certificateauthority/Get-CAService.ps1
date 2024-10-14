function Get-CAService
{
    <#
    .SYNOPSIS
        Get the CertSvc service.
    .DESCRIPTION
        Returns "Running" or "Stopped".
    .EXAMPLE
        Get-CAService;
    #>
    [cmdletbinding()]
    [OutputType([string])]
    param
    (
    )

    BEGIN
    {
        # Write to log.
        $customProgress = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Getting CertSvc service status';

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

            # Write to log.
            Write-CustomLog -Message ("Service is '{0}'" -f $service.Status) -Level Verbose;
        }
        # Something went wrong.
        catch
        {
            # Write to event log.
            Write-CustomEventLog -EventId 31;

            # Throw execption.
            throw ("Service '{0}' dont exist. {1}" -f $serviceName, $_.Exception.Message);
        }
    }
    END
    {
        # Write to log.
        Write-CustomProgress @customProgress;

        # Return status.
        return [string]$service.Status;
    }
}