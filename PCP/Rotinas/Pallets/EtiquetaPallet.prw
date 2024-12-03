#include "Protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"

/*/{Protheus.doc} EtiquetaPallet
Impressao das etiquetas pallets
@type function
@author Vinicius Franceschi
@since 19/03/2024
@version P12
@database MSSQL,Oracle
/*/

User Function EtiquetaPallet(cCodMontagem,lReimp)
	Private cPerg := "IMPETQ"

	Default cCodMontagem := ""
	Default lReimp  := .F.

	If !lReimp
		If Pergunte(cPerg,.T.)
			DbSelectArea("ZZD")
			ZZD->(dBsetOrder(1)) //ZZD_FILIAL + ZZD_CODM
			IF ZZD->(dbSeek(FWxFilial("ZZD")+MV_PAR01))
				ProcessaImpressao(MV_PAR01)
			Else
				FWAlertWarning("Codigo de Montagem "+MV_PAR01+" não existe ou nao foi preenchido!", "Impressão Pallets")
			EndIf
		EndIf
	Else
		ProcessaImpressao(cCodMontagem)
	Endif

Return

/*/{Protheus.doc} ProcessaImpressao
Funcao responsavel pelo processamento da impressao da etiqueta
@type function
@author Vinicius Franceschi
@since 19/03/2024
@version P12
@database MSSQL,Oracle
/*/

