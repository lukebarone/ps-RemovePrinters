<#
.SYNOPSIS
  Remove old printers by name. This version requires Windows Vista or higher

.DESCRIPTION
  This Cmdlet takes in a list of printers, and cycles through the removal
  process. If the printer does not exist, an error is NOT logged, and the
  script can continue. This behaviour is intentional in order to allow SysAdmins
  to deploy the script silently to their users, and gain the results back.

.PARAMETER PrintersToRemove
  (REQUIRED) An array of printers to cycle through and
  remove. Use the exact name of the printer to have it included in the list

.PARAMETER PrintDriversToRemove
  (optional) An array of printer drivers to cycle
  through and remove. You can obtain a list by running the "prndrvr.vbs -l"
  command on a computer with drivers to remove. Alternatively, you can
  leave the array empty, and the script will remove any unused (determined
  by the system) print drivers automatically.

.NOTES
  Written by Luke Barone. (C) 2018

.LINK
  https://github.com/lukebarone/ps-RemovePrinters

#>
[CmdletBinding()]
param (
    [Parameter(Mandatory=$True)] [string[]]$PrintersToRemove,
    [Parameter(Mandatory=$False)][string[]]$PrintDriversToRemove
)

# The variables below should only be changed from the default if the scripts
# are not in this location!
$PrintingAdminScriptsFolder = "C:\Windows\System32\Printing_Admin_Scripts\en-US"
$PrintScriptFiles = @("prnmngr.vbs", "prndrvr.vbs")

# SANITY CHECK
If (($PrintScriptFiles | ForEach {Test-Path ($PrintingAdminScriptsFolder + "\" + $_)}) -contains $false) {
    Write-Host "Required scripts not found in specified folder! I need the two
    VBS scripts inside of $($PrintingAdminScriptsFolder) in order to function!"
    Exit 1
}

#SCRIPT START
Write-Output "Starting at $(Get-Date -Format g) on client $($env:COMPUTERNAME)"
C:\Windows\System32\cscript.exe //H:CSCRIPT //S | out-null
cd $PrintingAdminScriptsFolder
Write-Output ""
Write-Output "Removing selected printers..."
$PrintersToRemove | foreach {
    & .\prnmngr.vbs -d -p "$_".ToString() | findstr "0x80041002" | out-null
    If ($LASTEXITCODE -eq 0) {
        Write-Output "    $_ does not exist"
    } else {
        Write-Output "    $_ removed"
    }
}
Write-Output ""

If($PrintDriversToRemove.count -gt 0) {
    Write-Output "Removing selected Printer Drivers..."
    $PrintDriversToRemove | foreach {
        & .\prndrvr.vbs -d -m "$_" -v 3 -e "Windows x64".ToString() | findstr "0x80041002" | out-null
        If ($LASTEXITCODE -eq 0) {
            Write-Output "    $_ does not exist"
        } else {
            Write-Output "    $_ driver removed"
        }
    }
} else {
    Write-Output "Removing excess Printer Drivers..."
    .\prndrvr.vbs -x
}