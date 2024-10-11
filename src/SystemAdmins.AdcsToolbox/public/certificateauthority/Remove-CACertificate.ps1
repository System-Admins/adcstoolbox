function Remove-CACertificate
{
    <#
    .SYNOPSIS
        Remove certificate/request from certificate authority.
    .DESCRIPTION
        Return list of removed certificates/requests.
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
        $progressId = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Removing certificates/requests from certificate authority' -Type 'Begin';

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
                $result = Remove-CACertificateRevoked -Date $Date;
            }
            # If state is expired.
            elseif ($State -eq 'Expired')
            {
                # Get expired certificates.
                $result = Remove-CACertificateExpired -Date $Date;
            }
            # If state is denied.
            elseif ($State -eq 'Denied')
            {
                # Get denied requests.
                $result = Remove-CACertificateRequestDenied -Date $Date;
            }
            # If state is failed.
            elseif ($State -eq 'Failed')
            {
                # Get failed requests.
                $result = Remove-CACertificateRequestFailed -Date $Date;
            }
            # Else use default.
            else
            {
                # Get certificates.
                $result += [PSCustomObject]@{
                    Revoked = Remove-CACertificateRevoked -Date $Date;
                    Expired = Remove-CACertificateExpired -Date $Date;
                    Denied  = Remove-CACertificateRequestDenied -Date $Date;
                    Failed  = Remove-CACertificateRequestFailed -Date $Date;
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
                $result = Remove-CACertificateRevoked;
            }
            # If state is expired.
            elseif ($State -eq 'Expired')
            {
                # Get expired certificates.
                $result = Remove-CACertificateExpired;
            }
            # If state is denied.
            elseif ($State -eq 'Denied')
            {
                # Get denied requests.
                $result = Remove-CACertificateRequestDenied;
            }
            # If state is failed.
            elseif ($State -eq 'Failed')
            {
                # Get failed requests.
                $result = Remove-CACertificateRequestFailed;
            }
            # Else use default.
            else
            {
                # Get certificates.
                $result += [PSCustomObject]@{
                    Revoked = Remove-CACertificateRevoked;
                    Expired = Remove-CACertificateExpired;
                    Denied  = Remove-CACertificateRequestDenied;
                    Failed  = Remove-CACertificateRequestFailed;
                };
            }
        }
    }
    END
    {
        # Write to log.
        Write-CustomProgress -ProgressId $progressId -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Getting certificates/requests from certificate authority' -Type 'End';

        # Return the result.
        return $result;
    }
}