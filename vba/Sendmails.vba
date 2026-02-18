Sub SendEmails()
    ' Initialisation des variables
    Dim OutlookApp As Outlook.Application
    Dim OutlookMail As Outlook.MailItem
    Dim i As Integer
    Dim j As Integer
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
    Dim MailList As Collection
    Dim TempMail As String
    Dim Recipients As String
    Dim BatchSize As Integer
    Dim MailCounter As Integer

    ' Initialiser les variables et chemins
    Call Init_var(HtmlFilePath, DocumentLink, WS, LastRowListEmail, LastRowMailRD, MailRD)

    ' Lire le contenu du fichier HTML
    HtmlFile = FreeFile
    Open HtmlFilePath For Input As HtmlFile
    HtmlContent = ""
    Do While Not EOF(HtmlFile)
        Line Input #HtmlFile, LineOfText
        HtmlContent = HtmlContent & LineOfText & vbCrLf
    Loop
    Close HtmlFile

    ' Créer une instance d'Outlook
    On Error Resume Next
    Set OutlookApp = New Outlook.Application
    On Error GoTo 0

    ' Initialiser la collection pour déduplication
    Set MailList = New Collection

    ' Boucler à travers chaque ligne de données dans TABLEListemail
    For i = 1 To LastRowListEmail
        ' Lire l'adresse email du destinataire en copie cachée
        TempMail = WS.ListObjects("TABLEListemail").DataBodyRange(i, 3).Value
        
        ' Vérifier et ajouter à la liste si l'adresse est valide et non dupliquée
        If IsValidEmail(TempMail) Then
            On Error Resume Next
            MailList.Add TempMail, TempMail ' Utiliser l'adresse comme clé pour déduplication
            On Error GoTo 0
        End If
    Next i

    ' Définir la taille des lots et initialiser le compteur de mails
    BatchSize = 100
    MailCounter = 0
    Recipients = ""

    ' Boucler à travers la liste dédupliquée pour envoyer les emails par groupes de 100
    For j = 1 To MailList.Count
        Recipients = Recipients & MailList(j) & ";"
        MailCounter = MailCounter + 1

        If MailCounter = BatchSize Or j = MailList.Count Then
            ' Créer un nouvel email
            Set OutlookMail = OutlookApp.CreateItem(olMailItem)

            ' Configurer l'email
            With OutlookMail
                .To = MailRD ' Adresses des responsables de domaine
                .BCC = Left(Recipients, Len(Recipients) - 1) ' Supprimer le dernier point-virgule
                .Subject = "[Cyber programme] - Contrôle utilisation API - WebService mise a jour RefWeb. (Action requise)"
                .HTMLBody = Replace(HtmlContent, "[LINK]", DocumentLink)
                .Importance = olImportanceHigh ' Définir l'importance élevée
                .Display ' Utilisez .Display au lieu de .Send pour permettre à l'utilisateur de voir et de modifier les emails avant l'envoi
            End With

            ' Réinitialiser les variables pour le prochain lot
            Recipients = ""
            MailCounter = 0
        End If
    Next j

    ' Libérer les objets
    Set OutlookMail = Nothing
    Set OutlookApp = Nothing
End Sub

Sub Init_var(ByRef HtmlFilePath As String, ByRef DocumentLink As String, ByRef WS As Worksheet, ByRef LastRowListEmail As Long, ByRef LastRowMailRD As Long, ByRef MailRD As String)
    ' Initialiser les chemins et variables
    HtmlFilePath = "C:\chemin\vers\texteairefweb.html" ' Modifier avec le chemin réel
    DocumentLink = "http://www.example.com/document.pdf" ' Modifier avec le lien réel
    Set WS = ThisWorkbook.Sheets("LISTE MAIL")
    LastRowListEmail = WS.ListObjects("TABLEListemail").ListRows.Count
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
End Sub

Function IsValidEmail(email As String) As Boolean
    ' Vérifier la syntaxe de l'adresse email
    Dim regex As Object
    Set regex = CreateObject("VBScript.RegExp")
    regex.Pattern = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"
    IsValidEmail = regex.Test(email)
End Function
