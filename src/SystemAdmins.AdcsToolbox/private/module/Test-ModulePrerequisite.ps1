function Test-ModulePrerequisite
{
    <#
    .SYNOPSIS
        Test if all prerequisites are fulfilled.
    .DESCRIPTION
        Return nothing if all prerequisites are fulfilled.
    .EXAMPLE
        Test-ModulePrerequisite;
    #>
    [cmdletbinding()]
    [OutputType([void])]
    param
    (
    )

    BEGIN
    {
        # Write to log.
        $progressId = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Check if module prerequisites are fulfilled' -Type 'Begin';
    }
    PROCESS
    {
        # Get the operating system.
        $operatingSystem = Get-OperatingSystem;

        # If the operating system is not Windows.
        if ($operatingSystem -ne 'Windows')
        {
            # Throw execption.
            throw ("The operating system is '{0}', aborting" -f $operatingSystem);

            # Exit script.
            exit 1;
        }

        # Get the Windows edition.
        $windowsEdition = Get-WindowsEdition;

        # If the Windows edition is not Windows Server.
        if ($windowsEdition.Edition -notlike '*Windows Server*')
        {
            # Throw execption.
            throw ("Not running Windows Server, the host is running '{0}', aborting" -f $windowsEdition.Edition);

            # Exit script.
            exit 1;
        }

        # Test if the current user is a local administrator.
        $isLocalAdmin = Test-LocalAdmin;

        # If the current user is not a local administrator.
        if ($false -eq $isLocalAdmin)
        {
            # Throw execption.
            throw ('The current user is not a local administrator, aborting');

            # Exit script.
            exit 1;
        }

        # Test if the certificate utility is available.
        $isCertUtilAvailable = Test-CertUtil;

        # If the certificate utility is not available.
        if ($false -eq $isCertUtilAvailable)
        {
            # Throw execption.
            throw ('The certificate utility (certutil.exe) is not available, aborting');

            # Exit script.
            exit 1;
        }

        # Test if the Extensible Storage Engine utility is available.
        $isEseUtiltyAvailable = Test-EsentUtl;

        # If the Extensible Storage Engine utility is not available.
        if ($false -eq $isEseUtiltyAvailable)
        {
            # Throw execption.
            throw ('The Extensible Storage Engine utility (esentutl.exe) is not available, aborting');

            # Exit script.
            exit 1;
        }

        # Test if the Active Directory Certificate Services role is installed.
        $isCertSvcInstalled = Test-CAInstalled;

        # If the Active Directory Certificate Services role is not installed.
        if ($false -eq $isCertSvcInstalled)
        {
            # Throw execption.
            throw ('The Active Directory Certificate Services role is not installed on this host, aborting');

            # Exit script.
            exit 1;
        }

        # Test if the required modules are installed.
        $isModuleDependency = Get-ModuleDependency;

        # If the required modules are not installed.
        if ($false -eq $isModuleDependency)
        {
            # Throw execption.
            throw ('The required PowerShell modules are not installed, aborting');

            # Exit script.
            exit 1;
        }
    }
    END
    {
        # Write to log.
        Write-CustomProgress -ProgressId $progressId -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Check if module prerequisites are fulfilled' -Type 'End';
    }
}