#Include 'protheus.ch'
#Include 'parmtype.ch'
#Include 'RestFul.CH'
#Include 'tbiconn.ch'
#Include "TopConn.ch"

#Define STR_PULA chr(13)+Chr(10)
 
//+------------------------------------------------------------------------------------------------------------------+
//| Programa | Consultas | Autor | Jair Matos | Data | 30/07/2024 													 | 
//+------------------------------------------------------------------------------------------------------------------+
//| Descr. | Serviço REST Generico para execução de consultas query 												 | 
//| | PARA CONEXÃO COM O APP POR API PARA SER SUBMETIDO A LIBERAÇÃO 												 | 
//+------------------------------------------------------------------------------------------------------------------+
//| 																												 |
//+------------------------------------------------------------------------------------------------------------------+
WSRESTFUL Consultas DESCRIPTION "Serviço REST Generico para execução de consultas query"

	WSDATA _cAlias      As String //Alias da tabela
	WSDATA _cCampos     As String //Campos separados por virgula
	WSDATA _cWhere      As String //Campos separados por virgula



	WSMETHOD GET DESCRIPTION "Retorna as consultas de uma tabela qualquer passada na URL" WSSYNTAX "/_cAlias,_cCampos,_cWhere"

END WSRESTFUL

WSMETHOD GET WSRECEIVE _cAlias,_cCampos,_cWhere WSSERVICE Consultas

	Local aReturn           := {}
	Local _cAlias   := cValtoChar(Self:_cAlias)
	Local _cCampos  := cValtoChar(Self:_cCampos)
	Local _cWhere   := cValtoChar(Self:_cWhere)

	Local aCab      := StrTokArr2( _cCampos, ",",.F.) //Titulo dos campos

	// define o tipo de retorno do método
	Self:SetContentType("application/json")


	//Executando a query
	aReturn := Consulta_SQL(_cAlias, _cCampos,aCab,_cWhere)

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

Static Function Consulta_SQL(_cAlias, _cCampos,aCab,_cWhere)

	Local cQuery    := ""
	Local cQRY      := ""
	Local aQuery    := {}
	Local aResult   := {}
	Local nX        := 0

	_cWhere := StrTran(_cWhere,"%20"," " )

	if len(_cAlias) > 3
		//Montando a Consulta tabela fora padrão P12
		cQuery := " SELECT "                           + STR_PULA
		cQuery += _cCampos                             + STR_PULA
		cQuery += " FROM"+" "+_cAlias                  + STR_PULA
		cQuery += " WHERE "                            + STR_PULA
		cQuery += " D_E_L_E_T_ = ' ' "                 + STR_PULA
		cQuery  += _cWhere                             + STR_PULA
	ELSE
		//Montando a Consulta
		cQuery := " SELECT "                           + STR_PULA
		cQuery += _cCampos                             + STR_PULA
		cQuery += " FROM"+" "+RetSQLName(_cAlias)      + STR_PULA
		cQuery += " WHERE "                            + STR_PULA
		cQuery += " D_E_L_E_T_ = ' '"                  + STR_PULA
		cQuery  += _cWhere                             + STR_PULA
	ENDIF

	//Executando consulta
	cQuery := ChangeQuery(cQuery)
	cQRY := MPSysOpenQuery(cQuery)


	ConOut( PadC( "Consultas - Query", 30 ) )
	ConOut( Replicate( "-", 30 ) )
	ConOut( cValToChar(cQuery) )
	ConOut( Replicate( "-", 30 ) )


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
//| Programa | Consultas | Autor | Jair Matos | Data | 30/07/2024 													 | 
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
