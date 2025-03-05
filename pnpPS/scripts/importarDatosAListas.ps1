param ([string]$Mensaje)

function ImportarLista {
    param ($lista)

    $internalNameLista = $lista.internalName
    $displayNameLista = $lista.displayname
    $nombreHojaExcel = $lista.hojaDatosExcel
    Write-Host "Comienzo de la importación $($internalNameLista)"
    Write-Host "inicio del script ErrorFileImportacion: "  $ErrorFileImportacion
    Write-Host "Nombre lista: " $internalNameLista 
    #Necesario el módulo ImportExcel:  Install-Module -Name ImportExcel -Scope CurrentUser
    $fileCSV = (".\ESPECIFICO\"+$nombreIntranet+"\Data\contentPlan.xlsx")  #[TODO]
    #IMPORTANTE: fichero csv formato UTF-8 por tema caracteres
    $registros = Import-Excel -Path $fileCSV -WorksheetName $nombreHojaExcel
    $headers = $registros | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
    $numRegistro = 0
    $ErroresImportacion = @()
    try {	
        $registros | ForEach-Object {
            $numRegistro = $numRegistro + 1 
            if ($numRegistro % 20 -eq 0) {
                Write-Host "." -ForegroundColor Cyan
                Write-host "Número de registros pendientes:  $( $registros.Count - $numRegistro )"    -f Yellow
            }
            $hashTable = @{}
            foreach ($header in $headers) {
                $hashTable[$header] = $_.$header
            }	
            $listItem = Add-PnPListItem -List $displayNameLista -Values $hashTable
        }
    }
    catch {
        Write-Host -f Red "Error:" $_.Exception.Message
    }
}

Try{    
    if ($siteJson.PSObject.Properties.Name -contains "listas" -and $siteJson.listas.Count -gt 0) {
        Write-Host $mensaje
        foreach ($lista in $siteJson.listas) {
            ImportarLista -lista $lista
        }
    }    
}
catch {
	write-host "Error leyendo listas: $($_.Exception.Message)" -foregroundcolor Red
}




                     




Write-Host  "Fin del script: ErrorFileImportacion: "  $ErrorFileImportacion
