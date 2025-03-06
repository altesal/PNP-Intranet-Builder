import os
import pandas as pd #pip install pandas
import json
import sys

if len(sys.argv) < 3:
    print("Uso: py.exe .\\CreaJSONIntranets.py <alias_intranet> <Entorno: DEV, INT, PRE, PRO>")
    sys.exit(1)

alias_intranet = sys.argv[1]
entornoDespliegue = sys.argv[2].upper()

if entornoDespliegue not in ["DEV", "INT", "PRE", "PRO"]:
    print("Error: El valor del entorno debe ser 'DEV', 'INT', 'PRE' o 'PRO'.")
    sys.exit(1)

carpetaFicheroDatos = os.path.join("..", "pnpPS", "ESPECIFICO", alias_intranet, "Data")
fileConfig = os.path.join("..", "pnpPS", "ESPECIFICO", alias_intranet, "config.json")
with open(fileConfig, "r", encoding="utf-8") as f:
    infoConfig = json.load(f)

configDescripccion = next((entorno["Descripcion"] for entorno in infoConfig["Configuracion"] if entorno["Entorno"] == entornoDespliegue), None)
print("ConfigDescripccion:", configDescripccion)
configEntorno = entornoDespliegue
print("Entorno:", configEntorno)
configTenanturl = next((entorno["TenantURL"] for entorno in infoConfig["Configuracion"] if entorno["Entorno"] == entornoDespliegue), None)
print("TenantURL:", configTenanturl)
configAplicacionRegistradaAzure = next((entorno["AplicacionRegistradaAzure"] for entorno in infoConfig["Configuracion"] if entorno["Entorno"] == entornoDespliegue), None)
print("ClientID:", configAplicacionRegistradaAzure)
configInteractive = next((entorno["Interactive"] for entorno in infoConfig["Configuracion"] if entorno["Entorno"] == entornoDespliegue), None)
print("Modo interactivo:", configInteractive)

respuesta = input("¿Deseas continuar? (presiona Enter para sí, 'no' para salir): ").strip().lower()
if respuesta == 'no':
    print("Saliendo del script.")
    sys.exit(0) 
print("Continuando con el script...")

print(f"Busque su fichero contentPlan.json en la ruta: {carpetaFicheroDatos}")
os.makedirs(carpetaFicheroDatos, exist_ok=True)
output_file = os.path.join(carpetaFicheroDatos, "contentPlan.json")


#Functions
def obtener_site_sin_prefijo(url):
    if len(url) >= 4 and url[:3] in ["DEV", "PRE", "PRO"] and url[3] == "-":
        return url[4:]
    return url

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
        "urlSiteAbsoluta": f"{configTenanturl}sites/{configEntorno}-{row['urlSite']}",
        "urlSite":f"{configEntorno}-{row["urlSite"].split('/')[-1]}",
        "typeSite": row["typeSite"],
        "esHUB":row["esHUB"],
        "titleHUB":row["titleHUB"] if pd.notna(row["titleHUB"]) else "",
        "asociarAHUB": f"{configTenanturl}sites/{configEntorno}-{row["asociarAHUB"]}" if pd.notna(row["asociarAHUB"]) and str(row["asociarAHUB"]).strip() else "",
        "navegacion":""
    }
    data["sites"].append(site)

#Hoja Modulos a desplegar
columnasHojaModulos = ['Modulo','Desplegar','Site','Propiedades']
modulosSiteExcel = pd.read_excel(excelContentPlanPath, sheet_name='Modulos', usecols=columnasHojaModulos)
modulosSiteExcel = modulosSiteExcel.fillna("")

for site in data["sites"]:
  site_name = obtener_site_sin_prefijo(site["urlSite"])  
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
columnasFileRecursos = ['Site','TipoRecurso','Lista_internalname','Lista_displayname','Lista_template','Lista_displayNameForTitle','Lista_HojaDatosExcel']
columnasFileColumnasDeLista = ['scope','internalNameLista','internalName','displayName','isrequired','typef','choiceOptions']
columnasDeLista = pd.read_excel(excelContentPlanPath, sheet_name='columnasListas', usecols=columnasFileColumnasDeLista)
recursosSite = pd.read_excel(excelContentPlanPath, sheet_name='Recursos', usecols=columnasFileRecursos)
recursosSite = recursosSite.fillna("")
columnasDeLista = columnasDeLista.fillna("")

recursosListas = recursosSite[recursosSite["TipoRecurso"] == "Lista"]
for site in data["sites"]:
    site_name = obtener_site_sin_prefijo(site["urlSite"])
    listas = [
        {
          "displayname": row["Lista_displayname"],
          "internalname": row["Lista_internalname"],
          "templateLista":row["Lista_template"],
          "hojaDatosExcel":row["Lista_HojaDatosExcel"],
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
columnasHojaContentPlan = ['ID', 'Nivel','NavPrincipal', 'ParentID', 'Description', 'urlN1','pageURL','enllac','Plantilla recomanat']
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
            folder = row["Description"]
            parent_level2_desc = folder  # Guardar el nombre para los niveles 3+
        elif nivel >= 3:
            folder = parent_level2_desc

        if row["enllac"]:
            link = row["enllac"]
        else:
            link = f"{configTenanturl}sites/{configEntorno}-{row["urlN1"]}{row["pageURL"]}"

        nodo = {
            "ID": row["ID"],
            "Nivel":row["Nivel"],
            "NavPrincipal" : 1 if row["NavPrincipal"] == 1 else 0,
            "Descripcion": row["Description"],
            "url": link,
            "plantilla":row["Plantilla recomanat"],
            "folder": folder,
            "Submenus": construir_navegacion(tablaExcelNavegacion, row["ID"],site_url,parent_level2_desc)  # Llamada recursiva
        }
        items.append(nodo)
    return items

# Iteramos por cada sitio y le agregamos la navegación
for site in data["sites"]:
    site_url_ContentPlan_sinPrefijo = obtener_site_sin_prefijo(site["urlSite"])
    navegacion = construir_navegacion(tablaExcelNavegacion, parent_id="",site_url=site_url_ContentPlan_sinPrefijo)  # Ajustar el parent_id según sea necesario
 
    site["navegacion"] = navegacion  # Agregar la navegación al site

with open(output_file, "w") as file:
        json.dump(data, file, indent=4)

print(f"Archivo guardado en: {os.path.abspath(output_file)}")