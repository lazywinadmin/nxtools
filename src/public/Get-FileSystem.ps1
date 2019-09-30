function Get-FileSystem
{
<#
.SYNOPSIS
    Retrieve the file systems information
.DESCRIPTION
    Retrieve the file systems information.
    This function is a wrapper around the systemctl command in Linux.

    This has been tested on Ubuntu, Redhat
.PARAMETER Path
    Specify the path of the filesystem to return
.EXAMPLE
    Get-FileSystem
.EXAMPLE
    Get-FileSystem -Path '/d/d5/'
#>
    [CmdletBinding()]
    PARAM(
        [ValidateNotNullOrEmpty]
        $Path)
    try{
        $FunctionName = (Get-Variable -Name MyInvocation -Scope 0 -ValueOnly).mycommand

        if(-not $IsLinux)
        {
            Write-Error -Message "[$functionname] Exiting, not a linux machine"
        }
        $Cmd = "df -B1 $Path --portability"
        Write-Verbose -Message "[$FunctionName] Executing command '$cmd'"
        $result = Invoke-Expression -Command $Cmd -ErrorAction Stop

        if($LASTEXITCODE -ne 0){
            Write-Verbose -Message "[$FunctionName] Something wrong happened. LastExitCode '$LastExitCode'"
            Write-Error -Message $result
        }

        Write-Verbose -Message "[$FunctionName] Parsing output..."
        # Replace the whitespaces by semi-colon
        $result -replace '\s+',';'|
        Select-Object -Skip 1 |
        ConvertFrom-Csv -Delimiter ";" -Header FileSystem,Size,Used,Free,'Used%','MountedOn'|
        Select-Object -Property FileSystem,Size,Free,Used,@{
            Label='Used%';
            Expression={
                $_.'Used%' -replace '%'
            }},
            MountedOn
    }
    catch
    {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}