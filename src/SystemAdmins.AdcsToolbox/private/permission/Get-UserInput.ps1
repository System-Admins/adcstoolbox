function Get-UserInput
{
    <#
    .SYNOPSIS
        Get user input.
    .DESCRIPTION
        Validate user input and return.
    .PARAMETER Question
        Ask the user a question.
    .PARAMETER Options
        Options to choose from.
    .EXAMPLE
        Get-UserInput -Question 'Choose an option' -Options 'Option1', 'Option2', 'Option3';
    #>
    [cmdletbinding()]
    [OutputType([string[]])]
    param
    (
        # Question to ask the user.
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Question,

        # Options to choose from.
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Options
    )

    BEGIN
    {
        # Write to log.
        $progressId = Write-CustomProgress -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Ask for user input' -Type 'Begin';
    }
    PROCESS
    {
        # Ask user.
        do
        {
            # Flag to check if the user input is valid.
            [bool]$isValid = $true;

            # Ask the user.
            $userInput = Read-Host -Prompt $Question;

            # If the user input is not in the options.
            if ($Options -notcontains $userInput)
            {
                # Set flag to false.
                $isValid = $false;
            }
        }
        # While the flag is false.
        while($false -eq $isValid);

        # Write to log.
        Write-CustomLog -Message ("User input '{0}' is valid" -f $userInput) -Level Verbose;
    }
    END
    {
        # Write to log.
        Write-CustomProgress -ProgressId $progressId -Activity $MyInvocation.MyCommand.Name -CurrentOperation 'Ask for user input' -Type 'End';

        # Return user input.
        return $userInput;
    }
}