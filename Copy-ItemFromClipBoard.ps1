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
while($true){
    Clear-Host
    Read-Host "�I�������t�H���_�܂��̓t�@�C�����f�X�N�g�b�v�ɃR�s�[���܂�" | Out-Null
    try{
        $ItemList | Out-Host
    } catch{
    }
    "1 ... �t�H���_�z�����܂߂ăR�s�["
    "2 ... �t�H���_�z�����܂߂��ɃR�s�["
    "3 ... �R�s�[�Ώۂ�����ɍi�荞��"
    "4 ... �R�s�[���L�����Z��"
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
        $ItemList = $ItemList | Out-GridView -OutputMode Multiple -Title "�R�s�[�Ώۂ�����ɍi�荞��"
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
Read-Host "�R�s�[���������܂���" | Out-Null
