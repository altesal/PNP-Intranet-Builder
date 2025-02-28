param (
[string]$mensaje  = $(throw "...")
)
Write-Host "($mensaje) Script: $($MyInvocation.MyCommand.Name)" 
$site = $siteJson.urlSite
Write-Host "Site: $($site)"

Function Remove-Accents {
    param ($inputString)
    $normalizedString = $inputString.Normalize([Text.NormalizationForm]::FormD)
    return ($normalizedString -replace '\p{M}', '')
}

Function Descripcion-Tratada {
    param ($descripcionSinTratar)
    
    $descripcionSinAcentos = Remove-Accents $descripcionSinTratar.ToLower()
    $newDescripcion = $descripcionSinAcentos -replace "[^a-zA-Z0-9 ]", "" -replace " ", "-"
    return $newDescripcion
}

Function Mostrar-Navegacion {
    param($menu)

    foreach($item in $menu) {
        
        if($item.Nivel -le 2 -and ![string]::IsNullOrEmpty($item.Descripcion)) {
            $urlDocumentLibrary = Descripcion-Tratada -descripcionSinTratar $item.descripcion
            $list = Get-PnPList -Identity $urlDocumentLibrary -ErrorAction SilentlyContinue
            if (!$list) {
                New-PnPList -Title $item.descripcion -Url $urlDocumentLibrary -Template DocumentLibrary #-EnableContentTypes $true
                Write-Output "Biblioteca '$urlDocumentLibrary' creada. ID: $($item.ID), Nivel: $($item.Nivel), Descripcion: $($item.Descripcion) Desc.Tratada: $($urlDocumentLibrary)"
            } else {
                Write-Output "La biblioteca '$urlDocumentLibrary' ya existe."
            }
        }

        #Write-Host "Crear fichero $($item.descripcion) plantilla $($item.plantilla) en la biblioteca $($item.folder)" -f Green
        $sourceURLFile = $null
        Write-Host "Plantilla: $($item.plantilla) y itemURL= $($item.url)"
        switch($item.plantilla){
            "PT_Final" {
                 $sourceURLFile = "/sites/$($site)/SitePages/PT_Final.aspx"
                 
            }
            "PT_Distribuidora" {
                 $sourceURLFile = "/sites/$($site)/SitePages/PT_Distribuidora.aspx"
            }
        }
       
       if ($null -ne $sourceURLFile ){
            $destinationLibraryName = Descripcion-Tratada -descripcionSinTratar $item.folder
            $destinationLibrary = "($item.url)/$($destinationLibraryName)"
            $newInternalName = Descripcion-Tratada -descripcionSinTratar $item.descripcion
            $newDisplayName = $item.Descripcion
            $targetUrl = "/sites/$($site)/$($destinationLibraryName)"
            #$targetUrl = "/sites/ics2-persones/persones"

            Write-Host "SourceFile-1: $($sourceURLFile) " 
            Write-Host "destinationLibraryName: $($destinationLibraryName) " 
            Write-Host "destinationLibrary: $($destinationLibrary) " 
            Write-Host "newInternalName: $($newInternalName) " 
            Write-Host "newDisplayName: $($newDisplayName) " 
             Write-Host "item_url: $($item.url) " 
             Write-Host  "Target URL" $targetUrl 


            Copy-PnPFile -SourceUrl $sourceURLFile -TargetUrl $targetUrl -Overwrite -Force
               #Copy-PnPFile -SourceUrl "/sites/ics2-lics/SitePages/PT_Distribuidora.aspx" -TargetUrl "/sites/ics2-lics/lics" -Overwrite -Force
            
            $file = Get-PnPFile -Url "$($targetUrl)/destinationLibraryName/)" -AsListItem
            Write-Host "EOEOEOEOEOEO" $targetUrl
            <#
            #$file = Get-PnPFile -Url $targetUrl  -AsListItem
            $file.Id
            Set-PnPListItem -List $destinationLibraryName -Identity $file.Id -Values @{
                "FileLeafRef" = "hola.aspx"  # Cambia el nombre (URL)
                "Title" = "HOLA"        # Cambia el título (nombre visible)
            }
            
            #>
   
        }
        
        if($item.submenus.Count -gt 0){
            Mostrar-Navegacion -menu $item.submenus
        } 
    }
}

foreach($item in $siteJson.navegacion){
    Mostrar-Navegacion -menu $item
}