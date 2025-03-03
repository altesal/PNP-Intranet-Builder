param ($descripcionSinTratar)

$descripcionSinAcentos = Remove-Accents $descripcionSinTratar.ToLower()
$newDescripcion = $descripcionSinAcentos -replace "[^a-zA-Z0-9 ]", "" -replace " ", "-"
return $newDescripcion
