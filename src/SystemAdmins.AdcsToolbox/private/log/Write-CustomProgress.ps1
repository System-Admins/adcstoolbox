function Write-CustomProgress
{
    <#
    .SYNOPSIS
        Write progress to the screen.
    .DESCRIPTION
        Wrap Write-Progress used in the module.
    .PARAMETER Activity
        Name of the activity.
    .PARAMETER CurrentOperation
        Current operation.
    .PARAMETER Type
        Start or end.
    .EXAMPLE
        $progress = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Getting all certificate' -Type 'Start';
        Write-CustomProgress -Id $progress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Getting all certificate' -Type 'End';

    #>
    [cmdletbinding()]
    [OutputType([int])]
    param
    (
        # Name of the function.
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Activity = $MyInvocation.MyCommand.Name,

        # Current operation.
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$CurrentOperation,

        # Start or end.
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('Start', 'End')]
        [string]$Type,

        # Id of the progress.
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$Id = (Get-Random -Minimum 0 -Maximum ([int]::MaxValue))
    )

    BEGIN
    {
    }
    PROCESS
    {
        # If type is "Start".
        if ($Type -eq 'Start')
        {
            # Write to log.
            Write-CustomLog -Message ("Starting processing '{0}' with ID '{1}'" -f $Activity, $Id) -Level Verbose;

            # Write progress.
            Write-Progress -Id $Id -Activity $Activity -CurrentOperation $CurrentOperation;
        }
        # Else if type is "End".
        else
        {
            # Write progress.
            Write-Progress -Id $Id -Activity $Activity -CurrentOperation $CurrentOperation -Completed;

            # Write to log.
            Write-CustomLog -Message ("Ending process '{0}' with ID '{1}'" -f $Activity, $Id) -Level Verbose;
        }
    }
    END
    {
        # If type is "Start".
        if ($Type -eq 'Start')
        {
            # Return id.
            return $Id;
        }
    }
}