[CmdletBinding()]
param(
  # we limit the inputs to the 5 possible save slots
  # [ValidateSet("Slot1", "Slot2", "Slot3", "Slot4", "Slot5")]


  # Accept time in N hours for every backup
  [Parameter(HelpMessage = "")]
  [int]$BackupEveryNHours = 12,

  # Backup start time
  [Parameter(HelpMessage = "")]
  [int]$BackupStartTime = 0,

  # Accept time in n days for every TFDS restart
  # might not need if I set up auto server stop/start
  [Parameter(HelpMessage = "")]
  [int]$RestartFrequency = 1,

  # Restart start time
  [Parameter(HelpMessage = "")]
  [int]$RestartStartTime = 0

)

# Set-Location is going to be useful

# "Global" variables
$curDirectory = Get-Location
$scriptDirectory = "C:\Servers\TheForest\scripts"

function Main {

  $action = New-ScheduledTaskAction -Execute Powershell.exe `
                                    -Argument '-File $scriptDirectory\RestartServer.ps1'
  $trigger1 = New-ScheduledTaskTrigger -DaysInterval $RestartFrequency
  $trigger2 = New-ScheduledTaskTrigger -AtStartup

  Register-ScheduledTask  -TaskName "Restart TFDS Server" `
                          -Action $action
                          -Trigger $trigger1, $trigger2

  # Register-ScheduledTask vs Register-ScheduledJob?
}

Get-Location -Stack