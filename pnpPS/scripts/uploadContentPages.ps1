param (
[string]$mensaje  = $(throw "...")
)
Write-Host "($mensaje) Script: $($MyInvocation.MyCommand.Name)" 

$templatesPath = (Resolve-Path ("ESPECIFICO\"+$nombreIntranet+"\Templates\ContentPages")).Path

Get-ChildItem -Path $templatesPath -File | Where-Object { $_.Extension -eq ".xml" }  | ForEach-Object {

    Write-Host "TemplatesPath: $($templatesPath )"
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $tmpTempplateFiles = $templatesPath + "\tmp"
    Remove-Item -Path $tmpTempplateFiles\* -Recurse -Force
    $sourceFilePath = Join-Path -Path $templatesPath -ChildPath $_.Name
    $destinationFilePath = Join-Path -Path $tmpTempplateFiles -ChildPath "$($_.BaseName)_$timestamp$($_.Extension)"
    Write-host "Source FilePath: $($sourceFilePath) y Destination FilePath: $($destinationFilePath)"
    Copy-Item -Path $sourceFilePath -Destination $destinationFilePath -Force

    $fullPath = $_.FullName
    $fullPath = $destinationFilePath
    
    [xml]$xmlContent = Get-Content -Path $fullPath
    
    $namespaceManager = New-Object System.Xml.XmlNamespaceManager($xmlContent.DocumentElement.OwnerDocument.NameTable)
    $namespaceManager.AddNamespace("pnp", "http://schemas.dev.office.com/PnP/2022/09/ProvisioningSchema")  
    $aspxPages = $xmlContent.SelectNodes("//pnp:ClientSidePage[(@PromoteAsTemplate='false' and @PromoteAsNewsArticle='true') or @PageName='Home.aspx']", $namespaceManager)
    
    Write-Host "Número total de páginas ASPX en el fichero $($fullPath): $($aspxPages.Count)"
    $paginasValidas = @()
    $aspxPages | ForEach-Object { 
        #Write-Host "🔍 Depuración: Objeto actual: $($_ | Out-String)" -ForegroundColor Cyan
        if (-not $_.PageName) {
            Write-Host "⚠️ El nodo no tiene PageName." -ForegroundColor Yellow
            continue
        } else {
            $page = $_
            $pageName = $_.PageName
        }

        $contentTypeId = $_.ContentTypeID
        if($contentTypeId)
        {
            Try{
                $contentType = Get-PnPContentType -Identity $contentTypeId -ErrorAction Stop
                $paginasValidas += $pageName
            }
            catch {
                #Write-Host "Intentando eliminar nodo: $($page.OuterXml)" -ForegroundColor Cyan
                Write-Host "ParentNode antes de eliminar: $($page.ParentNode.Name)" -ForegroundColor Magenta

                if ($page.ParentNode -ne $null) {
                    $removedNode = $page.ParentNode.RemoveChild($page)
                    $xmlContent.Save($fullPath)
                    Write-Host "📂 XML guardado en: $fullPath" -ForegroundColor Green
                    if ($removedNode -ne $null) {
                        Write-Host "✅ Nodo eliminado correctamente: $($page.GetAttribute('PageName'))" -ForegroundColor Green
                    } else {
                        Write-Host "❌ RemoveChild() no eliminó el nodo. Puede que no sea un hijo directo." -ForegroundColor Red
                    }
                } else {
                    Write-Host "❌ Error: ParentNode es null. No se puede eliminar el nodo." -ForegroundColor Red
                }

                Write-Host "⚠️ Warning: $($_.Exception.Message) Página: $($page.GetAttribute('PageName'))" -ForegroundColor Yellow
            }
        } else {
            $paginasValidas += $pageName
        }
       
    }
   $paginasValidas
    if($paginasValidas.Count -gt 0)
    {
        Invoke-PnPSiteTemplate -Path $fullPath 
        $paginasValidas | ForEach-Object {
            Write-Host "📄 Publicando página: $_" 
            if ($_ -eq "Home.aspx")
            {
                $SetPnPPage = Set-PnPPage -Identity $_ -Publish -PromoteAs HomePage
            }
            else {
                $SetPnPPage = Set-PnPPage -Identity $_ -Publish -PromoteAs NewsArticle
            }
        }
    }
    Write-Host "Fichero a borrar $($fullPath)"
    Remove-Item $fullPath
}
