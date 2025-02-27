param (
[string]$mensaje  = $(throw "...")
)

Write-Host "($mensaje) Script: $($MyInvocation.MyCommand.Name)" 

$page = Get-PnPPage -Identity  "Home.aspx"
$page.Controls.Clear()
$page.Save()

Write-Host "Section 1 - Galería de Noticias Destacadas"
$section1 = Add-PnPPageSection -Page $page -SectionTemplate TwoColumnLeft
$wpGaleriaDestacats = Add-PnPPageWebPart -Page $page -DefaultWebPartType NewsFeed -Section 1 -Column 1
$wpAvisos = Add-PnPPageWebPart -Page $page -DefaultWebPartType NewsFeed -Section 1 -Column 2
Write-Host "Section 2 - Webpart de Avisos"
$section2 = Add-PnPPageSection -Page $page -SectionTemplate TwoColumnLeft
$wpNovetats = Add-PnPPageWebPart -Page $page -DefaultWebPartType NewsFeed -Section 2 -Column 1

$ct = Get-PnPContentType | Where-Object { $_.Name -eq "Noticia" }
$contentTypeId = $ct.Id.StringValue
$jsonConfig = @"
{
    "newsDataSourceProp": 3,
    "sites": [
        {
            "Url": "https://zs8ry.sharepoint.com/sites/ics2-inici"
        }
    ],
    "filters": [
        {
            "filterType": 6,
            "value": "Noticia",
            "values": [],
            "op": 5,
            "fieldname": "SPContentType",
            "fieldInfo": 1
        }
    ],
    "filterKQLQuery": "SPContentType:*Noticia*"
}
"@
$wpNovetats.PropertiesJson = $jsonConfig


Write-Host "Section 3 - Módulo de Enlaces"
$section3 = Add-PnPPageSection -Page $page -SectionTemplate OneColumn
Write-Host "Section 4 - Módulo de Noticias (Izquierda) | Módulo de Calendario (Derecha)"
$section4 = Add-PnPPageSection -Page $page -SectionTemplate TwoColumnLeft
Write-Host "Section 5 - Módulo de Enlaces Botones"
$section5 = Add-PnPPageSection -Page $page -SectionTemplate OneColumn


$page.Save()
#Get-PnPClientSideComponent -Page "Hoome.aspx"
