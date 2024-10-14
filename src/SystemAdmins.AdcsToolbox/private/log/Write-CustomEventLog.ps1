function Write-CustomEventLog
{
    <#
    .SYNOPSIS
        Write entry to the Event Log.
    .DESCRIPTION
        Wrap Write-EventLog used in the module.
    .PARAMETER Source
        Source of the event.
    .PARAMETER EventId
        Event id.
    .PARAMETER AdditionalMessage
        Additional message to write to the event log.
    .PARAMETER RawData
        Raw data.
    .EXAMPLE
        Write-CustomEventLog -Source 'SystemAdmins.AdcsToolbox' -EventId 1 -Message 'This is a test message';
    #>
    [cmdletbinding()]
    param
    (
        # Source of the event.
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$Source = $script:ModuleName,

        # Event id.
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$EventId,

        # Message to write to the event log.
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$AdditonalMessage,

        # Raw data.
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        $RawData,

        # Event log table.
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        $EventLogTable = $script:ModuleEventLogTable
    )

    BEGIN
    {
        # Write to log.
        $customProgress = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Write to event log';

        # Find the event id in the event log table.
        $eventLog = $EventLogTable | Where-Object { $_.eventId -eq $EventId };

        # If event id dont exist.
        if ($null -eq $eventLog)
        {
            # Write to log.
            Write-CustomLog -Message ('Event id {0} does not exist in the event log table' -f $EventId) -Level Verbose;

            # Use default event id.
            $eventLog = $EventLogTable | Where-Object { $_.eventId -eq 0 };
        }
    }
    PROCESS
    {
        # If source dont exist.
        if ([System.Diagnostics.EventLog]::SourceExists($Source) -eq $False)
        {
            # Write to log.
            Write-CustomLog -Message ("Creating new source '{0}' in the event log 'Application'" -f $Source) -Level Verbose;

            # Create source.
            $null = New-EventLog -LogName 'Application' -Source $Source;
        }

        # Write to log.
        Write-CustomLog -Message ("Writing to event log of id '{0}'" -f $eventLog.eventId) -Level Verbose;

        # If additional message is set.
        if ($AdditonalMessage)
        {
            # Write to log.
            Write-CustomLog -Message ("Adding additional message '{0}'" -f $AdditonalMessage) -Level Verbose;

            # Add additional message.
            $message = $eventLog.message + "`n$AdditonalMessage";
        }
        else
        {
            # Set message.
            $message = $eventLog.message;
        }

        # Create splat for Write-EventLog.
        $splat = @{
            LogName   = 'Application';
            Source    = $Source;
            EventId   = $eventLog.eventId;
            EntryType = $eventLog.entryType;
            Message   = $message;
            Category  = 1;
        }

        # If raw data is set.
        if ($RawData)
        {
            # Add raw data.
            $null = $splat.Add('RawData', (Convert-ObjectToBytes -InputObject $RawData));
        }

        # Write to event log.
        Write-EventLog @splat;
    }
    END
    {
        # Write to log.
        Write-CustomProgress @customProgress;
    }
}