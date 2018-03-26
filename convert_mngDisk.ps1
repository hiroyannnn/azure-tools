#######################################################
# 管理ディスク化
#
# 2018/1/25
#######################################################
######################
# 変数
######################
$rgName = "rg-iwb"
$vmName = "CSPCSH01"
$scriptPath = $MyInvocation.MyCommand.Path
$BASEDIR= Split-Path -Parent $scriptPath
$LOG = $BASEDIR + ""
######################
# メイン処理
######################
Start-Transcript 
# VMの停止
Stop-AzureRmVM -ResourceGroupName $rgName -Name $vmName -Force
# 管理ディスク化
ConvertTo-AzureRmVMManagedDisk -ResourceGroupName $rgName -VMName $vmName
# VMの起動
Start-AzureRmVM -ResourceGroupName $rgName -Name $vmName
Stop-transcript
