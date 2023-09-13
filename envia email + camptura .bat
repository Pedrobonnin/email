@echo off

REM Definir Nombre Backups
set "Backups=Harina"

REM Definir variables globales para los correos electrónicos
set "EmailFrom=bonninpedro1@gmail.com"
set "EmailTo=bonninpedro1@gmail.com"

REM Definir variables globales para las rutas de carpetas y archivos
set "FolderOrigen=G:\a"
set "FolderDestino=G:\b"

REM Ruta donde guardar la captura de pantalla
set "DirCaptura="

REM Ruta del capturador nircmd
set "nircmd=nircmd\nircmd.exe"






REM Ejecutar el código PowerShell y guardar los resultados en variables
for /f "usebackq delims=" %%A in (`powershell -Command "$FolderInfo = Get-ChildItem -Path '%FolderDestino%' -Recurse | Measure-Object -Property Length -Sum; $SizeAfter = [Math]::Round($FolderInfo.Sum / 1GB, 4).ToString(); $FilesCountAfter = $FolderInfo.Count; Write-Output $SizeAfter, $FilesCountAfter"`) do (
    if not defined Size (
        set "Size=%%A"
    ) else (
        set "FilesCount=%%A"
    )
)



REM Obtener la fecha y hora actual
for /f "tokens=2 delims==" %%G in ('wmic os get localdatetime /value') do set "datetime=%%G"

REM Formatear la fecha y hora en el formato dd/mm/aa
set "timestamp=%datetime:~6,2%-%datetime:~4,2%-%datetime:~2,2% hs%time:~0,2%-%time:~3,2%"



REM Realizar la copia con Robocopy y crea registro
set "Reg=%Backups%_registro _ %timestamp%.txt"
ROBOCOPY %FolderOrigen% %FolderDestino% /E /V /TEE /LOG:"%Reg%" 

REM Ejecutar el código PowerShell y guardar los resultados en variables
for /f "usebackq delims=" %%A in (`powershell -Command "$FolderInfo = Get-ChildItem -Path '%FolderDestino%' -Recurse | Measure-Object -Property Length -Sum; $SizeAfter = [Math]::Round($FolderInfo.Sum / 1GB, 4).ToString(); $FilesCountAfter = $FolderInfo.Count; Write-Output $SizeAfter, $FilesCountAfter"`) do (
    if not defined SizeAfter (
        set "SizeAfter=%%A"
    ) else (
        set "FilesCountAfter=%%A"
    )
)


REM Imprimir los resultados antes de la copia
echo Peso de la carpeta antes de la copia: %Size% GB
echo Cantidad de archivos antes de la copia: %FilesCount%

echo.

REM Imprimir los resultados después de la copia
echo Peso de la carpeta despues de la copia: %SizeAfter% GB
echo Cantidad de archivos despues de la copia: %FilesCountAfter%


REM Direccion + nombre de captura
set "ScreenshotPath=%DirCaptura%%Backups% %timestamp%.png"
set "ScreenshotCam=%DirCaptura%Camaras %Backups% %timestamp%.png"

echo.

REM Disco Comprobasion de espacio
REM Verificar si la carpeta es una ruta completa o solo un nombre de carpeta
if "%FolderDestino:~2,1%"=="" (
    REM Si es solo un nombre de carpeta, obtener la ruta del disco actual
    set "FolderDestino=%~dp0%FolderDestino%"
)

set "Disco=%FolderDestino:~0,2%"
for %%A in ("%FolderDestino%") do set "nombre_carpeta=%%~nxA"

echo La carpeta "%nombre_carpeta%" se encuentra en el disco %Disco%

for /f "usebackq delims=" %%A in (`powershell -Command "$disk = Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DeviceID -eq '%Disco%' }; $total = $disk.Size; $free = $disk.FreeSpace; $totalGB = $total / 1GB; $freeGB = $free / 1GB; $totalMB = $total / 1MB; $freeMB = $free / 1MB; $totalKB = $total / 1KB; $freeKB = $free / 1KB; $EspacioTotal = ('{0:N2}' -f $totalGB) + ' GB (' + ('{0:N2}' -f $totalMB) + ' MB, ' + ('{0:N2}' -f $totalKB) + ' KB)'; $EspacioLibre = ('{0:N2}' -f $freeGB) + ' GB (' + ('{0:N2}' -f $freeMB) + ' MB, ' + ('{0:N2}' -f $freeKB) + ' KB)'; Write-Host $EspacioTotal; Write-Host $EspacioLibre; Write-Output $EspacioTotal, $EspacioLibre"`) do (
  if not defined EspacioTotalVariable (
    set "EspacioTotalVariable=%%A"
  ) else (
    set "EspacioLibreVariable=%%A"
  )
)

