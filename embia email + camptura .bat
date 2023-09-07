@ECHO OFF


REM Ruta de nircmd.exe
SET NircmdPath=E:\descargas\Compressed\nircmd\nircmd.exe

ROBOCOPY "E:\a" "E:\b"  /E /V /TEE

REM Ruta donde guardar la captura de pantalla
SET ScreenshotPath=C:\Users\bonni\Desktop\captura_pantalla1.png

REM Ejecutar el comando de captura de pantalla con nircmd
"%NircmdPath%" savescreenshot "%ScreenshotPath%"

REM Verificar si la captura de pantalla se realizó exitosamente
IF EXIST "%ScreenshotPath%" (
    ECHO Captura de pantalla guardada exitosamente en %ScreenshotPath%

    REM Enviar correo electrónico con la captura de pantalla adjunta
    PowerShell.exe -ExecutionPolicy Bypass -Command "$EmailFrom = 'bonninpedro1@gmail.com'; $EmailTo = 'ffrancoisoy@gmail.com'; $Subject = 'Captura de pantalla'; $Body = 'Adjunto la captura de pantalla'; $SMTPServer = 'smtp.gmail.com'; $SMTPClient = New-Object Net.Mail.SmtpClient($SMTPServer, 587); $SMTPClient.EnableSsl = $true; $SMTPClient.Credentials = New-Object System.Net.NetworkCredential('bonninpedro1@gmail.com', 'ibfzyqajpnjqhngu'); $Email = New-Object System.Net.Mail.MailMessage($EmailFrom, $EmailTo, $Subject, $Body); $AttachmentPath = '%ScreenshotPath%'; $Attachment = New-Object System.Net.Mail.Attachment($AttachmentPath); $Email.Attachments.Add($Attachment); $SMTPClient.Send($Email);"
) ELSE (
    ECHO Error al realizar la captura de pantalla
)