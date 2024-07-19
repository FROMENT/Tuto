Sub SendEmails()
    Dim OutlookApp As Object
    Dim OutlookMail As Object
    Dim WordApp As Object
    Dim WordDoc As Object
    Dim i As Integer
    Dim LastRowListEmail As Long
    Dim LastRowMailRD As Long
    Dim MailBody As String
    Dim WordFilePath As String
    Dim DocumentLink As String
    Dim WS As Worksheet
    Dim MailRD As String
    Dim MailBCC As String

    ' Définir la feuille "LISTE MAIL"
    Set WS = ThisWorkbook.Sheets("LISTE MAIL")

    ' Définir le chemin du fichier Word
    WordFilePath = "C:\chemin\vers\texteairefweb.docx" ' Modifier avec le chemin réel

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
    Set OutlookApp = GetObject(Class:="Outlook.Application")
    If OutlookApp Is Nothing Then
        Set OutlookApp = CreateObject(Class:="Outlook.Application")
    End If
    On Error GoTo 0

    ' Créer une instance de Word
    On Error Resume Next
    Set WordApp = GetObject(Class:="Word.Application")
    If WordApp Is Nothing Then
        Set WordApp = CreateObject(Class:="Word.Application")
    End If
    On Error GoTo 0

    ' Ouvrir le document Word
    Set WordDoc = WordApp.Documents.Open(WordFilePath)
    WordDoc.Content.Copy ' Copier le contenu du document

    ' Boucler à travers chaque ligne de données dans TABLEListemail
    For i = 1 To LastRowListEmail
        ' Créer un nouvel email
        Set OutlookMail = OutlookApp.CreateItem(0)

        ' Créer le corps de l'email à partir du contenu du document Word
        WordDoc.Content.Copy
        MailBody = WordApp.Selection.PasteAndFormat(0)
        
        ' Remplacer les espaces réservés dans le contenu Word
        MailBody = Replace(MailBody, "[NOM]", WS.ListObjects("TABLEListemail").DataBodyRange(i, 2).Value)
        MailBody = Replace(MailBody, "[LINK]", DocumentLink)
        
        ' Lire l'adresse email du destinataire en copie cachée
        MailBCC = WS.ListObjects("TABLEListemail").DataBodyRange(i, 3).Value

        ' Configurer l'email
        With OutlookMail
            .To = MailRD ' Adresses des responsables de domaine
            .BCC = MailBCC ' Adresses des destinataires en copie cachée
            .Subject = "Referencement Webservice - Collecte Initiale"
            .HTMLBody = MailBody
            .Send
        End With
    Next i

    ' Fermer le document Word sans enregistrer
    WordDoc.Close False
    WordApp.Quit

    ' Libérer les objets
    Set WordDoc = Nothing
    Set WordApp = Nothing
    Set OutlookMail = Nothing
    Set OutlookApp = Nothing
End Sub