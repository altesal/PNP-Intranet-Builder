param (
[string]$Mensaje
)

Write-host "*******************************************"
Write-host "************** $Mensaje  ************"
Write-host "*******************************************"

Get-PnPNavigationNode -Location QuickLaunch |  Remove-PnPNavigationNode -Force
$web = Get-PnPWeb
Set-PnPWeb -MegaMenuEnabled:$false
Write-Host  "MegaMenuEnabled: "  $($web.MegaMenuEnabled) 
Write-Host "Creando la Navegación QuickLunch para " $siteJson.urlSiteAbsoluta

function Procesar-Navegacion {
    param (
        [Parameter(Mandatory = $true)]
        [array]$items,
        [Parameter(Mandatory = $false)]
        [object]$parentNode = $null # Nodo padre opcional, necesario para niveles más profundos
    )

    foreach ($item in $items) {
        Write-Host "ID: $($item.ID)"
        $descripcionItemMenu = if ([string]::IsNullOrEmpty($item.Descripcion)) { "Sin descripción" } else { $item.Descripcion }
        Write-Host "Descripcion: $($item.Descripcion)"
        Write-Host "URL: $($item.url)"
        Write-Host "Nivel: $($item.Nivel)" -ForegroundColor Green


        switch($item.plantilla){
            "PT_Distribuidora"{
                $pagina = & "..\Utils\tratarDescripcion.ps1" -descripcionSinTratar $item.descripcion
                $folder = "SitePages"
                $linkMenu = "$($item.url)/$($folder)/$($pagina).aspx"
            }
            "PT_Final" {
                $pagina = & "..\Utils\tratarDescripcion.ps1" -descripcionSinTratar $item.descripcion
                $folder = "SitePages"
                $linkMenu = "$($item.url)/$($folder)/$($pagina).aspx"
            }
            "Link" {
                $linkMenu = $item.url
            }
            default {
                $linkMenu = $item.url
            }
        }
        Write-Host "link Nav QuickLunch==== $($linkMenu)"

        #try {
            #$response = Invoke-WebRequest -Uri $linkMenu -MaximumRedirection 0 -ErrorAction Stop
            #Write-Host "La URL es válida y accesible. Código de estado: $($response.StatusCode)"
            
            if ($parentNode -eq $null) {
                $navNode = Add-PnPNavigationNode -Title $($descripcionItemMenu) -Url $linkMenu -Location QuickLaunch
                Write-Host "Nodo principal creado: $($descripcionItemMenu)"
            } else {
                $navNode = Add-PnPNavigationNode -Title $($descripcionItemMenu) -Url $linkMenu -Parent $parentNode.Id -Location QuickLaunch
                Write-Host "Nodo hijo creado: $($descripcionItemMenu) bajo el nodo $($parentNode.Title)"
            }
        #} catch {
        #   Write-Host "La URL no es accesible. Error: $($_.Exception.Message)"
        #}

        if ($item.Submenus -and $item.Submenus.Count -gt 0) {
            Write-Host "Procesando recursivamente los submenús del menú: $($descripcionItemMenu)" -ForegroundColor Cyan
            Procesar-Navegacion -items $item.Submenus -parentNode $navNode
        }
    }
}

$items = $siteJson.navegacion.Submenus

if ($items -and $items.Count -gt 0) {
    Write-Host "Existen elementos de navegación. Procesando..."
    Procesar-Navegacion -items $items
} else {
    Write-Host "No hay submenús en la navegación." 
}