[CmdletBinding()]
param(
    # flag to test script instead of running
    [switch]$isTesting,

    # we limit the inputs to the 5 possible save slots
    # input is an array and can save any number of slots
    # default saves Slot1 only
    [ValidateSet("Slot1", "Slot2", "Slot3", "Slot4", "Slot5")]
    [string[]]$SaveSlot = "Slot1"
)

# returns time-sortable timestamp
function Timestamp([switch]$save, [switch]$log) {

    if ($save) {return Get-Date -Format "yyyy-MM-dd--HH-mm-ss"}
    if ($log) {return Get-Date -Format "[yyyy-MM-dd HH:mm:ss] "}

}

function Write-Log {

    param(
        [string]$output, 
        [string]$path = "C:\Servers\logs\", 
        [string]$fileName = "log.txt"
    )

    $timestamp = Timestamp -log
    $contents = $timestamp + $output
    $fullPath = $path + $fileName

    Add-Content -Path $fullPath -Value $contents -Force

    if ($isTesting) {
        
    }

}

# copy file, move it into ./backups/SlotN/[timestamp]
Function Make-Backup([string]$slot) {

    $saveName = Timestamp -save 
    $saveName += "-backup"
    $curUser = $env:username
    $savePath = "C:\Users\$curUser\AppData\LocalLow\SKS\TheForestDedicatedServer\ds\Multiplayer\$slot"
    $destination = "C:\Servers\TheForest\backups\$slot\$saveName"
    $logName = "backups_log.txt"

    if (Test-Path $savePath) {

        $output = "Attempting to make backup."

        # test destination path is valid, \backups might not exist
        $result = Copy-Item -Path $savePath -Destination $destination -ErrorAction SilentlyContinue -Recurse -PassThru

        Write-Log -output $output -fileName $logName

        if ($result -ne $null) {
            $output = "Backup of $slot successful. Located at '$destination'."
        } else {
            $output = "Cannot find path '$path' because it does not exist."
        }

        Write-Log -output $output -fileName $logName

    } else {

        $output = "$slot not found, skipping."
        
        Write-Log -output $output -fileName $logName

    }
  
}


function Function-Tests {

    Write-Host "`nTesting functions`n-----------------------"
    Write-Host "Testing Start-Server"
    # Start-Server

    Write-Host "`nTesting Is-Running"
    # Is-Running

    Write-Host "`nTesting Stop-Server"
    # Stop-Server

    Write-Host "`nTesting Is-Running, stopped server"
    # Is-Running

    Write-Host "`nTesting Timestamp"
    # Timestamp

    Write-Host "`nTesting Write-Log"
    Write-Log -output "Testing, 1, 2, 3" -fileName "test_log.txt"

    Write-Host "`nFinished file testing"

}

function Main {
    # might use -recurse flag

    foreach ($slot in $SaveSlot) {
        Make-Backup($slot)
    }

    $logName = "backups_log.txt"
    Write-Log -output "Finished backing up save files." -fileName $logName

}

if ($isTesting) {Function-Tests}
else {Main}
