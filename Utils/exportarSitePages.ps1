# ************** INFO PRIVADA *************
$siteCollectionPlantillaACopiar = "https://zs8ry.sharepoint.com/sites/ics2-inici"
$nombreIntranet = "ICS2"
$clientId = "<client_id>"
# ************* Nombre fichero exportado ***
$templateName = "HomeICS2" 
# ************** FIN INFO PRIVADA***********

$saveTemplateLocation = ("..\pnpPS\ESPECIFICO\"+$nombreIntranet+"\Templates\exportaciones")  
 

if (Test-Path $saveTemplateLocation)
{
    try {
        #Connect-PnPOnline -Url $siteCollectionPlantillaACopiar -ClientId  $clientId -Interactive
        Connect-PnPOnline -Url $siteCollectionPlantillaACopiar -UseWebLogin
        $totalPagesPromoted = 0
        $totalPagesNOTPromoted = 0
        $context = Get-PnPContext
        if ($context -eq $null) {
            Write-Host "❌ No hay conexión activa con SharePoint." -ForegroundColor Red
        } else {
            Write-Host "✅ Conectado a SharePoint correctamente." -ForegroundColor Green
            Write-Host "URL del sitio conectado: $($context.Url) con ModoInteractivo $($modoInteractivo)" -ForegroundColor Cyan
            $siteTemplate = Get-PnPSiteTemplate -IncludeAllClientSidePages -Handlers Pages,PageContents -OutputInstance
            $pagesPromotedTemplate = New-PnPSiteTemplate
            $pagesNOTPromotedTemplate = New-PnPSiteTemplate
            
            foreach($page in $siteTemplate.ClientSidePages)
            {
                if($page.PromoteAsTemplate -eq $false )
                {
                    if($page.PromoteAsNewsArticle -eq $true) {
                        $pagesPromotedTemplate.ClientSidePages.Add($page) 
                        $totalPagesPromoted++
                    } else {
                        $pagesNOTPromotedTemplate.ClientSidePages.Add($page)
                        $totalPagesNOTPromoted++
                    }
                    
                }
            }
            $templateNamePromoted = $templateName + "-Promoted"
            $templateNameNOTPromoted = $templateName + "-NOTPromoted"
            Write-Host "Plantillas disponibles... $($totalPagesPromoted) páginas promoted y $($totalPagesNOTPromoted) páginas NOT promoted"
            Save-PnPSiteTemplate -Template $pagesPromotedTemplate -Out ("{0}\{1}.xml" -f $saveTemplateLocation, $templateNamePromoted) -Force
            Save-PnPSiteTemplate -Template $pagesNOTPromotedTemplate -Out ("{0}\{1}.xml" -f $saveTemplateLocation, $templateNameNOTPromoted) -Force
        }
    } catch {
        Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    }                
} else {
     Write-Host "❌ Error: No existe la carpeta $($saveTemplateLocation)" -ForegroundColor Red
}



               
                
