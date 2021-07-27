if($null -eq $args[0]){
  $ClipboardList = Get-Clipboard -Format FileDropList
  if($ClipboardList.count -eq 0){
      try{
          $ClipBoardItemList = Get-Clipboard | % Trim | Where-Object {$_ -ne ""} | Get-Item -Force -ErrorAction Stop
      }catch{
          Read-Host "�t�H���_�܂��̓t�@�C�����N���b�v�{�[�h�ɃR�s�[���Ă�������" | Out-Null
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
    Read-Host "�I�������t�H���_�܂��̓t�@�C�����f�X�N�g�b�v�ɃR�s�[���܂�" | Out-Null
    try{
        $ItemList | Sort-Object PSParentPath, Attributes | Out-Host
    } catch{
    }
    "1 ... �t�H���_�z�����܂߂ăR�s�["
    "2 ... �t�H���_�z�����܂߂��ɃR�s�["
    "3 ... �R�s�[�Ώۂ��i�荞��"
    "4 ... �f�B���N�g�������ׂēW�J����"
    "5 ... �f�B���N�g����1�K�w�����W�J����(Win10�ȍ~)"
    "6 ... �R�s�[���L�����Z��"
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
        $SelectedItemList = $ItemList | Sort-Object PSParentPath, Attributes | Select-Object Mode, LastWriteTime, Length, Name, FullName | Out-GridView -OutputMode Multiple -Title "�R�s�[�Ώۂ��i�荞��" | % FullName | Get-Item
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
Read-Host "�R�s�[���������܂���" | Out-Null
