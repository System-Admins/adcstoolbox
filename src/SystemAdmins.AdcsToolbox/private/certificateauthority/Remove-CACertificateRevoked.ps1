function Remove-CACertificateRevoked
{
    <#
    .SYNOPSIS
        Remove revoked certificates.
    .DESCRIPTION
        This will remove revoked ADCS certificates that are expired up to a certain date.
    .PARAMETER Date
        Date to remove revoked certificates up-to. Default is today.
    .PARAMETER Limit
        Limit the number of certificates to remove.
    .EXAMPLE
        Remove-CACertificateExpired -Limit 100;
        .EXAMPLE
        Remove-CACertificateExpired -Date (Get-Date).AddDays(-30) -Limit 100;
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([string])]
    param
    (
        # Date to remove expired certificates up-to. Default is today.
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [ValidateScript({ $_ -le (Get-Date) })]
        [DateTime]$RevokedDate = (Get-Date),

        # Limit the number of certificates to remove.
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [int]$Limit = 150000
    )

    BEGIN
    {
        # Write to log.
        $progressId = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Removing revoked certificates from CA' -Type 'Begin';

        # Arguments to be used with CertUtil.exe.
        [string]$certUtilArguments = '';

        # If date is set.
        if ($PSBoundParameters.ContainsKey('RevokedDate'))
        {
            # Get revoked certificates.
            $revokedCertificates = Get-CACertificateRevoked -Date $RevokedDate;
        }
        # Else use default.
        else
        {
            # Get revoked certificates.
            $revokedCertificates = Get-CACertificateRevoked;
        }

        # Array list for removed certificates.
        [System.Collections.ArrayList]$removedCertificates = New-Object System.Collections.ArrayList;
    }
    PROCESS
    {
        # Foreach revoked certificate.
        foreach ($revokedCertificate in $revokedCertificates)
        {
            # If limit is reached.
            if ($removedCertificates.Count -gt $Limit)
            {
                # Write to log.
                Write-CustomLog -Message ('Limit of {0} certificates removal reached' -f $Limit) -Level Verbose;

                # Stop function.
                break;
            }

            # Create arguments.
            [string]$certutilArguments = ('-deleterow {0}' -f $revokedCertificate.RequestId);

            # If whatif is not set.
            if ($PSCmdlet.ShouldProcess($revokedCertificate.RequestId, 'Removing revoked certificate'))
            {
                # Write to log.
                Write-CustomLog -Message ("Removing revoked  certificate with id '{0}'" -f $revokedCertificate.RequestId) -Level Verbose;

                # Try to remove the certificate.
                try
                {
                    # Remove expired certificate.
                    $null = Invoke-CertUtil -Arguments $certutilArguments -ErrorAction Stop;

                    # Add to removed certificates.
                    $null = $removedCertificates.Add($revokedCertificate);

                    # Write to log.
                    Write-CustomLog -Message ("Succesfully removed revoked  certificate with id '{0}'" -f $revokedCertificate.RequestId) -Level Verbose;
                }
                # Something went wrong.
                catch
                {
                    # Write to log.
                    Write-CustomLog -Message ("Failed to remove revoked  certificate with id '{0}'. {1}" -f $revokedCertificate.RequestId, $_.Exception.Message) -Level Warning;
                }
            }
            # Else whatif is set.
            else
            {
                # Continue to next certificate.
                continue;
            }
        }
    }
    END
    {
        # Write to log.
        Write-CustomProgress -ProgressId $progressId -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Removing revoked certificates from CA' -Type 'End';

        # Return the removed certificates.
        return $removedCertificates;
    }
}