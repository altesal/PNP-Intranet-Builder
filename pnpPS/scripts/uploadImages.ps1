param (
[string]$mensaje  = $(throw "...")
)
Write-Host "($mensaje) Script: $($MyInvocation.MyCommand.Name)" 

$localPath = ".\ESPECIFICO\$($nombreIntranet)\Images\logo.png"
$urlBibliotecaImagenes = "siteImages"
$titleBibliotecaImagenes = "Site Images"
$siteRelativeUrl = "/sites/$($siteJson.urlSite)/$($urlBibliotecaImagenes)"
 
try {
    Write-host "siteRelativeUrl: $($siteRelativeUrl)"

    $library = Get-PnPList | Where-Object { $_.Title -eq $titleBibliotecaImagenes -or 
                                            $_.RootFolder.ServerRelativeUrl -eq $siteRelativeUrl } 
    if ($library -eq $null) {
        $library = New-PnPList -Title $titleBibliotecaImagenes -Url $urlBibliotecaImagenes -Template PictureLibrary
        $library = Get-PnPList -Identity $titleBibliotecaImagenes
    } 

    if (Test-Path $localPath)
    {
        Write-Host "Folder: $($library.RootFolder.ServerRelativeUrl)" 
        $logofile = Add-PnPFile -Path $localPath -Folder $library.RootFolder.ServerRelativeUrl
    } else {
        Write-Host "No existe ficherode logo $($localPath)" -f Red
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)" -f Red
}



