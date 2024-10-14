function Get-DateTimeShortDateFormat
{
    <#
    .SYNOPSIS
        Get the short date format for the current culture.
    .DESCRIPTION
        Returns something like dd-MM-yyyy.
    .EXAMPLE
        Get-DateTimeShortDateFormat;
    #>
    [cmdletbinding()]
    [OutputType([string])]
    param
    (
    )

    BEGIN
    {
        # Write to log.
        $customProgress = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Getting short date format';

        # Get regional date format.
        [CultureInfo]$culture = [CultureInfo]::CurrentCulture;

        # Value to return.
        [string]$shortDatePattern = $null;
    }
    PROCESS
    {
        # Get short date format.
        $shortDatePattern = $culture.DateTimeFormat.ShortDatePattern;

        # Write to log.
        Write-CustomLog -Message ("Short date format is '{0}'" -f $shortDatePattern) -Level Verbose;
    }
    END
    {
        # Write to log.
        Write-CustomProgress @customProgress;

        # Return the short date format.
        return $shortDatePattern;
    }
}