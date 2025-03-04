param ($descripcionSinTratar)

Function Remove-Accents {
    param ($inputString)
    $normalizedString = $inputString.Normalize([Text.NormalizationForm]::FormD)
    return ($normalizedString -replace '\p{M}', '')
}

$descripcionSinAcentos = Remove-Accents $descripcionSinTratar.ToLower()
$newDescripcion = $descripcionSinAcentos -replace "[^a-zA-Z0-9 ]", "" -replace " ", "-"
return $newDescripcion
