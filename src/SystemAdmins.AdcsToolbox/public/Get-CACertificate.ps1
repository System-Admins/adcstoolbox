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

        # Object array for the result.
        $result = New-Object System.Collections.ArrayList;
    }
    PROCESS
    {
        # If date is set.
        if ($PSBoundParameters.ContainsKey('Date'))
        {
            # If state is revoked.
            if ($State -eq 'Revoked')
            {
                # Get revoked certificates.
                $result = Get-CACertificateRevoked -Date $Date;
            }
            # If state is expired.
            elseif ($State -eq 'Expired')
            {
                # Get expired certificates.
                $result = Get-CACertificateExpired -Date $Date;
            }
            # If state is denied.
            elseif ($State -eq 'Denied')
            {
                # Get denied requests.
                $result = Get-CACertificateRequestDenied -Date $Date;
            }
            # If state is failed.
            elseif ($State -eq 'Failed')
            {
                # Get failed requests.
                $result = Get-CACertificateRequestFailed -Date $Date;
            }
            # Else use default.
            else
            {
                # Get certificates.
                $result += [PSCustomObject]@{
                    Revoked = Get-CACertificateRevoked -Date $Date;
                    Expired = Get-CACertificateExpired -Date $Date;
                    Denied = Get-CACertificateRequestDenied -Date $Date;
                    Failed = Get-CACertificateRequestFailed -Date $Date;
                };
            }
        }
        # Else use default.
        else
        {
            # If state is revoked.
            if ($State -eq 'Revoked')
            {
                # Get revoked certificates.
                $result = Get-CACertificateRevoked;
            }
            # If state is expired.
            elseif ($State -eq 'Expired')
            {
                # Get expired certificates.
                $result = Get-CACertificateExpired;
            }
            # If state is denied.
            elseif ($State -eq 'Denied')
            {
                # Get denied requests.
                $result = Get-CACertificateRequestDenied;
            }
            # If state is failed.
            elseif ($State -eq 'Failed')
            {
                # Get failed requests.
                $result = Get-CACertificateRequestFailed;
            }
            # Else use default.
            else
            {
                # Get certificates.
                $result += [PSCustomObject]@{
                    Revoked = Get-CACertificateRevoked;
                    Expired = Get-CACertificateExpired;
                    Denied = Get-CACertificateRequestDenied;
                    Failed = Get-CACertificateRequestFailed;
                };
            }
        }
    }
    END
    {
        # Write to log.
        Write-CustomProgress @customProgress;

        # Return the result.
        return $result;
    }
}