function Set-CACrlConfig
{
    <#
    .SYNOPSIS
        Set certificate authority revocation configuration.
    .DESCRIPTION
        Returns nothing.
    .PARAMETER PeriodUnits
        Period units.
    .PARAMETER Period
        Period.
    .PARAMETER DeltaPeriodUnits
        Delta period units.
    .PARAMETER DeltaPeriod
        Delta period.
    .PARAMETER OverlapUnits
        Overlap units.
    .PARAMETER OverlapPeriod
        Overlap period.
    .PARAMETER DeltaOverlapUnits
        Delta overlap units.
    .PARAMETER DeltaOverlapPeriod
        Delta overlap period.
    .PARAMETER RevocationCheck
        Disable or enable revocation check.
    .EXAMPLE
        Set-CACrlConfig -PeriodUnits 2 -Period Weeks -DeltaPeriodUnits 0 -DeltaPeriod Days -OverlapUnits 0 -OverlapPeriod Weeks -DeltaOverlapUnits 0 -DeltaOverlapPeriod Days -RevocationCheck $true;
    #>
    [cmdletbinding()]
    [OutputType([void])]
    param
    (
        # Period units.
        [Parameter(Mandatory = $false)]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$PeriodUnits,

        # Period.
        [Parameter(Mandatory = $false)]
        [ValidateSet('Days', 'Weeks', 'Months', 'Years')]
        [string]$Period,

        # Delta period units.
        [Parameter(Mandatory = $false)]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$DeltaPeriodUnits,

        # Delta period.
        [Parameter(Mandatory = $false)]
        [ValidateSet('Days', 'Weeks', 'Months', 'Years')]
        [string]$DeltaPeriod,

        # Overlap units.
        [Parameter(Mandatory = $false)]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$OverlapUnits,

        # Overlap period.
        [Parameter(Mandatory = $false)]
        [ValidateSet('Days', 'Weeks', 'Months', 'Years')]
        [string]$OverlapPeriod,

        # Delta overlap units.
        [Parameter(Mandatory = $false)]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$DeltaOverlapUnits,

        # Delta overlap period.
        [Parameter(Mandatory = $false)]
        [ValidateSet('Days', 'Weeks', 'Months', 'Years')]
        [string]$DeltaOverlapPeriod,

        # Disable or enable revocation check.
        [Parameter(Mandatory = $false)]
        [bool]$RevocationCheck
    )

    BEGIN
    {
        # Write to log.
        $customProgress = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Setting CRL configuration on certificate authority';

        # Get the registry path.
        [pscustomobject]$registryPath = Get-CARegistryPath;
    }
    PROCESS
    {
        # Set period units.
        if ($PSBoundParameters.ContainsKey('PeriodUnits'))
        {
            # Write to log.
            Write-CustomLog -Message ('Setting CRL period units to "{0}"' -f $PeriodUnits) -Level Verbose;

            # Set period units.
            Set-ItemProperty -Path $registryPath.ActiveConfiguration -Name 'CRLPeriodUnits' -Value $PeriodUnits -Force;
        }

        # Set period.
        if ($PSBoundParameters.ContainsKey('Period'))
        {
            # Write to log.
            Write-CustomLog -Message ('Setting CRL period to "{0}"' -f $Period) -Level Verbose;

            # Set period.
            Set-ItemProperty -Path $registryPath.ActiveConfiguration -Name 'CRLPeriod' -Value $Period -Force;
        }

        # Set delta period units.
        if ($PSBoundParameters.ContainsKey('DeltaPeriodUnits'))
        {
            # Write to log.
            Write-CustomLog -Message ('Setting CRL delta period units to "{0}"' -f $DeltaPeriodUnits) -Level Verbose;

            # Set delta period units.
            Set-ItemProperty -Path $registryPath.ActiveConfiguration -Name 'CRLDeltaPeriodUnits' -Value $DeltaPeriodUnits -Force;
        }

        # Set delta period.
        if ($PSBoundParameters.ContainsKey('DeltaPeriod'))
        {
            # Write to log.
            Write-CustomLog -Message ('Setting CRL delta period to "{0}"' -f $DeltaPeriod) -Level Verbose;

            # Set delta period.
            Set-ItemProperty -Path $registryPath.ActiveConfiguration -Name 'CRLDeltaPeriod' -Value $DeltaPeriod -Force;
        }

        # Set overlap units.
        if ($PSBoundParameters.ContainsKey('OverlapUnits'))
        {
            # Write to log.
            Write-CustomLog -Message ('Setting CRL overlap units to "{0}"' -f $OverlapUnits) -Level Verbose;

            # Set overlap units.
            Set-ItemProperty -Path $registryPath.ActiveConfiguration -Name 'CRLOverlapUnits' -Value $OverlapUnits -Force;
        }

        # Set overlap period.
        if ($PSBoundParameters.ContainsKey('OverlapPeriod'))
        {
            # Write to log.
            Write-CustomLog -Message ('Setting CRL overlap period to "{0}"' -f $OverlapPeriod) -Level Verbose;

            # Set overlap period.
            Set-ItemProperty -Path $registryPath.ActiveConfiguration -Name 'CRLOverlapPeriod' -Value $OverlapPeriod -Force;
        }

        # Set delta overlap units.
        if ($PSBoundParameters.ContainsKey('DeltaOverlapUnits'))
        {
            # Write to log.
            Write-CustomLog -Message ('Setting CRL delta overlap units to "{0}"' -f $DeltaOverlapUnits) -Level Verbose;

            # Set delta overlap units.
            Set-ItemProperty -Path $registryPath.ActiveConfiguration -Name 'CRLDeltaOverlapUnits' -Value $DeltaOverlapUnits -Force;
        }

        # Set delta overlap period.
        if ($PSBoundParameters.ContainsKey('DeltaOverlapPeriod'))
        {
            # Write to log.
            Write-CustomLog -Message ('Setting CRL delta overlap period to "{0}"' -f $DeltaOverlapPeriod) -Level Verbose;

            # Set delta overlap period.
            Set-ItemProperty -Path $registryPath.ActiveConfiguration -Name 'CRLDeltaOverlapPeriod' -Value $DeltaOverlapPeriod -Force;
        }

        # Set revocation check.
        if ($PSBoundParameters.ContainsKey('RevocationCheck'))
        {
            # If the revocation check should be enabled.
            if ($RevocationCheck)
            {
                # Write to log.
                Write-CustomLog -Message 'Enabling CRL revocation check' -Level Verbose;

                # Set revocation check.
                Set-ItemProperty -Path $registryPath.ActiveConfiguration -Name 'CRLRevocationCheckEnabled' -Value 2 -Force;
            }
            # If the revocation check should b disabled.
            else
            {
                # Write to log.
                Write-CustomLog -Message 'Disabling CRL revocation check' -Level Verbose;

                # Set revocation check.
                Set-ItemProperty -Path $registryPath.ActiveConfiguration -Name 'CRLRevocationCheckEnabled' -Value 10 -Force;
            }
        }

        # Write to event log.
        Write-CustomEventLog -EventId 62 -AdditionalMessage (Out-String -InputObject $PSBoundParameters);
    }
    END
    {
        # Write to log.
        Write-CustomProgress @customProgress;
    }
}