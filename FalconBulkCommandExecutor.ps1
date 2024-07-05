using module @{ ModuleName = 'PSFalcon'; ModuleVersion = '2.0' }
param(
    [Parameter(Mandatory = $true,
        Position = 1)]
    [string] $Command, ##Parameter of the command to be executed

    [Parameter(Mandatory = $true,
        Position = 2)]
    [string] $GroupIDPath, ## Parameter of the group to be command to be executed
    
    [Parameter(Position = 3)]
    [string] $ArgumentsforMac, ## Parameter of if any command to be executed with arguments in Mac clients

    [Parameter(Position = 4)]
    [string] $ArgumentsforWindows, ## Parameter of if any command to be executed with arguments in Windows clients

    [Parameter(Position = 5)]
    [string] $ArgumentsforLinux, ## Parameter of if any command to be executed with arguments in Linux clients

    [Parameter(Position = 6)]
    [string] $ScriptPathforMac, ## Parameter of if any script to be executed in Mac clients

    [Parameter(Position = 7)]
    [string] $ScriptPathforWindows, ## Parameter of if any script to be executed in Windows clients

    [Parameter(Position = 8)]
    [string] $ScriptPathforLinux, ## Parameter of if any script to be executed in Linux clients
    )
## A function for execute command or run any script##
function uploadCommand
{
    param (
            $GroupName, 
            $SPFW, # Boolean value for ScriptPathforWindows
            $SPFM, # Boolean value for ScriptPathforMac
            $SPFL, # Boolean value for ScriptPathforLinux
            $AFW, # Boolean value for ArgumentsforWindows
            $AFM, # Boolean value for ArgumentsforMac
            $AFL  # Boolean value for ArgumentsforLinux
    )
    echo "GroupName:'$GroupName'"
    $GroupId = Get-FalconHostGroup -Filter "name:'$($GroupName.ToLower())'" ## GroupName to GroupID
    echo "GroupId:'$GroupId'"
    $Members=[System.Collections.ArrayList]@()
    $empty=$Members.add( (Get-FalconHostGroupMember -Id $GroupId -All) )## To take Members from GroupID
    $HostCounter=0
    $WinCount=0
    $MacCount=0
    $LinuxCount=0
    $WinHosts=[System.Collections.ArrayList]@()
    $LinuxHosts=[System.Collections.ArrayList]@()
    $MacHosts=[System.Collections.ArrayList]@()
    $OSVersion=[System.Collections.ArrayList]@()
    $HostIDforOS=[System.Collections.ArrayList]@()
    $HostIDforOS=$Members.Split(" ")
    foreach ($Item in $HostIDforOS){ ##For adding hosts in specific array list for OS
            $ArrayID=$OSVersion.Add( (Get-FalconHost -Filter "device_id:'$Item'" -detailed | select platform_name) )
                if($OSVersion[$HostCounter] -like "*windows*"){
                    $ArrayID=$WinHosts.add(""+$Item)
                    $WinCount++
                }
                elseif($OSVersion[$HostCounter] -like "*linux*"){
                    $ArrayID=$LinuxHosts.add(""+$Item)
                    $LinuxCount++
                }
                elseif($OSVersion[$HostCounter] -like "*mac*" ){
                    $ArrayID=$MacHosts.add(""+$Item)
                    $MacCount++
                }
                $HostCounter++
    }
    $ExportNameWin = "$pwd\rtrWinHosts_$($Command -replace ' ','_')_$GroupId.csv" ## For Export output for command or script
    $ExportNameMac = "$pwd\rtrMacHosts_$($Command -replace ' ','_')_$GroupId.csv" ## For Export output for command or script
    $ExportNameLinux = "$pwd\rtrLinuxHosts_$($Command -replace ' ','_')_$GroupId.csv" ## For Export output for command or script
        if($Command -eq "runscript"){
                if( ($WinCount -ne 0) -and ($SPFW) ){ ## Executing powershell script in Windows clients
                    echo "Script runs on Windows clients"
                    $EncodedScript = [Convert]::ToBase64String(## If Command is "runscript" it will be convert to Base64 to be executed for Windows
                        [System.Text.Encoding]::Unicode.GetBytes((Get-Content -Path $ScriptPathforWindows -Raw)))
                    $Param = @{
                        Command = 'runscript'
                        Arguments = '-Raw=```powershell.exe -Enc ' + $EncodedScript + '```'## To run from command line with powershell
                        HostIds = $WinHosts
                    }
                    Invoke-FalconRTR @Param | Export-Csv -Path $ExportNameWin  
                    $Csv = Import-Csv $ExportNameWin
                    foreach ($Row in $Csv)#For Add our csv to hostname column
                    {
                        $Data = $Row | select aid
                        echo $Data > hostIDS.txt
                        $Data1=Get-Content hostIDS.txt 
                        $Data1=$Data1[3]
                        $Data =Get-FalconHost -Filter "device_id:'$Data1'" -detailed | select hostname
                        $Row | Add-Member -Name 'hostname' -Value $Data -MemberType NoteProperty
                    }
                    $Csv | Export-Csv -Path $ExportNameWin -NoTypeInformation}
                if( ($LinuxCount -ne 0) -and ($SPFL)){ ##Executing bash script in Linux clients
                    echo "Script runs on Linux clients"
                    $LinuxScript = Get-Content -Path $ScriptPathforLinux -Raw
                        $Param = @{
                        Command = 'runscript'
                        Arguments = '-Raw=```'+$LinuxScript+'```'
                        HostIds = $LinuxHosts
                    }
                    Invoke-FalconRTR @Param | Export-Csv -Path $ExportNameLinux
                    $Csv = Import-Csv $ExportNameLinux
                    foreach ($Row in $Csv)#For Add our csv to hostname column
                    {
                        $Data = $Row | select aid
                        echo $Data > hostIDS.txt
                        $Data1=Get-Content hostIDS.txt 
                        $Data1=$Data1[3]
                        $Data =Get-FalconHost -Filter "device_id:'$Data1'" -detailed | select hostname
                        $Row | Add-Member -Name 'hostname' -Value $Data -MemberType NoteProperty
                    }
                    $Csv | Export-Csv -Path $ExportNameLinux -NoTypeInformation}
                if( ($MacCount -ne 0) -and ($SPFM)){##Executing bash script in Mac clients
                    echo "Script runs on Mac clients"
                    $MacScript = Get-Content -Path $ScriptPathforMac -Raw
                        $Param = @{
                        Command = 'runscript'
                        Arguments = '-Raw=```'+$MacScript+'```'
                        HostIds = $MacHosts
                    }
                    Invoke-FalconRTR @Param | Export-Csv -Path $ExportNameMac
                    $Csv = Import-Csv $ExportNameMac
                    foreach ($Row in $Csv)#For Add our csv to hostname column
                    {
                        $Data = $Row | select aid
                        echo $Data > hostIDS.txt
                        $Data1=Get-Content hostIDS.txt 
                        $Data1=$Data1[3]
                        $Data =Get-FalconHost -Filter "device_id:'$Data1'" -detailed | select hostname
                        $Row | Add-Member -Name 'hostname' -Value $Data -MemberType NoteProperty
                    }
                    $Csv | Export-Csv -Path $ExportNameMac -NoTypeInformation}
                echo "--------------------------------------------------------------"
                }
        else {           
            if( ($WinCount -ne 0) -and ($AFW) ){ ## Execute RTR commands on Windows clients
                $Param = @{
                        Command = $Command
                        Argument = $ArgumentsforWindows
                        HostIds = $WinHosts
                        }
                echo "Command runs in Windows clients"
                Invoke-FalconRTR @Param | Export-Csv -Path $ExportNameWin ## Running command
                $Csv = Import-Csv $ExportNameWin
                foreach ($Row in $Csv)#For Add our csv to hostname column
                {
                    $Data = $Row | select aid
                    echo $Data > hostIDS.txt
                    $Data1=Get-Content hostIDS.txt 
                    $Data1=$Data1[3]
                    $Data =Get-FalconHost -Filter "device_id:'$Data1'" -detailed | select hostname
                    $Row | Add-Member -Name 'hostname' -Value $Data -MemberType NoteProperty
                }
                $Csv | Export-Csv -Path $ExportNameWin -NoTypeInformation}   
            if( ($MacCount -ne 0) -and ($AFM)){## Execute RTR commands on Mac clients
                $Param = @{
                                Command = $Command
                                Argument = $ArgumentsforMac
                                HostIds = $MacHosts
                            }
                        echo "Command runs in Mac clients"
                        Invoke-FalconRTR @Param | Export-Csv -Path $ExportNameMac ## Running command
                        $Csv = Import-Csv $ExportNameMac
                        foreach ($Row in $Csv)#For Add our csv to hostname column
                        {
                            $Data = $Row | select aid
                            echo $Data > hostIDS.txt
                            $Data1=Get-Content hostIDS.txt 
                            $Data1=$Data1[3]
                            $Data =Get-FalconHost -Filter "device_id:'$Data1'" -detailed | select hostname
                            $Row | Add-Member -Name 'hostname' -Value $Data -MemberType NoteProperty
                        }
                        $Csv | Export-Csv -Path $ExportNameMac -NoTypeInformation
                }
            if( ($LinuxCount -ne 0) -and ($AFL)){ ## Execute RTR commands on Linux clients
                    $Param = @{
                                Command = $Command
                                Argument = $ArgumentsforLinux
                                HostIds = $LinuxHosts
                            }
                        echo "Command runs in Linux Clients"
                        Invoke-FalconRTR @Param | Export-Csv -Path $ExportNameLinux ## Running command
                        $Csv = Import-Csv $ExportNameLinux

                        foreach ($Row in $Csv)#For Add our csv to hostname column
                        {
                            $Data = $Row | select aid
                            echo $Data > hostIDS.txt
                            $Data1=Get-Content hostIDS.txt 
                            $Data1=$Data1[3]
                            $Data =Get-FalconHost -Filter "device_id:'$Data1'" -detailed | select hostname
                            $Row | Add-Member -Name 'hostname' -Value $Data -MemberType NoteProperty
                        }
                        $Csv | Export-Csv -Path $ExportNameLinux -NoTypeInformation
                }
                echo "--------------------------------------------------------------"
    }
}
$GroupName=[System.Collections.ArrayList]@()
$empty=$GroupName.add((Get-Content -Path $GroupIDPath))
$HostNames = Get-Content $GroupIDPath
foreach($Line in $HostNames) {
    uploadCommand -GroupName $Line -SPFW $PSBoundParameters.Keys.Contains("scriptpathforwindows") -SPFM $PSBoundParameters.Keys.Contains("scriptpathformac") -SPFL $PSBoundParameters.Keys.Contains("scriptpathforlinux") -AFW $PSBoundParameters.Keys.Contains("argumentsforwindows") -AFM $PSBoundParameters.Keys.Contains("argumentsformac") -AFL $PSBoundParameters.Keys.Contains("argumentsforlinux")
}
#Developed by Fatih YILMAZ(onlyf8)
