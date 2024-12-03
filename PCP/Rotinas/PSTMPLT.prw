#Include "Protheus.ch"

User Function PSTMPLT()
	Private lMarker     := .T.
	Private aDespes := {}

//Alimenta o array
	BUSDATA()


	DEFINE MsDIALOG o3Dlg TITLE 'Manutencao Pallet' From 0, 4 To 650, 1180 Pixel

	oPnMaster := tPanel():New(0,0,,o3Dlg,,,,,,0,0)
	oPnMaster:Align := CONTROL_ALIGN_ALLCLIENT

	oDespesBrw := fwBrowse():New()
	oDespesBrw:setOwner( oPnMaster )

	oDespesBrw:setDataArray()
	oDespesBrw:setArray( aDespes )
	oDespesBrw:disableConfig()
	oDespesBrw:disableReport()

	oDespesBrw:SetLocate() // Habilita a Localização de registros

	//Create Mark Column
	oDespesBrw:AddMarkColumns({|| IIf(aDespes[oDespesBrw:nAt,01], "LBOK", "LBNO")},; //Code-Block image
	{|| SelectOne(oDespesBrw, aDespes)},; //Code-Block Double Click
	{|| SelectAll(oDespesBrw, 01, aDespes) }) //Code-Block Header Click

	oDespesBrw:addColumn({"CodM"              , {||aDespes[oDespesBrw:nAt,02]}, "C", "@!"    , 1,  20    ,                           		 , .F. , , .F.,, "aDespes[oDespesBrw:nAt,02]",, .F., .T.,                                    , "ETDESPES1"    })
	oDespesBrw:addColumn({"Pallet"                  , {||aDespes[oDespesBrw:nAt,03]}, "C", "@!"    , 1, 100    ,                           	 , .F. , , .F.,, "aDespes[oDespesBrw:nAt,03]",, .F., .T.,                                    , "ETDESPES2"    })
	oDespesBrw:addColumn({"Pedido"                   , {||aDespes[oDespesBrw:nAt,04]}, "C", "@!"    , 1, 100    ,                            , .F. , , .F.,, "aDespes[oDespesBrw:nAt,04]",, .F., .T.,                                    , "ETDESPES3"    })
	oDespesBrw:addColumn({"Doc"                , {||aDespes[oDespesBrw:nAt,05]}, "C", "@!"    , 1, 100    ,                           		 , .F. , , .F.,, "aDespes[oDespesBrw:nAt,05]",, .F., .T.,                                    , "ETDESPES4"    })
	oDespesBrw:addColumn({"Serie"                   , {||aDespes[oDespesBrw:nAt,06]}, "C", "@!"    , 1, 100    ,                           	 , .F. , , .F.,, "aDespes[oDespesBrw:nAt,06]",, .F., .T.,                                    , "ETDESPES5"    })
	oDespesBrw:addColumn({"Item"                   , {||aDespes[oDespesBrw:nAt,07]}, "C", "@!"    , 1, 100    ,                           	 , .F. , , .F.,, "aDespes[oDespesBrw:nAt,07]",, .F., .T.,                                    , "ETDESPES6"    })
	oDespesBrw:addColumn({"Cliente"                   , {||aDespes[oDespesBrw:nAt,08]}, "C", "@!"    , 1, 100    ,                           , .F. , , .F.,, "aDespes[oDespesBrw:nAt,08]",, .F., .T.,                                    , "ETDESPES7"    })
	oDespesBrw:addColumn({"Qtd Caixas"             , {||aDespes[oDespesBrw:nAt,09]}, "N", "@E 99,999,999.99"    , 11, 2    ,              	 , .T. , , .F.,, "aDespes[oDespesBrw:nAt,09]",, .F., .T.,                                    , "ETDESPES8"    })


	oDespesBrw:setEditCell( .T. , { || VldDoc() } ) //activa edit and code block for validation

	//oDespesBrw:acolumns[7]:ledit     := .T.
	//oDespesBrw:acolumns[7]:cReadVar:= 'aDespes[oDespesBrw:nAt,7]'

	DEFINE SBUTTON FROM 300,493 TYPE 1 ACTION (GrvLin(oDespesBrw),o3Dlg:End())ENABLE OF o3Dlg // botao confirmar
	DEFINE SBUTTON FROM 300,523 TYPE 2 ACTION (oDespesBrw:Refresh(),o3Dlg:End())ENABLE OF o3Dlg // botao para sair com o close
	DEFINE SBUTTON FROM 300,543 TYPE 3 ACTION (GrvExc(oDespesBrw),o3Dlg:End())ENABLE OF o3Dlg // botao para excluir

	//DEFINE SBUTTON FROM 20,10 TYPE 1 ACTION (oDespesBrw:Refresh(),o3Dlg:End())ENABLE OF o3Dlg // botao confirmar
	//DEFINE SBUTTON FROM 20,40 TYPE 2 ACTION (oDespesBrw:Refresh(),o3Dlg:End())ENABLE OF o3Dlg // botao para sair com o close

	oDespesBrw:Activate(.T.)

	Activate MsDialog o3Dlg

