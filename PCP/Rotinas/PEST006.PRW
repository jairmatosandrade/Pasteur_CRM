#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

/*/{Protheus.doc} PEST006
Função que fará o ajuste de empenho para produto a granel
@author Jair
@since 27/06/2024
@version 1.0
@type function
/*/
User Function PEST006(_cAlias)

	Local aEditSB1 := {"D4_LOTECTL","DC_LOCALIZ"}
	Local cDelOk 	:= "AllwaysFalse"
	
	Private lOk      := .F.
	Private cFilSC2  := ""
	Private cNumPes := 0
	Private cOPs 		:= ""
	private aKeys := {}
	//Objetos da Janela
	Private oDlgPvt
	Private oMsGetSB1
	Private aHeadSB1 := {}
	Private aColsSB1 := {}
	Private oBtnSalv
	Private oBtnFech
	//Tamanho da Janela
	Private nJanLarg    := 1040
	Private nJanAltu    := 500
	//Fontes
	Private cFontUti   := "Tahoma"
	Private oFontAno   := TFont():New(cFontUti,,-38)
	Private oFontSub   := TFont():New(cFontUti,,-20)
	Private oFontSubN  := TFont():New(cFontUti,,-20,,.T.)
	Private oFontBtn   := TFont():New(cFontUti,,-14)

	cOPs := ValidGrid(_cAlias)
	If cOPs ==""
		Help(, , "Processo Envase", , "Não é possivel gerar Ajuste de empenho do produto a granel!", 1, 0, , , , , , {"Selecione as OP´s para Ajuste de empenho do produto a granel!"})
		(_cAlias)->(DbGoTop())
		Return
	EndIf

	//Criando o cabeçalho da Grid
	//              Título               Campo        		Máscara         		Tamanho                   Decimal   Valid  Usado  Tipo F3     Combo
	aAdd(aHeadSB1, {"Ordem Produção",   "D4_OP",  		    "",             		TamSX3("D4_OP")[01],        0,      ".T.", ".T.", "C", "",    ""} )
	aAdd(aHeadSB1, {"Produto",          "D4_COD",  		    "",             		TamSX3("D4_COD")[01],       0,      ".T.", ".T.", "C", "",    ""} )
	aAdd(aHeadSB1, {"Descrição",        "B1_DESC",  		"",             		30/*TamSX3("B1_DESC")[01]*/,0,      ".T.", ".T.", "C", "",    ""} )
	aAdd(aHeadSB1, {"Armazém",         	"D4_LOCAL",   		"",             		TamSX3("D4_LOCAL")[01],     0,      ".T.", ".T.", "C", "",    ""} )
	aAdd(aHeadSB1, {"Lote",      		"D4_LOTECTL", 		"",             		TamSX3("D4_LOTECTL")[01],  	0,      "u_vldLote(n)", ".T.", "C", "",    ""} )
	aAdd(aHeadSB1, {"Endereço",      	"DC_LOCALIZ",		"",             		TamSX3("DC_LOCALIZ")[01],  	0,      ".T.", ".T.", "C", "",    ""} )
	aAdd(aHeadSB1, {"Quant.",       	"D4_QUANT", 		"@E 99,999,999,999.9999",TamSX3("D4_QUANT")[01],  	4,      ".T.", ".T.", "N", "",    ""} )
	aAdd(aHeadSB1, {"Qtd.Pesada", 		"D4_QTDEORI",  		"@E 99,999,999,999.9999",TamSX3("D4_QTDEORI")[01],  4,      ".T.", ".T.", "N", "",    ""} )
	aAdd(aHeadSB1, {"SD4 Recno",        "XX_RECNO",  		"@E 999,999", 			018,                      	0,      ".T.", ".T.", "N", "",    ""} )

	Processa({|| fCarAcols()}, "Processando")

	//Criação da tela com os dados que serão informados
	oDlgPvt		:= MSDialog():New( 000,000,nJanAltu,nJanLarg,"Ajuste de empenho do produto a granel",,,.F.,,,,,,.T.,,,.T. )
	oDlgPvt:nStyle := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
	oDlgPvt:lEscClose := .F.

	//Labels gerais
	@ 004, 003 SAY "Pasteur"                SIZE 200, 030 FONT oFontAno  OF oDlgPvt COLORS RGB(149,179,215) PIXEL
	@ 012, 155 SAY "Ajuste de Empenho de produtos a granel" 	SIZE 250, 030 FONT oFontSubN OF oDlgPvt COLORS RGB(031,073,125) PIXEL

	//Botões
	@ 006, (nJanLarg/2-001)-(0052*02) BUTTON oBtnFech  PROMPT "Fechar"        SIZE 050, 018 OF oDlgPvt ACTION (oDlgPvt:End())                               FONT oFontBtn PIXEL
	@ 006, (nJanLarg/2-001)-(0052*01) BUTTON oBtnSalv  PROMPT "Confirmar"     SIZE 050, 018 OF oDlgPvt ACTION (fSalvar(),oDlgPvt:End())                     FONT oFontBtn PIXEL

	//Grid dos pesagens
	oMsGetSB1 := MsNewGetDados():New(    029,; //nTop      - Linha Inicial
	003,;                						//nLeft     - Coluna Inicial
	(nJanAltu/2)-3,;     						//nBottom   - Linha Final
	(nJanLarg/2)-3,;     						//nRight    - Coluna Final
	GD_UPDATE,;			                        //nStyle    - Estilos para edição da Grid (GD_INSERT = Inclusão de Linha; GD_UPDATE = Alteração de Linhas; GD_DELETE = Exclusão de Linhas)
	"AllwaysTrue()",;    						//cLinhaOk  - Validação da linha
	,;                   						//cTudoOk   - Validação de todas as linhas
	"",;                 						//cIniCpos  - Função para inicialização de campos
	aEditSB1,;             						//aAlter    - Colunas que podem ser alteradas
	,;                   						//nFreeze   - Número da coluna que será congelada
	9999,;               						//nMax      - Máximo de Linhas
	,;                   						//cFieldOK  - Validação da coluna
	,;                   						//cSuperDel - Validação ao apertar '+'
	cDelOk,;                   					//cDelOk    - Validação na exclusão da linha
	oDlgPvt,;            						//oWnd      - Janela que é a dona da grid
	aHeadSB1,;           						//aHeader   - Cabeçalho da Grid
	aColsSB1)            						//aCols     - Dados da Grid

	//SetKey(VK_F4, {|| MaViewSB2(oMsGetSB1:aCols[oMsGetSB1:nAt][2]) })  //Seta um bloco de código para sua tecla
	SetKey(VK_F4, {||F4Lote(,,,"A465",oMsGetSB1:aCols[oMsGetSB1:nAt][2],oMsGetSB1:aCols[oMsGetSB1:nAt][5]) })  //Seta um bloco de código para sua tecla

	//Ativa e exibe a janela
	ACTIVATE MSDIALOG oDlgPvt CENTERED

	// Limpa definição de bloco de código para tecla F1
	SetKey(VK_F4, {||})

	(_cAlias)->(DbGoTop())

