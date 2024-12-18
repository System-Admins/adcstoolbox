function Convert-ObjectToByte
{
    <#
    .SYNOPSIS
        Convert object to byte array.
    .DESCRIPTION
        Return byte array.
    .EXAMPLE
        Convert-ObjectToByte;
    #>
    [cmdletbinding()]
    [OutputType([byte[]])]
    param
    (
        # Object to convert to byte array.
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [object]$InputObject
    )

    BEGIN
    {
        # Write to log.
        $customProgress = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Convert input object to byte array';

        # Variable for the byte array result.
        [byte[]]$byteArray = $null;

        # Create a MemoryStream.
        $memoryStream = New-Object System.IO.MemoryStream;

        # Create a BinaryFormatter
        $binaryFormatter = New-Object System.Runtime.Serialization.Formatters.Binary.BinaryFormatter;
    }
    PROCESS
    {
        # Try to serialize the object to a MemoryStream.
        try
        {
            # Serialize the object to the MemoryStream
            $binaryFormatter.Serialize($memoryStream, $InputObject);

            # Convert the MemoryStream to a byte array
            $byteArray = $memoryStream.ToArray();
        }
        # Finally close stream.
        finally
        {
            # Clean up.
            $memoryStream.Close();
            $memoryStream.Dispose();
        }
    }
    END
    {
        # Write to log.
        Write-CustomProgress @customProgress;

        # Return result.
        return $byteArray;
    }
}