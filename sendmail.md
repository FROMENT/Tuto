Pour inclure les adresses des "Responsables de domaine" dans le champ "To" et envoyer les messages en copie cachée (BCC) aux destinataires de votre liste, vous pouvez adapter le script comme suit :

1. **Assurez-vous que votre fichier Excel contient une colonne supplémentaire pour les adresses des "Responsables de domaine".** Par exemple, supposons que cette colonne est "D" et contient les adresses des "Responsables de domaine".

2. **Modifiez le script VBA pour inclure les adresses des "Responsables de domaine" dans le champ "To" et les adresses des autres destinataires en copie cachée (BCC) :**

```vba
Sub SendEmails()
    Dim OutlookApp As Object
    Dim OutlookMail As Object
    Dim i As Integer
    Dim LastRow As Long
    Dim MailBody As String
    Dim HtmlFilePath As String
    Dim HtmlFile As Integer
    Dim HtmlContent As String
    Dim LineOfText As String
    Dim DocumentLink As String

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

        ' Remplacer les espaces réservés dans le contenu HTML
        MailBody = Replace(HtmlContent, "[NOM]", Cells(i, 2).Value)
        MailBody = Replace(MailBody, "[LINK]", DocumentLink)

        ' Configurer l'email
        With OutlookMail
            .To = Cells(i, 4).Value ' Colonne contenant les adresses des "Responsables de domaine"
            .BCC = Cells(i, 3).Value ' Colonne contenant les adresses des destinataires en copie cachée
            .Subject = "Referencement Webservice - Collecte Initiale"
            .HTMLBody = MailBody
            .Send
        End With
    Next i

    ' Libérer les objets
    Set OutlookMail = Nothing
    Set OutlookApp = Nothing
End Sub
```

3. **Personnalisez le script :**
   - Modifiez `HtmlFilePath` pour indiquer le chemin correct vers votre fichier HTML.
   - Modifiez `DocumentLink` pour inclure le lien réel vers votre document.
   - Assurez-vous que les colonnes et les lignes dans votre fichier Excel sont correctement référencées : colonne "B" pour les noms, colonne "C" pour les adresses BCC, et colonne "D" pour les adresses des "Responsables de domaine".

4. **Exécutez le script :**
   - Retournez dans Excel.
   - Appuyez sur `Alt + F8` pour ouvrir la boîte de dialogue des macros.
   - Sélectionnez `SendEmails` et cliquez sur `Exécuter`.

Ce script lira le contenu HTML du fichier `texteairefweb.html`, remplacera les espaces réservés par le nom du destinataire et le lien vers le document, enverra un email à chaque adresse principale (Responsables de domaine) en utilisant le champ "To", et enverra les adresses des autres destinataires en copie cachée (BCC) avec le sujet spécifié. Assurez-vous que les chemins d'accès aux fichiers sont corrects et que les permissions nécessaires sont en place pour accéder à Outlook et envoyer des emails via un script.