if($null -eq $args[0]){
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
}else{
  $ItemList = $args | Get-Item -Force | Sort-Object Name | Sort-Object Mode -Descending
}
while($true){
    Clear-Host
    Read-Host "選択したフォルダまたはファイルをデスクトップにコピーします" | Out-Null
    try{
        $ItemList | Sort-Object PSParentPath, Attributes | Out-Host
    } catch{
    }
    "1 ... フォルダ配下も含めてコピー"
    "2 ... フォルダ配下を含めずにコピー"
    "3 ... コピー対象を絞り込む"
    "4 ... ディレクトリをすべて展開する"
    "5 ... ディレクトリを1階層だけ展開する(Win10以降)"
    "6 ... コピーをキャンセル"
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
        $SelectedItemList = $ItemList | Sort-Object PSParentPath, Attributes | Select-Object Mode, LastWriteTime, Length, Name, FullName | Out-GridView -OutputMode Multiple -Title "コピー対象を絞り込む" | % FullName | Get-Item
        if($null -ne $SelectedItemList){
          $ItemList = $SelectedItemList
        }
    }
    if($return -eq 4){
        $ItemList = $ItemList | Get-ChildItem -Recurse -Force | Sort-Object -Unique
    }
    if($return -eq 5){
        $ItemList = $ItemList | Get-ChildItem -Recurse -Depth 1 | Sort-Object -Unique
    }
    if($return -eq 6){
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
