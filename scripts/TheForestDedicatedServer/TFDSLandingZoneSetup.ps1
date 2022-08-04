<#
    Written by Matthew Johnson, March 14, 2020

    TFDSLandingZoneSetup.ps1

    This script does the following:
      * downloads necessary files
      * creates directories
      * unzips if necessary
      * installs files
      * creates shortcut with launch parameters

    This might have to get creative with locked down
    instance, or maybe that's just internet explorer.

    "You must provide to a curl command the proxy host, port, and credentials if
    authenticated. SL errors could be thrown because of this"
#>

$steamCMDUrl = "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip"
$dxwebsetupUrl = "https://download.microsoft.com/download/1/7/1/1718CCC4-6315-4D8E-9543-8E28A4E18C4C/dxwebsetup.exe"


# returns timestamp
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

  if ($isTesting -eq $true) {
      
  }
}

# creates directory where everything will be set up
function Make-Dir {
  param(
    [Parameter(HelpMessage = "The default directory is C:\Servers")]
    [string]$DirectoryToCreate = "C:\Servers"
  )

  $logFileName = "Landing_Zone_Setup_Logs.txt"
  
  if (-not (Test-Path $DirectoryToCreate -PathType Container)) {
    try {
      New-Item -Path $DirectoryToCreate -ItemType Directory -ErrorAction Stop | Out-Null #-Force
    }
    catch {
      $output = "Unable to create directory '$DirectoryToCreate'. Error was: $_"
      Write-Log -output $output -fileName $logFileName
    }

    $output = "Successfully created directory '$DirectoryToCreate'."
    Write-Log -output $output -fileName $logFileName
  }
  else {
    $output = "Directory already exists"
    Write-Log -output $output -fileName $logFileName
  }
}

<#
  This file is designed to download the two necessary files
  for TFDS. This doesn't offer any support for other files.
#>
function Download-File {

  param(
    [Parameter(Mandatory = $true)]
    [string]$url,
    [Parameter(HelpMessage = "Default is the current directory")]
    [string]$destination = "$pwd\",
    [Parameter(HelpMessage = "Default file name is 'file.txt'")]
    [string]$fileName = "file.txt"
  )

  # this is shit code, fix it lol
  if ($url -eq $steamCMDUrl) {
    $destination += "steamcmd.zip"
  } elseif ($url -eq $dxwebsetupUrl) {
    $destination += "dxwebsetup.exe"
  } else  {
    $destination += $fileName
  }

  $file = New-Object System.Net.WebClient
  $file.DownloadFileAsync($url, $destination)
}

function Is-Valid-Url ([string]$url) {
    
  $result = Invoke-WebRequest $url
  return ($result.StatusCode -eq 200)
}

function Main {

  <#
    move to C:\
    Create new paths
    * C:\Servers\
    * C:\Servers\TheForest\
    * C:\Servers\TheForest\scripts\
    * C:\Servers\TheForest\logs\
    * C:\Servers\TheForest\SteamCMD\

    Check URLs and download 2 files

    Unzip and/or run files. Somehow automate that.

    Call/run steamCMD to install TFDS and wait

    Create shortcut in \scripts and add launch parameters
  #>

  [string[]]$dirsToMake = "C:\Servers\", `
                          "C:\Servers\TheForest\", `
                          "C:\Servers\TheForest\scripts\", `
                          "C:\Servers\TheForest\logs\", `
                          "C:\Servers\TheForest\SteamCMD\"

  foreach ($directory in $dirsToMake) {
    Make-Dir($directory)
  }
}
