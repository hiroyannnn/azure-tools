#######################################################
# 管理ディスクをコピーする
#
# 2018/1/25 
#######################################################
######################
# 変数
######################
$srcsubscriptionid = "xxx"
$dstsubscriptionid = "xxx"
# ディスクの情報
$sourcergname = "rg-win2016-dev01"
$diskname = "VCMATAD01_OsDisk_1_0297a2a09da447f18e2056bee0a307b2"
# コピー先の各種パラメーター
$targetrgname = "rg-iwb"
$storageacccountname = "storageiwb"
$countainername = "vhds"
$destdiskname = "CIWBSH01_OsDisk.vhd"

######################
# メイン処理
######################
start-transcript
# コピー元の情報
# ログイン
Login-AzureRmAccount
Select-AzureRmSubscription -SubscriptionId $srcsubscriptionid
 
# SAS URL の作成
$mdiskURL = Grant-AzureRmDiskAccess -ResourceGroupName $sourcergname -DiskName $diskname -Access Read -DurationInSecond 3600
 
# コピー先の情報
# ログイン
Login-AzureRmAccount
Select-AzureRmSubscription -SubscriptionId $dstsubscriptionid
  
$storageacccountkey = Get-AzureRmStorageAccountKey -ResourceGroupName $targetrgname -Name $storageacccountname
$storagectx = New-AzureStorageContext -StorageAccountName $storageacccountname -StorageAccountKey $storageacccountkey[0].Value
$targetcontainer = Get-AzureStorageContainer -Name $countainername -Context $storagectx
 

$sourceSASurl = $mdiskURL.AccessSAS
 
# コピー
$ops = Start-AzureStorageBlobCopy -AbsoluteUri $sourceSASurl -DestBlob $destdiskname -DestContainer $targetcontainer.Name -DestContext $storagectx
Get-AzureStorageBlobCopyState -Container $targetcontainer.Name -Blob $destdiskname -Context $storagectx -WaitForComplete

stop-transcript