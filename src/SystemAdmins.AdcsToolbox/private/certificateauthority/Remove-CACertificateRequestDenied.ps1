function Remove-CACertificateRequestDenied
{
    <#
    .SYNOPSIS
        Remove denied certificate requests.
    .DESCRIPTION
        This will remove ADCS denied requests that are submitted up to a certain date.
    .PARAMETER Date
        Date to remove denied certificate requests up-to. Default is today.
    .PARAMETER Limit
        Limit the number of requests to remove.
    .EXAMPLE
        Remove-CACertificateExpired -Limit 100;
    .EXAMPLE
        Remove-CACertificateExpired -Date (Get-Date).AddDays(-30) -Limit 100;
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([string])]
    param
    (
        # Date to remove denied requests up-to. Default is today.
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [ValidateScript({ $_ -le (Get-Date) })]
        [DateTime]$Date = (Get-Date),

        # Limit the number of requests to remove.
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [int]$Limit = 150000
    )

    BEGIN
    {
        # Write to log.
        $progressId = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Removing denied requests from CA' -Type 'Begin';

        # Arguments to be used with CertUtil.exe.
        [string]$certUtilArguments = '';

        # If date is set.
        if ($PSBoundParameters.ContainsKey('Date'))
        {
            # Get denied requests.
            $deniedRequests = Get-CACertificateRequestDenied -Date $Date;
        }
        # Else use default.
        else
        {
            # Get denied requests.
            $deniedRequests = Get-CACertificateRequestDenied;
        }

        # Array list for removed requests.
        [System.Collections.ArrayList]$removedRequests = New-Object System.Collections.ArrayList;
    }
    PROCESS
    {
        # Foreach denied request.
        foreach ($deniedRequest in $deniedRequests)
        {
            # If limit is reached.
            if ($removedRequests.Count -gt $Limit)
            {
                # Write to log.
                Write-CustomLog -Message ('Limit of {0} request removal reached' -f $Limit) -Level Verbose;

                # Stop function.
                break;
            }

            # Create arguments.
            [string]$certutilArguments = ('-deleterow {0}' -f $deniedRequest.RequestId);

            # If whatif is not set.
            if ($PSCmdlet.ShouldProcess($deniedRequest.RequestId, 'Removing denied request'))
            {
                # Write to log.
                Write-CustomLog -Message ("Removing denied request with id '{0}'" -f $deniedRequest.RequestId) -Level Verbose;

                # Try to remove the certificate.
                try
                {
                    # Remove denied request.
                    $null = Invoke-CertUtil -Arguments $certutilArguments -ErrorAction Stop;

                    # Add to remoed requests.
                    $null = $removedRequests.Add($deniedRequest);

                    # Write to log.
                    Write-CustomLog -Message ("Succesfully removed denied request with id '{0}'" -f $deniedRequest.RequestId) -Level Verbose;

                    # Write to event log.
                    Write-CustomEventLog -EventId 123 -AdditionalMessage ("Request ID '{0}'" -f $expiredCertificate.RequestId);
                }
                # Something went wrong.
                catch
                {
                    # Write to event log.
                    Write-CustomEventLog -EventId 126 -AdditionalMessage ("Request ID '{0}'" -f $expiredCertificate.RequestId);

                    # Write to log.
                    Write-CustomLog -Message ("Failed to remove denied request with id '{0}'. {1}" -f $deniedRequest.RequestId, $_.Exception.Message) -Level Warning;
                }
            }
            # Else whatif is set.
            else
            {
                # Continue to next request.
                continue;
            }
        }
    }
    END
    {
        # Write to log.
        Write-CustomProgress -ProgressId $progressId -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Removing denied requests from CA' -Type 'End';

        # Return the removed requests.
        return $removedRequests;
    }
}