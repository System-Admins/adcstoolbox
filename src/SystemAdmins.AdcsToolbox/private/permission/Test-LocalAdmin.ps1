function Test-LocalAdmin
{
    <#
    .SYNOPSIS
        Test if the current user is a local administrator.
    .DESCRIPTION
        Test if the current user is a member of the local "administrators" group.
    .EXAMPLE
        Test-IsLocalAdmin;
    #>
    [cmdletbinding()]
    [OutputType([bool])]
    param
    (
    )

    BEGIN
    {
        # Write to log.
        $progressId = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Testing if the current user is a local administrator' -Type 'Begin';

        # Boolean to check if the user is a local admin.
        [bool]$isLocalAdmin = $false;

        # Get the current user.
        [Security.Principal.WindowsIdentity]$currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent();
    }
    PROCESS
    {
        # Is running as administrator.
        if (($currentIdentity).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator'))
        {
            # Write to log.
            Write-CustomLog -Message ('The current user is a local administrator') -Level Verbose;

            # Set valid.
            $isLocalAdmin = $true;
        }
        # Else not running as administrator.
        else
        {
            # Write to log.
            Write-CustomLog -Message ('The current user is not a local administrator') -Level Verbose;
        }
    }
    END
    {
        # Write to log.
        Write-CustomProgress -ProgressId $progressId -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Testing if the current user is a local administrator' -Type 'End';

        # Return bool.
        return $isLocalAdmin;
    }
}