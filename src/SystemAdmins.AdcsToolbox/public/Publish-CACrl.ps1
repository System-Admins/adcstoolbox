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

        # CertUtil argument.
        [string]$certUtilArguments = '-crl';
    }
    PROCESS
    {
        # Write to log.
        Write-CustomLog -Message "Publishing CRL" -Level Verbose;

        # Invoke certutil.
        $result = Invoke-CertUtil -Arguments $certUtilArguments;

        # Write to event log.
        Write-CustomEventLog -EventId 61;
    }
    END
    {
        # Write to log.
        Write-CustomProgress @customProgress;
    }
}