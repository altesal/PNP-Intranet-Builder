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
            if ([bool]$site.esHUB) {
                Unregister-PnPHubSite -Site $urlAbsoluta
                Write-Host "Baja de Site como HUB: " $urlAbsoluta -f Green
            }
            Remove-PnPTenantSite -Url $urlAbsoluta -SkipRecycleBin -Force
            Start-Sleep -Seconds 1
            Write-Host "Site borrado: " $urlAbsoluta
        }else {
            Write-Host "No existe el site: " $urlAbsoluta
        }
    }
    catch {
        write-host "Error: $($_.Exception.Message)" -foregroundcolor Red
    }
 } 
