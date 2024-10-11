function Get-ModuleDependency
{
    <#
    .SYNOPSIS
        Test and import if required modules is installed.
    .DESCRIPTION
        Return true or false.
    .PARAMETER Modules
        Required modules.
    .EXAMPLE
        Get-ModuleDependency -Modules 'ADCSAdministration', 'ADCSDeployment';
    #>
    [cmdletbinding()]
    [OutputType([bool])]
    param
    (
        # Required modules.
        [Parameter(Mandatory = $false)]
        [string[]]$Modules = @(
            'ADCSAdministration',
            'ADCSDeployment'
        )
    )

    BEGIN
    {
        # Write to log.
        $progressId = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Check if required modules are installed' -Type 'Begin';

        # Boolean to return.
        [bool]$isValid = $true;
    }
    PROCESS
    {
        # Foreach module.
        foreach ($module in $Modules)
        {
            # Try to get module.
            $moduleInstalled = Get-Module -Name $module -ListAvailable;

            # If the module isnt available.
            if ($null -eq $moduleInstalled)
            {
                # Write to log.
                Write-CustomLog -Message ("Module '{0}' is not available" -f $module) -Level Verbose;

                # Set boolean to false.
                $isValid = $false;
            }
            # Else module is available.
            else
            {
                # Write to log.
                Write-CustomLog -Message ("Module '{0}' is available" -f $module) -Level Verbose;

                # Import module.
                Import-Module -Name $module;
            }
        }
    }
    END
    {
        # Write to log.
        Write-CustomProgress -ProgressId $progressId -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Check if required modules are installed' -Type 'End';

        # Return boolean.
        return $isValid;
    }
}