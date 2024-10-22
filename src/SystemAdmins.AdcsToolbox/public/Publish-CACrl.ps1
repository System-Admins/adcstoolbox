function Publish-CACrl
{
    <#
    .SYNOPSIS
        Publish the certificate revocation list.
    .DESCRIPTION
        Return nothing.
    .EXAMPLE
        Publish-CACrl;
    #>
    [cmdletbinding()]
    [OutputType([void])]
    param
    (
    )

    BEGIN
    {
        # Write to log.
        $customProgress = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Publish certificate authority CRL';

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

        # Try to publish CRL.
        try
        {
            # Write to log.
            Write-CustomLog -Message 'Trying to publish CRL' -Level Verbose;

            # Publish the CRL.
            $null = $caAdmin.PublishCRL($caConfigString, 0);

            # Write to log.
            Write-CustomLog -Message 'Successfully published the CRL' -Level Verbose;

            # Write to event log.
            Write-CustomEventLog -EventId 61;
        }
        catch
        {
            # Write to event log.
            Write-CustomEventLog -EventId 63;

            # Write to log.
            Write-CustomLog -Message ('Failed to publish CRL. Error: {0}' -f $_.Exception.Message) -Level Error;

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