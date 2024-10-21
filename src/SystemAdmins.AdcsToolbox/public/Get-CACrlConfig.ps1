function Get-CACrlConfig
{
    <#
    .SYNOPSIS
        Get certificate authority revocation configuration.
    .DESCRIPTION
        Returns object with CRL configuration for the CA.
    .EXAMPLE
        Get-CACrlConfig;
    #>
    [cmdletbinding()]
    [OutputType([pscustomobject])]
    param
    (
    )

    BEGIN
    {
        # Write to log.
        $customProgress = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Getting CRL configuration from certificate authority';

        # Object to return.
        [pscustomobject]$configuration = [pscustomobject]@{
            PeriodUnits            = $null;
            Period                 = $null;
            DeltaPeriodUnits       = $null;
            DeltaPeriod            = $null;
            OverlapUnits           = $null;
            OverlapPeriod          = $null;
            DeltaOverlapUnits      = $null;
            DeltaOverlapPeriod     = $null;
            DeltaNextPublish       = $null;
            NextPublish            = $null;
            PublicationURLs        = @();
            RevocationCheckEnabled = $null;
        };
    }
    PROCESS
    {
        # Get period units.
        $configuration.PeriodUnits = Get-CAConfigEntry -Entry 'CRLPeriodUnits';

        # Get period.
        $configuration.Period = Get-CAConfigEntry -Entry 'CRLPeriod';

        # Get delta period units.
        $configuration.DeltaPeriodUnits = Get-CAConfigEntry -Entry 'CRLDeltaPeriodUnits';

        # Get delta period.
        $configuration.DeltaPeriod = Get-CAConfigEntry -Entry 'CRLDeltaPeriod';

        # Get overlap period units.
        $configuration.OverlapUnits = Get-CAConfigEntry -Entry 'CRLOverlapUnits';

        # Get overlap period.
        $configuration.OverlapPeriod = Get-CAConfigEntry -Entry 'CRLOverlapPeriod';

        # Get delta overlap period units.
        $configuration.DeltaOverlapUnits = Get-CAConfigEntry -Entry 'CRLDeltaOverlapUnits';

        # Get delta overlap period.
        $configuration.DeltaOverlapPeriod = Get-CAConfigEntry -Entry 'CRLDeltaOverlapPeriod';

        # Get delta next publish.
        $deltaNextPublish = Get-CAConfigEntry -Entry 'CRLDeltaNextPublish';

        # If the delta next publish is not null.
        if ($null -ne $deltaNextPublish)
        {
            # Convert byte array to integer
            $deltaNextPublishInt64 = [BitConverter]::ToInt64($deltaNextPublish, 0);

            # Convert integer to DateTime
            $configuration.DeltaNextPublish = [DateTime]::FromFileTimeUtc($deltaNextPublishInt64);
        }

        # Get next publish.
        $nextPublish = Get-CAConfigEntry -Entry 'CRLNextPublish';

        # If the next publish is not null.
        if ($null -ne $nextPublish)
        {
            # Convert byte array to integer
            $nextPublishInt64 = [BitConverter]::ToInt64($nextPublish, 0);

            # Convert integer to DateTime
            $configuration.NextPublish = [DateTime]::FromFileTimeUtc($nextPublishInt64);
        }

        # Get publication URLs.
        $publicationURLs = Get-CAConfigEntry -Entry 'CRLPublicationURLs';

        # If the publication URLs is not null.
        if ($null -ne $publicationURLs)
        {
            # Loop through each string in the input array.
            foreach ($string in $publicationURLs)
            {
                # Use a regular expression to match the part after the colon.
                if ($string -match ':(.*)$')
                {
                    # Add the matched part to the array.
                    $configuration.PublicationURLs += $matches[1];
                }
            }
        }

        # Get if revocation check is enabled.
        $revocationCheckEnabled = Get-CAConfigEntry -Entry 'CRLFlags';

        # If the revocation check is enabled.
        if ($revocationCheckEnabled -eq 2)
        {
            # Set to true.
            $configuration.RevocationCheckEnabled = $true;
        }
        # Else set to false.
        else
        {
            # Set to false.
            $configuration.RevocationCheckEnabled = $false;
        }
    }
    END
    {
        # Write to log.
        Write-CustomProgress @customProgress;

        # Return configuration.
        return $configuration;
    }
}