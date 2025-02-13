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


# Desplegar una nueva intranet

1. Crear dentro de `pnpPS>ESPECIFICO` la siguiente estructura de carpetas 

    `<nombre_entorno>`

       ✅  Data. Contiene el fichero contentPlan.xlsx a partir del que se generará el contentPlan.json
       ✅  Images. Contiene por ejemplo el logo
       ✅  Templates. 
                    - Subir plantillas **Requiere conexión interactive**
                    - Contiene ficheros xml con plantillas
                    - Los ficheros xml pueden generarse ejecutando el script individual exportarTemplates.ps1 de Utils (este script no requiere conexión interactive) 
                    - Recomendable no incluir caracteres especiales en los nombres de ficheros de plantillas
                    

2. Hojas del contentPlan.xlsx

    - Hoja: SITES. Columnas: ['typeSite','titleSite','urlSite','esHUB','titleHUB','asociarAHUB']

    - Hoja: Modulos. Columnas: ['Modulo','Desplegar','Site','Propiedades']

3. Generar el contentPlan.json. Abrir una terminal y colocándose en `Utils>JSON` ejecutar

    ```
    py.exe CreaJSONIntranets.py <alias_intranet>






