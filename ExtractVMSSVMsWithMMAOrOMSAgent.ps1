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

foreach ($subscription in $subscriptions)
{
    # Set the subscription context
    Set-AzContext -Subscription $subscription.Id

    # Get all VMSS instances in the subscription
    $vmss = Get-AzVmss

    foreach ($vmssInstance in $vmss)
    {
        # Get all VMs that are part of the VMSS
        $vms = Get-AzVmssVM -ResourceGroupName $vmssInstance.ResourceGroupName -VMScaleSetName $vmssInstance.Name
        
        foreach ($vm in $vms)
        {
            # Check if MMA extension is installed
            $MMAExtension = $vm.Extensions | Where-Object { $_.Publisher -eq 'Microsoft.EnterpriseCloud.Monitoring' -and $_.Type -eq 'MicrosoftMonitoringAgent' }
            $OMSExtension = $vm.Extensions | Where-Object { $_.Publisher -eq 'Microsoft.EnterpriseCloud.Monitoring' -and $_.Type -eq 'OmsAgentForLinux' }

            # if ($MMAExtension -ne $null -or $OMSExtension -ne $null) {
                if ($MMAExtension -eq $null -or $OMSExtension -eq $null) {
                # Add the VM to the list
                $vmList += [PSCustomObject]@{
                    SubscriptionId = $subscription.Id
                    ResourceGroupName = $vmssInstance.ResourceGroupName
                    VMName = $vm.Name
                }
                Write-Output "MMA or OMS extension is installed on VM $($vm.Name) in resource group $($resourceGroup.ResourceGroupName)."
            } else {
                Write-Output "MMA or OMS extension is not installed on VM $($vm.Name) in resource group $($resourceGroup.ResourceGroupName)."
            }
        }
    }
}

# Export the VM list to a CSV file
$vmList | Export-Csv "VMList.csv" -NoTypeInformation