Return
/*/{Protheus.doc} fCarAcols
Função que carrega o aCols
@type function
@version  1.0
@author Jair Matos
@since 27/06/2024
/*/
Static Function fCarAcols()
	Local aArea     := GetArea()
	local cAliasSD4	:= getNextAlias()
	Local cQuery    := ""
	Local nAtual    := 0
	Local nTotal    := 0

	//Seleciona dados da tabela SD4 e SB1
	cQuery := " SELECT D4_COD,D4_OP,D4_LOCAL,D4_QUANT,D4_QTDEORI,D4_LOTECTL,'' as DC_LOCALIZ, B1_DESC, SD4.R_E_C_N_O_ AS SD4REC "
	cQuery += " FROM "+RetSQLName("SD4")+" SD4 "
	cQuery += " INNER JOIN "+RetSQLName("SB1")+" SB1 ON B1_COD = D4_COD AND SB1.D_E_L_E_T_ <> '*' AND B1_TIPO= '" + GETMV("MV_XTPENV") + "'"
	cQuery += " WHERE SD4.D_E_L_E_T_ <> '*' "
	cQuery += " AND D4_FILIAL ='"+cFilSC2+"' "
	cQuery += " AND SD4.D4_OP IN (" + substr(cOPs,1,len(cOPs)-1) + ") "
	cQuery += " ORDER BY SD4.D4_OP "


	TCQuery cQuery New Alias &cAliasSD4

	//Setando o tamanho da régua
	Count To nTotal
	ProcRegua(nTotal)

	//Enquanto houver dados
	(cAliasSD4)->(DbGoTop())
	While ! (cAliasSD4)->(EoF())

		//Atualizar régua de processamento
		nAtual++
		IncProc("Adicionando " + Alltrim((cAliasSD4)->D4_OP) + " (" + cValToChar(nAtual) + " de " + cValToChar(nTotal) + ")...")

		//Adiciona o item no aCols
		aAdd(aColsSB1, { ;
			(cAliasSD4)->D4_OP,;
			(cAliasSD4)->D4_COD,;
			(cAliasSD4)->B1_DESC,;
			(cAliasSD4)->D4_LOCAL,;
			(cAliasSD4)->D4_LOTECTL,;
			Space(TamSX3("DC_LOCALIZ")[01]),;
			(cAliasSD4)->D4_QUANT,;
			(cAliasSD4)->D4_QTDEORI,;
			(cAliasSD4)->SD4REC,;
			.F.;
			})

		(cAliasSD4)->(DbSkip())
	EndDo
	(cAliasSD4)->(DbCloseArea())

	RestArea(aArea)
