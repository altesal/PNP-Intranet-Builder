param (
[string]$mensaje  = $(throw "...")
)
Write-Host "($mensaje) Script: $($MyInvocation.MyCommand.Name)" 


Try{
    Get-PnPNavigationNode -Location "TopNavigationBar" |  Remove-PnPNavigationNode -Force
    Write-Host "Creando la Navegación Principal en " $siteJson.urlSiteAbsoluta

    function Check-NavPrincipal {
        param (
            [Parameter(Mandatory = $true)]
            $navegacion
        )

        foreach ($item in $navegacion) {
            if ($item.NavPrincipal -eq 1) {
                Write-Host "El item '$($item.Descripcion)' (ID: $($item.ID)) con $($item.url)   tiene NavPrincipal = $($item.NavPrincipal)"
                #$item
                Add-PnPNavigationNode -Title $item.Descripcion -Url $item.url -Location "TopNavigationBar"
                $navnode = Get-PnPNavigationNode -Location TopNavigationBar
                Write-host  $navnode.Title -f Yellow 
                $navnodeTotal = Get-PnPNavigationNode
                Write-host  $navnodeTotal.Title -f Yellow 
            }
            # Llamada recursiva para Submenus
            if ($item.Submenus.Count -gt 0) {
                Check-NavPrincipal -navegacion $item.Submenus
            }
        }
    }

    foreach ($site in $JSONFIle.sites) {
        Write-Host "Verificando sitio: $($site.titleSite) y site.navegacion: $($site.navegacion)"
        Check-NavPrincipal -navegacion $site.navegacion
    }
}
catch 
{
	write-host "Error: $($_.Exception.Message)" -foregroundcolor Red
}