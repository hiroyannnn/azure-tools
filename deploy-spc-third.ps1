########################################
# �֐��錾
########################################
function deploy_vm()
{
    $name =  "CSPC" + $hostn
    $vmname = "C" + $customerL + $hostn
    $pipname = $name + "-pip"
    $piptype = "Static"
    $nicname = $name + "-nic"
    $nicaddress = $nwnum + $nicaddressnum
    $osdisk = $vmname + "-osDisk"
    $vhduri = "https://" + $storageaccountname + "ssd.blob.core.windows.net/vhds/" + $osdisk + ".vhd"

    echo "-�ϐ��ݒ�---------------------------------"
    echo "�yname�z" $name 
    echo "�yvmname�z" $vmname 
    echo "�ypipname�z" $pipname 
    echo "�ypiptype�z" $piptype 
    echo "�ynicname�z" $nicname 
    echo "�ynicaddressnum�z" $nicaddressnum 
    echo "�ynicaddress�z" $nicaddress 
    echo "�yvmsize�z" $vmsize 
    echo "�yosdisk�z" $osdisk 
    echo "�yvhduri�z" $vhduri
    echo "------------------------------------------"


    $yn = read-host "�ȏ�ł��ԈႢ�Ȃ��ł����H(y/n)"
    if ( $yn -eq "y" )
        {
            # �p�u���b�NIP�A�h���X�̍쐬
            $pip = get-AzureRmPublicIpAddress -ResourceGroupName $resourcegroupname -Name $pipname 

            # �l�b�g���[�N�C���^�[�t�F�[�X�̍쐬
            $vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $resourcegroupname -Name $virtualnetworkname
            $subnet = Get-AzureRmVirtualNetworkSubnetConfig -Name $subnetname -VirtualNetwork $vnet
            $nic = New-AzureRmNetworkInterface -Location $location -ResourceGroupName $resourcegroupname -Name $nicname -PrivateIpAddress $nicaddress -Subnet $subnet -PublicIpAddress $pip

            # ���z�}�V���̍쐬
            $vm = New-AzureRmVMConfig -VMName $name -VMSize $vmsize
            $vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id
            $vm = Set-AzureRmVMOSDisk -VM $vm -VhdUri $vhduri -CreateOption attach -Name $osdisk -Windows
            New-AzureRmVM -ResourceGroupName $resourcegroupname -Location $location -VM $vm

        }
    else
        {
            echo "���萔�ł���AD�T�[�o�̍쐬��������x��蒼���Ă�������"
        }
}

########################################
# �ϐ��錾
########################################
Start-Transcript
# SPC�̃f�v���C�ithird�j���J�n���܂�
$customer = "iwb"
$customerL = $customer.ToUpper()
$nwnum = "10.10.0."

# �O���t�@�C���i���ʕϐ��j�̓ǂݍ���
. .\deploy-spc-ini.ps1

########################################
# Azure�ւ̐ڑ�
########################################

# Azure�ւ̃��O�C��
$azaccount = Login-AzureRmAccount

# �T�u�X�N���v�V�����̑I��
Select-AzureRmSubscription -SubscriptionId "xxx"

########################################
# AD���̍쐬
########################################

# �ϐ��錾
$hostn = "SH01"
$nicaddressnum = "101"
$vmsize = "Standard_B2s"
deploy_vm


Stop-Transcript