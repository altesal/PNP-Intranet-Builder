param (
[string]$mensaje  = $(throw "...")
)
Write-Host "($mensaje) Script: $($MyInvocation.MyCommand.Name)" 

$sites = Get-Content $contenPlanFile | ConvertFrom-Json
$sites.sites | ForEach-Object {
    Try{
        $site = $_
        $urlAbsoluta = $site.urlSiteAbsoluta 
        $sharepointSite = Get-PnPTenantSite -Url $urlAbsoluta -ErrorAction SilentlyContinue
        if ($sharepointSite) {
            Write-Host "Ya existe el site: " $urlAbsoluta 
        }else {
            Write-Host "NO existe el site: " $urlAbsoluta
            $siteNew = New-PnPSite -Type $site.typeSite -Title $site.titleSite -Url $urlAbsoluta
           
            Start-Sleep -Seconds 1
           	
            if ( [bool]$site.esHUB) {
                if(-not $site.titleHUB)
                {
                    Write-Host "Error al crear el HUB site porque no tiene valor la propiedad titleHUB" -f Red
                    return
                }
                Register-PnPHubSite -Site $urlAbsoluta 
                Set-PnPHubSite -Identity $urlAbsoluta -Title $site.titleHUB   
                Write-Host "HUB Site creado:" $urlAbsoluta -f Green
                Start-Sleep -Seconds 2
            }
            else{
                 $hubSite = Get-PnPTenantSite -Url $site.asociarAHUB -ErrorAction SilentlyContinue
                 if ($hubSite)
                 {
                    Add-PnPHubSiteAssociation -Site $siteNew -HubSite $hubSite.Url
                 }
                 Write-Host "Site creado:" $urlAbsoluta  ($esHUBsite  ? "HUB SITE" : "Sitio no hub") 
            }
        }
    }
    catch {
        write-host "Error: $($_.Exception.Message)" -foregroundcolor Red
    }
 } 

$sites.sites | Where-Object ($_.esHub -eq $true) | ForEach-Object {
    
        $site = $_ 
        Write-Host $site.urlSiteAbsoluta -f Yellow
}