param (
[Parameter(Mandatory=$false)] [string]$entorno  = $(throw "Cuál es el nombre del entorno para el que se generará el log?")
)

try {
    $horaexec = Get-Date
    $fechaFichero = $horaexec.Year.ToString() + `
                    ( "00" + $horaexec.Month).SubString(("00"+$horaexec.Month).Length-2,2) + `
                    ( "00" + $horaexec.Day).SubString(("00"+$horaexec.Day).Length-2,2) +  ` 
                    ( "00" + $horaexec.Hour).SubString(("00"+$horaexec.Hour).Length-2,2) + `
                    ( "00" + $horaexec.Minute).SubString(("00"+$horaexec.Minute).Length-2,2) 

    $extensionFichero = ".log"
    return $entorno + $fechaFichero + $extensionFichero
} catch {

}



