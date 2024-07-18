D'accord, merci pour la clarification. Voici comment vous pouvez ajuster le script pour utiliser les deux tableaux dans l'onglet "Liste mail@" :

1. **Assurez-vous que votre fichier Excel contient une feuille nommée "Liste mail@" avec les deux tableaux :**
   - Un tableau nommé `Listemail` contenant les colonnes `ID`, `Nom`, `Mail` (colonnes A, B, et C respectivement).
   - Un tableau nommé `mailRD` contenant les adresses des "Responsables de domaine" dans la colonne `Mail` (colonne E).

2. **Modifiez le script VBA pour utiliser les tableaux corrects :**

```vba
Sub SendEmails()
    Dim OutlookApp As Object
    Dim OutlookMail As Object
    Dim i As Integer
    Dim LastRowListemail As Long
    Dim LastRowMailRD As Long
    Dim MailBody As String
    Dim HtmlFilePath As String
    Dim HtmlFile As Integer
    Dim HtmlContent As String
    Dim LineOfText As String
    Dim DocumentLink As String
    Dim RDList As String
    Dim cell As Range

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

    ' Définir le dernier rang de données dans le tableau Listemail
    With Worksheets("Liste mail@")
        LastRowListemail = .Cells(.Rows.Count, 1).End(xlUp).Row
    End With

    ' Définir le dernier rang de données dans le tableau mailRD
    With Worksheets("Liste mail@")
        LastRowMailRD = .Cells(.Rows.Count, 5).End(xlUp).Row
    End With

    ' Créer la liste des Responsables de domaine
    RDList = ""
    With Worksheets("Liste mail@")
        For Each cell In .Range("E2:E" & LastRowMailRD)
            RDList = RDList & cell.Value & ";"
        Next cell
    End With
    ' Supprimer le dernier point-virgule
    If Len(RDList) > 0 Then RDList = Left(RDList, Len(RDList) - 1)

    ' Créer une instance d'Outlook
    On Error Resume Next
    Set OutlookApp = GetObject(Class:="Outlook.Application")
    If OutlookApp Is Nothing Then
        Set OutlookApp = CreateObject(Class:="Outlook.Application")
    End If
    On Error GoTo 0

    ' Boucler à travers chaque ligne de données dans Listemail
    With Worksheets("Liste mail@")
        For i = 2 To LastRowListemail
            ' Créer un nouvel email
            Set OutlookMail = OutlookApp.CreateItem(0)

            ' Remplacer les espaces réservés dans le contenu HTML
            MailBody = Replace(HtmlContent, "[NOM]", .Cells(i, 2).Value)
            MailBody = Replace(MailBody, "[LINK]", DocumentLink)

            ' Configurer l'email
            With OutlookMail
                .To = RDList ' Liste des Responsables de domaine
                .BCC = .Cells(i, 3).Value ' Colonne contenant les adresses des destinataires en copie cachée
                .Subject = "Referencement Webservice - Collecte Initiale"
                .HTMLBody = MailBody
                .Send
            End With
        Next i
    End With

    ' Libérer les objets
    Set OutlookMail = Nothing
    Set OutlookApp = Nothing
End Sub
```

### Instructions supplémentaires :

1. **Personnalisez le script :**
   - Modifiez `HtmlFilePath` pour indiquer le chemin correct vers votre fichier HTML.
   - Modifiez `DocumentLink` pour inclure le lien réel vers votre document.

2. **Structure des feuilles de calcul :**
   - Feuille "Liste mail@" :
     - Tableau `Listemail` : colonnes `ID` (A), `Nom` (B), `Mail` (C).
     - Tableau `mailRD` : colonne `Mail` (E).

3. **Exécutez le script :**
   - Retournez dans Excel.
   - Appuyez sur `Alt + F8` pour ouvrir la boîte de dialogue des macros.
   - Sélectionnez `SendEmails` et cliquez sur `Exécuter`.

Ce script lira le contenu HTML du fichier `texteairefweb.html`, remplacera les espaces réservés par le nom du destinataire et le lien vers le document, enverra un email à chaque adresse principale (Responsables de domaine) en utilisant le champ "To", et enverra les adresses des autres destinataires en copie cachée (BCC) avec le sujet spécifié. Assurez-vous que les chemins d'accès aux fichiers sont corrects et que les permissions nécessaires sont en place pour accéder à Outlook et envoyer des emails via un script.