#include "protheus.ch"
#INCLUDE "topconn.ch"
/*/{Protheus.doc} MT340SB7
Ponto de entrada responsável pelo processamento do acerto do inventário.
@type function
@version  1.0
@author Jair Matos
@since 02/08/2024
@return variant, return lret
/*/
User Function MT340SB7()
	Local lRet 		:= .T.
	Local cQuery	:= ""
	Local cAliasZZE	:= getNextAlias()

		cQuery := " SELECT DISTINCT ZZE_CODETI,ZZE_QTDDIG,'S' AS INVENT FROM "+RetSQLName("ZZE")+" "
		cQuery += " WHERE ZZE_CODINV = '"+SB7->B7_DOC+"' "
		cQuery += " AND ZZE_CODPRD = '"+SB7->B7_COD+"' "
		cQuery += " AND ZZE_INVENT   = 'S' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		cQuery += " UNION "
		cQuery += " SELECT DISTINCT ZZE_CODETI,ZZE_QTDDIG,'N' AS INVENT FROM "+RetSQLName("ZZE")+" "
		cQuery += " WHERE ZZE_CODINV = '"+SB7->B7_DOC+"' "
		cQuery += " AND ZZE_CODPRD = '"+SB7->B7_COD+"' "
		cQuery += " AND ZZE_INVENT   = 'N' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		cQuery += " AND NOT EXISTS( SELECT DISTINCT ZZE_CODETI,ZZE_QTDDIG,'S' AS INVENT FROM "+RetSQLName("ZZE")+" "
		cQuery += " WHERE ZZE_CODINV = '"+SB7->B7_DOC+"' "
		cQuery += " AND ZZE_CODPRD = '"+SB7->B7_COD+"' "
		cQuery += " AND ZZE_INVENT   = 'S' "
		cQuery += " AND D_E_L_E_T_ <> '*' )"

		TCQuery cQuery New Alias &cAliasZZE

		While (cAliasZZE)->(!Eof())

			If (cAliasZZE)->INVENT=='S'
				dbSelectArea("ZZC")
				ZZC->(dbSetOrder(1))
				If ZZC->(dbSeek(FWxFilial("ZZC")+(cAliasZZE)->ZZE_CODETI))
					If ZZC->ZZC_QUANT <> (cAliasZZE)->ZZE_QTDDIG
						Reclock("ZZC", .F.)
						ZZC->ZZC_QUANT := (cAliasZZE)->ZZE_QTDDIG
						MsUnLock()
					EndIf
				EndIf
			else
				//Exclui a etiqueta que contem o mesmo lote e não foi utilizada
				dbSelectArea("ZZC")
				ZZC->(DbSetOrder(1)) //ZZC_FILIAL, ZZC_CODETI, R_E_C_N_O_, D_E_L_E_T_
				If ZZC->(dbSeek(FWxFilial("ZZC")+(cAliasZZE)->ZZE_CODETI))
					RecLock("ZZC", .F.)
					ZZC->(DbDelete())
					ZZC->(MsUnlock())
				EndIf
			EndIf
			(cAliasZZE)->(dbSkip())
		EndDO
		(cAliasZZE)->(DBCloseArea())

Return lRet
