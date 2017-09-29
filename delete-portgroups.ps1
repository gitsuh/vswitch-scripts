$vmhosts = get-vmhost
$report = @()

foreach ($vmhost in $vmhosts){
	$vswitches = get-virtualswitch
	foreach ($vswitch in $vswitches){
		$portgroups = get-virtualportgroup
		foreach ($portgroup in $portgroups){
			$reportobj = New-Object System.Object
			$reportobj | Add-Member -type NoteProperty -name vmhost -Value $vmhost
			$reportobj | Add-Member -type NoteProperty -name vswitch -Value $vswitch
			if($portgroup.name -like "*portgroupnametoexclude*"){
				$reportobj | Add-Member -type NoteProperty -name portgroup -Value $portgroup
				$reportobj | Add-Member -type NoteProperty -name shouldiremove -Value $false
			}else{ 
				$reportobj | Add-Member -type NoteProperty -name portgroup -Value $portgroup
				$reportobj | Add-Member -type NoteProperty -name shouldiremove -Value $true
			}
			$report += $reportobj
		}
	}
}

foreach($item in $report){
	if($item.shouldiremove -eq $true){
		if($item.portgroup.GetType() -ne [VMware.VimAutomation.ViCore.Impl.V1.Host.Networking.DistributedPortGroupImpl]){
			write-host "REMOVE" $item.portgroup
			remove-virtualportgroup -VirtualPortGroup $item.portgroup -confirm:$false
		}
	}
}
