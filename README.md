# ps-RemovePrinters
Powershell script to remove printers and drivers in Windows 7+

# Getting things ready
This script requires Windows 7+, with Powershell installed. Testing is 
still required on different architectures, so please open an issue if 
something does not work!

Currently, it will look for **Version 3** drivers for **Windows x64** 
arch when deleting drivers by name.

## Switches

- **`$PrintersToRemove`** - (REQUIRED) An array of printers to cycle through and remove. Use the exact name of the printer to have it included in the list.
- **`$PrintDriversToRemove`** - (optional) An array of printer drivers to cycle though and remove. You can obtain a list by running the `prndrvr.vbs -l` command on your computer. Alternatively, if this variable is empty, the script will remove any drivers not currently in 
use.

# Running the script

You can either deploy it with your favourite remote-management tool, or run it locally. The tool will require Admin Rights to remove printers not installed by the user. If you use shared printers and the user has the shared printer mapped, then the script should remove it if included in the printer list.
