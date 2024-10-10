function Test-CAInstalled
{
    <#
    .SYNOPSIS
        Test if the CertSvc role is installed.
    .DESCRIPTION
        Return true or false.
    .EXAMPLE
        Test-CAInstalled;
    #>
    [cmdletbinding()]
    [OutputType([pscustomobject])]
    param
    (
    )

    BEGIN
    {
        # Write to log.
        $progressId = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Check if CertSvc is installed' -Type 'Begin';

        # Boolean to return.
        [bool]$isInstalled = $false;
    }
    PROCESS
    {
        # Get Windows feature.
        $adcsCertAuthority = Get-WindowsFeature -Name ADCS-Cert-Authority;

        # If the role is installed.
        if ($true -eq $adcsCertAuthority.Installed)
        {
            # Write to log.
            Write-CustomLog -Message 'CertSvc role is installed' -Level Verbose;

            # Set boolean to true.
            $isInstalled = $true;
        }
        # Else the role is not installed.
        else
        {
            # Write to log.
            Write-CustomLog -Message 'CertSvc role is not installed' -Level Verbose;
        }
    }
    END
    {
        # Write to log.
        Write-CustomProgress -ProgressId $progressId -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Check if CertSvc is installed' -Type 'End';

        # Return boolean.
        return $isInstalled;
    }
}