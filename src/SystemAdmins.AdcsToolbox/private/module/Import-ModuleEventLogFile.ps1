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
            throw ("The event log config file '{0}' dont exist, aborting" -f $Path);
        }

        # Try to import JSON file.
        try
        {
            # Write to log.
            Write-CustomLog -Message ("Importing the event log JSON file '{0}'" -f $Path) -Level Verbose;

            # Import JSON file.
            $eventLogTable = Get-Content -Path $Path -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop;

            # Write to log.
            Write-CustomLog -Message ("The event log JSON file '{0}' was imported successfully" -f $Path) -Level Verbose;
        }
        catch
        {
            # Throw error.
            throw ("Something went wrong while importing the event log JSON file '{0}', the execption is:`r`n" -f $Path, $_);
        }
    }
    END
    {
        # Write to log.
        Write-CustomProgress @customProgress;

        # Return edition.
        return $eventLogTable;
    }
}