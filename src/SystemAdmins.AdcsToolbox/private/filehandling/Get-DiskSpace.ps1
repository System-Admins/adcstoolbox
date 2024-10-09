function Get-DiskSpace
{
    <#
    .SYNOPSIS
        Get computer disk sizes.
    .DESCRIPTION
        Return sizes of the disk.
    .EXAMPLE
        Get-DiskSpace;
    #>
    [cmdletbinding()]
    [OutputType([System.Collections.ArrayList])]
    param
    (
    )

    BEGIN
    {
        # Write to log.
        $progressId = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Get disk size' -Type 'Start';

        # Get disk info.
        $disks = Get-WmiObject -Class Win32_LogicalDisk;

        # Object array to return.
        [System.Collections.ArrayList]$result = @();
    }
    PROCESS
    {
        # Foreach disk.
        foreach ($disk in $disks)
        {
            # Construct disk space object.
            $result.Add(
                [PSCustomObject]@{
                    DriveLetter    = $disk.DeviceID;
                    VolumeName     = $disk.VolumeName;
                    FreeSpace      = $disk.FreeSpace;
                    TotalSpace     = $disk.Size;
                    FreeSpaceInGB  = [math]::Round($disk.FreeSpace / 1GB);
                    TotalSpaceInGB = [math]::Round($disk.Size / 1GB);
                }
            );
        }
    }
    END
    {
        # Write to log.
        Write-CustomProgress -Id $progressId -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Get disk size' -Type 'End';

        # Return result.
        return $result;
    }
}