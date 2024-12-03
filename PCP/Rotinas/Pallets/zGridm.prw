#include "Protheus.ch"
#include "FwMvcDef.CH"
#include "FwBrowse.CH"
#include "TOPCONN.CH"

/* 
Ponto de entrada em MVC para popular os dados da grid preenchido pelo usuario
@type  Function
@author Vinicius Franceschi
@since  21/02/2024
@version version
@see zGrid
@see PSTIPLT
@obs cLoadMontagem é uma variavel private oriunda do fonte GridM
*/

User Function zGridM()
	Local aArea 	:= FWGetArea()
	Local aParam 	:= PARAMIXB
	Local aRet 		:= .T.

	Local cIdPonto	:= ""
	Local cIdModel	:= ""
	Local nLinha	:= 0
	Local cStatus 	:= ""
	Local cDescStatus := ""
	Local nSaldoCaixas := 0

	Local oObj 		:= Nil
	Local oModel
	Local oModelGrid
	Local oView

	Local cAlias :=	""

	Begin Sequence

		If aParam != Nil

			oObj := aParam[1]
			cIdPonto := aParam[2]
			cIdModel := aParam[3]

			If cIdPonto == "BUTTONBAR"
				aRet := {}

				oModel      := FWModelActive()
				oModelGrid  := oModel:GetModel("GRIDID")
				oView       := FWViewActive()

				If oModelGrid:CanClearData()
					oModelGrid:ClearData()
				EndIf

				cQuery := GetQryDados()
				TcQuery cQuery New Alias(cAlias:=GetNextAlias())

				If (cAlias)->(!EOF())
					(cAlias)->(DbGoTop())
					nLinha := 1

					While (cAlias)->(!EOF())

						cStatus := (cAlias)->ZZD_STATUS
						If cStatus == "A"
							cDescStatus := "Aberto"
						Else
							cDescStatus := "Encerrado"
						Endif

						nSaldoCaixas := RetornaSaldoEtq((cAlias)->ZZD_DOC,(cAlias)->ZZD_SERIE,(cAlias)->ZZD_CLIENTE,;
							(cAlias)->ZZD_LOJA,(cAlias)->ZZD_CODPRD,(cAlias)->ZZD_ITEM)

						oModelGrid:AddLine()
						oModelGrid:GoLine(nLinha)
						oModelGrid:SetValue("ZZD_CODM", 	(cAlias)->ZZD_CODM)
						oModelGrid:SetValue("ZZD_PALLET", 	(cAlias)->ZZD_PALLET)
						oModelGrid:SetValue("ZZD_ITEM",   	(cAlias)->ZZD_ITEM)
						oModelGrid:SetValue("ZZD_CODPRD",	(cAlias)->ZZD_CODPRD)
						oModelGrid:SetValue("ZZD_DESC",		Alltrim((cAlias)->ZZD_DESC))
						oModelGrid:SetValue("ZZD_QTDCX",	(cAlias)->ZZD_QTDCX)
						oModelGrid:SetValue("D2_ETQPLT",	nSaldoCaixas)
						oModelGrid:SetValue("ZZD_STATUS",	cDescStatus)
						oModelGrid:SetValue("ZZD_CLIENT",	(cAlias)->ZZD_CLIENT)
						oModelGrid:SetValue("ZZD_LOJA",		(cAlias)->ZZD_LOJA)
						oModelGrid:SetValue("ZZD_DOC",		(cAlias)->ZZD_DOC)
						oModelGrid:SetValue("ZZD_SERIE",	(cAlias)->ZZD_SERIE)

						nLinha++
						(cAlias)->(dbSkip())
					EndDo
					(cAlias)->(dbCloseArea())

				Endif

				oModelGrid:GoLine(1)
				oView:Refresh()
			EndIf
		EndIf

	End Sequence

	FWRestArea(aArea)
Return aRet

/*
Query para fazer filtro dos dados a serem populados na grid
*/
Static Function GetQryDados()
	Local cQuery := ""

	cQuery := " SELECT  " + CRLF
	cQuery +=  " *" + CRLF
	cQuery += " FROM "  + RetSqlName("ZZD") + " ZZD " + CRLF
	cQuery += " WHERE 1=1  " + CRLF
	cQuery += " AND ZZD.ZZD_FILIAL ='" + FWxFilial("ZZD") + "'" + CRLF
	cQuery += " AND ZZD.D_E_L_E_T_ = '' " + CRLF
	cQuery += " AND ZZD_CODM = '"+cLoadMontagem+"' "

Return cQuery

/*
Retorna o saldo da etiqueta que esta no item da SD2
*/
Static Function RetornaSaldoEtq(cDoc,cSerie,cCliente,cLoja,cCodigo,cItem)
	Local nSaldo := 0

	Default cDoc 		:= ""
	Default cSerie 		:= ""
	Default cCliente 	:= ""
	Default cLoja 		:= ""
	Default cCodigo 	:= ""
	Default cItem 		:= ""

	dBselectarea("SD2")
	SD2->(dbSetOrder(3)) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM

	IF SD2->(dbSeek(FWxFilial("SD2") + cDoc + cSerie + cCliente + cLoja + cCodigo + cItem ))
		nSaldo := (SD2->D2_QTSEGUM - SD2->D2_ETQPLT)
	Endif

Return nSaldo
