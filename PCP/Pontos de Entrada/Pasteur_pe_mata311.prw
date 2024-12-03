#include "protheus.ch"
#include "parmtype.ch"
#INCLUDE "Topconn.ch"
/*/{Protheus.doc} MATA311
Ponto de entrada Transferencia entre Filiais
@type function
@version  1.0   
@author Jair Matos  
@since 09/05/2024
@return variant, true ou false
/*/
User Function MATA311()

	Local aParam    := PARAMIXB
	Local xRet      := .T.
	Local xValue 	:= Nil
	Local oObj      := ""
	Local cIdPonto  := ""
	Local cIdModel  := ""
	Local lIsGrid   := .F.
	Private cCodRet := ""

	If aParam <> NIL .and. FunName() == "MATA311"
		oObj := aParam[1]
		cIdPonto := aParam[2]
		cIdModel := aParam[3]
		lIsGrid := (Len(aParam) > 3)

		If cIdPonto == "MODELPOS" //Chamada na validação total do modelo
			If!INCLUI
				xValue := FWFldGet("NNS_XORDPS")
				If !Empty(xValue)
					Help(, , "PE MVC MODELPOS", , "A transferencia está sendo utilizada na Ordem de Pesagem "+xValue+" e não poderá ser alterada / excluida!", 1, 0, , , , , , {"A exclusão deve ser feita através da rotina de Ordem de Pesagem!"})
					xRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf

Return xRet
