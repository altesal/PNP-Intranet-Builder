# ************** INFO PRIVADA *************
$siteCollectionPlantillaACopiar = "https://<tenantName>.sharepoint.com/sites/ics2-inici"
$nombreIntranet = "<aliasIntranet>"
$clientId = "<client_id>"
# **************FIN INFO PRIVADA***********

$saveTemplateLocation = ("..\pnpPS\ESPECIFICO\"+$nombreIntranet+"\Templates\")  
$templateName = "templates"  

if (Test-Path $saveTemplateLocation)
{
    try {
        #Connect-PnPOnline -Url $siteCollectionPlantillaACopiar -ClientId  $clientId -Interactive
        Connect-PnPOnline -Url $siteCollectionPlantillaACopiar -UseWebLogin

        $context = Get-PnPContext
        if ($context -eq $null) {
            Write-Host "❌ No hay conexión activa con SharePoint." -ForegroundColor Red
        } else {
            Write-Host "✅ Conectado a SharePoint correctamente." -ForegroundColor Green
            Write-Host "URL del sitio conectado: $($context.Url) con ModoInteractivo $($modoInteractivo)" -ForegroundColor Cyan
            $siteTemplate = Get-PnPSiteTemplate -IncludeAllClientSidePages -Handlers Pages,PageContents -OutputInstance
            $pagesTemplate = New-PnPSiteTemplate
            foreach($page in $siteTemplate.ClientSidePages)
            {
                if($page.PromoteAsTemplate -eq $true)
                {
                    $pagesTemplate.ClientSidePages.Add($page)
                }
            }

            Write-Host "Plantillas disponibles..."
            $pagesTemplate

            Save-PnPSiteTemplate -Template $pagesTemplate -Out ("{0}{1}.xml" -f $saveTemplateLocation, $templateName) -Force
        }
    } catch {
        Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    }                
} else {
     Write-Host "❌ Error: No existe la carpeta Templates o está mal configurada la ruta de acceso" -ForegroundColor Red
}



               
                
