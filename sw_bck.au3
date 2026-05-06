#include <GUIConstantsEx.au3>
#include <EditConstants.au3>
#include <WindowsConstants.au3>
#include <GuiListView.au3>
#include <GuiEdit.au3>
#include <File.au3>

Global $g_sDate = @YEAR & @MON & @MDAY

; --- INTERFACE ---
Global $hGUI = GUICreate("Enterasys Backup Tool v3.2", 1000, 600)
GUISetBkColor(0xDCDCDC)

Local $idListView = GUICtrlCreateListView("IP Address|Name", 10, 10, 280, 540)
_GUICtrlListView_SetColumnWidth($idListView, 0, 130)
Local $idBtnAdd = GUICtrlCreateButton("AJOUTER SWITCH", 10, 560, 280, 30)

GUICtrlCreateLabel("Login SSH:", 310, 15)
Global $idInpLogin = GUICtrlCreateInput("mmansouri", 310, 35, 100, 20)

GUICtrlCreateLabel("Password:", 420, 15)
Global $idInpPass = GUICtrlCreateInput("", 420, 35, 130, 20, $ES_PASSWORD)

GUICtrlCreateLabel("IP Serveur TFTP:", 560, 15)
Global $idInpTFTPIP = GUICtrlCreateInput("10.20.24.254", 560, 35, 110, 20)

Local $idBtnTftp = GUICtrlCreateButton("Lancer TFTP64", 690, 30, 110, 30)
Local $idBtnRun = GUICtrlCreateButton("LANCER BACKUP", 810, 30, 170, 30)
GUICtrlSetFont(-1, 9, 800)

Global $idEditLog = GUICtrlCreateEdit("", 310, 80, 680, 510, BitOR($WS_VSCROLL, $ES_READONLY, $ES_MULTILINE, $ES_AUTOVSCROLL))
GUICtrlSetFont(-1, 10, 400, 0, "Consolas")

LoadSwitchList($idListView)
GUISetState(@SW_SHOW)

; --- BOUCLE PRINCIPALE ---
While 1
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE
            Exit
        Case $idBtnAdd
            AddNewDevice($idListView)
        Case $idBtnTftp
            If FileExists("tftpd64.exe") Then 
                Run("tftpd64.exe", @ScriptDir)
            Else
                MsgBox(48, "Erreur", "tftpd64.exe introuvable dans le dossier.")
            EndIf
        Case $idBtnRun
            DoBackup($idListView)
    EndSwitch
WEnd

; --- FONCTIONS ---

Func DoBackup($hLV)
    Local $idItem = GUICtrlRead($hLV)
    If $idItem <= 0 Then Return MsgBox(48, "Info", "Sélectionnez un switch.")

    Local $sData = GUICtrlRead($idItem)
    Local $aHost = StringSplit($sData, "|", 2)
    Local $sUser = GUICtrlRead($idInpLogin)
    Local $sPass = GUICtrlRead($idInpPass)
    Local $sTFTPIP = GUICtrlRead($idInpTFTPIP)
    
    LogMsg(">>> CONNEXION SSH : " & $aHost[1])

    ; Lancement de Plink avec capture des flux
    Local $sCmd = 'plink.exe -batch -ssh -t -l "' & $sUser & '" -pw "' & $sPass & '" ' & $aHost[0]
    Local $iPID = Run($sCmd, @ScriptDir, @SW_HIDE, 0x7)

    If @error Then 
        LogMsg("ERREUR : Impossible de lancer plink.exe. Vérifiez qu'il est dans le dossier.")
        Return
    EndIf

    Sleep(2500) 
    
    LogMsg("--- Commande : Génération config ---")
    StdinWrite($iPID, "show config outfile configs/" & $aHost[1] & "-" & $g_sDate & @CRLF)
    Sleep(5000) 
    
    LogMsg("--- Commande : Transfert TFTP ---")
    StdinWrite($iPID, "copy configs/" & $aHost[1] & "-" & $g_sDate & " tftp://" & $sTFTPIP & "/" & $aHost[1] & "-" & $g_sDate & @CRLF)
    Sleep(5000) 
    
    StdinWrite($iPID, "exit" & @CRLF)

    While ProcessExists($iPID)
        Local $sOutput = StdoutRead($iPID)
        If $sOutput <> "" Then 
            GUICtrlSetData($idEditLog, GUICtrlRead($idEditLog) & $sOutput)
            _GUICtrlEdit_LineScroll($idEditLog, 0, _GUICtrlEdit_GetLineCount($idEditLog))
        EndIf
        
        Local $sError = StderrRead($iPID)
        If $sError <> "" Then LogMsg("DEBUG ERROR: " & $sError)
        Sleep(50)
    WEnd
    
    LogMsg(">>> SESSION TERMINEE.")
EndFunc

Func LoadSwitchList($hLV)
    _GUICtrlListView_DeleteAllItems($hLV)
    If Not FileExists("switch.lst") Then Return
    Local $aList
    _FileReadToArray("switch.lst", $aList)
    If @error Then Return
    For $i = 1 To $aList[0]
        Local $sLine = StringStripWS($aList[$i], 3)
        If $sLine <> "" And StringInStr($sLine, "|") Then GUICtrlCreateListViewItem($sLine, $hLV)
    Next
EndFunc

Func AddNewDevice($hLV)
    Local $sIP = InputBox("Ajout", "IP du switch :")
    If @error Or $sIP = "" Then Return
    Local $sName = InputBox("Ajout", "Nom du switch :")
    If @error Or $sName = "" Then Return
    Local $hFile = FileOpen("switch.lst", 1)
    FileWriteLine($hFile, $sIP & "|" & $sName)
    FileClose($hFile)
    LoadSwitchList($hLV)
EndFunc

Func LogMsg($t)
    GUICtrlSetData($idEditLog, GUICtrlRead($idEditLog) & @CRLF & "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] " & $t & @CRLF)
    _GUICtrlEdit_LineScroll($idEditLog, 0, _GUICtrlEdit_GetLineCount($idEditLog))
EndFunc