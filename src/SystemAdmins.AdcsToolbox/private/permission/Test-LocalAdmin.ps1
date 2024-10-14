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
        $customProgress = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Testing if the current user is a local administrator';

        # Boolean to check if the user is a local admin.
        [bool]$isLocalAdmin = $false;
    }
    PROCESS
    {
        # Is running as administrator.
        if (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator'))
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

            # Write to event log.
            Write-CustomEventLog -EventId 91;
        }
    }
    END
    {
        # Write to log.
        Write-CustomProgress @customProgress;

        # Return bool.
        return $isLocalAdmin;
    }
}