function Get-CACertificate
{
    <#
    .SYNOPSIS
        Get certificate/request from certificate authority.
    .DESCRIPTION
        Return list of certificates/requests.
    .PARAMETER State
        State of certificate/request (revoked, expired, denied, failed).
    .PARAMETER Date
        Date to get certificate up-to. Default is today.
    .EXAMPLE
        Get-CACertificate -State 'Revoked';
    .EXAMPLE
        Get-CACertificate -State 'Revoked' -Date (Get-Date).AddDays(-30);

    #>
    [cmdletbinding()]
    [OutputType([System.Collections.ArrayList])]
    param
    (
        # State of certificate/request (revoked, expired, denied, failed).
        [Parameter(Mandatory = $false)]
        [ValidateSet('Revoked', 'Expired', 'Denied', 'Failed')]
        [string]$State,

        # Date to get certificate up-to. Default is today.
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [ValidateScript({ $_ -le (Get-Date) })]
        [DateTime]$Date = (Get-Date)
    )

    BEGIN
    {
        # Write to log.
        $customProgress = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Getting certificates/requests from certificate authority';

        # Get the common name of the certificate authority.
        $caCommonName = Get-CACommonName;

        # Get hostname of the certificate authority.
        $hostname = $env:COMPUTERNAME

        # Construct CA config string.
        $caConfigString = ('{0}\{1}' -f $hostname, $caCommonName);

        # Object array for the result.
        $result = New-Object System.Collections.ArrayList;

        # Properties to fetch.
        $properties = @(
            'RequestId',
            'RequesterName',
            'Binary Certificate',
            'CommonName',
            'CertificateTemplate',
            'Certificate Effective Date',
            'Certificate Expiration Date',
            'CertificateHash',
            'SerialNumber',
            'StatusCode',
            'Request Submission Date',
            'Request Disposition',
            'Revocation Reason',
            'Revocation Date'
        );
    }
    PROCESS
    {
        # Try to create a new instance of ICertView2 interface.
        try
        {
            # Write to log.
            Write-CustomLog -Message ('Trying to instantiate ICertView2 interface') -Level Verbose;

            # Instantiate ICertView2 interface.
            $caView = New-Object -ComObject CertificateAuthority.View;

            # Write to log.
            Write-CustomLog -Message ('Successfully instantiate ICertView2 interface') -Level Verbose;
        }
        # Something went wrong.
        catch
        {
            # Throw exception.
            throw ('Failed to instantiate ICertView2 interface. {0}' -f $_.Exception.Message);
        }

        # Try to connect to the certificate authority.
        try
        {
            # Write to log.
            Write-CustomLog -Message ("Trying to connect to certificate authority '{0}'" -f $caConfigString) -Level Verbose;

            # Connect to the certificate authority.
            $caView.OpenConnection($caConfigString);

            # Write to log.
            Write-CustomLog -Message ('Successfully connected to certificate authority') -Level Verbose;
        }
        # Something went wrong.
        catch
        {
            # Throw exception.
            throw ('Failed to connect to certificate authority. {0}' -f $_.Exception.Message);
        }

        # SeekOperator:
        #CVR_SEEK_NONE = 0
        #CVR_SEEK_EQ = 1
        #CVR_SEEK_LT = 2
        #CVR_SEEK_LE = 4
        #CVR_SEEK_GE = 8
        #CVR_SEEK_GT = 10

        # SortOrder:
        #CVR_SORT_NONE = 0
        #CVR_SORT_ASCEND = 1
        #CVR_SORT_DESCEND = 2

        # If the state is 'Revoked'.
        if ($State -eq 'Revoked')
        {
            # Write to log.
            Write-CustomLog -Message ("Set restriction to revoked certificates") -Level Verbose;

            # Get the column index.
            $columnIndex = $caView.GetColumnIndex($false, 'Disposition');

            # Set the restriction (index, seekoperator, sortorder, value).
            $null = $caView.SetRestriction($columnIndex, 1, 0, 21);

            # If the date is set.
            if ($PSBoundParameters.ContainsKey('Date'))
            {
                # Write to log.
                Write-CustomLog -Message ("Set restriction to lower than date '{0}'" -f $Date) -Level Verbose;

                # Get the column index.
                $columnIndex = $caView.GetColumnIndex($false, 'Revocation Date');

                # Set the restriction (index, seekoperator, sortorder, value).
                $null = $caView.SetRestriction($columnIndex, 2, 0, $Date);
            }
        }
        # Else if the state is 'Expired'.
        elseif ($State -eq 'Expired')
        {
            # Write to log.
            Write-CustomLog -Message ("Set restriction to expired certificates") -Level Verbose;
            Write-CustomLog -Message ("Set restriction to lower than date '{0}'" -f $Date) -Level Verbose;

            # Get the column index.
            $columnIndex = $caView.GetColumnIndex($false, 'NotAfter');

            # Set the restriction (index, seekoperator, sortorder, value).
            $null = $caView.SetRestriction($columnIndex, 2, 0, $Date);
        }
        # Else if the state is 'Denied'.
        elseif ($State -eq 'Denied')
        {
            # Write to log.
            Write-CustomLog -Message ("Set restriction to denied certificates") -Level Verbose;

            # Get the column index.
            $columnIndex = $caView.GetColumnIndex($false, 'Request Disposition');

            # Set the restriction (index, seekoperator, sortorder, value).
            $null = $caView.SetRestriction($columnIndex, 1, 0, 31);

            # If the date is set.
            if ($PSBoundParameters.ContainsKey('Date'))
            {
                # Write to log.
                Write-CustomLog -Message ("Set restriction to lower than date '{0}'" -f $Date) -Level Verbose;

                # Get the column index.
                $columnIndex = $caView.GetColumnIndex($false, 'Request Submission Date');

                # Set the restriction (index, seekoperator, sortorder, value).
                $null = $caView.SetRestriction($columnIndex, 2, 0, $Date);
            }
        }
        # Else if the state is 'Failed'.
        elseif ($State -eq 'Failed')
        {
            # Write to log.
            Write-CustomLog -Message ("Set restriction to failed certificates") -Level Verbose;

            # Get the column index.
            $columnIndex = $caView.GetColumnIndex($false, 'Request Disposition');

            # Set the restriction (index, seekoperator, sortorder, value).
            $null = $caView.SetRestriction($columnIndex, 1, 0, 30);

            # If the date is set.
            if ($PSBoundParameters.ContainsKey('Date'))
            {
                # Write to log.
                Write-CustomLog -Message ("Set restriction to lower than date '{0}'" -f $Date) -Level Verbose;

                # Get the column index.
                $columnIndex = $caView.GetColumnIndex($false, 'Request Submission Date');

                # Set the restriction (index, seekoperator, sortorder, value).
                $null = $caView.SetRestriction($columnIndex, 2, 0, $Date);
            }
        }

        # Set the result column count.
        $null = $caView.SetResultColumnCount($properties.Count);

        # Foreach property
        foreach ($property in $properties)
        {
            # Set the result column.
            $null = $CAView.SetResultColumn($caView.GetColumnIndex($false, $property));
        }

        # Try to open the database.
        try
        {
            # Write to log.
            Write-CustomLog -Message ('Trying to open the AD CS database') -Level Verbose;

            # Open the database.
            $databaseRow = $caView.OpenView();

            # Write to log.
            Write-CustomLog -Message ('Successfully opened the AD CS database') -Level Verbose;
        }
        # Something went wrong.
        catch
        {
            # Throw exception.
            throw ('Failed to open the AD CS database. {0}' -f $_.Exception.Message);
        }

        # As long as there are more table rows in the database.
        while ($databaseRow.Next() -ne -1)
        {
            # Create a new object.
            $databaseItem = New-Object -TypeName PSObject;

            # Get all row columns.
            $databaseColumn = $databaseRow.EnumCertViewColumn();

            # As long as there are more columns in the row.
            while ($databaseColumn.Next() -ne -1)
            {
                # Add the column to the object.
                Add-Member -InputObject $databaseItem -MemberType NoteProperty $($databaseColumn.GetName()) -Value $($databaseColumn.GetValue(1)) -Force;
            }

            # Add the object to the result.
            $null = $result.Add($databaseItem);

            # Reset the column data
            $databaseColumn.Reset();
        }

        # Reset the row data.
        $databaseRow.Reset();

        # Write to log.
        Write-CustomLog -Message ('Found {0} certificate(s)/request(s)' -f $result.Count) -Level Verbose;
    }
    END
    {
        # Write to log.
        Write-CustomProgress @customProgress;

        # Return the result.
        return $result;
    }
}