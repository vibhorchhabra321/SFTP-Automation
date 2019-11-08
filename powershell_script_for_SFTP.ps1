$arr = Get-ChildItem .\Documents\ | Where-Object {$_.PSIsContainer} | ForEach-Object {$_.Name}
$sftpaccounts_list=@()
class sftpaccounts{
[string]$foldername
[string]$foldersize
}
for($i=0; $i -lt $arr.length; $i++)
{
$obj= New-Object sftpaccounts
$obj.foldername=$arr[$i]
$directory=$arr[$i]
$foldersize="{0:N2} GB" -f ((Get-ChildItem .\Documents\$directory\ -Recurse -File | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum / 1GB)
$obj.foldersize=$folders
$sftpaccounts_list+=$obj
echo $sftpaccounts_list
}