function Test-EntrustSecurityWorldInstalled
{
    <#
    .SYNOPSIS
        Test if the Entrust Security World Software is installed.
    .DESCRIPTION
        Return true or false.
    .EXAMPLE
        Test-EntrustSecurityWorldInstalled;
    #>
    [cmdletbinding()]
    [OutputType([bool])]
    param
    (
    )

    BEGIN
    {
        # Write to log.
        $customProgress = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Check if Entrust Security World Software is installed';

        # Boolean to return.
        [bool]$isInstalled = $false;
    }
    PROCESS
    {
        # If the software is installed.
        if ($null -eq $env:NFAST_KMDATA)
        {
            # Write to log.
            Write-CustomLog -Message 'Entrust Security World Software is installed' -Level Verbose;

            # Test if the folder exist.
            if (Test-Path -Path $env:NFAST_KMDATA)
            {
                # Write to log.
                Write-CustomLog -Message ("Security World data folder '{0}' exist" -f $env:NFAST_KMDATA) -Level Verbose;

                # Set boolean to true.
                $isInstalled = $true;
            }
        }
        # Else the role is not installed.
        else
        {
            # Write to log.
            Write-CustomLog -Message 'Entrust Security World Software is not installed' -Level Verbose;

            # Write to event log.
            Write-CustomEventLog -EventId 151;
        }
    }
    END
    {
        # Write to log.
        Write-CustomProgress @customProgress;

        # Return boolean.
        return $isInstalled;
    }
}