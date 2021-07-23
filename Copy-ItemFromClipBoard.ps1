$ClipboardList = Get-Clipboard -Format FileDropList
if($ClipboardList.count -eq 0){
    try{
        $ClipBoardItemList = Get-Clipboard | % Trim | Where-Object {$_ -ne ""} | Get-Item -Force -ErrorAction Stop
    }catch{
        Read-Host "フォルダまたはファイルをクリップボードにコピーしてください" | Out-Null
        return
    }
    $ItemList = $ClipBoardItemList | Sort-Object Name | Sort-Object Mode -Descending
} else{
    $ItemList = $ClipboardList | Get-Item -Force | Sort-Object Name | Sort-Object Mode -Descending
}
while($true){
    Clear-Host
    Read-Host "選択したフォルダまたはファイルをデスクトップにコピーします" | Out-Null
    try{
        $ItemList | Out-Host
    } catch{
    }
    "1 ... フォルダ配下も含めてコピー"
    "2 ... フォルダ配下を含めずにコピー"
    "3 ... コピー対象をさらに絞り込む"
    "4 ... コピーをキャンセル"
    $return = Read-Host
    if($return -eq 1){
        $Recurse = $true
        break
    }
    if($return -eq 2){
        $Recurse = $false
        break
    }
    if($return -eq 3){
        $ItemList = $ItemList | Out-GridView -OutputMode Multiple -Title "コピー対象をさらに絞り込む"
        if($ItemList.count -eq 0){
            return
        }
    }
    if($return -eq 4){
        return
    }
}
$DirectoryItemList = $ItemList | Where-Object {$_.PSIsContainer}
foreach($item in $DirectoryItemList){
    $Destination = "~\Desktop" + ($item.FullName | Split-Path -NoQualifier)
    if($Recurse){
        if(Test-Path $Destination){
            Copy-Item -Recurse -Force -Path $item.FullName -Destination ($Destination | Split-Path)
        } else {
            Copy-Item -Recurse -Path $item.FullName -Destination $Destination
        }
    } else{
        if(Test-Path $Destination){
            continue
        } else {
            Copy-Item -Path $item.FullName -Destination $Destination
        }
    }
}
$FileItemList = $ItemList | Where-Object {-not $_.PSIsContainer}
foreach($item in $FileItemList){
    $Destination = "~\Desktop" + ($item.FullName | Split-Path -NoQualifier)
    if(Test-Path ($Destination | Split-Path)){
        Copy-Item -Path $item.FullName -Destination $Destination
    } else {
        Copy-Item -Path ($item.FullName | Split-Path) -Destination ($Destination | Split-Path)
        Copy-Item -Path $item.FullName -Destination $Destination
    }
}
Read-Host "コピーが完了しました" | Out-Null
