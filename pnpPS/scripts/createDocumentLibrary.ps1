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
                $docLibrary = New-PnPList -Title $item.descripcion -Url $urlDocumentLibrary -Template DocumentLibrary #-EnableContentTypes $true
                Write-Output "Biblioteca '$urlDocumentLibrary' creada. ID: $($item.ID), Nivel: $($item.Nivel), Descripcion: $($item.Descripcion) Desc.Tratada: $($urlDocumentLibrary)"
            } else {
                Write-Output "La biblioteca '$urlDocumentLibrary' ya existe."
            }
        }

        #Write-Host "Crear fichero $($item.descripcion) plantilla $($item.plantilla) en la biblioteca $($item.folder)" -f Green
        $ficheroACopiar = $null
        Write-Host "Plantilla: $($item.plantilla) y itemURL= $($item.url)"
        switch($item.plantilla){
            "PT_Final" {
                 #$ficheroACopiar = "/sites/$($site)/SitePages/PT_Final.aspx"
                 $ficheroACopiar = "PT_Final.aspx"
                $pathTemplate = "C:\Users\mjped\Documents\Repos\PNP-Intranet-Builder\pnpPS\ESPECIFICO\ICS2\Templates\PT_Final.xml"
                 
            }
            "PT_Distribuidora" {
                 #$ficheroACopiar = "/sites/$($site)/SitePages/PT_Distribuidora.aspx"
                 $ficheroACopiar = "PT_Distribuidora.aspx"
                $pathTemplate = "C:\Users\mjped\Documents\Repos\PNP-Intranet-Builder\pnpPS\ESPECIFICO\ICS2\Templates\PT_Distribuidora.xml"
            }
        }
       
       
       if ($null -ne $ficheroACopiar ){
            $destinationLibraryName = Descripcion-Tratada -descripcionSinTratar $item.folder
            $destinationLibrary = "($item.url)/$($destinationLibraryName)"
            $newInternalName = Descripcion-Tratada -descripcionSinTratar $item.descripcion
            $newDisplayName = $item.Descripcion
            $sourceURLFile = "/sites/$($site)/SitePages/$($ficheroACopiar)"
            $targetUrl = "/sites/$($site)/$($destinationLibraryName)"
            #$targetUrl = "/sites/ics2-persones/persones"

            Write-Host "SourceFile-1: $($ficheroACopiar) " 
            Write-Host "destinationLibraryName: $($destinationLibraryName) " 
            Write-Host "destinationLibrary: $($destinationLibrary) " 
            Write-Host "newInternalName: $($newInternalName) " 
            Write-Host "newDisplayName: $($newDisplayName) " 
             Write-Host "item_url: $($item.url) " 
             Write-Host  "Target URL" $targetUrl 
             Write-Host "sourceURLFile: " $sourceURLFile
            Write-Host "Ruta completa fichero destino: $($item.url)/$destinationLibraryName/$($ficheroACopiar)" 


            $SourceSiteURL = "$($item.url)/SitePages"
            $DestinationSiteURL = "$($item.url)/$destinationLibraryName/"
            $PageName =  $ficheroACopiar
            
           
            #Export the Source page
            #$TempFile = [System.IO.Path]::GetTempFileName()
            #Export-PnPPage -Force -Identity $PageName -Out $TempFile
            
            #Import the page to the destination site
            Invoke-PnPSiteTemplate -Path $pathTemplate
            Write-Host "Antes del invoke..."
            $SetPnPPage = Set-PnPPage -Identity $ficheroACopiar  -Publish 
            Write-Host "Despues del invoke..."
            $newfile = "$($newInternalName).aspx"
            Write-Host "Despues del newFile..."
            $file = Get-PnPFile -Url $sourceURLFile -AsListItem #-ErrorAction Silently
            Write-Host "Despues del file......."
            if ($file) {
                Rename-PnPFile -ServerRelativeUrl $sourceURLFile -TargetFileName $newfile -OverwriteIfAlreadyExists -Force
                $newUrlfile = "$($item.url)/SitePages/$($newfile)"
                Write-Host "newUrlfile.1: $($newUrlfile) e item_url: $($item.url)"
                $page = Get-PnPPage -Identity $newfile #-ErrorAction SilentlyContinue
                #$page =  Get-PnPPage -Identity $($item.url) $newfile -Web (Get-PnPWeb -Identity "Subsite1")

                Write-Host "Page.2: $($newUrlfile)"
                if ($page) {
                    Set-PnPPage -Identity $newfile -LayoutType Home -Title $newDisplayName
                } else {
                    Write-Host "La página $newfile no existe."
                }
            } else {
                Write-Host "El archivo $sourceURLFile no existe."
            }

            
             

               #Copy-PnPFile -SourceUrl $sourceURLFile -TargetUrl $targetUrl -Overwrite -Force
               #Copy-PnPFile -SourceUrl "/sites/ics2-lics/SitePages/PT_Distribuidora.aspx" -TargetUrl "/sites/ics2-lics/lics" -Overwrite -Force
            <#
            $file = Get-PnPFile -Url  "$($item.url)/$destinationLibraryName/$($ficheroACopiar)" 
            Write-Host "EOEOEOEOEOEO: "     $file.Id  $targetUrl 
            
            #$file = Get-PnPFile -Url $targetUrl  -AsListItem
            
            
            
            Set-PnPListItem -List $destinationLibraryName -Identity $file.Id -Values @{
                "FileLeafRef" = "hola.aspx"  # Cambia el nombre (URL)
                "Title" = "HOLA"        # Cambia el título (nombre visible)
            }
            
            #>
   
<#
#Parameters
$SourceSiteURL = "https://crescent.sharepoint.com/sites/marketing"
$DestinationSiteURL = "https://crescent.sharepoint.com/sites/branding"
$PageName =  "About.aspx"
 
#Connect to Source Site
Connect-PnPOnline -Url $SourceSiteURL -Interactive
 
#Export the Source page
$TempFile = [System.IO.Path]::GetTempFileName()
Export-PnPPage -Force -Identity $PageName -Out $TempFile
 
#Import the page to the destination site
Connect-PnPOnline -Url $DestinationSiteURL -Interactive
Invoke-PnPSiteTemplate -Path $TempFile


#Read more: https://www.sharepointdiary.com/2020/07/sharepoint-online-copy-pages-to-another-site-using-powershell.html#ixzz91ZZmeWFL
https://www.sharepointdiary.com/2020/07/sharepoint-online-copy-pages-to-another-site-using-powershell.html


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