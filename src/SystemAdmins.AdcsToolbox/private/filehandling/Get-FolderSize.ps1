function Get-FolderSize
{
    <#
    .SYNOPSIS
        Get the size of a folder.
    .DESCRIPTION
        Return the size of a folder.
    .PARAMETER Path
        Path to the folder.
    .PARAMETER FileTypeInclude
        Only certain file types.
    .PARAMETER FileNameInclude
        Only certain file names.
    .EXAMPLE
        Get-FolderSize -Path 'C:\Temp';
    .EXAMPLE
        Get-FolderSize -Path 'C:\Temp' -FileTypeInclude '.txt', '.log';
    .EXAMPLE
        Get-FolderSize -Path 'C:\Temp' -FileNameInclude 'file1.txt', 'file2.log';
    #>
    [cmdletbinding()]
    [OutputType([pscustomobject])]
    param
    (
        # Path to the folder.
        [Parameter(Mandatory = $true)]
        [ValidateScript({ Test-Path $_ -PathType 'Container' })]
        [string]$Path,

        # Only certain file types.
        [Parameter(Mandatory = $false, ParameterSetName = 'FileType')]
        [string[]]$FileTypeInclude = @(),

        # Only certain file names.
        [Parameter(Mandatory = $false, ParameterSetName = 'FileName')]
        [string[]]$FileNameInclude = @()
    )

    BEGIN
    {
        # Write to log.
        $customProgress = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Get folder size';

        # Variable to store the size.
        [long]$folderSizeInBytes = 0;

        # Object to return.
        [pscustomobject]$result = [pscustomobject]@{
            Path  = $Path;
            Bytes = 0
            Kb    = 0;
            Mb    = 0;
            Gb    = 0;
            Tb    = 0;
        };
    }
    PROCESS
    {
        # If file type include is not empty.
        if ($FileTypeInclude.Count -gt 0)
        {
            # Get child items of certain extensions.
            $items = Get-ChildItem -Path $Path -Recurse -File -Force | Where-Object { $_.Extension -in $FileTypeInclude };
        }
        # Else if file name include is not empty.
        elseif ($FileNameInclude.Count -gt 0)
        {
            # Get child items of certain names.
            $items = Get-ChildItem -Path $Path -Recurse -File -Force | Where-Object { $_.Name -in $FileNameInclude };
        }
        # Else get all child items.
        else
        {
            # Get child items.
            $items = Get-ChildItem -Path $Path -Recurse -File -Force;
        }

        # Foreach item.
        foreach ($item in $items)
        {
            # Add size to total.
            $folderSizeInBytes += $item.Length;
        }


        # Write to log.
        Write-CustomLog -Message ("Folder '{0}' size is {1} bytes" -f $Path, $folderSizeInBytes) -Level Verbose;

        # If folder size is more than 0.
        if ($folderSizeInBytes -gt 0)
        {
            # Set size.
            $result.Bytes = $folderSizeInBytes;

            # Convert to KB, MB, GB, TB.
            $result.Kb = [math]::Round($folderSizeInBytes / 1KB, 2);
            $result.Mb = [math]::Round($folderSizeInBytes / 1MB, 2);
            $result.Gb = [math]::Round($folderSizeInBytes / 1GB, 2);
            $result.Tb = [math]::Round($folderSizeInBytes / 1TB, 2);
        }
    }
    END
    {
        # Write to log.
        Write-CustomProgress @customProgress;

        # Return result.
        return $result;
    }
}