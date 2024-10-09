function Invoke-CertUtil
{
    <#
    .SYNOPSIS
        Invoke certificate utility (certutil.exe).
    .DESCRIPTION
        Return output from the certificate utility.
    .EXAMPLE
        Invoke-CertUtil;
    #>
    [cmdletbinding()]
    [OutputType([bool])]
    param
    (
        # Arguments to pass to the certutil utility.
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Arguments
    )

    BEGIN
    {
        # Write to log.
        $progressId = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Running certificate utility (certutil.exe)' -Type 'Start';

        # Path to the utility.
        [string]$utilityPath = 'C:\Windows\System32\certutil.exe';

        # Output.
        [string]$result = '';
    }
    PROCESS
    {
        # Test if the utility exists.
        $certUtilAvailable = Test-CertUtil;

        # If the utility does not exist.
        if ($false -eq $certUtilAvailable)
        {
            # Throw execption.
            throw ('The certificate utility (certutil.exe) is not available, aborting');
        }

        # Create process object.
        $processStartInfo = New-Object System.Diagnostics.ProcessStartInfo;
        $processStartInfo.FileName = $utilityPath;
        $processStartInfo.RedirectStandardError = $true;
        $processStartInfo.RedirectStandardOutput = $true;
        $processStartInfo.UseShellExecute = $false;
        $processStartInfo.CreateNoWindow = $true;

        # If arguments is specified.
        if (!([string]::IsNullOrEmpty($Arguments)))
        {
            # Set arguments.
            $processStartInfo.Arguments = $Arguments;
        }

        # Try to run certutil.exe with arguments.
        try
        {
            # If arguments is set.
            if (!([string]::IsNullOrEmpty($Arguments)))
            {
                # Write to log.
                Write-CustomLog -Message ("Trying to execute certutil.exe with arguments '{0}'" -f $Arguments) -Level Verbose;
            }
            # Else no arguments.
            else
            {
                # Write to log.
                Write-CustomLog -Message 'Trying to execute certutil.exe without arguments' -Level Verbose;
            }

            # Start the certutil process.
            $process = New-Object System.Diagnostics.Process;
            $process.StartInfo = $processStartInfo;
            $null = $process.Start();
            $process.WaitForExit();

            # If exit code is not 0 (success).
            if ($process.ExitCode -eq 0)
            {
                # If arguments is set.
                if (!([string]::IsNullOrEmpty($Arguments)))
                {
                    # Write to log.
                    Write-CustomLog -Message ("Succesfully executed certutil.exe with arguments '{0}'" -f $Arguments) -Level Verbose;
                }
                # Else no arguments.
                else
                {
                    # Write to log.
                    Write-CustomLog -Message 'Succesfully executed certutil.exe without arguments' -Level Verbose;
                }

                # Get output.
                $result = $process.StandardOutput.ReadToEnd();
            }
            # Else if the exit code is 939523027 (success, but throttled).
            elseif ($process.ExitCode -eq 939523027)
            {
                # Write to log.
                Write-CustomLog -Message ('Succesfully executed certutil.exe, but code exit code 939523027 (which mean throttled). Will retry operation' -f $Arguments) -Level Verbose;

                # Retry the process.
                $null = Invoke-CertUtility -Arguments $Arguments;
            }
            # Else exit code is not 0 (mayby an error).
            else
            {
                # Get error.
                $standardError = $process.StandardError.ReadToEnd();

                # Throw execption.
                throw ('Failed to run certutil.exe. {0}' -f $standardError);
            }
        }
        # Something went wrong.
        catch
        {
            # Throw execption.
            throw ('Something went wrong while executing certutil.exe. {1}' -f $Arguments, $_);
        }
    }
    END
    {
        # Write to log.
        Write-CustomProgress -Id $progressId -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Running certificate utility (certutil.exe)' -Type 'End';

        # Return result.
        return $result;
    }
}