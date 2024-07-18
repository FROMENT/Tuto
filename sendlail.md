Sub SendEmails()
    Dim OutlookApp As Object
    Dim OutlookMail As Object
    Dim i As Integer
    Dim LastRow As Long
    Dim MailBody As String
    Dim AttachmentPath As String
    Dim HtmlFilePath As String
    Dim HtmlFile As Integer
    Dim HtmlContent As String
    Dim LineOfText As String

    ' Définir le chemin de la pièce jointe
    AttachmentPath = "C:\chemin\vers\la\piece_jointe.pdf" ' Modifier avec le chemin réel
    
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

    ' Définir le dernier rang de données dans la colonne A
    LastRow = Cells(Rows.Count, 1).End(xlUp).Row

    ' Créer une instance d'Outlook
    On Error Resume Next
    Set OutlookApp = GetObject(Class:="Outlook.Application")
    If OutlookApp Is Nothing Then
        Set OutlookApp = CreateObject(Class:="Outlook.Application")
    End If
    On Error GoTo 0

    ' Boucler à travers chaque ligne de données
    For i = 2 To LastRow
        ' Créer un nouvel email
        Set OutlookMail = OutlookApp.CreateItem(0)

        ' Configurer l'email
        With OutlookMail
            .To = Cells(i, 3).Value
            .Subject = "Referencement Webservice - Collecte Initiale"
            .HTMLBody = HtmlContent
            .Attachments.Add AttachmentPath
            .Send
        End With
    Next i

    ' Libérer les objets
    Set OutlookMail = Nothing
    Set OutlookApp = Nothing
End Sub