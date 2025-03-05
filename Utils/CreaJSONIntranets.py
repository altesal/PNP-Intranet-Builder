import os
import pandas as pd #pip install pandas
import json
import sys

if len(sys.argv) < 2:
    print("Uso: py.exe .\\CreaJSONIntranets.py <alias_intranet>")
    sys.exit(1)

alias_intranet = sys.argv[1]
carpetaFicheroDatos = os.path.join("..", "pnpPS", "ESPECIFICO", alias_intranet, "Data")

print(f"Busque su fichero contentPlan.json en la ruta: {carpetaFicheroDatos}")
os.makedirs(carpetaFicheroDatos, exist_ok=True)
output_file = os.path.join(carpetaFicheroDatos, "contentPlan.json")

data = {}
data["sites"] = []

excelContentPlanPath = os.path.join(carpetaFicheroDatos, "contentPlan.xlsx")

#Hoja SITES a desplegar
columnasHojaSites = ['typeSite','titleSite','urlSite','esHUB','titleHUB','asociarAHUB']
tablaExcelSites = pd.read_excel(excelContentPlanPath, sheet_name='SITES', usecols=columnasHojaSites)
tablaExcelSites = tablaExcelSites.fillna("")

for _, row in tablaExcelSites.iterrows():
    site = {
        "titleSite": row["titleSite"],
        "urlSiteAbsoluta": row["urlSite"],
        "urlSite":row["urlSite"].split('/')[-1],
        "typeSite": row["typeSite"],
        "esHUB":row["esHUB"],
        "titleHUB":row["titleHUB"] if pd.notna(row["titleHUB"]) else "",
        "asociarAHUB":row["asociarAHUB"] if pd.notna(row["asociarAHUB"]) else "",
        "navegacion":""
    }
    data["sites"].append(site)

#Hoja Modulos a desplegar
columnasHojaModulos = ['Modulo','Desplegar','Site','Propiedades']
modulosSiteExcel = pd.read_excel(excelContentPlanPath, sheet_name='Modulos', usecols=columnasHojaModulos)
modulosSiteExcel = modulosSiteExcel.fillna("")

for site in data["sites"]:
  site_name = site["urlSite"]  
  modulos = [
      {
        "modulo": row["Modulo"],
        "desplegar": row["Desplegar"],
        "propiedades" : {
            prop.split("=")[0]: prop.split("=")[1]
            for prop in row["Propiedades"].split(";") if "=" in prop
        } 
      }
      for _, row in modulosSiteExcel.iterrows() if row["Site"] == site_name or row["Site"] == "All"
  ]
  site["modulos"] = modulos  

#Hoja Content Plan. Recursos
#xls = pd.ExcelFile(excelContentPlanPath)
#print("Hojas disponibles:", xls.sheet_names)
columnasFileRecursos = ['Site','TipoRecurso','Lista_internalname','Lista_displayname','Lista_template','Lista_displayNameForTitle']
columnasFileColumnasDeLista = ['scope','internalNameLista','internalName','displayName','isrequired','typef','choiceOptions']
columnasDeLista = pd.read_excel(excelContentPlanPath, sheet_name='columnasListas', usecols=columnasFileColumnasDeLista)
recursosSite = pd.read_excel(excelContentPlanPath, sheet_name='Recursos', usecols=columnasFileRecursos)
recursosSite = recursosSite.fillna("")
columnasDeLista = columnasDeLista.fillna("")

recursosListas = recursosSite[recursosSite["TipoRecurso"] == "Lista"]
for site in data["sites"]:
    site_name = site["urlSite"]  
    listas = [
        {
          "displayname": row["Lista_displayname"],
          "internalname": row["Lista_internalname"],
          "templateLista":row["Lista_template"],
          "displayNameForTitle":row["Lista_displayNameForTitle"],
          "columnas": [ 
              {
                "scope": col["scope"],
                "nombreColumna": col["internalName"],
                "displayName": col["displayName"],
                "isrequired": int(col["isrequired"]),
                "typef": col["typef"]
              } | ({"choiceOptions": col["choiceOptions"]} if col["typef"] == "Choice" else {})
               for _, col in columnasDeLista.iterrows()  if col["internalNameLista"] == row["Lista_internalname"]
          ]
        }
        for _, row in recursosListas.iterrows() if row["Site"] == site_name
    ]
    site["listas"] = listas  

#Hoja Content Plan. Navegación
columnasHojaContentPlan = ['ID', 'Nivel','NavPrincipal', 'ParentID', 'displayNameN1', 'urlN1','link','Plantilla recomanat']
tablaExcelNavegacion = pd.read_excel(excelContentPlanPath, sheet_name='ContentPlan', usecols=columnasHojaContentPlan)
tablaExcelNavegacion = tablaExcelNavegacion.fillna("")

def construir_navegacion(tablaExcelNavegacion, parent_id, site_url, parent_level2_desc=""):
    items = []
    df_filtrado = tablaExcelNavegacion[(tablaExcelNavegacion["ParentID"] == parent_id) & (tablaExcelNavegacion["urlN1"] == site_url)]
    #print(f"DataFrame: {df_filtrado}")
    for _, row in df_filtrado.iterrows():
        nivel = row["Nivel"]

        if nivel == 0:
            folder = ""
        elif nivel == 1 or nivel == 2:
            folder = row["displayNameN1"]
            parent_level2_desc = folder  # Guardar el nombre para los niveles 3+
        elif nivel >= 3:
            folder = parent_level2_desc

        nodo = {
            "ID": row["ID"],
            "Nivel":row["Nivel"],
            "NavPrincipal" : 1 if row["NavPrincipal"] == 1 else 0,
            "Descripcion": row["displayNameN1"],
            "url": row["link"],
            "plantilla":row["Plantilla recomanat"],
            "folder": folder,
            "Submenus": construir_navegacion(tablaExcelNavegacion, row["ID"],site_url,parent_level2_desc)  # Llamada recursiva
        }
        items.append(nodo)
    return items

# Iteramos por cada sitio y le agregamos la navegación
for sitio in data["sites"]:
    navegacion = construir_navegacion(tablaExcelNavegacion, parent_id="",site_url=sitio["urlSite"])  # Ajustar el parent_id según sea necesario
 
    sitio["navegacion"] = navegacion  # Agregar la navegación al sitio


with open(output_file, "w") as file:
        json.dump(data, file, indent=4)

print(f"Archivo guardado en: {os.path.abspath(output_file)}")