#include "Protheus.ch"
#include "topconn.ch"
/*/{Protheus.doc} CBINV05
Ponto de entrada após gravação da tabela SB7. É executado após a inclusão do registro de inventário ('SB7') a partir da rotina automática.
@type function
@version 1.0
@author Jair Matos  
@since 25/07/2024
@return variant, logical, lret
/*/User Function CBINV05()
Local lret 	:= .T.
Local cQuery:= ""
Local cAlias:= GetNextAlias()

//grava a quantidade total na tabela ZZE
cQuery := " SELECT  B7_COD, B7_DOC,ZZE_CODINV, ZZE_NUM,ZZE_CODPRD, ZZE.ZZE_CODETI,ZZE_QTDDIG, CBC_QUANT, CBC_QTDORI, CBC_LOCALI, 'S' AS ALTERA "
cQuery += " FROM "+ RetSqlName("SB7") +" SB7 "
cQuery += " JOIN "+ RetSqlName("CBC") +" CBC ON CBC.D_E_L_E_T_ <>  '*' AND CBC_FILIAL = B7_FILIAL AND CBC_CODINV = B7_DOC AND CBC_COD = B7_COD AND CBC_QUANT=B7_QUANT
cQuery += " JOIN "+ RetSqlName("ZZE") +" ZZE ON ZZE.D_E_L_E_T_ <>  '*'
cQuery += " AND ZZE_CODINV = CBC_CODINV AND ZZE_NUM = CBC_NUM AND ZZE_CODPRD= CBC_COD "
cQuery += " AND ZZE_LOCAL = CBC_LOCAL AND ZZE_LOTECT = CBC_LOTECT "
cQuery += " WHERE SB7.B7_FILIAL ='" + FWxFilial("SB7") + "'"
cQuery += " AND SB7.B7_DOC  ='" + SB7->B7_DOC + "'"
cQuery += " AND SB7.B7_COD  ='" + SB7->B7_COD + "'"
cQuery += " AND SB7.D_E_L_E_T_ = '' "
cQuery += " UNION "
cQuery += " SELECT  B7_COD, B7_DOC,ZZE_CODINV, ZZE_NUM,ZZE_CODPRD, ZZE.ZZE_CODETI,ZZE_QTDDIG, CBC_QUANT, CBC_QTDORI, CBC_LOCALI, 'N' AS ALTERA "
cQuery += " FROM "+ RetSqlName("SB7") +" SB7 "
cQuery += " JOIN "+ RetSqlName("CBC") +" CBC ON CBC.D_E_L_E_T_ <>  '*' AND CBC_FILIAL = B7_FILIAL AND CBC_CODINV = B7_DOC AND CBC_COD = B7_COD AND CBC_QUANT!=B7_QUANT
cQuery += " JOIN "+ RetSqlName("ZZE") +" ZZE ON ZZE.D_E_L_E_T_ <>  '*'
cQuery += " AND ZZE_CODINV = CBC_CODINV AND ZZE_NUM = CBC_NUM AND ZZE_CODPRD= CBC_COD "
cQuery += " AND ZZE_LOCAL = CBC_LOCAL AND ZZE_LOTECT = CBC_LOTECT "
cQuery += " AND ZZE_CODETI NOT IN ( SELECT  ZZE.ZZE_CODETI FROM "+ RetSqlName("SB7") +" SB7 "
cQuery += " JOIN "+ RetSqlName("CBC") +" CBC ON CBC.D_E_L_E_T_ <>  '*' AND CBC_FILIAL = B7_FILIAL AND CBC_CODINV = B7_DOC AND CBC_COD = B7_COD AND CBC_QUANT=B7_QUANT
cQuery += " JOIN "+ RetSqlName("ZZE") +" ZZE ON ZZE.D_E_L_E_T_ <>  '*'
cQuery += " AND ZZE_CODINV = CBC_CODINV AND ZZE_NUM = CBC_NUM AND ZZE_CODPRD= CBC_COD "
cQuery += " AND ZZE_LOCAL = CBC_LOCAL AND ZZE_LOTECT = CBC_LOTECT "
cQuery += " WHERE SB7.B7_FILIAL ='" + FWxFilial("SB7") + "'"
cQuery += " AND SB7.B7_DOC  ='" + SB7->B7_DOC + "'"
cQuery += " AND SB7.B7_COD  ='" + SB7->B7_COD + "'"
cQuery += " AND SB7.D_E_L_E_T_ = '' ) "
cQuery += " WHERE SB7.B7_FILIAL ='" + FWxFilial("SB7") + "'"
cQuery += " AND SB7.B7_DOC  ='" + SB7->B7_DOC + "'"
cQuery += " AND SB7.B7_COD  ='" + SB7->B7_COD + "'"
cQuery += " AND SB7.D_E_L_E_T_ = '' "


TCQUERY cQuery NEW ALIAS &cAlias

dbSelectArea(cAlias)
(cAlias)->(DBGoTop())
While (cAlias)->(!Eof())

	If (cAlias)->ALTERA=='S'
		//VALIDA ZZE
		dbSelectArea("ZZE")
		ZZE->(DbSetOrder(2)) //ZZE_FILIAL, ZZE_CODINV, ZZE_NUM, ZZE_CODETI
		If ZZE->(dbSeek(FWxFilial("ZZE")+(cAlias)->ZZE_CODINV+(cAlias)->ZZE_NUM+(cAlias)->ZZE_CODETI))

			Reclock("ZZE",.F.)
			ZZE->ZZE_QTDGRV := (cAlias)->CBC_QUANT
			ZZE->ZZE_LOCALI := (cAlias)->CBC_LOCALI
			ZZE->ZZE_INVENT := "S"
			ZZE->(MSUnlock())
		EndIf
	EndIf

	(cAlias)->(DBSkip())
EndDo
(cAlias)->(DBCloseArea())

Return lRet
/*/{Protheus.doc} V035ALTQTD
Ponto de entrada para pegar a quantidade digitada na etiqueta/produto.
O ponto de entrada V035ALTQTD, permite ao usuário manipular a quantidade informada. O ponto de entrada irá receber a quantidade digitada e irá devolver a quantidade convertida.
@type function
@version 1.0
@author Jair matos
@since 25/07/2024
@return variant, logical, lret
/*/
User Function V035ALTQTD()
	Local lRet := .T.

	dbSelectArea("ZZE")
	ZZE->(DbSetOrder(2)) //ZZE_FILIAL, ZZE_CODINV, ZZE_NUM, ZZE_CODETI
	If ZZE->(dbSeek(FWxFilial("ZZE")+ZZE->ZZE_CODINV+ZZE->ZZE_NUM+ZZE->ZZE_CODETI))

		Reclock("ZZE",.F.)
		ZZE->ZZE_QTDDIG += nQtdEtiq
		ZZE->(MSUnlock())

	EndIf

return lRet
