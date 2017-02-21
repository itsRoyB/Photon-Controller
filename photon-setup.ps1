##  Roy Berkowitz 2017 ###########################################################
##################################################################################
# Prerequisites & Instructions
#	1.) Create directory at C:\photon
#	2.) Download photon.exe and place in C:\photon path (https://github.com/vmware/photon-controller/releases/download/v1.1.0/photon-windows-1.1.0-5de1cb7.exe)
#	3.) Open Powershell and go to C:\
#	4.) Fill out attached CSV with your values
#	5.) Run photon-setup.ps1 from C:\ and enter in path to CSV when prompted
##################################################################################
	
	#################################################################################
	# Add PowerCLI Snapins
	#################################################################################
	#Import-Module VMware.VimAutomation.Core
	#Import-Module VMware.VimAutomation.Vds
	
	Set-Location C:\photon

   	#################################################################################
	# Import CSV	
	#################################################################################
	$FilePath = Read-Host "Please provide the full path the CSV configuration file" 
	$csv = Import-Csv $FilePath
	
	#################################################################################
	# Set variables
	#################################################################################
	
	$tenant = $csv.Tenant
	$resource = $csv.Resource
	$project = $csv.Project
	$memory = $csv.Memory
    	$cpu = $csv.CPU
	$vm_count = $csv.VM_Count
	$cluster = $csv.Cluster
	$master_ip = $csv.Master_IP
	$etcd_ip = $csv.etcd_IP
	$workers = $csv.Workers
	$dns = $csv.DNS
	$gateway = $csv.Gateway
	$netmask = $csv.Netmask
	$net_id = "669705d54754327147d8"
	# Default dvpg_824 = "669705d54754327147d8"
	# dvpg_828 = "669705d548340e325481"
	
	#################################################################################
	# Set the Photon Controller Target
	#################################################################################
	Write-Host "Setting the Photon Platform Target to Communicate With" -ForegroundColor Green
	.\photon.exe target set http://153.64.33.245:28080
	
	#################################################################################
	# Create a Tenant
	#################################################################################
	Write-Host "Creating $tenant Tenant in Photon Controller" -ForegroundColor Green
	Write-Host "Tenant ID: " -ForegroundColor Yellow -NoNewLine
	.\photon.exe -n tenant create $tenant 
	
	#################################################################################
	# Create a Resource Ticket
	#################################################################################
	Write-Host "Creating $resource Resource Ticket in Photon Controller" -ForegroundColor Green
	Write-Host "Resource-Ticket ID: " -ForegroundColor Yellow -NoNewLine
	.\photon.exe -n resource-ticket create --tenant $tenant --name $resource --limits "vm.memory $memory GB, vm.cpu $cpu COUNT, vm $vm_count COUNT"
	
	#################################################################################
	# Create a Project
	#################################################################################
	Write-Host "Creating $project Project in Photon Controller" -ForegroundColor Green
	Write-Host "Project ID: " -ForegroundColor Yellow -NoNewLine
	.\photon.exe -n project create  --tenant $tenant --name $project --resource-ticket $resource --limits "vm.memory $memory GB, vm.cpu $cpu COUNT, vm $vm_count COUNT"
	
	#################################################################################
	# Set the Tenant
	#################################################################################
	Write-Host "Setting the Photon Platform $tenant Tenant to Work Against" -ForegroundColor Green
	.\photon.exe tenant set $tenant
	
	#################################################################################
	# Set the Project
	#################################################################################
	Write-Host "Setting the Photon Platform $project Project to Work Against" -ForegroundColor Green
	.\photon.exe project set $project
	
	#################################################################################
	# Create the Cluster
	#################################################################################
	Write-Host "Creating $cluster Cluster in the Set Tenant/Project" -ForegroundColor Green
	Write-Host "Cluster ID: " -ForegroundColor Yellow -NoNewLine
	$cluster_msg = .\photon.exe -n cluster create -n $cluster -k KUBERNETES --master-ip $master_ip --etcd1 $etcd_ip --container-network 192.168.0.0/16 --dns $dns --gateway $gateway --netmask $netmask -w $net_id -c $workers 
	$cluster_msg
	
	#################################################################################
	# Check if Completed Message Appears
	#################################################################################
	if ($cluster_msg -like "*cluster*created*")
	{
	exit
	}
	else
	{
	Write-Host " Cluster Did Not Deploy Successfully, Please Delete the VMs and Tenant and Run Again!" -ForegroundColor Red
	}
	
	
	<#
	Plan to incorporate Add provisioned VMs to correct folder in vSphere
	Plan to figure out cleanup when cluster deploy fails (supposedly coming in next Photon version)
	#>
