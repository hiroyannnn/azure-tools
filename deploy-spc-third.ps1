########################################
# 関数宣言
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

    echo "-変数設定---------------------------------"
    echo "【name】" $name 
    echo "【vmname】" $vmname 
    echo "【pipname】" $pipname 
    echo "【piptype】" $piptype 
    echo "【nicname】" $nicname 
    echo "【nicaddressnum】" $nicaddressnum 
    echo "【nicaddress】" $nicaddress 
    echo "【vmsize】" $vmsize 
    echo "【osdisk】" $osdisk 
    echo "【vhduri】" $vhduri
    echo "------------------------------------------"


    $yn = read-host "以上でお間違いないですか？(y/n)"
    if ( $yn -eq "y" )
        {
            # パブリックIPアドレスの作成
            $pip = get-AzureRmPublicIpAddress -ResourceGroupName $resourcegroupname -Name $pipname 

            # ネットワークインターフェースの作成
            $vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $resourcegroupname -Name $virtualnetworkname
            $subnet = Get-AzureRmVirtualNetworkSubnetConfig -Name $subnetname -VirtualNetwork $vnet
            $nic = New-AzureRmNetworkInterface -Location $location -ResourceGroupName $resourcegroupname -Name $nicname -PrivateIpAddress $nicaddress -Subnet $subnet -PublicIpAddress $pip

            # 仮想マシンの作成
            $vm = New-AzureRmVMConfig -VMName $name -VMSize $vmsize
            $vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id
            $vm = Set-AzureRmVMOSDisk -VM $vm -VhdUri $vhduri -CreateOption attach -Name $osdisk -Windows
            New-AzureRmVM -ResourceGroupName $resourcegroupname -Location $location -VM $vm

        }
    else
        {
            echo "お手数ですがADサーバの作成をもう一度やり直してください"
        }
}

########################################
# 変数宣言
########################################
Start-Transcript
# SPCのデプロイ（third）を開始します
$customer = "iwb"
$customerL = $customer.ToUpper()
$nwnum = "10.10.0."

# 外部ファイル（共通変数）の読み込み
. .\deploy-spc-ini.ps1

########################################
# Azureへの接続
########################################

# Azureへのログイン
$azaccount = Login-AzureRmAccount

# サブスクリプションの選択
Select-AzureRmSubscription -SubscriptionId "xxx"

########################################
# AD環境の作成
########################################

# 変数宣言
$hostn = "SH01"
$nicaddressnum = "101"
$vmsize = "Standard_B2s"
deploy_vm


Stop-Transcript