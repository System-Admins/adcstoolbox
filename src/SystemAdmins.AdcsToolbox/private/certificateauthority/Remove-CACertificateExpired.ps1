function Remove-CACertificateExpired
{
    <#
    .SYNOPSIS
        Remove expired certificates.
    .DESCRIPTION
        This will remove expired ADCS certificates that are expired up to a certain date.
    .PARAMETER Date
        Date to remove expired certificates up-to. Default is today.
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
        [DateTime]$ExpireDate = (Get-Date),

        # Limit the number of certificates to remove.
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [int]$Limit = 150000,

        # Path for exporting the removed certificates.
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ExportPath = 'C:\Temp\RemovedCertificates.csv'
    )

    BEGIN
    {
        # Write to log.
        $customProgress = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Removing expired certificates from CA';

        # Arguments to be used with CertUtil.exe.
        [string]$certUtilArguments = '';

        # If date is set.
        if ($PSBoundParameters.ContainsKey('ExpireDate'))
        {
            # Get expired certificates.
            $expiredCertificates = Get-CACertificateExpired -Date $ExpireDate;
        }
        # Else use default.
        else
        {
            # Get expired certificates.
            $expiredCertificates = Get-CACertificateExpired;
        }

        # Array list for removed certificates.
        [System.Collections.ArrayList]$removedCertificates = New-Object System.Collections.ArrayList;
    }
    PROCESS
    {
        # Foreach expired certificate.
        foreach ($expiredCertificate in $expiredCertificates)
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
            [string]$certutilArguments = ('-deleterow {0}' -f $expiredCertificate.RequestId);

            # If whatif is not set.
            if ($PSCmdlet.ShouldProcess($expiredCertificate.RequestId, 'Removing expired certificate'))
            {
                # Write to log.
                Write-CustomLog -Message ("Removing expired certificate with id '{0}'" -f $expiredCertificate.RequestId) -Level Verbose;

                # Try to remove the certificate.
                try
                {
                    # Remove expired certificate.
                    $null = Invoke-CertUtil -Arguments $certutilArguments -ErrorAction Stop;

                    # Add to removed certificates.
                    $null = $removedCertificates.Add($expiredCertificate);

                    # Write to event log.
                    Write-CustomEventLog -EventId 121 -AdditionalMessage ("Request ID '{0}'" -f $expiredCertificate.RequestId);

                    # Write to log.
                    Write-CustomLog -Message ("Succesfully removed expired certificate with id '{0}'" -f $expiredCertificate.RequestId) -Level Verbose;
                }
                # Something went wrong.
                catch
                {
                    # Write to event log.
                    Write-CustomEventLog -EventId 125 -AdditionalMessage ("Request ID '{0}'" -f $expiredCertificate.RequestId);

                    # Write to log.
                    Write-CustomLog -Message ("Failed to remove expired certificate with id '{0}'. {1}" -f $expiredCertificate.RequestId, $_.Exception.Message) -Level Warning;
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
        Write-CustomProgress @customProgress;

        # Return the removed certificates.
        return $removedCertificates;
    }
}