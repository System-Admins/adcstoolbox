function Get-ModuleDependency
{
    <#
    .SYNOPSIS
        Test if required modules is installed.
    .DESCRIPTION
        Return true or false.
    .EXAMPLE
        Get-ModuleDependency;
    #>
    [cmdletbinding()]
    [OutputType([bool])]
    param
    (
    )

    BEGIN
    {
        # Write to log.
        $progressId = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Check if required modules are installed' -Type 'Start';

        # Modules to check.
        $modules = @(
            'ADCSAdministration',
            'ADCSDeployment'
        );

        # Boolean to return.
        [bool]$isValid = $true;
    }
    PROCESS
    {
        # Foreach module.
        foreach ($module in $modules)
        {
            # Try to get module.
            $moduleInstalled = Get-Module -Name $module -ListAvailable;

            # If the module isnt available.
            if ($null -eq $moduleInstalled)
            {
                # Write to log.
                Write-CustomLog -Message ("Module '{0}' is not available" -f $module);

                # Set boolean to false.
                $isValid = $false;
            }
        }
    }
    END
    {
        # Write to log.
        Write-CustomProgress -Id $progressId -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Check if required modules are installed' -Type 'End';

        # Return boolean.
        return $isValid;
    }
}