function Invoke-CertUtil
{
    <#
    .SYNOPSIS
        Invoke certificate utility (certutil.exe).
    .DESCRIPTION
        Return output from the certificate utility.
    .PARAMETER Arguments
        Arguments to pass to the cert
    .EXAMPLE
        Invoke-CertUtil;
    .EXAMPLE
        Invoke-CertUtil -Arguments '-pulse';
    #>
    [cmdletbinding()]
    [OutputType([string])]
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
        $customProgress = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Running certificate utility (certutil.exe)';

        # Path to the utility.
        [string]$utilityPath = 'C:\Windows\System32\certutil.exe';

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
                # Write to log.
                Write-CustomLog -Message ('Succesfully executed certutil.exe') -Level Verbose;

                # Get output.
                $result = $process.StandardOutput.ReadToEnd();
            }
            # Else if the exit code is 939523027 (success, but throttled).
            elseif ($process.ExitCode -eq 939523027)
            {
                # Write to log.
                Write-CustomLog -Message ('Succesfully executed certutil.exe, but code exit code 939523027 (which mean throttled). Will retry operation' -f $Arguments) -Level Verbose;

                # Retry the process.
                $null = Invoke-CertUtil -Arguments $Arguments;
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
            throw ('Something went wrong while executing certutil.exe. {0}' -f $_);
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