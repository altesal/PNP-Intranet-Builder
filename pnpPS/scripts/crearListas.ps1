param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$mensaje  = $(throw "Cuál es el nombre de la intranet a desplegar...")
)

function CrearLista {
    param (
        [Parameter(Mandatory = $true)]
        $lista
    )

    $listUrl = $lista.internalname
    $listName = $lista.displayname
    $listTemplate = $lista.templateLista
    	
    if (Get-PnPList -Identity $listName -ErrorAction SilentlyContinue) {
        Remove-PnPList -Identity $listName -Recycle -Force
    }
    $newList = New-PnPList -Title $listName -Url ("Lists/"+$listUrl) -Template $listTemplate
    Write-Host "Nueva lista creada -> Title: $($newList.Title)"
        
    if($lista.displayNameForTitle -ne "Title" -and -not [string]::IsNullOrWhiteSpace($lista.displayNameForTitle)){
        $fieldTitle = Get-PnPField -List $listName -Identity "Title"
         Set-PnPField -List $listName -Identity $fieldTitle.Id -Values @{Title=$lista.displayNameForTitle} 
    }

    foreach($columna in $lista.columnas){
        switch ($columna.typef) {
            "Text" {
                $field = Add-PnPField -List $listName `
                    -DisplayName $columna.displayName `
                    -InternalName $columna.nombreColumna `
                    -Type $columna.typef  `
                    -AddToDefaultView -ErrorAction Continue		
					
		        if ([bool]$columna.isrequired -eq $true){	
					$field.Required = $true
					$field.Update()
				}
            }
            Default {
                Write-Host "Tipo de columna no reconocida"
            }
        }
    }
}

Try{
    
    if ($siteJson.PSObject.Properties.Name -contains "listas" -and $siteJson.listas.Count -gt 0) {
        Write-Host $mensaje
        Write-Host "El sitio: $($siteJson.titleSite) TIENE LISTAS" -f Green
        foreach ($lista in $siteJson.listas) {
            CrearLista -lista $lista
        }
    }
    
}
catch {
	write-host "Error: $($_.Exception.Message)" -foregroundcolor Red
}