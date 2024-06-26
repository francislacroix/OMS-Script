# Disclaimer
# This script is provided for testing purposes only. It should be tested out internally before being used in Production Environment. 
# The author provides this script "as is" without warranty of any kind, either expressed or implied.
# The user assumes all risks associated with the use of this script. Before implementing it in a production environment,
# it is strongly recommended that the user thoroughly test the script and review it for any potential issues or risks.

# By using this script, you agree to these terms and acknowledge that any damages or issues arising from its use are the sole responsibility of the user.

#Create the VM List
$vmList = @()

# Get all subscriptions we have access to
$subscriptions = Get-AzSubscription

foreach ($subscription in $subscriptions) {
    # Set the subscription context
    Set-AzContext -Subscription $subscription.Id

    # Get all VMSS instances in the subscription
    $vmss = Get-AzVmss

    foreach ($vmssInstance in $vmss) {
        # Get all VMs that are part of the VMSS
        $vms = Get-AzVmssVM -ResourceGroupName $vmssInstance.ResourceGroupName -VMScaleSetName $vmssInstance.Name
        
        foreach ($vm in $vms) {
            # Check if MMA extension is installed
            $MMAExtension = $vm.Resources | Where-Object { $_.Publisher -eq 'Microsoft.EnterpriseCloud.Monitoring' -and $_.VirtualMachineExtensionType -eq 'MicrosoftMonitoringAgent' }
            $OMSExtension = $vm.Resources | Where-Object { $_.Publisher -eq 'Microsoft.EnterpriseCloud.Monitoring' -and $_.VirtualMachineExtensionType -eq 'OmsAgentForLinux' }

            if ($MMAExtension -ne $null -or $OMSExtension -ne $null) {

                # Add the VM to the list
                $vmList += [PSCustomObject]@{
                    SubscriptionId    = $subscription.Id
                    ResourceGroupName = $vmssInstance.ResourceGroupName
                    VMSSName          = $vmssInstance.Name
                    InstanceID        = $vm.InstanceId
                }
                Write-Output "MMA or OMS extension is installed on Instance $($vm.InstanceId) in VMSS $($vmssInstance.Name) in resource group $($vmssInstance.ResourceGroupName)."
            }
            else {
                Write-Output "MMA or OMS extension is not installed on Instance $($vm.InstanceId) in VMSS $($vmssInstance.Name) in resource group $($vmssInstance.ResourceGroupName)."
            }
        }
    }
}

# Export the VM list to a CSV file
$vmList | Export-Csv "VMList.csv" -NoTypeInformation