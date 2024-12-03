#include "protheus.ch"
#include "parmtype.ch"
#INCLUDE "Topconn.ch"
/*/{Protheus.doc} PCPA124
Ordena��o das opera��es no roteiro
@type function
@version  1.0   
@author Jair Matos  
@since 17/06/2024
@return variant, true ou false
/*/
User Function PCPA124()

	Local aParam    := PARAMIXB
	Local xRet      := .T.
	Local nX        := 0
	Local xValue 	:= Nil
	Local oObj      := ""
	Local oModelx   := Nil
	Local oModelGrid:= Nil
	Local cIdPonto  := ""
	Local cIdModel  := ""
	Local lIsGrid   := .F.
	Private cCodRet := ""

	If aParam <> NIL //.and. FunName() == "PCPA124"
		oObj := aParam[1]
		cIdPonto := aParam[2]
		cIdModel := aParam[3]
		lIsGrid := (Len(aParam) > 3)

		If cIdPonto == "MODELPOS" //Chamada na valida��o total do modelo
			oModelx:= FWModelActive() //ModeloMestre e depois realizar o processo no ModeloDetalhe
			oModelGrid:= oModelx:GetModel("PCPA124_SG2")

			for nX:= 1 to oModelGrid:Length()
				oModelGrid:GoLine(nX)
				If   xValue <> Nil .and.  xValue==oModelGrid:GetValue("G2_OPERAC")	//Valida na tabela SG2 se o campo G2_OPERAC tem em mais de 1 linha. Se sim, lan�a a mensagem
					Help(, , "PE MVC MODELPOS", , "N�o poder� existir mais de 1 opera��o com o campo 'Tipo Opera��o' igual a 'Manipula��o' dentro do mesmo roteiro !", 1, 0, , , , , , {"N�o � poss�vel salvar o registro, h� duas opera��es de Manipula��o: Ajustar o cadastro e retornar para a tela de inclus�o e/ou altera��o !"})
					xRet := .F.
				else
					xValue := oModelGrid:GetValue("G2_OPERAC")
				EndIf
			next

		EndIf
	EndIf

Return xRet