Static Function ProcessaImpressao(cCodMontagem)
	Local cAlias := getNextAlias()
	Local cQuery := ""
	Local cCodZPL := ""
	Local cMunicipio := ""
	Local cNomeCli := ""
	Local cNotaFscal := ""
	Local cSerie := ""
	Local cNomeTransp := ""
	Local cConteudo := 0
	Local nQtdPallets := 0
	Local nQtdPorEtiqueta :=0
	Local nLinha := 0
	Local cAllPedidos := ""
	Local cProduto := ""
	Local cFila := ""
	Local cTpImp 	:= "000001"   //Impressora
	Local cModelo,lTipo,nPortIP,cServer,cEnv,lDrvWin,cPorta

	Private cPergunta	:= "IMPCB5"

	Default cCodMontagem := ""

	Begin Sequence

		If !( Pergunte(cPergunta,.T.) )
			Break
		EndIf

		cQuery := " SELECT  CB5_CODIGO FROM "  + RetSqlName("CB5") + " "
		cQuery += " WHERE CB5_FILIAL ='" + FWxFilial("CB5") + "'" + CRLF
		cQuery += " AND CB5_MODELO  ='" + MV_PAR01 + "'" + CRLF
		cQuery += " AND D_E_L_E_T_ = '' " + CRLF

		TCQUERY cQuery NEW ALIAS &cAlias
		If (cAlias)->(!Eof())
			cTpImp :=  (cAlias)->CB5_CODIGO
			(cAlias)->(DBSkip())
		Endif

		(cAlias)->(DBCloseArea())

		cConteudo	:= getQtdConteudo(cCodMontagem)
		cQuery 		:= getQryDados(cCodMontagem)
		nQtdPallets	:= getQtdPallets(cCodMontagem)
		cAllPedidos := getAllSalesOrders(cCodMontagem)
		aMyPallets	:= GetMyPallets(cCodMontagem)

		nQtdPorEtiqueta := cConteudo/nQtdPallets//realizar soma pelo numero da etiqueta na tabela ZZD->ZZD_PALLET
		nQtdPorEtiqueta := Round(nQtdPorEtiqueta,2)

		TCQUERY cQuery new alias &cAlias
		dbSelectArea(cAlias)
		(cAlias)->(DBGoTop())

		cNotaFscal	:= (cAlias)->F2_DOC
		While (cAlias)->(!Eof())
			cNomeCli	:= Alltrim((cAlias)->A1_NOME)
			cMunicipio	:= Alltrim((cAlias)->A1_MUN)

			IF !(cAlias)->F2_DOC $ cNotaFscal
				cNotaFscal	+= ","+(cAlias)->F2_DOC
			EndIf
			cSerie		:= (cAlias)->F2_SERIE
			cNomeTransp := Alltrim((cAlias)->A4_NREDUZ)
			cProduto	:= (cAlias)->ZZD_CODPRD

			(cAlias)->(DBSkip())

		EndDo

		//jair
		If ! CB5->(DbSeek(xFilial("CB5")+cTpImp))
			FWAlertWarning("Tipo de Impressão "+cTpImp+" não existe ou nao foi preenchido!", "Tipo Impressão")
			Return
		EndIf

		cModelo :=Trim(CB5->CB5_MODELO)
		If cPorta ==NIL
			If CB5->CB5_TIPO == '4'
				cPorta:= "IP"
			Else
				IF CB5->CB5_PORTA $ "12345"
					cPorta  :='COM'+CB5->CB5_PORTA+':'+CB5->CB5_SETSER
				EndIf
				IF CB5->CB5_LPT $ "12345"
					cPorta  :='LPT'+CB5->CB5_LPT+':'
				EndIf
			EndIf
		EndIf

		lTipo   :=CB5->CB5_TIPO $ '12'
		nPortIP :=Val(CB5->CB5_PORTIP)
		cServer :=Trim(CB5->CB5_SERVER)
		cEnv    :=Trim(CB5->CB5_ENV)
		cFila   := NIL
		If CB5->CB5_TIPO=="3"
			cFila := Alltrim(Tabela("J3",CB5->CB5_FILA,.F.))
		EndIf
		nBuffer := CB5->CB5_BUFFER
		lDrvWin := (CB5->CB5_DRVWIN =="1")

		//msCbPrinter(Alltrim(MV_PAR01), cPorta,,, .F.,,,,,cFila,.F.,)
		MSCBPRINTER(cModelo,cPorta,,,lTipo,nPortIP,cServer,cEnv,nBuffer,cFila,lDrvWin,Trim(CB5->CB5_PATH))
		MSCBCHKSTATUS(CB5->CB5_VERSTA =="1")
		msCbInfoEti("", "")

		For nLinha := 1 To nQtdPallets
			MSCBBEGIN(1,6)
			cCodZPL := "^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^JMA^PR4,4~SD15^JUS^LRN^CI0^XZ"+CRLF
			cCodZPL += "^XA"+CRLF
			cCodZPL += "^MMT"+CRLF
			cCodZPL += "^PW1199"+CRLF
			cCodZPL += "^LL0799"+CRLF
			cCodZPL += "^LS0"+CRLF
			cCodZPL += "^FT23,160^ACN,36,20^FH\^FDCLIENTE:"+ FWNoAccent(cNomeCli) + " ^FS"+CRLF
			cCodZPL += "^FT23,227^ACN,36,20^FH\^FDREGI\C7O/CD: ^FS"+CRLF
			cCodZPL += "^FT278,227^A0N,36,40^FH\^FD" + FWNoAccent(cMunicipio) + "^FS"+CRLF
			cCodZPL += "^FT23,296^ACN,36,20^FH\^FDNOTAS FISCAIS: ^FS"+CRLF
			cCodZPL += "^FT362,296^A0N,36,36^FH\^FD" + cNotaFscal + "^FS"+CRLF
			cCodZPL += "^FT27,355^ACN,36,20^FH\^FDPEDIDOS:^FS"+CRLF
			cCodZPL += "^FT219,355^A0N,36,36^FH\^FD" + cAllPedidos + "^FS"+CRLF
			cCodZPL += "^FT23,422^ACN,36,20^FH\^FDTRANSPORTADORA:^FS"+CRLF
			cCodZPL += "^FT413,422^A0N,36,36^FH\^FD" + FWNoAccent(cNomeTransp) + "^FS"+CRLF
			cCodZPL += "^BY2,3,170^FT450,628^BCN,,Y,N"+CRLF
			cCodZPL += "^FD>:" + aMyPallets[nLinha][1][1] + "^FS"+CRLF
			cCodZPL += "^FT170,687^ACN,36,20^FH\^FDCONTE\E9DO:^FS"+CRLF
			cCodZPL += "^FT766,680^ACN,36,20^FH\^FDTOTAL PALLETS:^FS"+CRLF
			cCodZPL += "^FT103,757^A0N,54,52^FH\^FD" + cValToChar(aMyPallets[nLinha][1][2]) + " / " + cValToChar(cConteudo) + " CAIXAS^FS"+CRLF
			cCodZPL += "^FT899,757^A0N,54,52^FH\^FD" + cValToChar(nLinha)  + " / " +  cValToChar(nQtdPallets) + "^FS"+CRLF
			cCodZPL += "^FT164,91^A0N,79,74^FB947,1,0,C^FH\^FDKILT DISTRIBUIDORA^FS"+CRLF
			cCodZPL += "^PQ1,0,1,Y^XZ"+CRLF
			MscbWrite( cCodZPL )
			msCbEnd()
		Next

		msCbClosePrinter()

		FWAlertSuccess("Codigo de Montagem "+cCodMontagem+" foi impresso corretamente!", "Impressão Pallets")

		(cAlias)->(DBCloseArea())

	End Sequence

