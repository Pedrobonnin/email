@echo off


REM Definir las variables globales

REM Carpeta Origen
set "SourceFolder=E:\descargas\Video\Nueva carpeta\origen"

REM Carpeta Destino
set "Folder=E:\descargas\Video\Nueva carpeta\destino"

REM Destino de la captura
set "ScreenshotPath=C:\Users\bonni\Desktop\back ups email\captura\captura_pantalla1.png"

REM Exe captura de pantalla nircmd
set "Nircmd=C:\Users\bonni\Desktop\back ups email\nircmd\nircmd.exe"





REM Ejecutar el código PowerShell y guardar los resultados en variables
for /f "usebackq delims=" %%A in (`powershell -Command "$FolderInfo = Get-ChildItem -Path '%Folder%' -Recurse | Measure-Object -Property Length -Sum; $Size = $FolderInfo.Sum / 1MB; $FilesCount = $FolderInfo.Count; Write-Output $Size, $FilesCount"`) do (
    if not defined Size (
        set "Size=%%A"
    ) else (
        set "FilesCount=%%A"
    )
)

REM Imprimir los resultados antes de la copia
echo Peso de la carpeta antes de la copia: %Size% MB
echo Cantidad de archivos antes de la copia: %FilesCount%

REM Realizar la copia con Robocopy
ROBOCOPY "%SourceFolder%" "%Folder%" /E /V /TEE

REM Obtener los datos de la carpeta después de la copia de seguridad
for /f "usebackq delims=" %%A in (`powershell -Command "$FolderInfo = Get-ChildItem -Path '%Folder%' -Recurse | Measure-Object -Property Length -Sum; $SizeAfter = $FolderInfo.Sum / 1MB; $FilesCountAfter = $FolderInfo.Count; Write-Output $SizeAfter, $FilesCountAfter"`) do (
    if not defined SizeAfter (
    	set "SizeAfter=%%A"
    ) else (
    	set "FilesCountAfter=%%A"
    )
)

REM Imprimir los resultados después de la copia
echo Peso de la carpeta despues de la copia: %SizeAfter% MB
echo Cantidad de archivos despues de la copia: %FilesCountAfter%

REM Ejecuta Screenhot
"%Nircmd%" savescreenshot "%ScreenshotPath%"

REM Verificar si la captura de pantalla se realizó exitosamente
if exist "%ScreenshotPath%" (
    echo Captura de pantalla guardada exitosamente en %ScreenshotPath%
    REM Enviar correo electrónico con la captura de pantalla y los datos adjuntos
    PowerShell.exe -ExecutionPolicy Bypass -Command "$EmailFrom = 'bonninpedro1@gmail.com'; $EmailTo = 'bonninpedro1@gmail.com'; $Subject = 'Informe Backups Pollos'; $Body = 'Adjunto los datos del Backups'; $Body += \"`r`nPeso de la carpeta antes de la copia: %Size% MB\"; $Body += \"`r`nCantidad de archivos antes de la copia: %FilesCount%\"; $Body += \"`r`n\"; $Body += \"`r`nPeso de la carpeta despues de la copia: %SizeAfter% MB\"; $Body += \"`r`nCantidad de archivos despues de la copia: %FilesCountAfter%\"; $Body += \"`r`nAdjunto la captura de pantalla del Backups\"; $SMTPServer = 'smtp.gmail.com'; $SMTPClient = New-Object Net.Mail.SmtpClient($SMTPServer, 587); $SMTPClient.EnableSsl = $true; $SMTPClient.Credentials = New-Object System.Net.NetworkCredential('bonninpedro1@gmail.com', ''); $Email = New-Object System.Net.Mail.MailMessage($EmailFrom, $EmailTo, $Subject, $Body); $AttachmentPath = '%ScreenshotPath%'; $Attachment = New-Object System.Net.Mail.Attachment($AttachmentPath); $Email.Attachments.Add($Attachment); $SMTPClient.Send($Email);"

    REM Eliminar la imagen de captura
    del "%ScreenshotPath%"
) else (
    echo Error al realizar la captura de pantalla
)
