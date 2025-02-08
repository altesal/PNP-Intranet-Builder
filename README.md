# PNP-Intranet-Builder

# Instrucciones para montar el entorno

1. Crear la siguiente estructura de carpetas

    pnpPS

        ESPECIFICO\.gitkeep

    Utils

        jSON
            CreaJSONIntranets.py


2. Incluir en el .gitignore  pnpPS7/ESPECIFICO/*


# Desplegar una nueva intranet

1. Crear dentro de `pnpPS>ESPECIFICO` la siguiente estructura de carpetas 

    `<nombre_entorno>`

        Data\contentPlan.xlsx

2. Hojas del contentPlan.xlsx

    - Hoja: SITES. Columnas: ['typeSite','titleSite','urlSite','esHUB','titleHUB','asociarAHUB']


3. Generar el contentPlan.json. Abrir una terminal y colocándose en `Utils>JSON` ejecutar

    ```
    py.exe CreaJSONIntranets.py <alias_intranet>






