#INCLUDE "TOTVS.CH"
#include "topconn.ch"

/*/{Protheus.doc} ACDA35GR
Ponto de entrada para Executar customizações complementares.  Ponto de entrada executado no laço que percorre os itens originais da tabela CBC durante execução da função ACDA35GR.
@type function
@version 1.0
@author Jair Matos  
@since 30/07/2024
@return variant, logical, lret
/*/User Function ACDA35GR()
Local lret 	:= .T.
Local cQuery:= ""
Local cAlias:= GetNextAlias()

cQuery := " SELECT  * FROM "+ RetSqlName("CBC") +"  "
cQuery += " WHERE CBC_FILIAL ='" + FWxFilial("CBC") + "'"
cQuery += " AND CBC_NUM  ='" + CBC->CBC_NUM + "'"
cQuery += " AND D_E_L_E_T_ = '*' "

TCQUERY cQuery NEW ALIAS &cAlias

dbSelectArea(cAlias)
(cAlias)->(DBGoTop())

While (cAlias)->(!Eof())

	dbSelectArea("ZZE")
	ZZE->(DbSetOrder(1)) //ZZE_FILIAL, ZZE_CODINV, ZZE_NUM, ZZE_CODPRD

	If ZZE->(dbSeek(FWxFilial("ZZE") + (cAlias)->CBC_CODINV+(cAlias)->CBC_NUM+(cAlias)->CBC_COD))

		RecLock('ZZE',.F.)
		ZZE->(DBDelete())
		ZZE->(MsUnLock())

	EndIf

	(cAlias)->(DBSkip())

EndDo

(cAlias)->(DBCloseArea())


Return lret
