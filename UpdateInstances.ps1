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

    # Set the context to the proper subscription (make sure you are logged in)
    Set-AzContext -Subscription $SubscriptionId

    # Get the VM
    $VM = Get-AzVmssVM -ResourceGroupName $ResourceGroupName -VMScaleSetName $VMScaleSetName -InstanceId $VMInstanceID

    # Check if MMA or OMS extension is installed
    $MMAExtension = $vm.Resources | Where-Object { $_.Publisher -eq 'Microsoft.EnterpriseCloud.Monitoring' -and $_.VirtualMachineExtensionType -eq 'MicrosoftMonitoringAgent' }
    $OMSExtension = $vm.Resources | Where-Object { $_.Publisher -eq 'Microsoft.EnterpriseCloud.Monitoring' -and $_.VirtualMachineExtensionType -eq 'OmsAgentForLinux' }

    if ($MMAExtension -ne $null -or $OMSExtension -ne $null) {
        Update-AzVmssInstance -ResourceGroupName $ResourceGroupName -VMScaleSetName $VMScaleSetName -InstanceId $VMInstanceID
        Write-Output "Updated Instance $VMInstanceID in VMSS $VMScaleSetName in resource group $ResourceGroupName."
    }
    else {
        Write-Output "MMA or OMS extension is not installed on Instance $VMInstanceID in VMSS $VMScaleSetName in resource group $ResourceGroupName."
    }
}