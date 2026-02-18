Sub SendEmailsInBatches()
    Dim OutlookApp As Outlook.Application
    Dim OutlookMail As Outlook.MailItem
    Dim i As Integer
    Dim LastRowListEmail As Long
    Dim LastRowMailRD As Long
    Dim MailBody As String
    Dim HtmlFilePath As String
    Dim HtmlFile As Integer
    Dim HtmlContent As String
    Dim LineOfText As String
    Dim DocumentLink As String
    Dim WS As Worksheet
    Dim MailRD As String
    Dim MailBCC As String
    Dim BCCAddresses As Collection
    Dim BatchCount As Integer

    ' Définir la feuille "LISTE MAIL"
    Set WS = ThisWorkbook.Sheets("LISTE MAIL")

    ' Définir le chemin du fichier HTML
    HtmlFilePath = "C:\chemin\vers\texteairefweb.html" ' Modifier avec le chemin réel

    ' Lire le contenu du fichier HTML
    HtmlFile = FreeFile
    Open HtmlFilePath For Input As HtmlFile
    HtmlContent = ""
    Do While Not EOF(HtmlFile)
        Line Input #HtmlFile, LineOfText
        HtmlContent = HtmlContent & LineOfText & vbCrLf
    Loop
    Close HtmlFile

    ' Définir le lien vers le document
    DocumentLink = "http://www.example.com/document.pdf" ' Modifier avec le lien réel

    ' Définir le dernier rang de données dans le tableau TABLEListemail
    LastRowListEmail = WS.ListObjects("TABLEListemail").ListRows.Count

    ' Définir le dernier rang de données dans le tableau TABLEMailRD
    LastRowMailRD = WS.ListObjects("TABLEMailRD").ListRows.Count

    ' Construire la liste des responsables de domaine
    MailRD = ""
    For i = 1 To LastRowMailRD
        If MailRD = "" Then
            MailRD = WS.ListObjects("TABLEMailRD").DataBodyRange(i, 1).Value
        Else
            MailRD = MailRD & ";" & WS.ListObjects("TABLEMailRD").DataBodyRange(i, 1).Value
        End If
    Next i

    ' Créer une instance d'Outlook
    On Error Resume Next
    Set OutlookApp = New Outlook.Application
    On Error GoTo 0

    ' Initialiser la collection pour les adresses BCC
    Set BCCAddresses = New Collection

    ' Boucler à travers chaque ligne de données dans TABLEListemail
    For i = 1 To LastRowListEmail
        Dim EmailAddress As String
        EmailAddress = WS.ListObjects("TABLEListemail").DataBodyRange(i, 3).Value

        ' Vérifier la syntaxe de l'adresse email
        If IsValidEmail(EmailAddress) Then
            On Error Resume Next
            ' Ajouter l'adresse email à la collection si elle n'est pas déjà présente
            BCCAddresses.Add EmailAddress, EmailAddress
            On Error GoTo 0
        End If

        ' Envoyer les emails par groupe de 100
        If BCCAddresses.Count >= 100 Then
            SendBatchEmail OutlookApp, MailRD, BCCAddresses, HtmlContent, DocumentLink, WS.ListObjects("TABLEListemail").DataBodyRange(i, 2).Value
            Set BCCAddresses = New Collection
        End If
    Next i

    ' Envoyer les emails restants
    If BCCAddresses.Count > 0 Then
        SendBatchEmail OutlookApp, MailRD, BCCAddresses, HtmlContent, DocumentLink, WS.ListObjects("TABLEListemail").DataBodyRange(i, 2).Value
    End If

    ' Libérer les objets
    Set OutlookMail = Nothing
    Set OutlookApp = Nothing
End Sub

Function IsValidEmail(strEmail As String) As Boolean
    Dim RegEx As Object
    Set RegEx = CreateObject("VBScript.RegExp")
    RegEx.Pattern = "^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$"
    IsValidEmail = RegEx.Test(strEmail)
End Function

Sub SendBatchEmail(OutlookApp As Outlook.Application, MailRD As String, BCCAddresses As Collection, HtmlContent As String, DocumentLink As String, Nom As String)
    Dim OutlookMail As Outlook.MailItem
    Dim MailBody As String
    Dim BCCList As String
    Dim i As Integer

    ' Construire la liste BCC
    BCCList = ""
    For i = 1 To BCCAddresses.Count
        If BCCList = "" Then
            BCCList = BCCAddresses(i)
        Else
            BCCList = BCCList & ";" & BCCAddresses(i)
        End If
    Next i

    ' Créer un nouvel email
    Set OutlookMail = OutlookApp.CreateItem(olMailItem)

    ' Remplacer les espaces réservés dans le contenu HTML
    MailBody = Replace(HtmlContent, "[NOM]", Nom)
    MailBody = Replace(MailBody, "[LINK]", DocumentLink)

    ' Configurer l'email
    With OutlookMail
        .To = MailRD ' Adresses des responsables de domaine
        .BCC = BCCList ' Adresses des destinataires en copie cachée
        .Subject = "Referencement Webservice - Collecte Initiale"
        .HTMLBody = MailBody
        .Display ' Utilisez .Display au lieu de .Send pour permettre à l'utilisateur de voir et de modifier les emails avant l'envoi
    End With

    ' Libérer les objets
    Set OutlookMail = Nothing
End Sub