Return
/*/{Protheus.doc} ValidGrid
Função que valida se usuario clicou em alguma OP da grid.
@type function
@version 1.0	  
@author Jair Matos
@since 27/06/2024
@param _cAlias, variant, alias com os dados
@return variant, retorna os dados
/*/Static function ValidGrid(_cAlias)
	Local cVar	:= ""
	(_cAlias)->(DbGoTop())

	cFilSC2 := (_cAlias)->TMP_FILIAL
	While (_cAlias)->(!Eof())
		If !Empty((_CALIAS)->TMP_OK)
			cVar += "'"+(_CALIAS)->TMP_NUM+TMP_ITEM+TMP_SEQ+"',"
		EndIf
		(_cAlias)->(DbSkip())
	End

Return cVar
/*/{Protheus.doc} vldLote
Função que altera o campo Lotectl para todos os registros
@type function
@version 1.0 
@author Jair Matos
@since 27/06/2024
@param nLin, numeric, numero da linha editada
@return variant,  retorna true
/*/
User Function vldLote(nLin)
	Local aColsAux  := oMsGetSB1:aCols
	Local nLinha    := 0
	Local nPosLot   := aScan(aHeadSB1, {|x| Alltrim(x[2]) == "D4_LOTECTL"})
	Local cLote		:= Alltrim(aColsAux[nLin][nPosLot])

	If MsgYesNo("Deseja replicar lote para todos os itens?","Atencao")
		//Percorrendo todas as linhas
		For nLinha := 1 To Len(aColsAux)
			If nLinha!=nLin
				aColsAux[nLinha][nPosLot] := cLote
			EndIF
		Next
	EndIf

	oMsGetSB1:refresh()

Return .T.
/*/{Protheus.doc} fSalvar
	chama fGravar regua de processamento
	@type function
	@version 1.0
	@author Jair Matos
	@since 27/06/2024
	@return logical, retorna lret
/*/
Static Function fSalvar()
	Local lRet			:= .F.
	Local oSay := NIL // CAIXA DE DIÁLOGO GERADA

	If MsgYesNo("Deseja salvar as OP's com Lote atualizado?","Atencao")

		FwMsgRun(NIL, {|oSay| lRet := fGravar(oSay)}, "Aguarde", "Atualizando SD4...")

	endIf

Return lRet
/*/{Protheus.doc} fGravar
Função que percorre as linhas e faz a gravação na SD4 via MATA381 opção 4
@type function
@version  1.0
@author Jair Matos
@since 10/06/2024
/*/
Static Function fGravar(oSay)
	Local aColsAux  := oMsGetSB1:aCols
	Local nPosOp   	:= aScan(aHeadSB1, {|x| Alltrim(x[2]) == "D4_OP"})
	Local nLinha    := 0
	Local nTotal 	:= 0
	Local lRet		:= .T.

	//Percorrendo todas as linhas
	For nLinha := 1 To Len(aColsAux)
		oSay:SetText("Working at: " + StrZero(nLinha, 6)) // ALTERA O TEXTO CORRETO
		ProcessMessages() // FORÇA O DESCONGELAMENTO DO SMARTCLIENT

		lRet := fGravaSD4(cFilSC2,aColsAux[nLinha][nPosOp])

		If lRet

			nTotal++
			DbSelectArea("SC2")//grava o campo SC2->C2_XIFLUIG = 'S'
			SC2->(dbSetOrder(1))//C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD
			If SC2->(dbSeek(cFilSC2+aColsAux[nLinha][nPosOp]))

				Reclock("SC2", .F.)
				SC2->C2_XIFLUIG := "S"
				MsUnLock()

			EndIf

		else
			Exit

		EndIf
	Next

	If nTotal == Len(aColsAux)
		FWAlertSuccess("O ajuste de Lote foi finalizado com sucesso para "+AllTrim(cValtochar(nTotal))+"  OP'S!", "Ajuste Lote")
	else
		FWAlertwarning("O ajuste de Lote não foi finalizado para todas as OP'S.!", "Ajuste Lote")
	EndIf

