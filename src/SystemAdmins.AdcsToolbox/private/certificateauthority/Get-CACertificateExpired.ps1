function Get-CACertificateExpired
{
    <#
    .SYNOPSIS
        Get expired certificates.
    .DESCRIPTION
        Return array list of expired certificates.
    .EXAMPLE
        Get-CACertificateExpired;
    #>
    [cmdletbinding()]
    [OutputType([string])]
    param
    (
        # Date to get expired certificates up-to. Default is today.
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [ValidateScript({ $_ -le (Get-Date) })]
        [DateTime]$ExpireDate = (Get-Date)
    )

    BEGIN
    {
        # Write to log.
        $progressId = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Getting expired certificates from CA' -Type 'Start';

        # Arguments to be used with CertUtil.exe.
        [string]$certUtilArguments = '';

        # Object array for the expired certificates.
        $expiredCertificates = New-Object System.Collections.ArrayList;
    }
    PROCESS
    {
        # If date is set.
        if ($null -ne $ExpireDate)
        {
            # Contruct the arguments.
            $certUtilArguments = ('-view -restrict "Certificate Expiration Date < {0}" -out "RequestId,RequesterName,CommonName,CertificateTemplate,Certificate Expiration Date,CertificateHash,StatusCode" csv' -f $ExpireDate.ToString("dd'/'MM'/'yyyy"));
        }
        # Else use default.
        else
        {
            # Contruct the arguments.
            $certUtilArguments = '-view -restrict "Certificate Expiration Date < NOW" -out "RequestId,RequesterName,CommonName,CertificateTemplate,Certificate Expiration Date,CertificateHash,StatusCode" csv';
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
            $csvData = $row | ConvertFrom-Csv -Header 'RequestId', 'RequesterName', 'CommonName', 'CertificateTemplate', 'ExpirationDate', 'CertificateHash', 'StatusCode' -Delimiter ',';

            # Add the data to the object array.
            $null = $expiredCertificates.Add($csvData);
        }

        # Write to log.
        Write-CustomLog -Message ('Found {0} expired certificate(s)' -f $expiredCertificates.Count) -Level Verbose;
    }
    END
    {
        # Write to log.
        Write-CustomProgress -Id $progressId -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Getting expired certificates from CA' -Type 'End';

        # Return the expired certificates.
        return $expiredCertificates;
    }
}