Return

/*/{Protheus.doc} getQtdConteudo
Funcao para retornar a quantidade de caixas dentro do codigo de montagem
@type function
@author Vinicius Franceschi
@since 19/03/2024
@version P12
@database MSSQL,Oracle
/*/
Static Function getQtdConteudo(cCodMontagem)
	Local cQuery := ""
	Local cAlias := GetNextAlias()

	Local cConteudo := 0

	Default cCodMontagem := ""

	cQuery := " SELECT  " + CRLF
	cQuery += " SUM(ZZD_QTDCX) AS QTDCAIXAS " + CRLF
	cQuery += " FROM "  + RetSqlName("ZZD") + " ZZD " + CRLF
	cQuery += " WHERE ZZD.ZZD_FILIAL ='" + FWxFilial("ZZD") + "'" + CRLF
	cQuery += " AND ZZD.ZZD_CODM  ='" + cCodMontagem + "'" + CRLF
	cQuery += " AND ZZD.D_E_L_E_T_ = '' " + CRLF

	TCQUERY cQuery NEW ALIAS &cAlias
	dbSelectArea(cAlias)
	(cAlias)->(DBGoTop())
	While (cAlias)->(!Eof())

		cConteudo := (cAlias)->QTDCAIXAS

		(cAlias)->(DBSkip())
	EndDo

Return cConteudo

/*/{Protheus.doc} getQryDados
Funcao para retornar os dados necessarios para ser feita a impressao da etiqueta
@type function
@author Vinicius Franceschi
@since 19/03/2024
@version P12
@database MSSQL,Oracle
/*/
Static Function getQryDados(cCodMontagem)
	Local cQuery := ""

	Default cCodMontagem := ""

	cQuery := " SELECT  " + CRLF
	cQuery += " ZZD_CODM " + CRLF
	cQuery += " ,ZZD_CODPRD " + CRLF
	cQuery += " ,ZZD_PALLET " + CRLF
	cQuery += " ,ZZD_CLIENT " + CRLF
	cQuery += " ,ZZD_LOJA " + CRLF
	cQuery += " ,F2_DOC " + CRLF
	cQuery += " ,F2_SERIE " + CRLF
	cQuery += " ,F2_TRANSP " + CRLF
	cQuery += " ,A1_NOME " + CRLF
	cQuery += " ,A1_MUN " + CRLF
	cQuery += " ,A4_NREDUZ " + CRLF
	cQuery += " FROM "  + RetSqlName("ZZD") + " ZZD " + CRLF

	cQuery += " INNER JOIN " + retSqlName("SF2") + " SF2 " + CRLF
	cQuery +=  " ON SF2.F2_FILIAL = ZZD.ZZD_FILIAL  "+ CRLF
	cQuery +=  " AND SF2.F2_DOC = ZZD.ZZD_DOC" + CRLF
	cQuery +=  " AND SF2.F2_SERIE = ZZD.ZZD_SERIE" + CRLF
	cQuery +=  " AND SF2.D_E_L_E_T_ = ''" + CRLF

	cQuery += " INNER JOIN " + retSqlName("SA1") + " SA1 " + CRLF
	cQuery +=  " ON SA1.A1_COD = ZZD.ZZD_CLIENT  "+ CRLF
	cQuery +=  " AND SA1.A1_LOJA = ZZD.ZZD_LOJA" + CRLF
	cQuery +=  " AND SA1.D_E_L_E_T_ = ''" + CRLF

	cQuery += " LEFT JOIN " + retSqlName("SA4") + " SA4 " + CRLF
	cQuery +=  " ON SA4.A4_COD = SF2.F2_TRANSP" + CRLF
	cQuery +=  " AND SA4.D_E_L_E_T_ = ''" + CRLF

	cQuery += " WHERE ZZD.ZZD_FILIAL ='" + FWxFilial("ZZD") + "'" + CRLF
	cQuery += " AND ZZD.ZZD_CODM  ='" + cCodMontagem + "'" + CRLF
	cQuery += " AND ZZD.D_E_L_E_T_ = '' " + CRLF

Return cQuery

