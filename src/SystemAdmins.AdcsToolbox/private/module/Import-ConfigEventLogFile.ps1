function Import-ModuleEventLogFile
{
    <#
    .SYNOPSIS
        Import event log table from JSON file.
    .DESCRIPTION
        Import event log table from JSON file and convert it to a object array.
    .EXAMPLE
        Import-ConfigEventLogFile;
    #>
    [cmdletbinding()]
    param
    (
        # Path to the JSON file.
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$Path = $script:ModuleEventLogJsonFilePath
    )

    BEGIN
    {
        # Write to log.
        $customProgress = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Importing JSON file with event log entries';
    }
    PROCESS
    {
        # Test if file exists.
        if (-not (Test-Path -Path $Path))
        {
            # Throw error.
            throw ("The Event Log config file '{0}' dont exist, aborting" -f $Path);
        }

        # Import JSON file.
        $eventLogTable = Get-Content -Path $Path | ConvertFrom-Json;
    }
    END
    {
        # Write to log.
        Write-CustomProgress @customProgress;

        # Return edition.
        return $eventLogTable;
    }
}