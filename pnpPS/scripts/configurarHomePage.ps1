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
<#
$ct = Get-PnPContentType | Where-Object { $_.Name -eq "Noticia" }
$contentTypeId = $ct.Id.StringValue
$jsonConfig = @"
{
    "dataProvider": {
        "query": {
            "Properties": [
                {
                    "Name": "Filter",
                    "Value": "{\"contentTypeId\":\"$contentTypeId\"}"
                }
            ]
        }
    }
}
"@
$wpNovetats.PropertiesJson = $jsonConfig
#>

$page.Save()
