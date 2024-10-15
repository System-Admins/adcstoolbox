function Get-CACertificateRequestDenied
{
    <#
    .SYNOPSIS
        Get denied requests.
    .DESCRIPTION
        Return array list of denied requests.
    .PARAMETER Date
        Date to get certificate up-to. Default is today.
    .EXAMPLE
        Get-CACertificateRequestDenied;
    .EXAMPLE
        Get-CACertificateRequestDenied -Date (Get-Date).AddDays(-30);
    #>
    [cmdletbinding()]
    [OutputType([System.Collections.ArrayList])]
    param
    (
        # Date to get denied requests up-to. Default is today.
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [ValidateScript({ $_ -le (Get-Date) })]
        [DateTime]$Date = (Get-Date)
    )

    BEGIN
    {
        # Write to log.
        $customProgress = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Getting denied requests from CA';

        # Arguments to be used with CertUtil.exe.
        [string]$certUtilArguments = '';

        # Object array for the failed requests.
        $deniedRequests = New-Object System.Collections.ArrayList;
    }
    PROCESS
    {
        # If date is set.
        if ($PSBoundParameters.ContainsKey('Date'))
        {
            # Contruct the arguments.
            $certUtilArguments = ('-view -restrict "Disposition=31,Request Submission Date < {0}" -out "RequestId,RequesterName,CommonName,CertificateTemplate,Certificate Expiration Date,CertificateHash,StatusCode,Request Submission Date,Request Disposition" csv' -f $Date.ToString("dd'/'MM'/'yyyy"));
        }
        # Else use default.
        else
        {
            # Contruct the arguments.
            $certUtilArguments = '-view -restrict "Disposition=31" -out "RequestId,RequesterName,CommonName,CertificateTemplate,Certificate Expiration Date,CertificateHash,StatusCode,Request Submission Date,Request Disposition" csv';
        }

        # Invoke certutil.
        $result = Invoke-CertUtil -Arguments $certUtilArguments;

        # Get the rows.
        [string[]]$rows = $result -split '\n';

        # Foreach row.
        foreach ($row in $rows)
        {
            # If row is empty.
            if ([string]::IsNullOrEmpty($row))
            {
                # Skip.
                continue;
            }

            # Skip first row.
            if ($row -like '"Issued Request ID"*')
            {
                # Skip.
                continue;
            }

            # Convert row from CSV to object.
            $csvData = $row | ConvertFrom-Csv -Header 'RequestId', 'RequesterName', 'CommonName', 'CertificateTemplate', 'ExpirationDate', 'CertificateHash', 'StatusCode', 'RequestSubmissionDate', 'RequestDisposition' -Delimiter ',';

            # Convert the expiration date to datetime.
            [datetime]$expirationDate = [datetime]$csvData.ExpirationDate;

            # Set the revocation date.
            $csvData.ExpirationDate = $expirationDate;

            # Convert the submission date to datetime.
            [datetime]$requestSubmissionDate = [datetime]$csvData.RequestSubmissionDate;

            # Set the submission date.
            $csvData.RequestSubmissionDate = $requestSubmissionDate;

            # Add the data to the object array.
            $null = $deniedRequests.Add($csvData);
        }

        # Write to log.
        Write-CustomLog -Message ('Found {0} failed request(s)' -f $deniedRequests.Count) -Level Verbose;
    }
    END
    {
        # Write to log.
        Write-CustomProgress @customProgress;

        # Return the failed requests.
        return $deniedRequests;
    }
}