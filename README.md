## Falcon Bulk Command Executor: Automate RTR Commands and Scripts Across Falcon Groups

**Overview**

The Falcon Bulk Command Executor is a PowerShell script that simplifies the execution of RTR commands or scripts across Falcon-managed Windows, Mac, and Linux devices belonging to a specified group. It utilizes the PSFalcon module to interact with the Falcon RTR API and efficiently execute tasks on multiple devices.

**Key Features:**

* **Group-based execution:** Target specific devices by defining a group name or a file containing group names. You can run commands on multiple groups.
* **Cross-platform support:** Execute commands or scripts on Windows, Mac, and Linux devices.
* **Script execution:** Run custom PowerShell, bash, or other scripts on supported platforms.
* **Argument support:** Provide arguments for both RTR commands and scripts.
* **Output generation:** Generate CSV files containing execution results and hostnames.

**Installation**

1. **Install PSFalcon:** Ensure you have PSFalcon 2.0 or later installed. Follow the instructions from the PSFalcon GitHub repository: [https://github.com/CrowdStrike/psfalcon](https://github.com/CrowdStrike/psfalcon)

2. **Create an API Client:**

   - Navigate to the "Support -> API Client and Keys" section in Falcon.
   - Create a new API Client and note down the `ClientId`, `ClientSecret`, and `Hostname`.

**Usage**

1. **Save the script:** Download or copy the script and save it as a `.ps1` file (e.g., `falcon_rtr_executor.ps1`).

2. **Set execution policy (if needed):** Depending on your PowerShell execution policy settings, you might need to run `Set-ExecutionPolicy Unrestricted` to allow execution.

3. **Request Falcon Token:** In order to execute command on endpoints you need to get token for falcon client. **This token need for each powershell session**. When you open the powershell interface, run ``` Request-FalconToken -ClientId [Your Client ID] -ClientSecret [Your Client Secret] -Hostname [Your Hostname] ``` command.

4. **Provide parameters:**
   * `-Command` (Mandatory): The RTR command to be executed (e.g., `ping`, `netstat`, `put`). If using `runscript`, the actual script content needs to be provided using the relevant parameter.
   * `-GroupIDPath` (Mandatory): Path to a text file containing the Falcon group name (one group name per line). **All group names should be written in lowercase letters**.
   * **Optional parameters:**
      * `-ArgumentsforWindows` (Arguments for the Windows script)
      * `-ArgumentsforMac` (Arguments for the Mac script)
      * `-ArgumentsforLinux` (Arguments for the Linux script)
      * `-ScriptPathforWindows` (Path to a PowerShell script for Windows clients)
      * `-ScriptPathforMac` (Path to a bash script for Mac clients)
      * `-ScriptPathforLinux` (Path to a bash script for Linux clients)
        * **You need to give ```runscript``` for "Command" argument in order to run script on endpoints**

5. **Run the script:** Execute the script from your PowerShell terminal using the following syntax:

   ``` powershell
   ./falcon_rtr_executor.ps1 -Command <command> -GroupIDPath <group_id_file_path> [Optional parameters]
   ```
**Examples:**

- Execute ```ping``` command on all devices in the **"Web Servers"** group:
``` powershell
./falcon_rtr_executor.ps1 -Command ping -GroupIDPath C:\FalconScripts\web_server_group.txt [Optional parameters]
```

- Run a custom PowerShell script named **restart_apache.ps1** on Windows devices in the **"Web Servers"** group:

``` powershell
./falcon_rtr_executor.ps1 -Command runscript -GroupIDPath C:\FalconScripts\web_server_group.txt -ScriptPathforWindows C:\FalconScripts\restart_apache.ps1
```

- Run a custom Powershell script named **uptime.ps1** on Windows devices and a custom Bash script named **uptime.sh** on Linux devices in the **"Web Servers"** group:

``` powershell
./falcon_rtr_executor.ps1 -Command runscript -GroupIDPath C:\FalconScripts\web_server_group.txt -ScriptPathforWindows C:\FalconScripts\uptime.ps1 -ScriptPathForLinux C:\FalconScripts\uptime.sh
```

**Additional Information:**

- The script outputs CSV files for each OS type (Windows, Mac, Linux) containing the results of the executed command or script, along with the corresponding hostnames.

**Further Enhancements:**

- Error handling for invalid parameters or script execution failures.
- Progress indicators for longer-running commands.