/*/{Protheus.doc} getQtdPallets
Funcao para contar quantos pallets existem dentro de determinada montagem
@type function
@author Vinicius Franceschi
@since 19/03/2024
@version P12
@database MSSQL,Oracle
/*/
Static Function getQtdPallets(cCodMontagem)
	Local cQuery := ""
	Local cAlias := GetNextAlias()

	Local nTotalPallets := 0

	Default cCodMontagem := ""

	cQuery := " SELECT  " + CRLF
	cQuery += " DISTINCT(ZZD_PALLET) AS QTDPALLETS " + CRLF
	cQuery += " FROM "  + RetSqlName("ZZD") + " ZZD " + CRLF
	cQuery += " WHERE ZZD.ZZD_FILIAL ='" + FWxFilial("ZZD") + "'" + CRLF
	cQuery += " AND ZZD.ZZD_CODM  ='" + cCodMontagem + "'" + CRLF
	cQuery += " AND ZZD.D_E_L_E_T_ = '' " + CRLF

	TCQUERY cQuery NEW ALIAS &cAlias
	dbSelectArea(cAlias)
	(cAlias)->(DBGoTop())
	While (cAlias)->(!Eof())

		nTotalPallets ++

		(cAlias)->(DBSkip())
	EndDo

Return nTotalPallets

//
/*/{Protheus.doc} getQtdPallets
Funcao para retornar o codigo dos pallets
@type function
@author Vinicius Franceschi
@since 19/03/2024
@version P12
@database MSSQL,Oracle
/*/
Static Function GetMyPallets(cCodMontagem)
	Local cQuery := ""
	Local cAlias := GetNextAlias()

	Local _aLinha	:= {}
	Local aPallet 	:= {}

	Default cCodMontagem := ""

	cQuery := " SELECT  " + CRLF
	cQuery += " ZZD_PALLET AS QTDPALLETS,SUM(ZZD_QTDCX) AS QTDCAIXAS  " + CRLF
	cQuery += " FROM "  + RetSqlName("ZZD") + " ZZD " + CRLF
	cQuery += " WHERE ZZD.ZZD_FILIAL ='" + FWxFilial("ZZD") + "'" + CRLF
	cQuery += " AND ZZD.ZZD_CODM  ='" + cCodMontagem + "'" + CRLF
	cQuery += " AND ZZD.D_E_L_E_T_ = '' " + CRLF
	cQuery += " GROUP BY ZZD_PALLET "

	TCQUERY cQuery NEW ALIAS &cAlias
	dbSelectArea(cAlias)
	(cAlias)->(DBGoTop())
	While (cAlias)->(!Eof())
		_aLinha := {}

		aAdd(_aLinha,{(cAlias)->QTDPALLETS,(cAlias)->QTDCAIXAS })
		aAdd(aPallet,_aLinha)

		(cAlias)->(DBSkip())
	EndDo	

Return aPallet
//

/*/{Protheus.doc} getAllSalesOrders
Funcao para retornar o numero dos pedidos de venda atrelados a NF
@type function
@author Vinicius Franceschi
@since 26/03/2024
@version P12
@database MSSQL,Oracle
/*/
Static Function getAllSalesOrders(cCodMontagem)
	Local cQuery := ""
	Local cAlias := GetNextAlias()
	Local cPedidos := ""

	Default cCodMontagem := ""

	cQuery := " SELECT  " + CRLF
	cQuery += "   DISTINCT SD2.D2_PEDIDO " + CRLF
	cQuery += " FROM "  + RetSqlName("SD2") + " SD2 " + CRLF
	cQuery += " INNER JOIN " + retSqlName("ZZD") + " ZZD " + CRLF
	cQuery += " ON ZZD.ZZD_FILIAL = SD2.D2_FILIAL "+ CRLF
	cQuery += " AND ZZD.ZZD_DOC = SD2.D2_DOC " + CRLF
	cQuery += " AND ZZD.ZZD_SERIE = SD2.D2_SERIE " + CRLF
	cQuery += " AND ZZD.ZZD_CODM = '" + cCodMontagem + "' " + CRLF
	cQuery += " AND ZZD.D_E_L_E_T_ = ''" + CRLF
	cQuery += " WHERE SD2.D2_FILIAL ='" + FWxFilial("SD2") + "'" + CRLF
	cQuery += " AND SD2.D_E_L_E_T_ = '' " + CRLF

	TCQUERY cQuery NEW ALIAS &cAlias
	dbSelectArea(cAlias)
	(cAlias)->(DBGoTop())
	While (cAlias)->(!Eof())

		cPedidos += (cAlias)->D2_PEDIDO

		(cAlias)->(DBSkip())
		If (cAlias)->(!EOF())
			cPedidos += ","
		Endif

	EndDo

Return cPedidos
