# PNP-Intranet-Builder

# Instrucciones para montar el entorno

1. Crear la siguiente estructura de carpetas

    pnpPS
        ESPECIFICO\.gitkeep
    Utils
        jSON
            CreaJSONIntranets.py


2. Incluir en el .gitignore  

```
pnpPS/ESPECIFICO/*
!pnpPS/ESPECIFICO/.gitkeep
```

# Utilidades

1. Exportar páginas o plantillas

    ```
    Modificar los siguientes parámetros de configuración:

    $siteCollectionPlantillaACopiar = "https://<tenant>.sharepoint.com/sites/<nombre_site>"
    
    $nombreIntranet = "<alias_intranet>"
    
    $clientId = "<client_id>"  #No requerido
    
    $templateName = "<Nombre_fichero_XML>" 

    ``` 

    ```Ejecutar la instrucción:

    exportarSitePages.ps1 
    
    ```


    El xml se guardará bajo la carpeta Templates/exportaciones

2. Crear listas
    Excel del contentPlan. Dos hojas: Recursos y columnasListas
    
    Columnas Hoja Recursos: ['Site','TipoRecurso','Lista_internalname','Lista_displayname','Lista_template','Lista_displayNameForTitle','Lista_HojaDatosExcel']
    Columnas Hoja columnasListas = ['scope','internalNameLista','internalName','displayName','isrequired','typef','choiceOptions']

    La columan Id no aplica para TipoRecurso=Lista en la hoja Recursos

    El módulo CrearListas debe estar habilitado para una intranet concreta, o valer All si la lista se quiere crear en todos los sites
    
3. Importar items en una lista

    Hay que dar de alta los items a importar en una hoja del Excel con el nombre definido en la columan Lista_HojaDatosExcel, en la hoja Recursos de contentPlan.xlsx

    Deben coincidir entre la hoja de datos y la definición de columnas en la hoja columnas listas: igual número de columnas, mismo nombre de columnas. Se puede cambiar el display name de Title, en la columan Lista_displayNameForTitle de la hoja Recursos.

# Desplegar una nueva intranet

1. Crear dentro de `pnpPS>ESPECIFICO` la siguiente estructura de carpetas 

    `<nombre_entorno>`

       ✅  Data. Contiene el fichero contentPlan.xlsx a partir del que se generará el contentPlan.json
    
       ✅  Images. Contiene por ejemplo el logo.png
    
       ✅  Templates. 
    
                    - Subir plantillas **Requiere conexión interactive**
    
                    - Contiene ficheros xml con plantillas
    
                    - Los ficheros xml pueden generarse ejecutando el script individual exportarTemplates.ps1 de Utils (este script no requiere conexión interactive) 
    
                    - Recomendable no incluir caracteres especiales en los nombres de ficheros de plantillas
                    

2. Hojas del contentPlan.xlsx

    - Hoja: SITES. Columnas: ['typeSite','titleSite','urlSite','esHUB','titleHUB','asociarAHUB']

    - Hoja: Modulos. Columnas: ['Modulo','Desplegar','Site','Propiedades']

    - Hoja: Content Plan. Columnas: ['ID', 'Nivel','NavPrincipal', 'ParentID', 'displayNameN1', 'urlN1','link'] 
            Plantilla recomanat. Posibles valores [Home, PT_Final, PT_Distribuidora]

            

3. Generar el contentPlan.json. Abrir una terminal y colocándose en `Utils>JSON` ejecutar

    ```
    py.exe CreaJSONIntranets.py <alias_intranet>

    ````
4. Exportar una plantilla

    COnfigurar variables  en las primeras líneas del fichero exportarSitePages.ps1

    ```
    PS C:\...\PNP-Intranet-Builder\Utils
    exportarSitePages.ps1  #Puese usar conexión UseWebLogin
    exportarTemplates.psq  #Requiere conexión interactiva y cliensId
    ```    




