
//Bibliotecas
#Include "Totvs.ch"
#INCLUDE "topconn.ch"

//+------------------------------------------------------------------------------------------------------------------+
//| Programa | Consultas | Autor | Jair Matos | Data | 05/06/2024 													 | 
//+------------------------------------------------------------------------------------------------------------------+
//| Descr. | Fun��es customizadas para FLUIG																		 | 
//| 																												 | 
//+------------------------------------------------------------------------------------------------------------------+

/*/{Protheus.doc} TiraGraf
Function que retira caracteres especiais	
@type function
@version 1.0
@author Jair Matos
@since 05/06/2024
@param _sOrig, variant, variavel que ser� validada
@return variant, variavel que foi validada 
/*/
User function TiraGraf (_sOrig)
	local _sRet := _sOrig
	_sRet = strtran (_sRet, "�", "a")
	_sRet = strtran (_sRet, "�", "e")
	_sRet = strtran (_sRet, "�", "i")
	_sRet = strtran (_sRet, "�", "o")
	_sRet = strtran (_sRet, "�", "u")
	_SRET = STRTRAN (_SRET, "�", "A")
	_SRET = STRTRAN (_SRET, "�", "E")
	_SRET = STRTRAN (_SRET, "�", "I")
	_SRET = STRTRAN (_SRET, "�", "O")
	_SRET = STRTRAN (_SRET, "�", "U")
	_sRet = strtran (_sRet, "�", "a")
	_sRet = strtran (_sRet, "�", "o")
	_SRET = STRTRAN (_SRET, "�", "A")
	_SRET = STRTRAN (_SRET, "�", "O")
	_sRet = strtran (_sRet, "�", "a")
	_sRet = strtran (_sRet, "�", "e")
	_sRet = strtran (_sRet, "�", "i")
	_sRet = strtran (_sRet, "�", "o")
	_sRet = strtran (_sRet, "�", "u")
	_SRET = STRTRAN (_SRET, "�", "A")
	_SRET = STRTRAN (_SRET, "�", "E")
	_SRET = STRTRAN (_SRET, "�", "I")
	_SRET = STRTRAN (_SRET, "�", "O")
	_SRET = STRTRAN (_SRET, "�", "U")
	_sRet = strtran (_sRet, "�", "c")
	_sRet = strtran (_sRet, "�", "C")
	_sRet = strtran (_sRet, "�", "a")
	_sRet = strtran (_sRet, "�", "A")
	_sRet = strtran (_sRet, "�", "")
	_sRet = strtran (_sRet, "�", "")
	_sRet = strtran (_sRet, '"', "")
	_sRet = strtran (_sRet, "'", "")
	_sRet = strtran (_sRet, "", "")
	_sRet = strtran (_sRet, "\", "")
	_sRet = strtran (_sRet, "�", "")
	_sRet = strtran (_sRet, "�", "")
	_sRet = strtran (_sRet, "(", "")
	_sRet = strtran (_sRet, ")", "")
	_sRet = strtran (_sRet, "_", "")
	_sRet = strtran (_sRet, "%", "")
	_sRet = strtran (_sRet, "$", "")
	_sRet = strtran (_sRet, "#", "")
	_sRet = strtran (_sRet, "@", "")
	_sRet = strtran (_sRet, "?", "")
	_sRet = strtran (_sRet, "<", "")
	_sRet = strtran (_sRet, ">", "")
	_sRet = strtran (_sRet, ",", "")
	_sRet = strtran (_sRet, ";", "")
	_sRet = strtran (_sRet, "[", "")
	_sRet = strtran (_sRet, "]", "")
	_sRet = strtran (_sRet, "{", "")
	_sRet = strtran (_sRet, "}", "")
	_sRet = strtran (_sRet, ":", "")
	_sRet = strtran (_sRet, "=", "")
	_sRet = strtran (_sRet, "+", "")
	_sRet = strtran (_sRet, "&", "")
	_sRet = strtran (_sRet, "^", "")
	_sRet = strtran (_sRet, "~", "")
	_sRet = strtran (_sRet, "!", "")
	_sRet = strtran (_sRet, "*", "")
	_sRet = strtran (_sRet, ".,", "")
	_sRet = strtran (_sRet, "~~", "")
	_sRet = strtran (_sRet, "  ", "")
	_sRet = strtran (_sRet, "�", "")
	_sRet = strtran (_sRet, "�", "")
	_sRet = strtran (_sRet, chr (9), "") // TAB
	_sRet = strtran (_sRet, chr (10), "") // espaco
	_sRet = strtran (_sRet, chr (13), "") // espaco

return _sRet
/*/{Protheus.doc} fCriaDir
Cria diretorio wsfluigerrors na system
@type function
@version  1.0
@author Jair Matos
@since 04/06/2024
@param cPatch, character, caminho do diretorio
@param cBarra, character, barra separadora
@return variant, retorna true ou false
/*/
User Function fCriaDir(cPatch, cBarra)

	Local lRet   := .T.
	Local aDirs  := {}
	Local nPasta := 1
	Local cPasta := ""
	DEFAULT cBarra	:= "\"

	aDirs := Separa(cPatch, cBarra)
	For nPasta := 1 to Len(aDirs)
		If !Empty (aDirs[nPasta])
			cPasta += cBarra + aDirs[nPasta]
			If !ExistDir (cPasta) .And. MakeDir(cPasta) != 0
				lRet := .F.
				Exit
			EndIf
		EndIf
	Next nPasta

Return lRet
