param (
[Parameter(Mandatory=$true)] [string]$nombreIntranet  = $(throw "Cuál es el nombre de la intranet a desplegar...")
)
clear

Function desplegarModulo {
    param (
        [string]$nombreModulo
    )
    try {
        $modulo = $siteJson.modulos | Where-Object { $_.modulo -eq $nombreModulo -and $_.desplegar -eq 1 }
        if ($modulo) {
            if( $modoInteractivo -eq $true) { 
                Connect-PnPOnline -Url $urlAbsoluta -ClientId $clientId -Interactive
            } 
            else {
                Connect-PnPOnline -Url $urlAbsoluta -UseWebLogin
            }

            $context = Get-PnPContext
            if ($context -eq $null) {
                Write-Host "❌ No hay conexión activa con SharePoint." -ForegroundColor Red
            } else {
                Write-Host "✅ Conectado a SharePoint correctamente." -ForegroundColor Green
                Write-Host "URL del sitio conectado: $($context.Url) con ModoInteractivo $($modoInteractivo)" -ForegroundColor Cyan
                
                switch($nombreModulo) {
                    'HomePage'{
                        & .\scripts\configurarHomePage.ps1 -Mensaje "Configurando pàgina de inici..." 
                    }
                    'NoticiasAvisos'{
                        & .\scripts\addModuleNews.ps1 -Mensaje "Módulo News. Añadir content types Noticia y Avis..." -Modulo $modulo
                    }
                    'Templates'{
                        & .\scripts\uploadTemplates.ps1 -Mensaje "Subiendo plantillas a la biblioteca de páginas de sitio"
                    }
                    'Images'{
                        & .\scripts\uploadImages.ps1 -Mensaje "Subiendo imágenes a la biblioteca Site Assets"
                    }
                }
            }
        } else {
            Write-Output "El sitio $($siteJson.urlSite) no tiene el módulo $($nombreModulo)"
        }
    }
    catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Tipo de excepción: $($_.Exception.GetType().FullName)" 
        Write-Host "Detalles completos de la excepción: $($_.Exception.ToString())" 
        Write-Host "Pila de llamadas (StackTrace): $($_.Exception.StackTrace)"

    }
}


try
{
    $title="ACCIONES SOBRE LA INTRANET"
    $questionAccion = '¿Qué acción quieres realizar?'
    $choicesAccion = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
    $choicesAccion.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&1.Borrar y crear estructura de sites'))
    $choicesAccion.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&2.Desplegar Intranet'))
    $decisionAccion = $Host.UI.PromptForChoice($title, $questionAccion, $choicesAccion, 0)

    switch -regex ($decisionAccion) {
        '0' {
                Write-Host 'Borrar y crear estructura de sites...'
                $accion = 'Borrar-Crear-Sites'
                $descripcionAccion= "Borrar y crear estructura de sites..."
            }	
        '1' {
                Write-Host 'Desplegar intranet...'
                $accion = 'DesplegarIntranet'
                $descripcionAccion= "Desplegar intranet..."
            }	
        default { 
            $accion = ""
        }
    }

    $questionEntorno = '¿Cuál será el entorno de ejecución?'
    $choicesEntorno = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
    $choicesEntorno.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&1.DEV. DESARROLLO'))
    $choicesEntorno.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&2.INT. INTEGRACIÓN'))
    $choicesEntorno.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&3.PRE. PREPRODUCCIÓN'))
    $choicesEntorno.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&4.PRO. PRODUCCIÓN'))
    $titleEntorno="ENTORNOS"
    $entornoSeleccionado = $Host.UI.PromptForChoice($titleEntorno, $questionEntorno, $choicesEntorno, 0)

    $ficheroConfiguracion = ".\ESPECIFICO\$($nombreIntranet)\config.json" 
    $config = (Get-Content $ficheroConfiguracion | ConvertFrom-Json).Configuracion | Where-Object { $_.Entorno -eq "DEV" }
    if ($config.Count -ne 1) { throw "Se esperaba exactamente un objeto, pero se encontraron $($config.Count)." }
	$nombreFichero = & "..\Utils\nombreFicheroLog.ps1" -entorno $config.entorno
	$fitxerLog = (".\ESPECIFICO\" + $nombreIntranet + "\Log\" + $nombreFichero) 
    
    Start-Transcript -Path $fitxerLog
    $config
    $modoInteractivo = [bool]($config.Interactive -eq 1)
    $tenantUrl = $config.TenantURL
    $clientId = $config.AplicacionRegistradaAzure
    $contenPlanFile = (".\ESPECIFICO\"+$nombreIntranet+"\Data\contentPlan.json")

    switch ($accion) {
        "Borrar-Crear-Sites" {
            if( $modoInteractivo -eq $true) { 
   				Write-Host "Conexión interactiva..."        
        		Connect-PnPOnline -Url $tenantUrl -ClientId $clientId -Interactive
				& .\scripts\borrarSites.ps1 -Mensaje "Borrando sites..." 
				& .\scripts\crearSites.ps1 -Mensaje "Creando estructura de sites..." 
			} 
			else {
				Write-Host "Conexión UseWebLogin al urlTenant: "  $tenantUrl      
				Connect-PnPOnline -Url $tenantUrl -UseWebLogin
				Write-Host "BORRAR Y CREAR SITES - Requiere Permisos AllSites.FullControl en el registro de la aplicación de Azure"
			} 
			Write-Host "Conexión establecida con éxito al tenant "  $tenantUrl 
        }
        "DesplegarIntranet"
		{
            $JSONFIle = Get-Content $contenPlanFile | ConvertFrom-Json
            $JSONFIle.sites | ForEach-Object {
                Try{
                    $siteJson = $_
                    $urlAbsoluta = $siteJson.urlSiteAbsoluta
                  
                    $sharepointSite = Get-PnPTenantSite -Url $urlAbsoluta -ErrorAction SilentlyContinue
                   
                    if ($sharepointSite) {
                        desplegarModulo -nombreModulo "HomePage" 
                        desplegarModulo -nombreModulo "NoticiasAvisos"
                        desplegarModulo -nombreModulo "Images"
                        desplegarModulo -nombreModulo "Templates"
                    } else {
                        Write-Host "No existe el site actual: $($urlAbsoluta)"
                    }
                }
                catch {
                    write-host "Error: $($_.Exception.Message)" -foregroundcolor Red
                }
            } 
        }

    }

    Stop-Transcript

} 
catch{
   write-host "$($_.Exception.Message)" -foregroundcolor Red
}