echo Espacio total en GB: %EspacioTotalVariable%
echo Espacio libre en GB: %EspacioLibreVariable%


REM Filtro para pasar los datos en GB por Email
rem Filtrar el resultado en GB antes del paréntesis para EspacioTotalVariable
for /f "tokens=1 delims=(" %%B in ("%EspacioTotalVariable%") do (
  set "EspacioTotal=%%B"
)

rem Filtrar el resultado en GB antes del paréntesis para EspacioLibreVariable
for /f "tokens=1 delims=(" %%C in ("%EspacioLibreVariable%") do (
  set "EspacioLibre=%%C"
)
REM Fin Disco Comprobasion de espacio

REM Maximizar la ventana del archivo .bat actual
nircmd win max class "ConsoleWindowClass" title "%~f0"


REM Ejecutar el comando de captura de pantalla con nircmd
"%nircmd%" savescreenshot "%ScreenshotPath%"

REM Minimizar la ventana del archivo .bat actual
nircmd win min class "ConsoleWindowClass" title "%~f0"

REM Capturar la pantalla nuevamente después de minimizar CMD
"%nircmd%" savescreenshot "%ScreenshotCam%"



REM Verificar si la captura de pantalla se realizó exitosamente
if exist "%ScreenshotPath%" (
    echo Captura de pantalla guardada exitosamente en %ScreenshotPath%
if exist "%ScreenshotCam%" (
    echo Segunda captura de pantalla guardada exitosamente en %ScreenshotCam%

     REM Enviar correo electrónico con ambas capturas de pantalla, los datos adjuntos y la información de espacio en disco
        PowerShell.exe -ExecutionPolicy Bypass -Command "$EmailFrom = '%EmailFrom%'; $EmailTo = '%EmailTo%'; $Subject = 'Informe Backups %Backups%'; $Body = 'Adjunto los datos del Backups'; $Body += \"`r`nPeso de la carpeta antes de la copia: %Size% GB\"; $Body += \"`r`nCantidad de archivos antes de la copia: %FilesCount%\";$Body += \"`r`n\"; $Body += \"`r`nPeso de la carpeta despues de la copia: %SizeAfter% GB\"; $Body += \"`r`nCantidad de archivos despues de la copia: %FilesCountAfter%\";$Body += \"`r`n\";$Body += \"`r`nCapasidad del Disco: %EspacioTotal%\";$Body += \"`r`nEspacio Libre del Disco: %EspacioLibre%\"; $Body += \"`r`n\"; $Body += \"`r`nAdjunto las capturas de pantalla del Backups\"; $SMTPServer = 'smtp.gmail.com'; $SMTPClient = New-Object Net.Mail.SmtpClient($SMTPServer, 587); $SMTPClient.EnableSsl = $true; $SMTPClient.Credentials = New-Object System.Net.NetworkCredential('%EmailFrom%', ''); $Email = New-Object System.Net.Mail.MailMessage($EmailFrom, $EmailTo, $Subject, $Body); $AttachmentPath1 = '%ScreenshotPath%'; $Attachment1 = New-Object System.Net.Mail.Attachment($AttachmentPath1); $Email.Attachments.Add($Attachment1); $AttachmentPath2 = '%ScreenshotCam%'; $Attachment2 = New-Object System.Net.Mail.Attachment($AttachmentPath2); $Email.Attachments.Add($Attachment2); $AttachmentPath3 = '%Reg%'; $Attachment3 = New-Object System.Net.Mail.Attachment($AttachmentPath3); $Email.Attachments.Add($Attachment3); $SMTPClient.Send($Email);"


    REM Eliminar la imagenS de captura
    del "%ScreenshotPath%"
    del "%ScreenshotCam%"
    del "%Reg%"
) else (
    echo Error al realizar la captura de pantalla
)
)