return .t.

Static Function SelectOne(oDespesBrw, aArquivo)
	aArquivo[oDespesBrw:nAt,1] := !aArquivo[oDespesBrw:nAt,1]
	oDespesBrw:Refresh()
Return .T.

Static Function SelectAll(oDespesBrw, nCol, aArquivo)
	Local _ni := 1
	For _ni := 1 to len(aArquivo)
		aArquivo[_ni,1] := lMarker
	Next
	oDespesBrw:Refresh()
	lMarker:=!lMarker
Return .T.


//Alimenta a tabela temporaria
Static Function BUSDATA()
	Local cQuery    as Character
	Local cQryT3    as Character

	cQuery      := ""
	cQryT3      := GetNextAlias()
	aDespes := {}

	cQuery+="SELECT * FROM " + RetSqlName("ZZD")
	cQuery+=" WHERE D_E_L_E_T_='' "
	cQuery:=ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cQryT3, .T., .F. )

	(cQryT3)->(DbGoTop())
	While (cQryT3)->(!EOF())

		aadd(aDespes,{.f.,alltrim((cQryT3)->ZZD_CODM),alltrim((cQryT3)->ZZD_PALLET),alltrim((cQryT3)->ZZD_PEDIDO ),alltrim((cQryT3)->ZZD_DOC),alltrim((cQryT3)->ZZD_SERIE), alltrim((cQryT3)->ZZD_ITEM),alltrim((cQryT3)->ZZD_CLIENT ),ZZD->ZZD_QTDCX    })
		//aadd(aDespes,{.f.,alltrim((cQryT3)->A1_COD+(cQryT3)->A1_LOJA),alltrim((cQryT3)->A1_NOME),alltrim((cQryT3)->A1_END),alltrim((cQryT3)->A1_MUN)    })

		(cQryT3)->(dbSkip())
	EndDo
	(cQryT3)->(dbCloseArea())
	DbSelectArea('ZZD')

Return .t.

Static Function VldDoc()

Return


Static Function GrvLin()
	Local I

	If MSGYESNO("Confirma a Alteracao dos itens selecionados? ")
		dbSelectArea("SD2")
		dbSetOrder(3) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM

		dBselectarea("ZZD")
		dBsetOrder(1)

		nQtd := u_XQTDPLT()
		if cQTDP > nQtd
			FOR I:=1 TO LEN(aDespes)
				_cCodigo        :=  ADESPES[i][2]
				cQtdCX       	:=  ADESPES[i][9]
				if ADESPES[i][1]
					if ZZD->(dBseek(xFilial("ZZD")+_cCodigo))
						ZZD->(Reclock("ZZD",.F.))
						ZZD->ZZD_QTDCX      := cQtdCX
						ZZD->(MsUnlock())
					endif
				endif
			NEXT I

		else
			Alert("Quantidade de Pallets Excedida!")
			Return
		endif
	ENDIF
Return


Static Function GrvExc()
	Local I

	If MSGYESNO("Confirma a Exclusao dos itens selecionados? ")
		dbSelectArea("SD2")
		dbSetOrder(3) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM

		dBselectarea("ZZD")
		dBsetOrder(1)

		FOR I:=1 TO LEN(aDespes)
			_cCodigo        :=  ADESPES[i][2]
			if ADESPES[i][1]
				if ZZD->(dBseek(xFilial("ZZD")+_cCodigo))
					ZZD->(Reclock("ZZD",.F.))
					ZZD->(DbDelete())
					ZZD->(MsUnlock())
				endif
			endif
		NEXT I
	ENDIF
Return

Static Function PadF(cText, cField)
Return PadR(AllTrim(cText), TamSx3(cField)[1])


User Function XQTDPLT()

	Local cQuery := ""
	Local nTotalRec := ""
	Local aAlias := GetNextAlias()

	cQuery += "	SELECT COUNT(*) NREC FROM "+RETSQLNAME('ZZD')+" ZZD "
	cQuery += " WHERE D_E_L_E_T_ <> '*'
	cQuery += " AND ZZD_FILIAL ='"+xFilial("ZZD")+"'
	cQuery += " AND ZZD_DOC='"+MV_PAR03+"'
	cQuery += " AND ZZD_SERIE='"+MV_PAR03+"'
	//cQuery += " AND ZZD_DOC='"+MV_PAR03+"'
	//cQuery += " AND BJ_COD BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'"
	//TESTE LOTE
	//cQuery += " AND BJ_LOTECTL = '0000038573'

	aAlias := MPSysOpenQuery(cQuery)

	//Conta quantos registros existem, e seta no tamanho da régua
	nTotalRec := MpSysExecScalar(cQuery,"NREC")

Return nTotalRec
