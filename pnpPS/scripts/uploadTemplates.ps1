param (
[string]$mensaje  = $(throw "...")
)
Write-Host "($mensaje) Script: $($MyInvocation.MyCommand.Name)" 



$templatesPath = (Resolve-Path ("ESPECIFICO\"+$nombreIntranet+"\Templates")).Path

Get-ChildItem -Path $templatesPath -Filter "*.xml" -File | ForEach-Object {
    $fullPath = $_.FullName
    Write-Host "1. " $fullPath
    if (-not (Get-PnPConnection)) {
        Write-Host "No estás conectado a SharePoint." -ForegroundColor Red
        return
    }
    Invoke-PnPSiteTemplate -Path $fullPath
   
    [xml]$xmlContent = Get-Content -Path $fullPath -Encoding UTF8
    $namespaceManager = New-Object System.Xml.XmlNamespaceManager($xmlContent.NameTable)
    $namespaceManager.AddNamespace("pnp", "http://schemas.dev.office.com/PnP/2022/09/ProvisioningSchema")  
    $aspxPages = $xmlContent.SelectNodes("//pnp:ClientSidePage[@PromoteAsTemplate='true']", $namespaceManager)

    Write-Host "Número de templates con páginas ASPX: $($aspxPages.Count)"
    $aspxPages | ForEach-Object { 
        if ($_.PageName) {
                Write-Host "Template: $_.PageName"
                Set-PnPPage -Identity $_.PageName -Publish
            } else {
                Write-Host "El nodo no tiene PageName" -ForegroundColor Yellow
            }
    }

}
