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
columnasFileModulos = ['Modulo','Desplegar','Site','Propiedades']
modulosSiteExcel = pd.read_excel(excelContentPlanPath, sheet_name='Modulos', usecols=columnasFileModulos)
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



with open(output_file, "w") as file:
        json.dump(data, file, indent=4)

print(f"Archivo guardado en: {os.path.abspath(output_file)}")