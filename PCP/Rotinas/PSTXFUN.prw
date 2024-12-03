//Bibliotecas
#Include "Totvs.ch"
#INCLUDE "topconn.ch"

/*/{Protheus.doc} PSTPDSC
Funções customizadas Pasteur
@type function
@version 1.0
@author Jair Matos
@since 05/06/2024
/*/
User Function PSTPDSC()
	Local cDesc := ""

	cDesc := IIF(INCLUI,POSICIONE("SB1",1,XFILIAL("SB1")+ALLTRIM(M->D2_COD),"B1_DESC"),POSICIONE("SB1",1,XFILIAL("SB1")+ALLTRIM(SD2->D2_COD),"B1_DESC"))

Return cDesc


User Function PSTCDSC()
	Local cDesc := ""

	cDesc := IIF(INCLUI,POSICIONE("SA1",1,XFILIAL("SA1")+ALLTRIM(M->D2_CLIENTE+M->D2_LOJA),"A1_NOME")  ,POSICIONE("SA1",1,XFILIAL("SA1")+ALLTRIM(SD2->D2_CLIENTE+SD2->D2_LOJA),"A1_NOME")  )

Return cDesc


User Function PSTFDSC()

	Local cDesc := ""

	cDesc := Posicione("SF2", 1, xFilial("SD2")+ALLTRIM(SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA), "F2_TRANSP") 

Return cDesc
/*/{Protheus.doc} PesqNNR
Rotina para validar se campo NNR_XARMPS já está sendo utilizado. Caso sim retorna O local
@type function
@version  1.0
@author Jair Matos
@since 24/04/2024
@param cCodigo, character, CODIGO
@return logical, retorna verdadeiro ou false
/*/
User function PesqNNR()
	Local cAlias := GetNextAlias()
	Local cQuery := ""
	Local cCodRet  := ""

	cQuery := " SELECT NNR_CODIGO  as NNR_CODIGO FROM "+RetSQLName("NNR")
	cQuery += " WHERE D_E_L_E_T_ = ' ' AND NNR_XARMPS = 'S' "
	cQuery += " AND NNR_FILIAL ='" + FWxFilial("NNR") + "'"

	TCQUERY cQuery NEW ALIAS &cAlias

	If (cAlias)->(!EOF())
		cCodRet := (cAlias)->NNR_CODIGO
	EndIf

	(cAlias)-> (dbCloseArea())

Return cCodRet

