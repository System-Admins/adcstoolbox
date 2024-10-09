function Get-CertSvcService
{
    <#
    .SYNOPSIS
        Get the CertSvc service.
    .DESCRIPTION
        Returns "Running" or "Stopped".
    .EXAMPLE
        Get-CertSvcService;
    #>
    [cmdletbinding()]
    [OutputType([string])]
    param
    (
    )

    BEGIN
    {
        # Write to log.
        $progressId = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Getting CertSvc service status' -Type 'Begin';

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
            # Throw execption.
            throw ("Service '{0}' dont exist. {1}" -f $serviceName, $_.Exception.Message);
        }
    }
    END
    {
        # Write to log.
        Write-CustomProgress -ProgressId $progressId -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Getting CertSvc service status' -Type 'End';

        # Return status.
        return [string]$service.Status;
    }
}