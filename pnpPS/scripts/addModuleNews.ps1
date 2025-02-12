param (
    [string]$Mensaje,
    [Parameter(Mandatory = $true)] $Modulo
)

function Add-ContentType-ToSite {
    param (
        [Parameter(Mandatory = $true)] [string]$nameContentType = $null
    )

	$ctypes = Get-PnPContentType | Where-Object {$_.Group -eq "Espai intranets"} | Select-Object -ExpandProperty Name
	$ctypes | ForEach-Object { Write-Host $_ }
	$ListName = "Site Pages"
	$ctype = Get-PnPContentType -Identity $nameContentType
	Write-host "Info ctype "  $ctype.Name $ctype.Id
    Add-PnPContentTypeToList -List $ListName -ContentType $ctype.Name
    
}

Write-Host $Mensaje

$Modulo.propiedades.PSObject.Properties | ForEach-Object {
    	 Write-Output "Procesando propiedad: $($_.Name) = $($_.Value)"
	     if ($_.Name -eq "idContentTypeNoticies") {
            Write-Output "Procesando Noticia con ID: $($_.Value)"
            $idContentTypeNoticies = $_.Value
        } elseif ($_.Name -eq "idContentTypeAvis") {
            Write-Output "Procesando Aviso con ID: $($_.Value)"
            $idContentTypeAvis = $_.Value
        }
}

Write-host "UrlAbsoluta: $($urlAbsoluta)  nameContentType: $($nameContentType)"
Add-PnPContentTypesFromContentTypeHub -Site $urlAbsoluta -ContentTypes $idContentTypeNoticies
Add-PnPContentTypesFromContentTypeHub -Site $urlAbsoluta -ContentTypes $idContentTypeAvis  

Add-ContentType-ToSite  -nameContentType "Noticia" 
Add-ContentType-ToSite -nameContentType "Avis"