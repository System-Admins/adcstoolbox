function Remove-CACertificate
{
    <#
    .SYNOPSIS
        Remove certificate/request from certificate authority.
    .DESCRIPTION
        Return list of removed certificates/requests.
    .PARAMETER Id
        Request id to remove.
    .PARAMETER State
        State of certificate/request (revoked, expired, denied, failed).
    .PARAMETER Date
        Date to get certificate up-to. Default is today.
    .EXAMPLE
        Remove-CACertificate -State 'Revoked';
    .EXAMPLE
        Remove-CACertificate -State 'Revoked' -Date (Get-Date).AddDays(-30);

    #>
    [cmdletbinding()]
    [OutputType([System.Collections.ArrayList])]
    param
    (
        # State of certificate/request (revoked, expired, denied, failed).
        [Parameter(Mandatory = $false)]
        [ValidateSet('Revoked', 'Expired', 'Denied', 'Failed')]
        [string]$State,

        # Date to remove certificate up-to. Default is today.
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [ValidateScript({ $_ -le (Get-Date) })]
        [DateTime]$Date = (Get-Date),

        # Confirm the action.
        [Parameter(Mandatory = $false)]
        [switch]$Confirm = $true
    )

    BEGIN
    {
        # Write to log.
        $customProgress = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Removing certificates/requests from certificate authority';

        # Object array for the result.
        $result = New-Object System.Collections.ArrayList;

        # Ask user to confirm.
        if ($true -eq $Confirm)
        {
            # Get user input.
            $userInput = Get-UserInput -Question 'Do you want to continue with removing certificate/requests in the AD CS? (Answer: Yes or No)' -Options 'Yes', 'No';

            # If the user input is not 'Yes'.
            if ($userInput -ne 'Yes')
            {
                # Write to log.
                Write-CustomLog -Message 'User did not confirm the action' -Level Verbose;

                # Exit script.
                exit 1;
            }
        }

        # Get the common name of the certificate authority.
        $caCommonName = Get-CACommonName;

        # Get hostname of the certificate authority.
        $hostname = $env:COMPUTERNAME

        # Construct CA config string.
        $caConfigString = ('{0}\{1}' -f $hostname, $caCommonName);

        # Certificates to remove.
        $certificatesToRemove = @();

        # Splatting.
        $getCertificateSplat = @{};

        # If date is set.
        if ($PSBoundParameters.ContainsKey('Date'))
        {
            # Add to the splat.
            $getCertificateSplat.Add('Date', $Date);
        }

        # Result.
        $result = New-Object System.Collections.ArrayList;
    }
    PROCESS
    {
        # If state is not set.
        if (-not $PSBoundParameters.ContainsKey('State'))
        {
            # Add all states.
            $certificatesToRemove += Get-CACertificate -State 'Revoked' @getCertificateSplat;
            $certificatesToRemove += Get-CACertificate -State 'Expired' @getCertificateSplat;
            $certificatesToRemove += Get-CACertificate -State 'Denied' @getCertificateSplat;
            $certificatesToRemove += Get-CACertificate -State 'Failed' @getCertificateSplat;
        }
        # If state is revoked.
        elseif ($State -eq 'Revoked')
        {
            # Get revoked certificates.
            $certificatesToRemove = Get-CACertificate -State 'Revoked' @getCertificateSplat;
        }
        # If state is expired.
        elseif ($State -eq 'Expired')
        {
            # Get expired certificates.
            $certificatesToRemove = Get-CACertificate -State 'Expired' @getCertificateSplat;
        }
        # If state is denied.
        elseif ($State -eq 'Denied')
        {
            # Get denied requests.
            $certificatesToRemove = Get-CACertificate -State 'Denied' @getCertificateSplat;
        }
        # If state is failed.
        elseif ($State -eq 'Failed')
        {
            # Get failed requests.
            $certificatesToRemove = Get-CACertificate -State 'Failed' @getCertificateSplat;
        }

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

        # Foreach certificate to remove.
        foreach ($certificate in $certificatesToRemove)
        {
            # Try to remove the certificate.
            try
            {
                # Write to log.
                Write-CustomLog -Message ('Trying to remove certificate/request with id {0}' -f $certificate.RequestID) -Level Verbose;

                # Remove the certificate from the database.
                $null = $caAdmin.DeleteRow($caConfigString, 0, 0, 0, $certificate.RequestID);

                # Write to log.
                Write-CustomLog -Message ('Successfully removed certificate/request') -Level Verbose;

                # Depending on the state.
                switch ($certificate.State)
                {
                    # If the state is revoked.
                    'Revoked'
                    {
                        # Write to event log.
                        Write-CustomEventLog -EventId 122 -AdditionalMessage ($certificate);
                    }
                    # If the state is expired.
                    'Expired'
                    {
                        # Write to event log.
                        Write-CustomEventLog -EventId 121 -AdditionalMessage ($certificate);
                    }
                    # If the state is denied.
                    'Denied'
                    {
                        # Write to event log.
                        Write-CustomEventLog -EventId 123 -AdditionalMessage ($certificate);
                    }
                    # If the state is failed.
                    'Failed'
                    {
                        # Write to event log.
                        Write-CustomEventLog -EventId 124 -AdditionalMessage ($certificate);
                    }
                }

                # Add to result.
                $null = $result.Add($certificate);
            }
            # Something went wrong.
            catch
            {
                # Write to event log.
                Write-CustomEventLog -EventId 125 -AdditionalMessage ($certificate);

                # Throw exception.
                throw ('Failed to remove certificate/request with id {0}. {1}' -f $certificate.RequestID, $_.Exception.Message);
            }
        }

        # Write to event log.
        Write-CustomEventLog -EventId 63;
    }
    END
    {
        # Write to log.
        Write-CustomProgress @customProgress;

        # Return the result.
        return $result;
    }
}