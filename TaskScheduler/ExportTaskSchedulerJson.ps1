#requires -version 2
<#
.SYNOPSIS
  Export TaskScheduler tasks to JSON
.DESCRIPTION
  This script will get the list of TaskScheduler tasks with details from Windows and save to the JSON file.
  The tasks will be filtered by Author excluding empty, null and Microsoft Corporation that usually refer
  to system tasks.
.PARAMETER TaskPaths
    Array of TaskScheduler paths to export. Each string must begin and end with backslash. Star wildcard can be used.
.PARAMETER File
    Full path of the output file.
.INPUTS
  None
.OUTPUTS
  None
.NOTES
  Version:        1.0
  Author:         Stan Smoltis
  Creation Date:  20/02/2019
  Purpose/Change: Initial script development
  Website: https://github.com/smoltis/posh

.EXAMPLE
  .\ExportTaskSchedulerJson.ps1 -TaskPaths "\*\","\MyTasks\" -File "D:\github\posh\myTasks.json"
#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

param (
    [string[]]$TaskPaths = @("\*\"),
    [string]$File = "TaskScheduler.json"
    )
#-----------------------------------------------------------[Execution]------------------------------------------------------------

try{

    $json = $TaskPaths | 
        ForEach-Object { 
            Get-ScheduledTask -TaskPath $_.ToString() | 
            Where-Object { $_.Author -ne "Microsoft Corporation" -and $_.Author -ne "" -and $_.Author -ne $null } |
            ForEach-Object { 
                [pscustomobject]@{
                Name = $_.TaskName
                Path = $_.TaskPath
                LastRunTime = $(($_ | Get-ScheduledTaskInfo).LastRunTime)
                LastResult = $(($_ | Get-ScheduledTaskInfo).LastTaskResult)
                NextRunTime = $(($_ | Get-ScheduledTaskInfo).NextRunTime)
                Status = $_.State
                Command = $_.Actions.execute
                Arguments = $_.Actions.Arguments 
                Created = $_.Created
                Author = $_.Author
                Description = $_.Description
                }
            }
        }
    if ($json -ne $null -and $json -ne "") {
        $json | ConvertTo-Json | Out-File $File
        }

    }
catch {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Write-Host "{$FailedItem}: {$ErrorMessage}"
}

