Option Explicit

' Déclaration des fonctions SQLite externes
Private Declare Function sqlite3_open Lib "sqlite3.dll" (ByVal dbName As String, ByRef db As Long) As Long
Private Declare Function sqlite3_close Lib "sqlite3.dll" (ByVal db As Long) As Long
Private Declare Function sqlite3_exec Lib "sqlite3.dll" (ByVal db As Long, ByVal sql As String, ByVal callback As Long, ByVal arg As Long, ByRef errmsg As Long) As Long

' Fonction pour valider l'adresse email
Function IsValidEmail(email As String) As Boolean
    Dim regex As Object
    Set regex = CreateObject("VBScript.RegExp")
    regex.Pattern = "^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$"
    IsValidEmail = regex.Test(email)
End Function

Sub SendEmails()
    Dim OutlookApp As Object
    Dim OutlookMail As Object
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
    Dim BCCGroup As String
    Dim GroupSize As Integer
    
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
        If IsValidEmail(WS.ListObjects("TABLEMailRD").DataBodyRange(i, 1).Value) Then
            If MailRD = "" Then
                MailRD = WS.ListObjects("TABLEMailRD").DataBodyRange(i, 1).Value
            Else
                MailRD = MailRD & ";" & WS.ListObjects("TABLEMailRD").DataBodyRange(i, 1).Value
            End If
        End If
    Next i
    
    ' Grouper les emails BCC par taille de groupe (par exemple, 50 adresses par email)
    GroupSize = 50
    j = 1
    BCCGroup = ""
    
    ' Créer une instance d'Outlook
    On Error Resume Next
    Set OutlookApp = GetObject(Class:="Outlook.Application")
    If OutlookApp Is Nothing Then
        Set OutlookApp = CreateObject(Class:="Outlook.Application")
    End If
    On Error GoTo 0

    ' Boucler à travers chaque ligne de données dans TABLEListemail
    For i = 1 To LastRowListEmail
        ' Lire l'adresse email du destinataire en copie cachée
        MailBCC = WS.ListObjects("TABLEListemail").DataBodyRange(i, 3).Value
        If IsValidEmail(MailBCC) Then
            If BCCGroup = "" Then
                BCCGroup = MailBCC
            Else
                BCCGroup = BCCGroup & ";" & MailBCC
            End If
            j = j + 1
        End If
        
        ' Envoyer l'email lorsque le groupe est complet ou que c'est le dernier email
        If j > GroupSize Or i = LastRowListEmail Then
            ' Créer un nouvel email
            Set OutlookMail = OutlookApp.CreateItem(0)
            
            ' Remplacer les espaces réservés dans le contenu HTML
            MailBody = Replace(HtmlContent, "[NOM]", "")
            MailBody = Replace(MailBody, "[LINK]", DocumentLink)
            
            ' Configurer l'email
            With OutlookMail
                .To = MailRD ' Adresses des responsables de domaine
                .BCC = BCCGroup ' Adresses des destinataires en copie cachée
                .Subject = "Referencement Webservice - Collecte Initiale"
                .HTMLBody = MailBody
                .Send
            End With
            
            ' Réinitialiser le groupe BCC et le compteur
            BCCGroup = ""
            j = 1
        End If
    Next i
    
    ' Libérer les objets
    Set OutlookMail = Nothing
    Set OutlookApp = Nothing
End Sub
