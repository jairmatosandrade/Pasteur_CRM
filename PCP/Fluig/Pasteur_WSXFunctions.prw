
//Bibliotecas
#Include "Totvs.ch"
#INCLUDE "topconn.ch"

//+------------------------------------------------------------------------------------------------------------------+
//| Programa | Consultas | Autor | Jair Matos | Data | 05/06/2024 													 | 
//+------------------------------------------------------------------------------------------------------------------+
//| Descr. | Funções customizadas para FLUIG																		 | 
//| 																												 | 
//+------------------------------------------------------------------------------------------------------------------+

/*/{Protheus.doc} TiraGraf
Function que retira caracteres especiais	
@type function
@version 1.0
@author Jair Matos
@since 05/06/2024
@param _sOrig, variant, variavel que será validada
@return variant, variavel que foi validada 
/*/
User function TiraGraf (_sOrig)
	local _sRet := _sOrig
	_sRet = strtran (_sRet, "á", "a")
	_sRet = strtran (_sRet, "é", "e")
	_sRet = strtran (_sRet, "í", "i")
	_sRet = strtran (_sRet, "ó", "o")
	_sRet = strtran (_sRet, "ú", "u")
	_SRET = STRTRAN (_SRET, "Á", "A")
	_SRET = STRTRAN (_SRET, "É", "E")
	_SRET = STRTRAN (_SRET, "Í", "I")
	_SRET = STRTRAN (_SRET, "Ó", "O")
	_SRET = STRTRAN (_SRET, "Ú", "U")
	_sRet = strtran (_sRet, "ã", "a")
	_sRet = strtran (_sRet, "õ", "o")
	_SRET = STRTRAN (_SRET, "Ã", "A")
	_SRET = STRTRAN (_SRET, "Õ", "O")
	_sRet = strtran (_sRet, "â", "a")
	_sRet = strtran (_sRet, "ê", "e")
	_sRet = strtran (_sRet, "î", "i")
	_sRet = strtran (_sRet, "ô", "o")
	_sRet = strtran (_sRet, "û", "u")
	_SRET = STRTRAN (_SRET, "Â", "A")
	_SRET = STRTRAN (_SRET, "Ê", "E")
	_SRET = STRTRAN (_SRET, "Î", "I")
	_SRET = STRTRAN (_SRET, "Ô", "O")
	_SRET = STRTRAN (_SRET, "Û", "U")
	_sRet = strtran (_sRet, "ç", "c")
	_sRet = strtran (_sRet, "Ç", "C")
	_sRet = strtran (_sRet, "à", "a")
	_sRet = strtran (_sRet, "À", "A")
	_sRet = strtran (_sRet, "º", "")
	_sRet = strtran (_sRet, "ª", "")
	_sRet = strtran (_sRet, '"', "")
	_sRet = strtran (_sRet, "'", "")
	_sRet = strtran (_sRet, "", "")
	_sRet = strtran (_sRet, "\", "")
	_sRet = strtran (_sRet, "’", "")
	_sRet = strtran (_sRet, "”", "")
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
	_sRet = strtran (_sRet, "“", "")
	_sRet = strtran (_sRet, "”", "")
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
