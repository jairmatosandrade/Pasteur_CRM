#include "protheus.ch"
#include "parmtype.ch"
#INCLUDE "Topconn.ch"
/*
+===================================================================+
| Programa: Ponto De Entrada Locais De Estoque			 			|
| Autor   : Crm Services							  	            |
| Cliente : Pasteur								  	                |
| Data    : 01/10/2023         									    |
+===================================================================+ 
*/

User Function AGRA045()

	Local aParam    := PARAMIXB
	Local xRet      := .T.
	Local cRet      := ""
	Local oObj      := ""
	Local cIdPonto  := ""
	Local cIdModel  := ""
	Local lIsGrid   := .F.
	Private cCodRet := ""

	If aParam <> NIL
		oObj := aParam[1]
		cIdPonto := aParam[2]
		cIdModel := aParam[3]
		lIsGrid := (Len(aParam) > 3)

		If cIdPonto == "MODELPOS" //Chamada na validação total do modelo
			xValue := FWFldGet("NNR_XARMPS")
			If xValue == "S"
				cRet := U_PesqNNR() //Pesquisa codigo do Local de estoque
				If !Empty(cRet)//Valida se codigo já foi utilizado e se o campo NNR_XARMPS='S' .Caso sim , mostra msg para não gravar mais de um armazem com esta condição
					Help(, , "Armazem pesagem", , "Armazem de pesagem já está sendo utilizado para o armazem "+Alltrim(cRet)+"!", 1, 0, , , , , , {"O armazem de pesagem pode existir para somente um local!"})
					xRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
Return xRet
