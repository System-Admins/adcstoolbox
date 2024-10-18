function Wait-CAService
{
    <#
    .SYNOPSIS
        Wait for the CertSvc service until Stopped or Running.
    .DESCRIPTION
        Returns true or false.
    .EXAMPLE
        Wait-CAService;
    #>
    [cmdletbinding()]
    [OutputType([bool])]
    param
    (
        # Number of times to check before exiting threshold.
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$WaitLimit = 20,

        # State to wait for.
        [Parameter(Mandatory = $true)]
        [ValidateSet('Running', 'Stopped')]
        [string]$State
    )

    BEGIN
    {
        # Write to log.
        $customProgress = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Waiting on CertSvc service';

        # Try counter.
        $tryCount = 0;

        # Boolean to check if the service is in the desired state.
        [bool]$targetState = $false;
    }
    PROCESS
    {
        # Loop until the service is in the desired state.
        while ($false -eq $targetState)
        {
            # Increment try counter.
            $tryCount++;

            # Write to log.
            Write-CustomLog -Message ("Waiting for CertSvc status to be '{0}'. This is run number {1} out of {2}" -f $State, $tryCount, $WaitLimit) -Level Verbose;

            # Get the service status.
            $serviceStatus = Get-CAService;

            # Check if the service is in the desired state.
            if ($serviceStatus -eq $State)
            {
                # Write to log.
                Write-CustomLog -Message ("CertSvc status is now '{0}'" -f $serviceStatus) -Level Verbose;

                # Set the target state to true.
                $targetState = $true;
            }
            # Else service is not in desired state.
            else
            {
                # Wait for 5 seconds before checking again.
                Start-Sleep -Seconds 5;

                # Write to log.
                Write-CustomLog -Message ("CertSvc status is not ready, status is '{0}'. Waiting 5 seconds before getting status again" -f $serviceStatus) -Level Verbose;
            }

            # If the try counter is greater than the wait limit, exit the loop.
            if ($tryCount -ge $WaitLimit)
            {
                # Write to log.
                Write-CustomLog -Message ("CertSvc status is still '{0}' after {1} tries. Aborting the wait" -f $serviceStatus.Status, $tryCount) -Level Verbose;

                # Exit the loop.
                break;
            }
        }
    }
    END
    {
        # Write to log.
        Write-CustomProgress @customProgress;

        # Return the target state.
        return $targetState;
    }
}