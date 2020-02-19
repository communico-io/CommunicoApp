# Input bindings are passed in via param block.
param($InputBlob, $TriggerMetadata)

# Write out the blob name and size to the information log.
Write-Host "PowerShell Blob trigger function Processed blob! Name: $($TriggerMetadata.Name) Size: $($InputBlob.Length) bytes"

# Turn the Input Blob from a Byte[] into a MemoryStream object
$InStream = New-Object System.IO.MemoryStream $InputBlob, 0, $InputBlob.Length

# Create an Output MemoryStream object
$OutStream = New-Object System.IO.MemoryStream

# Create a GzipStream object by decompressing the Input MemoryStream
$GzStream = New-Object System.IO.Compression.GZipStream ([System.IO.MemoryStream]$InStream),([System.IO.Compression.CompressionMode]::Decompress)
$Buffer = New-Object byte[](1024)
while($true)
{
    $Read = $GzStream.Read($Buffer, 0, 1024)
    if ($Read -le 0) { break }
    $OutStream.Write($Buffer, 0, $Read)
}

# Turn the Output from a MemoryStream object into a Byte[]
[Byte[]]$OutputBlob = $OutStream.ToArray()

# Return the Byte[] to the OutputBlob binding
Push-OutputBinding -Name OutputBlob -Value $OutputBlob