Return
/*/{Protheus.doc} fGravaSD4
Grava alteração dos empenhos na tabela SD4
@type function
@version 1.0
@author Jair Matos
@since 03/05/2024
@param cNumOP, character, Numero da ordem de producao
@return variant, retorna true ou false
/*/Return lRet
Static Function fGravaSD4(cFilOP,cNumOP)
	Local lRet 		:= .T.
	Local nX        := 0
	Local nY        := 0
	Local aArea     := GetArea()
	Local aCabSD4	:= {}
	Local aLine     := {}
	Local aItens    := {}
	Local aIteSD4  := oMsGetSB1:aCols
	Local nPosCod   := aScan(aHeadSB1, {|x| Alltrim(x[2]) == "D4_COD"})
	Local nPosLot   := aScan(aHeadSB1, {|x| Alltrim(x[2]) == "D4_LOTECTL"})

	PRIVATE lMsErroAuto := .F.

	//Monta o cabeçalho com o número da OP que será alt		erada.
	//Necessário utilizar o índice 2 para efetuar _aLinha 	:= {} alteração.
	aCabSD4 := {{"D4_OP",cNumOP,NIL},;
		{"INDEX",2,Nil}}

	//Seta o índice da SDC
	SDC->(dbSetOrder(2))

	//Busca os empenhos da SD4 para alterar/excluir.
	SD4->(dbSetOrder(2))
	SD4->(dbSeek(cFilOP+PadR(cNumOP,Len(SD4->D4_OP))))

	While SD4->(!Eof()) .And. SD4->(D4_FILIAL+D4_OP) == FWXFILIAL("SD4")+PadR(cNumOP,Len(SD4->D4_OP))
		//Busca os empenhos da SD4 para alterar/excluir.
		DbSelectArea("SB1")
		SB1->(dbSetOrder(1))
		If SB1->(dbSeek(FWxFilial("SB1")+SD4->D4_COD)) .AND. B1_XITPES == 'S'
			//Adiciona as informações do empenho, conforme estão na tabela SD4.
			aLine := {}
			For nX := 1 To SD4->(FCount())
				if RTrim(SD4->(Field(nX))) $ "D4_OP|D4_COD|D4_LOCAL|D4_DATA|D4_QTDEORI|D4_QUANT|D4_LOTECTL|D4_XNUMPES|"
					aAdd(aLine,{SD4->(Field(nX)),SD4->(FieldGet(nX)),Nil})
				EndIf
			Next nX

			//Adiciona o identificador LINPOS para identificar que o registro já existe na SD4
			aAdd(aLine,{"LINPOS","D4_COD+D4_TRT+D4_LOTECTL+D4_NUMLOTE+D4_LOCAL+D4_OPORIG+D4_SEQ",;
				SD4->D4_COD,;
				SD4->D4_TRT,;
				SD4->D4_LOTECTL,;
				SD4->D4_NUMLOTE,;
				SD4->D4_LOCAL,;
				SD4->D4_OPORIG,;
				SD4->D4_SEQ})

			For nX := 1 to len(aIteSD4)

				If aIteSD4[nX][nPosCod] == SD4->D4_COD

					//Altera Lotectl
					nY := aScan(aLine,{|x| x[1] == "D4_LOTECTL"})
					If 		nY > 0
						//	Encontrou o valor da quantidade. Faz a alteração do valor.
						aLine[nY,2] := aIteSD4[nX][nPosLot]
					EndIf

					//Adiciona as informações do empenho no array de itens.
					aAdd(aItens,aLine)

				EndIf

			Next nX

		EndIf

		SD4->(dbSkip())
	End

	SetModulo("SIGAPCP","PCP")
	MSExecAuto({|x,y,z| mata381(x,y,z)}, aCabSD4, aItens, 4)

	If lMsErroAuto
		lRet := .F.
		MostraErro()
	EndIf

	RestArea(aArea)

Return lRet
