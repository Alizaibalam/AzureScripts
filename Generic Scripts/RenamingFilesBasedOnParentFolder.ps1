$FullName = Get-ChildItem -Path "C:\Users\Syed\Desktop\VISY Data" -Include *.csv -Recurse -File | select FullName
Foreach ( $x in $FullName)
{
    $foldername = Split-Path (Split-Path $x -Parent) -Leaf
    $Filname = [System.IO.Path]::GetFileName($x)
    $newname = $foldername + "_" + $filname 
    $newname = $newname -replace '[}]',''
    #Write-Host $newname
    #$x = $x -replace '["@{FullName="]',''
    $x = $x -replace '[}]',''
    $xsplit = $x.Split("=")
    $oldname = $xsplit[1]
    Rename-Item $oldname $newname
}
