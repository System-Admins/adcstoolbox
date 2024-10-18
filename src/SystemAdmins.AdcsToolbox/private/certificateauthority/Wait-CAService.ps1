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
        [boo]$targetState = $false;
    }
    PROCESS
    {
        # Loop until the service is in the desired state.
        while ($false -eq $targetState)
        {
            # Increment try counter.
            $tryCount++;

            # Write to log.
            Write-CustomLog -Message ("Waiting for CertSvc status to be '{0}'. This is run number {1}" -f $State, $tryCount) -Level Verbose;

            # Get the service status.
            $serviceStatus = Get-CAService;

            # Check if the service is in the desired state.
            if ($serviceStatus.Status -eq $State)
            {
                # Write to log.
                Write-CustomLog -Message ("CertSvc status is now '{0}'" -f $serviceStatus.Status) -Level Verbose;

                # Set the target state to true.
                $targetState = $true;
            }

            # If the try counter is greater than the wait limit, exit the loop.
            if ($tryCount -ge $WaitLimit)
            {
                # Write to log.
                Write-CustomLog -Message ("CertSvc status is still '{0}' after {1} tries. Aborting the wait" -f $serviceStatus.Status, $tryCount) -Level Verbose;

                # Exit the loop.
                break;
            }

            # Wait for 5 seconds before checking again.
            Start-Sleep -Seconds 5;
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