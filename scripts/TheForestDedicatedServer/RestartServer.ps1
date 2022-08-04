[CmdletBinding()]
param(
    # flag to test script instead of running
    [switch]$isTesting
)


function Is-Running {
    $active = Get-Process "TheForestDedicatedServer" -ErrorAction SilentlyContinue
    if ($active -ne $null) {return $true}
    else {return $false}
}

function Timestamp {
    return Get-Date -Format "[yyyy-MM-dd HH:mm:ss]"
}

function Start-Server {
    Start-Process -FilePath "TheForestDedicatedServer"

    if ($isTesting) {

    }
}

# stops the process and waits until actually stopped
function Stop-Server {
    Stop-Process -Name "TheForestDedicatedServer" -Force
    Wait-Process -Name "TheForestDedicatedServer"

    if ($isTesting) {

    }
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

function Function-Tests {

    Write-Host "`nTesting functions`n-----------------------"
    Write-Host "Testing Start-Server"
    Start-Server

    Write-Host "`nTesting Is-Running"
    Is-Running

    Write-Host "`nTesting Stop-Server"
    Stop-Server

    Write-Host "`nTesting Is-Running, stopped server"
    Is-Running

    Write-Host "`nTesting Timestamp"
    Timestamp

    Write-Host "`nTesting Write-Log"
    Write-Log -output "Testing, 1, 2, 3" -fileName "test_log.txt"

    Write-Host "`nFinished file testing"

}


function Main {

$logFile = "restart_server_log.txt"

    if (Is-Running) {

        Write-Log -output "Server currently running. Attempting to restart server." -fileName $logFile

        do {Stop-Server} until (Is-Running -eq $false)
        
        Write-Log -output "Server successfully stopped." -filename $logFile
        Write-Log -output "Attempting to start again." -filename $logFile

        do {Start-Server} until (Is-Running)

        Write-Log -output "Server successfully restarted." -filename $logFile

    } else {

        Write-Log -output "Server wasn't running. Attempting to start server." -filename $logFile
        
        do {Start-Server} until (Is-Running)

        Write-Log -output "Server now running." -filename $logFile
    }
}

if ($isTesting) {Function-Tests}
else {Main}