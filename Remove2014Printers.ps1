# Remove old printers by name - Written by Luke Barone
#
# VARIABLES TO EDIT
# $PrintersToRemove - (REQUIRED) An array of printers to cycle through and
#     remove. Use the exact name of the printer to have it included in the list
# $PrintDriversToRemove - (optional) An array of printer drivers to cycle
#     through and remove. You can obtain a list by running the "prndrvr.vbs -l"
#     command on a computer with drivers to remove. Alternatively, you can
#     leave the array empty, and the script will remove any unused (determined
#     by the system) print drivers automatically.
$PrintersToRemove = @("Printer1", "Printer2")
$PrintDriversToRemove = @("Driver1", "Driver2")

# The variables below should only be changed from the default if the scripts
# are not in this location!
$PrintingAdminScriptsFolder = "C:\Windows\System32\Printing_Admin_Scripts\en-US"
$PrintScriptFiles = @("prnmngr.vbs", "prndrvr.vbs")

# SANITY CHECKS
If ($PrintersToRemove.Length -eq 0) {
    Write-Host "Required variable not filled! Please edit the script and re-run"
    Exit 1
}
If (($PrintScriptFiles | ForEach {Test-Path ($PrintingAdminScriptsFolder + "\" + $_)}) -contains $false) {
    Write-Host "Required scripts not found in specified folder! I need the two
    VBS scripts inside of $($PrintingAdminScriptsFolder)
    in order to function!"
    Exit 2
}

#SCRIPT START
Write-Host "Starting at $(Get-Date -Format g) on client $($env:COMPUTERNAME)"
C:\Windows\System32\cscript.exe //H:CSCRIPT //S | out-null
cd $PrintingAdminScriptsFolder
Write-Host ""
Write-Host "Removing selected printers..."
$PrintersToRemove | foreach {
    & .\prnmngr.vbs -d -p "$_".ToString() | findstr "0x80041002" | out-null
    If ($LASTEXITCODE -eq 0) {
        Write-Host "    $_ does not exist"
    } else {
        Write-Host "    $_ removed"
    }
}
Write-Host ""

If($PrintDriversToRemove.count -gt 0) {
    Write-Host "Removing selected Printer Drivers..."
    $PrintDriversToRemove | foreach {
        & .\prndrvr.vbs -d -m "$_" -v 3 -e "Windows x64".ToString() | findstr "0x80041002" | out-null
        If ($LASTEXITCODE -eq 0) {
            Write-Host "    $_ does not exist"
        } else {
            Write-Host "    $_ driver removed"
        }
    }
} else {
    Write-Host "Removing excess Printer Drivers..."
    .\prndrvr.vbs -x
}