function Get-CACertificateRevoked
{
    <#
    .SYNOPSIS
        Get revoked certificates.
    .DESCRIPTION
        Return array list of revoked certificates.
    .PARAMETER Date
        Date to get certificate up-to. Default is today.
    .EXAMPLE
        Get-CACertificateRevoked;
    .EXAMPLE
        Get-CACertificateRevoked -Date (Get-Date).AddDays(-30);
    #>
    [cmdletbinding()]
    [OutputType([System.Collections.ArrayList])]
    param
    (
        # Date to get revoked certificates up-to. Default is today.
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [ValidateScript({ $_ -le (Get-Date) })]
        [DateTime]$Date = (Get-Date)
    )

    BEGIN
    {
        # Write to log.
        $progressId = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Getting expired certificates from CA' -Type 'Begin';

        # Arguments to be used with CertUtil.exe.
        $certUtilArguments = ('-view -restrict "Disposition=21" -out "RequestId,RequesterName,CommonName,CertificateTemplate,Certificate Expiration Date,CertificateHash,StatusCode,Revocation Reason,Revocation Date" csv');

        # Object array for the revoked certificates.
        $revokedCertificates = New-Object System.Collections.ArrayList;

        # Hash table over revoked reasons.
        $revocationReasons = @{
            0  = 'Unspecified';
            1  = 'Key Compromise';
            2  = 'CA Compromise';
            3  = 'Affiliation Changed';
            4  = 'Superseded';
            5  = 'Cessation of Operation';
            6  = 'Certificate Hold';
            8  = 'Remove From CRL';
            -1 = 'Unrevoke';
        };
    }
    PROCESS
    {
        # If date is set.
        if ($PSBoundParameters.ContainsKey('Date'))
        {
            # Contruct the arguments.
            $certUtilArguments = ('-view -restrict "Disposition=21,Revocation Date < {0}" -out "RequestId,RequesterName,CommonName,CertificateTemplate,Certificate Expiration Date,CertificateHash,StatusCode,Revocation Reason,Revocation Date" csv' -f $Date.ToString("dd'/'MM'/'yyyy"));
        }
        # Else use default.
        else
        {
            # Contruct the arguments.
            $certUtilArguments = '-view -restrict "Disposition=21" -out "RequestId,RequesterName,CommonName,CertificateTemplate,Certificate Expiration Date,CertificateHash,StatusCode,Revocation Reason,Revocation Date" csv';
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
            $csvData = $row | ConvertFrom-Csv -Header 'RequestId', 'RequesterName', 'CommonName', 'CertificateTemplate', 'ExpirationDate', 'CertificateHash', 'StatusCode', 'RevocationReason', 'RevocationDate' -Delimiter ',';

            # If revocation reason is set.
            if ($null -ne $csvData.RevocationReason)
            {
                # Split the revocation reason using regex.
                $revocationReason = [int]($csvData.RevocationReason -split ' ' | Select-Object -First 1);

                # Get the revocation reason.
                $csvData.RevocationReason = [PSCustomObject]@{
                    Id     = $revocationReason;
                    Reason = $revocationReasons[$revocationReason];
                };
            }

            # Convert the expiration date to datetime.
            [datetime]$expirationDate = [datetime]$csvData.ExpirationDate;

            # Set the revocation date.
            $csvData.ExpirationDate = $expirationDate;

            # Convert the revocation date to datetime.
            [datetime]$revocationDate = [datetime]$csvData.RevocationDate;

            # Set the revocation date.
            $csvData.RevocationDate = $revocationDate;

            # Add the data to the object array.
            $null = $revokedCertificates.Add($csvData);
        }

        # Write to log.
        Write-CustomLog -Message ('Found {0} revoked certificate(s)' -f $revokedCertificates.Count) -Level Verbose;
    }
    END
    {
        # Write to log.
        Write-CustomProgress -ProgressId $progressId -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Getting revoked certificates from CA' -Type 'End';

        # Return the revoked certificates.
        return $revokedCertificates;
    }
}