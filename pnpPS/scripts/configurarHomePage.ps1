param (
[string]$mensaje  = $(throw "...")
)

Write-Host "($mensaje) Script: $($MyInvocation.MyCommand.Name)" 

$page = Get-PnPPage -Identity  "Home.aspx"
$page.Controls.Clear()
$page.Save()

$section1 = Add-PnPPageSection -Page $page -SectionTemplate TwoColumnLeft
$wpGaleriaDestacats = Add-PnPPageWebPart -Page $page -DefaultWebPartType NewsFeed -Section 1 -Column 1
$wpAvisos = Add-PnPPageWebPart -Page $page -DefaultWebPartType NewsFeed -Section 1 -Column 2
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


$page.Save()
#Get-PnPClientSideComponent -Page "Hoome.aspx"
