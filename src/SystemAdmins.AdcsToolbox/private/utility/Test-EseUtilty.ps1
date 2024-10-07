function Test-EseUtilty
{
    <#
    .SYNOPSIS
        Test if Extensible Storage Engine utility (esentutl.exe) is available.
    .DESCRIPTION
        Return true of false
    .EXAMPLE
        Test-EseUtilty;
    #>
    [cmdletbinding()]
    [OutputType([bool])]
    param
    (
    )

    BEGIN
    {
        # Write to log.
        $progressId = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Check if esentutl.exe is available' -Type 'Start';

        # Path to the utility.
        [string]$utilityPath = 'C:\Windows\System32\esentutl.exe';

        # Boolean to return.
        [bool]$isAvailable = $false;
    }
    PROCESS
    {
        # If the utility exists.
        if (Test-Path -Path $utilityPath -PathType Leaf)
        {
            # Write to log.
            Write-CustomLog -Message 'Extensible Storage Engine utility (esentutl.exe) is available' -Level Verbose;

            # Set to true.
            $isAvailable = $true;
        }
        # Else the utility does not exist.
        else
        {
            # Write to log.
            Write-CustomLog -Message 'Extensible Storage Engine utility (esentutl.exe) is not available' -Level Verbose;
        }
    }
    END
    {
        # Write to log.
        Write-CustomProgress -Id $progressId -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Check if esentutl.exe is available' -Type 'End';

        # Return boolean.
        return $isAvailable;
    }
}