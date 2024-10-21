function Get-CAConfigEntry
{
    <#
    .SYNOPSIS
        Get CA config entry.
    .DESCRIPTION
        Return value of the CA config entry.
    .EXAMPLE
        Get-CAConfigEntry;
    #>
    [cmdletbinding()]
    param
    (
        # Entry.
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Entry
    )

    BEGIN
    {
        # Write to log.
        $customProgress = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Get CA config entry';

        # Get the common name of the certificate authority.
        $caCommonName = Get-CACommonName;

        # Get hostname of the certificate authority.
        $hostname = $env:COMPUTERNAME

        # Construct CA config string.
        $caConfigString = ('{0}\{1}' -f $hostname, $caCommonName);
    }
    PROCESS
    {
        # Try to create a new instance of ICertAdmin2 interface.
        try
        {
            # Write to log.
            Write-CustomLog -Message ('Trying to instantiate ICertAdmin2 interface') -Level Verbose;

            # Instantiate ICertAdmin2 interface.
            $caAdmin = New-Object -ComObject CertificateAuthority.Admin;

            # Write to log.
            Write-CustomLog -Message ('Successfully instantiate ICertAdmin2 interface') -Level Verbose;
        }
        # Something went wrong.
        catch
        {
            # Throw exception.
            throw ('Failed to instantiate ICertAdmin2 interface. {0}' -f $_.Exception.Message);
        }

        # Get CA config entry.
        try
        {
            # Write to log.
            Write-CustomLog -Message ("Trying to get CA config entry '{0}'" -f $Entry) -Level Verbose;

            # Get the CA config entry value.
            $caConfigEntry = $caAdmin.GetConfigEntry($caConfigString, '', $Entry);

            # Write to log.
            Write-CustomLog -Message 'Successfully got the CA config entry' -Level Verbose;
        }
        catch
        {
            # Write to log.
            Write-CustomLog -Message ('Failed to get CA config entry. Error: {0}' -f $_.Exception.Message) -Level Error;

            # Exit script.
            exit 1;
        }
    }
    END
    {
        # Write to log.
        Write-CustomProgress @customProgress;

        # Return the CA config entry value.
        return $caConfigEntry;
    }
}