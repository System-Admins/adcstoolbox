function Invoke-EsentUtl
{
    <#
    .SYNOPSIS
        Invokes the esentutl.exe utility on Windows.
    .DESCRIPTION
        Call the esentutl utility with arguments.
    .PARAMETER Arguments
        Arguments to pass to the esentutl utility.
    .EXAMPLE
        Invoke-EsentUtl -Arguments '-d "C:\Windows\System32\CertLog\<ca name>.edb"';
    #>
    [cmdletbinding()]
    [OutputType([bool])]
    param
    (
        # Arguments to pass to the Esentutil utility.
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Arguments
    )

    BEGIN
    {
        # Write to log.
        $progressId = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Running esentutl utility (esentutl.exe)' -Type 'Begin';

        # Path to the utility.
        [string]$utilityPath = 'C:\Windows\System32\esentutl.exe';

        # Output.
        [string]$result = '';
    }
    PROCESS
    {
        # Create process object.
        $processStartInfo = New-Object System.Diagnostics.ProcessStartInfo;
        $processStartInfo.FileName = $utilityPath;
        $processStartInfo.RedirectStandardError = $true;
        $processStartInfo.RedirectStandardOutput = $true;
        $processStartInfo.UseShellExecute = $false;
        $processStartInfo.CreateNoWindow = $true;

        # Set arguments.
        $processStartInfo.Arguments = $Arguments;

        # Try to run esentutl.exe with arguments.
        try
        {
            # Write to log.
            Write-CustomLog -Message ("Trying to execute esentutil.exe with arguments '{0}'" -f $Arguments) -Level Verbose;

            # Start the certutil process.
            $process = New-Object System.Diagnostics.Process;
            $process.StartInfo = $processStartInfo;
            $null = $process.Start();
            $process.WaitForExit();

            # If exit code is not 0 (success).
            if ($process.ExitCode -eq 0)
            {
                # Get output.
                $result = $process.StandardOutput.ReadToEnd();

                # Write to log.
                Write-CustomLog -Message ('Succesfully executed esentutl.exe') -Level Verbose;
            }
            # Else exit code is not 0 (mayby an error).
            else
            {
                # Get error.
                $standardError = $process.StandardError.ReadToEnd();

                # Throw execption.
                Write-CustomLog -Level Error -Message ('Failed to run esentutl.exe. {0}' -f $standardError);
            }
        }
        catch
        {
            # Throw execption.
            Write-CustomLog -Level Error -Message('Something went wrong while executing esentutl.exe. {0}' -f $_);
        }
    }
    END
    {
        # Write to log.
        Write-CustomProgress -ProgressId $progressId -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Running esentutl utility (esentutl.exe)' -Type 'End';

        # Return result.
        return $result;
    }
}