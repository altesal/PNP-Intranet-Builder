param (
[string]$mensaje  = $(throw "...")
)
Write-Host "($mensaje) Script: $($MyInvocation.MyCommand.Name)" 

$templatesPath = (Resolve-Path ("ESPECIFICO\"+$nombreIntranet+"\Templates\ContentPages")).Path

Get-ChildItem -Path $templatesPath -File | Where-Object { $_.Extension -eq ".xml" }  | ForEach-Object {     
    if (-not $_.FullName) {
        Write-Host "❌FullName: "   $_.FullName -f Green
        return  # Sale de la función o el script actual
    } else {
        Write-Host "FullName: "   $_.FullName -f Green
        $fullPath = $_.FullName
    }

    if (-not (Get-PnPConnection)) {
        Write-Host "No estás conectado a SharePoint." -ForegroundColor Red
        return
    }
     if (-not $_.FullName) {
        Write-Host "fullPath: "  $fullPath -f Green
        return  # Sale de la función o el script actual
    } else {
        Write-Host "fullPath: "   $fullPath -f Green
        $fullPath = $_.FullName
    }
    try {
        [xml]$xmlContent = Get-Content -Path $fullPath -Encoding UTF8
        if ($xmlContent.DocumentElement -eq $null) {
            Write-Host "❌ Error: El XML está vacío o mal formado." -ForegroundColor Red
            return
        } else {
            Write-Host "✅ XML cargado correctamente. Raíz: $($xmlContent.DocumentElement.Name)" -ForegroundColor Green
        }
    } catch {
        Write-Host "❌ Error al leer el XML: $_" -ForegroundColor Red
        return
    }
    $siteUrl = "/sites/"+$siteJson.urlSite
    $titleSite = $siteJson.titleSite
    Write-Host "SiteURL: $($siteUrl) Nombre site: $($titleSite) UrlAbsoluta a la que nos conectamos: $($urlAbsoluta)"
    if (-not $_.FullName) {
        Write-Host "❌ fullPath: "  $fullPath -f Green
        return  # Sale de la función o el script actual
    } else {
        Write-Host "✅fullPath: "   $fullPath -f Green
        $fullPath = $_.FullName
    }
    [xml]$xmlContent = Get-Content -Path $fullPath
    

    Invoke-PnPSiteTemplate -Path $fullPath -Parameters @{"SiteTitle"=$titleSite;"SiteUrl"=$siteUrl}
    
    $namespaceManager = New-Object System.Xml.XmlNamespaceManager($xmlContent.DocumentElement.OwnerDocument.NameTable)
    $namespaceManager.AddNamespace("pnp", "http://schemas.dev.office.com/PnP/2022/09/ProvisioningSchema")  
    $aspxPages = $xmlContent.SelectNodes("//pnp:ClientSidePage[@PromoteAsTemplate='false' and @PromoteAsNewsArticle='true']", $namespaceManager)
    #$aspxPages
    
    Write-Host "Número de páginas ASPX: $($aspxPages.Count)"
    $aspxPages | ForEach-Object { 
        if ($_.PageName) {
                Write-Host "Page: $_.PageName"
                Set-PnPPage -Identity $_.PageName -Publish
            } else {
                Write-Host "El nodo no tiene PageName" -ForegroundColor Yellow
            }
    }

}
