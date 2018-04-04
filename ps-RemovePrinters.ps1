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
# $LogToFile - (REQUIRED) A path to write the output to. The computer name will
#     be appended automatically. *DO NOT* include the trailing slash at the end
$PrintersToRemove = @("Printer1", "Printer2")
$PrintDriversToRemove = @("Driver1", "Driver2")
$LogToFile = "\\SERVER\TechFolder\printer_upgrade"

# The variables below should only be changed from the default if the scripts
# are not in this location!
$PrintingAdminScriptsFolder = "C:\Windows\System32\Printing_Admin_Scripts\en-US"
$PrintScriptFiles = @("prnmngr.vbs", "prndrvr.vbs")

# SANITY CHECKS
If (($PrintersToRemove.Length -eq 0) -Or ($LogToFile.Length -eq 0)) {
    Write-Host "Required variables not filled! Please edit the script and re-run"
    Exit 1
}
If (($PrintScriptFiles | ForEach {Test-Path ($PrintingAdminScriptsFolder + "\" + $_)}) -contains $false) {
    Write-Host "Required scripts not found in specified folder! I need the two
    VBS scripts inside of $($PrintingAdminScriptsFolder)
    in order to function!"
    Exit 2
}
If (!(Test-Path $LogToFile)) {
    New-Item -ItemType Directory -Force -Path $LogToFile
}
$LogToFile = Join-Path $LogToFile ($env:COMPUTERNAME + ".log")
Try {
    [io.file]::OpenWrite($LogToFile).close()
}
Catch {
    Write-Host "Unable to write to output file $LogToFile"
    Exit 4

}

#SCRIPT START
function Log {
    # Log function submitted by paulyphonic (https://social.technet.microsoft.com/Forums/office/en-US/4b8ee938-5e2e-429d-8d1c-3cd5c6abf9e4/trying-to-output-to-both-screen-and-file-but-teeobject-doesnt-seem-to-be-the-correct-answer?forum=winserverpowershell)
    param([string] $fileName, [switch] $echo, [switch] $clear )
    process {
        $input | % {
            if ($echo.IsPresent) { Write-Output $_ }
            [boolean] $isAppend = !$clear.IsPresent
            $_ | Out-File $fileName -Append:$isAppend | Out-Null
        }
    }
}

"Starting at $(Get-Date -Format g) on client $($env:COMPUTERNAME)" | Log $LogToFile -echo
C:\Windows\System32\cscript.exe //H:CSCRIPT //S | out-null
cd $PrintingAdminScriptsFolder
"" | Log $LogToFile -echo
"Removing selected printers..." | Log $LogToFile -echo
$PrintersToRemove | foreach {
    & .\prnmngr.vbs -d -p "$_".ToString() | findstr "0x80041002" | out-null
    If ($LASTEXITCODE -eq 0) {
        "    $_ does not exist" | Log $LogToFile -echo
    } else {
        "    $_ removed" | Log $LogToFile -echo
    }
}
"" | Log $LogToFile -echo

If($PrintDriversToRemove.count -gt 0) {
    "Removing selected Printer Drivers..." | Log $LogToFile -echo
    $PrintDriversToRemove | foreach {
        & .\prndrvr.vbs -d -m "$_" -v 3 -e "Windows x64".ToString() | findstr "0x80041002" | out-null
        If ($LASTEXITCODE -eq 0) {
            "    $_ does not exist" | Log $LogToFile -echo
        } else {
            "    $_ driver removed" | Log $LogToFile -echo
        }
    }
} else {
    "Removing excess Printer Drivers..." | Log $LogToFile -echo
    .\prndrvr.vbs -x
}