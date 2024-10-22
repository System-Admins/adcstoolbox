function Set-CAConfigEntry
{
    <#
    .SYNOPSIS
        Set CA config entry.
    .DESCRIPTION
        Return nothing.
    .EXAMPLE
        Set-CAConfigEntry;
    #>
    [cmdletbinding()]
    [OutputType([void])]
    param
    (
        # Entry.
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Entry,

        # Entry value.
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $EntryValue
    )

    BEGIN
    {
        # Write to log.
        $customProgress = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Set CA config entry';

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

        # Set CA config entry.
        try
        {
            # Write to log.
            Write-CustomLog -Message ("Trying to set CA config entry '{0}' to '{1}'" -f $Entry, $EntryValue) -Level Verbose;

            # Set the CA config entry value.
            $null = $caAdmin.SetConfigEntry($caConfigString, '', $Entry, $EntryValue);

            # Write to log.
            Write-CustomLog -Message 'Successfully set the CA config entry' -Level Verbose;
        }
        catch
        {
            # Write to log.
            Write-CustomLog -Message ('Failed to set CA config entry. Error: {0}' -f $_.Exception.Message) -Level Error;

            # Exit script.
            exit 1;
        }
    }
    END
    {
        # Write to log.
        Write-CustomProgress @customProgress;
    }
}