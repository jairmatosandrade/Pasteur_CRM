#Include 'protheus.ch'
#Include 'parmtype.ch'
#Include 'RestFul.CH'
#Include 'tbiconn.ch'
#Include "TopConn.ch"

#Define STR_PULA chr(13)+Chr(10)

//+------------------------------------------------------------------------------------------------------------------+
//| Programa | Consulta OP | Autor | Jair Matos | Data | 19/06/2024 												 | 
//+------------------------------------------------------------------------------------------------------------------+
//| Descr. | Serviço REST Generico para execução de consulta de Ordem de Pesagem(ZZA e ZZB)							 | 
//| 																												 | 
//+------------------------------------------------------------------------------------------------------------------+
//| 																												 |
//+------------------------------------------------------------------------------------------------------------------+
WSRESTFUL WSOrdemPesagem DESCRIPTION "Get ZZA/ZZB - Ordens de pesagem"

	WSMETHOD GET DESCRIPTION "Retorna a consulta da tabela ZZA e ZZB" WSSYNTAX "/"

END WSRESTFUL

WSMETHOD GET WSRECEIVE WSSERVICE WSOrdemPesagem

	Local aReturn           := {}
	Local _cCampos  		:= ""
	Local aCab      		:= {}

	// define o tipo de retorno do método
	Self:SetContentType("application/json")

	_cCampos:= "ZZA_FILIAL,ZZA_NUMPES,ZZA_NUMOP,ZZA_PRDPAI,ZZA_PRDDES,ZZA_QTDOP,ZZA_LOTE,ZZA_DTINI,ZZA_HORAIN,ZZA_DTFIM,ZZA_HORAF,ZZA_STATUS,ZZB_ITEM,"
	_cCampos+= "ZZB_NUMPES,ZZB_NUMOP,ZZB_CODPRD,ZZB_LOCAL,ZZB_QUANT,ZZB_QTDPES,ZZB_LOTE,ZZB_DTVLD,ZZB_END,ZZB_FASE,ZZB_USER,ZZB_TRANSF,ZZB_STATUS,ZZB_ETIQ"

	aCab := StrTokArr2(_cCampos, ",",.F.) //Titulo dos campos

	//Executando a query
	aReturn := Consulta_SQL(aCab,_cCampos)

	IF LEN(aReturn) > 0
		//Chama a funcao para gerar o JSON.
		cRet   := EncodeUTF8(JSON( { "Consulta" , aCab, aReturn}))

	Else
		Self:SetResponse('{"Retorno Protheus":')
		Self:SetResponse('[')
		Self:SetResponse('"Não Existe dados para essa consulta!"]')
		Self:SetResponse('}')

		Return(.T.)
	EndIf

	Self:SetResponse(cRet)

Return(.T.)

Static Function Consulta_SQL(aCab,_cCampos)

	Local cQuery    := ""
	Local cQRY      := ""
	Local aQuery    := {}
	Local aResult   := {}
	Local nX        := 0

	//Montando a Consulta
	cQuery := " SELECT "+_cCampos+" "				+ STR_PULA
	cQuery += " FROM "+RetSQLName("ZZA")+" ZZA "    + STR_PULA
	cQuery += " INNER JOIN "+RetSQLName("ZZB")+" ZZB ON ZZB_FILIAL = ZZA_FILIAL AND ZZB_NUMPES = ZZA_NUMPES AND ZZB.D_E_L_E_T_ <> '*'"+ STR_PULA
	cQuery += " WHERE ZZA.D_E_L_E_T_ <> '*' "+ STR_PULA
	//cQuery += " AND ZZA.ZZA_STATUS ='A' "

	//Executando consulta
	cQuery := ChangeQuery(cQuery)
	cQRY := MPSysOpenQuery(cQuery)

	//Percorrendo os registros
	While ! (cQRY)->(EoF())
		aQuery := {}
		For nX:= 1 to Len(aCab)
			If ValType(ALLTRIM(cValtoChar((cQRY)->&(aCab[nX]))))=="C"
				AADD(aQuery,U_TiraGraf(NOACENTO(EncodeUTF8(AnsiToOem(ALLTRIM(cValtoChar((cQRY)->&(aCab[nX]))))))))
			Else
				AADD(aQuery,ALLTRIM(cValtoChar((cQRY)->&(aCab[nX]))))
			EndIf
		Next
		AADD(aResult,aQuery)
		(cQRY)->(dbSkip())
	EndDo
	(cQRY)->(DbCloseArea())

Return aResult
//+------------------------------------------------------------------------------------------------------------------+
//| Programa | Consultas | Autor | Jair Matos | Data | 19/06/2024 													 | 
//+------------------------------------------------------------------------------------------------------------------+
//| Descr. | metodo que cria e formara um Json																		 | 
//| 																												 | 
//+------------------------------------------------------------------------------------------------------------------+
Static function JSON(aGeraXML)
	Local cxJSON  := ""
	Local aCab   := aGeraXML[2]
	Local aLin   := aGeraXML[3]
	Local L, C   := 0

	cxJSON += '['

	FOR L:= 1 TO LEN( aLin )

		cxJSON += '{'

		for C:= 1 to Len( aCab )

			IF VALTYPE(aLin[L][C]) = "C"
				If aCab[C] == "ObjectIn"
					cConteudo := VldObj(aLin[L][C])
				ElseIf aCab[C] == "ObjectOut"
					cConteudo := VldObj(aLin[L][C])
				ELSE
					cConteudo := '"'+aLin[L][C]+'" '
				EndIf
			ELSEIF VALTYPE(aLin[L][C]) = "N"
				cConteudo := ALLTRIM(STR(aLin[L][C]))
			ELSEIF VALTYPE(aLin[L][C]) = "D"
				cConteudo := '"'+DTOC(aLin[L][C])+'"'
			ELSEIF VALTYPE(aLin[L][C]) = "L"
				cConteudo := IF(aLin[L][C], 'true' , 'false')
			ELSE
				cConteudo := '"'+aLin[L][C]+'"'
			ENDIF

			cxJSON += '"'+aCab[C]+'":' + cConteudo

			IF C < LEN(aCab)
				cxJSON += ','
			ENDIF

		Next
		cxJSON += '}'
		IF L < LEN(aLin)
			cxJSON += ','
		Else
			cxJSON += ']'
		ENDIF

	Next

Return cxJSON
