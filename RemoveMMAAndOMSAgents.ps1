# Disclaimer
# This script is provided for testing purposes only. It should be tested out internally before being used in Production Environment. 
# The author provides this script "as is" without warranty of any kind, either expressed or implied.
# The user assumes all risks associated with the use of this script. Before implementing it in a production environment,
# it is strongly recommended that the user thoroughly test the script and review it for any potential issues or risks.

# By using this script, you agree to these terms and acknowledge that any damages or issues arising from its use are the sole responsibility of the user.


# Read the CSV file with VM details
$vmList = Import-Csv "VMList.csv"

foreach ($vm in $vmList) {
    $SubscriptionId = $vm.SubscriptionId
    $ResourceGroupName = $vm.ResourceGroupName
    $VMScaleSetName = $vm.VMSSName
    $VMInstanceID = $vm.InstanceId

    # Connect to the Azure account (make sure you are logged in)
    Set-AzContext -Subscription $SubscriptionId

    # Get the InstanceView of the VM
    $VM = Get-AzVmssVM -ResourceGroupName $ResourceGroupName -VMScaleSetName $VMScaleSetName -InstanceId $VMInstanceID

    # Check if MMA extension is installed
    $MMAExtension = $VMInstanceView.Resources | Where-Object { $_.Publisher -eq 'Microsoft.EnterpriseCloud.Monitoring' -and $_.VirtualMachineExtensionType -eq 'MicrosoftMonitoringAgent' }

    if ($MMAExtension -ne $null) {
        # Remove MMA extension
        Remove-AzVMExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Name $MMAExtension.Name -ForceRm
        Write-Output "MMA extension removed successfully from VM $VMName in resource group $ResourceGroupName."
    } else {
        Write-Output "MMA extension is not installed on VM $VMName in resource group $ResourceGroupName."
    }

    # Check if OMS extension is installed
    $OMSExtension = $VM.Extensions | Where-Object { $_.Publisher -eq 'Microsoft.EnterpriseCloud.Monitoring' -and $_.VirtualMachineExtensionType -eq 'OmsAgentForLinux' }

    if ($OMSExtension -ne $null) {
        # Remove MMA extension
        Remove-AzVMExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Name $OMSExtension.Name -ForceRm
        Write-Output "OMS extension removed successfully from VM $VMName in resource group $ResourceGroupName."
    } else {
        Write-Output "OMS extension is not installed on VM $VMName in resource group $ResourceGroupName."
    }
}