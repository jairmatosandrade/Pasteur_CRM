#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

Static oBmpVerde    := LoadBitmap( GetResources(), "BR_VERDE")
Static oBmpVermelho := LoadBitmap( GetResources(), "BR_VERMELHO")

/*/{Protheus.doc} PACD003
Função para realizar a leitura e pesagem de produto
@author Jair
@since 10/06/2024
@version 1.0
@type function
/*/
User Function PACD003()
	Local aArea := GetArea()
	Local aEditZZB := {"ZZB_ETIQ"}
	Local cDelOk := "AllwaysFalse"
	Private cNumPes := ZZA->ZZA_NUMPES
	//Objetos da Janela
	Private oDlgPvt
	Private oMsGetZZB
	Private aHeadZZB := {}
	Private aColsZZB := {}
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

	//Criando o cabeçalho da Grid
	//              Título               Campo        		Máscara         		Tamanho                   Decimal   Valid  Usado  Tipo F3     Combo
	aAdd(aHeadZZB, {"",                 "XX_COR",    	"@BMP",         			002,                      	0,      ".F.", "   ", "C", "",    "V",     "",      "",        "", "V"})
	aAdd(aHeadZZB, {"Status",           "ZZB_STATUS",  		"",             		TamSX3("ZZB_STATUS")[01],   0,      ".T.", ".T.", "C", "",    ""} )
	aAdd(aHeadZZB, {"Prod.Pai",         "ZZA_PRDPAI",  		"",             		TamSX3("ZZA_PRDPAI")[01],   0,      ".T.", ".T.", "C", "",    ""} )
	aAdd(aHeadZZB, {"Produto",          "ZZB_CODPRD",  		"",             		TamSX3("ZZB_CODPRD")[01],   0,      ".T.", ".T.", "C", "",    ""} )
	aAdd(aHeadZZB, {"Armazém",         	"ZZB_LOCAL",   		"",             		TamSX3("ZZB_LOCAL")[01],    0,      ".T.", ".T.", "C", "",    ""} )
	aAdd(aHeadZZB, {"Lote",      		"ZZB_LOTE", 		"",             		TamSX3("ZZB_LOTE")[01],  	0,      ".T.", ".T.", "C", "",    ""} )
	aAdd(aHeadZZB, {"Quant.",       	"ZZB_QUANT", 		"@E 99,999,999,999.9999",TamSX3("ZZB_QUANT")[01],  	4,      ".T.", ".T.", "N", "",    ""} )
	aAdd(aHeadZZB, {"Etiqueta", 		"ZZB_ETIQ",  		"@!",					TamSX3("ZZB_ETIQ")[01],		0,      "U_ChBalan()", ".T.", "C", "",    ""} )
	aAdd(aHeadZZB, {"Qtd.Pesada", 		"ZZB_QTDPES",  		"@E 99,999,999,999.9999",TamSX3("ZZB_QTDPES")[01],   4,      ".T.", ".T.", "N", "",    ""} )
	aAdd(aHeadZZB, {"ZZB Recno",        "XX_RECNO",  		"@E 999,999", 			018,                      	0,      ".T.", ".T.", "N", "",    ""} )

	Processa({|| fCarAcols()}, "Processando")

	//Criação da tela com os dados que serão informados
	DEFINE MSDIALOG oDlgPvt TITLE "" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL Style DS_MODALFRAME // Cria Dialog sem o botão de Fechar.

	oDlgPvt:lEscClose := .F.
	//Labels gerais
	@ 004, 003 SAY "Pasteur"                SIZE 200, 030 FONT oFontAno  OF oDlgPvt COLORS RGB(149,179,215) PIXEL
	@ 012, 155 SAY "Pesagem de Produtos" 	SIZE 200, 030 FONT oFontSubN OF oDlgPvt COLORS RGB(031,073,125) PIXEL

	//Botões
	@ 006, (nJanLarg/2-001)-(0052*02) BUTTON oBtnFech  PROMPT "Fechar"        SIZE 050, 018 OF oDlgPvt ACTION (oDlgPvt:End())                               FONT oFontBtn PIXEL
	@ 006, (nJanLarg/2-001)-(0052*01) BUTTON oBtnSalv  PROMPT "Confirmar"     SIZE 050, 018 OF oDlgPvt ACTION (fSalvar())                                   FONT oFontBtn PIXEL

	//Grid dos pesagens
	oMsGetZZB := MsNewGetDados():New(    029,; //nTop      - Linha Inicial
	003,;                						//nLeft     - Coluna Inicial
	(nJanAltu/2)-3,;     						//nBottom   - Linha Final
	(nJanLarg/2)-3,;     						//nRight    - Coluna Final
	GD_UPDATE,;			                        //nStyle    - Estilos para edição da Grid (GD_INSERT = Inclusão de Linha; GD_UPDATE = Alteração de Linhas; GD_DELETE = Exclusão de Linhas)
	"AllwaysTrue()",;    						//cLinhaOk  - Validação da linha
	,;                   						//cTudoOk   - Validação de todas as linhas
	"",;                 						//cIniCpos  - Função para inicialização de campos
	aEditZZB,;             						//aAlter    - Colunas que podem ser alteradas
	,;                   						//nFreeze   - Número da coluna que será congelada
	9999,;               						//nMax      - Máximo de Linhas
	,;                   						//cFieldOK  - Validação da coluna
	,;                   						//cSuperDel - Validação ao apertar '+'
	cDelOk,;                   					//cDelOk    - Validação na exclusão da linha
	oDlgPvt,;            						//oWnd      - Janela que é a dona da grid
	aHeadZZB,;           						//aHeader   - Cabeçalho da Grid
	aColsZZB)            						//aCols     - Dados da Grid

	ACTIVATE MSDIALOG oDlgPvt CENTERED

	RestArea(aArea)
Return
/*/{Protheus.doc} fCarAcols
Função que carrega o aCols
@type function
@version  1.0
@author Jair Matos
@since 10/06/2024
/*/
Static Function fCarAcols()
	Local aArea     := GetArea()
	local cAlias 	:= getNextAlias()
	Local cQuery    := ""
	Local nAtual    := 0
	Local nTotal    := 0
	Local oBmpAux

	//Seleciona dados da tabela ZZA e ZZB
	cQuery := " SELECT ZZB_STATUS, ZZA_PRDPAI, ZZB_CODPRD, ZZB_LOCAL, ZZB_LOTE, ZZB_QUANT, ZZB_ETIQ, ZZB_QTDPES, ZZB.R_E_C_N_O_ AS ZZBREC "
	cQuery += " FROM "+RetSQLName("ZZA")+" ZZA"
	cQuery += " INNER JOIN "+RetSQLName("ZZB")+" ZZB ON ZZB_FILIAL = ZZA_FILIAL AND ZZB_NUMPES = ZZA_NUMPES AND ZZB.D_E_L_E_T_ <> '*' "
	cQuery += " WHERE ZZA.D_E_L_E_T_ <> '*' AND ZZA_FILIAL ='"+xFilial("ZZA")+"' "
	cQuery += "AND ZZA_NUMPES ='"+cNumpes+"' "
	//cQuery += "AND ZZB_STATUS ='Aguardando Pesagem' "
	cQuery += "ORDER BY ZZB_CODPRD "

	TCQuery cQuery New Alias &cAlias

	//Setando o tamanho da régua
	Count To nTotal
	ProcRegua(nTotal)

	//Enquanto houver dados
	(cAlias)->(DbGoTop())
	While ! (cAlias)->(EoF())

		//Atualizar régua de processamento
		nAtual++
		IncProc("Adicionando " + Alltrim((cAlias)->ZZB_CODPRD) + " (" + cValToChar(nAtual) + " de " + cValToChar(nTotal) + ")...")

		//Se for Aguardando Pesagem será verde
		If Alltrim((cAlias)->ZZB_STATUS) == 'Aguardando Pesagem'
			oBmpAux := oBmpVerde

			//Senão, se for Pesagem Realizada será vermelho
		ElseIf Alltrim((cAlias)->ZZB_STATUS) == 'Pesagem Realizada'
			oBmpAux := oBmpVermelho
		EndIf

		//Adiciona o item no aCols
		aAdd(aColsZZB, { ;
			oBmpAux,;
			(cAlias)->ZZB_STATUS,;
			(cAlias)->ZZA_PRDPAI,;
			(cAlias)->ZZB_CODPRD,;
			(cAlias)->ZZB_LOCAL,;
			(cAlias)->ZZB_LOTE,;
			(cAlias)->ZZB_QUANT,;
			(cAlias)->ZZB_ETIQ,;
			(cAlias)->ZZB_QTDPES,;
			(cAlias)->ZZBREC,;
			.F.;
			})

		(cAlias)->(DbSkip())
	EndDo
	(cAlias)->(DbCloseArea())

	RestArea(aArea)
Return
/*/{Protheus.doc} fExecProc
	chama _aLinha := {	} regua de processamento
	@type function
	@version 1.0
	@author Jair Matos
	@since 25/04/2024
	@return logical, retorna lret
/*/
Static Function fSalvar()
	Local lRet			:= .F.
	Local oSay := NIL // CAIXA DE DIÁLOGO GERADA

	// GERA A TELA DE PROCESSAMENTO
	FwMsgRun(NIL, {|oSay| lRet := fGravar(oSay)}, "Aguarde", "Gravando dados...")

Return lRet

/*/{Protheus.doc} fGravar
Função que percorre as linhas e faz a gravação 
@type function
@version  1.0
@author Jair Matos
@since 10/06/2024
/*/
Static Function fGravar(oSay)
	Local aColsAux  := oMsGetZZB:aCols
	Local nPosRec   := aScan(aHeadZZB, {|x| Alltrim(x[2]) == "XX_RECNO"})
	Local nPosPes   := aScan(aHeadZZB, {|x| Alltrim(x[2]) == "ZZB_QTDPES"})
	Local nPosEti   := aScan(aHeadZZB, {|x| Alltrim(x[2]) == "ZZB_ETIQ"})
	Local nPosSta   := aScan(aHeadZZB, {|x| Alltrim(x[2]) == "ZZB_STATUS"})
	Local cProdPai  := ""
	Local cLoteZZA  := ""
	Local nLinha    := 0
	Local ntotGrv   := 0
	Local lFaltaEtiq:= .F.

	//valida se todas as etiquetas foram digitadas
	//Percorrendo todas as linhas
	For nLinha := 1 To Len(aColsAux)
		If Empty(aColsAux[nLinha][nPosEti])
			lFaltaEtiq := .T.
		Else
			If Alltrim(aColsAux[nLinha][nPosSta]) != 'Pesagem Realizada' .and. aColsAux[nLinha][nPosPes]>0
				ntotGrv++
			EndIf
		EndIf
	Next

	If ntotGrv>0 .and. Len(aColsAux)!=ntotGrv
		ZZA->(dbSetOrder(1))
		If ZZA->(dbSeek(xFilial("ZZA")+cNumPes))
			cProdPai := ZZA->ZZA_PRDPAI
			cLoteZZA := ZZA->ZZA_LOTE
			Reclock("ZZA", .F.)
			ZZA->ZZA_DTINI 	:= date()
			ZZA->ZZA_HORAIN := Time()
			If !lFaltaEtiq
				ZZA->ZZA_STATUS := "F"
				ZZA->ZZA_DTFIM 	:= date()
				ZZA->ZZA_HORAF := Time()
			EndIf
			MsUnLock()
		EndIf

		DbSelectArea('ZZB')

		//Percorrendo todas as linhas
		For nLinha := 1 To Len(aColsAux)

			oSay:SetText("Imprimindo etiqueta: " + StrZero(nLinha, 6)) // ALTERA O TEXTO CORRETO
			ProcessMessages() // FORÇA O DESCONGELAMENTO DO SMARTCLIENT

			//Posiciona no registro
			If aColsAux[nLinha][nPosRec] != 0
				ZZB->(DbGoTo(aColsAux[nLinha][nPosRec]))
			EndIf

			If Alltrim(ZZB->ZZB_STATUS)=='Aguardando Pesagem' .and. !Empty(aColsAux[nLinha][nPosEti]) .and. aColsAux[nLinha][nPosPes]>0

				RecLock('ZZB', .F.)
				ZZB->ZZB_QTDPES := aColsAux[nLinha][nPosPes]
				ZZB->ZZB_ETIQ   := aColsAux[nLinha][nPosEti]
				ZZB->ZZB_STATUS := "Pesagem Realizada"
				ZZB->ZZB_USER   := __cUserID
				ZZB->(MsUnlock())

				//Imprime as Etiqueta
				Impetiq(cProdPai,cLoteZZA,ZZB->ZZB_FASE,ZZB->ZZB_QTDPES,ZZB_ETIQ)
			EndIf
		Next

		If lFaltaEtiq
			FWAlertWarning("A pesagem foi efetuada para somente "+Alltrim(cValToChar(ntotGrv))+" item. Pesagem não finalizada!", "Gerar Pesagem")
		Else
			FWAlertSuccess("Pesagens Realizadas para todos os itens", "Gerar Pesagem")
		EndIf

	EndIf
	oDlgPvt:End()
Return
/*/{Protheus.doc} chBalan
Chama Balança
@type function
@version 1.0
@author Jair Matos
@since 11/06/2024
@return variant, retorna true ou false
/*/
User Function chBalan()
	Local nPeso     := 0
	Local lRet      := .T.
	Local xConteudo  := Readvar()
	Local cCodEtiq := &(xConteudo)
	Local nPosQtd   := aScan(aHeadZZB, {|x| Alltrim(x[2]) == "ZZB_QTDPES"})
	Local nPosQua   := aScan(aHeadZZB, {|x| Alltrim(x[2]) == "ZZB_QUANT"})
	Local nPosPrd   := aScan(aHeadZZB, {|x| Alltrim(x[2]) == "ZZB_CODPRD"})
	Local nPosLoc   := aScan(aHeadZZB, {|x| Alltrim(x[2]) == "ZZB_LOCAL"})
	Local nPosLot   := aScan(aHeadZZB, {|x| Alltrim(x[2]) == "ZZB_LOTE"})
	Local aColsAux  := oMsGetZZB:aCols[n]
	Local cQuery		:= ""
	local cAliasZZC		:= getNextAlias()


	cQuery := " SELECT * FROM "+RetSQLName("ZZC")
	cQuery += " WHERE D_E_L_E_T_ <> '*' AND ZZC_FILIAL ='"+xFilial("ZZC")+"' "
	cQuery += " AND ZZC_CODETI ='"+cCodEtiq+"' "
	cQuery += " AND ZZC_CODPRD ='"+aColsAux[nPosPrd]+"' "
	cQuery += " AND ZZC_LOCAL  ='"+aColsAux[nPosLoc]+"' "
	cQuery += " AND ZZC_LOTE   ='"+aColsAux[nPosLot]+"' "

	TCQuery cQuery New Alias &cAliasZZC
	If (cAliasZZC)->(EOF())
		FWAlertWarning("Etiqueta "+Alltrim(cCodEtiq)+" não existe para os dados da pesagem!", "Aviso")
		lRet := .F.
	EndIf

	If lRet
		nPeso :=LeBalan()
		If nPeso>0
			nPeso := aColsAux[nPosQua]//remover esta linha.....somente para testes
			//verifica se a quantidade pesada <> ZZB_QUANT
			If nPeso > aColsAux[nPosQua]
				FWAlertWarning("A Quantidade pesada é maior do que o empenho, favor ajustar! Qtde pesada:"+Alltrim(transform(nPeso,"@E 999.999"))+" ,Qtde necessaria:"+ AllTrim(cValtochar(aColsAux[nPosQua])), "Aviso")
				lRet :=.F.
			elseIf nPeso < aColsAux[nPosQua]
				FWAlertWarning("A Quantidade pesada é menor do que o empenho, favor ajustar!Qtde pesada:"+Alltrim(transform(nPeso,"@E 999.999"))+" ,Qtde necessaria:"+ AllTrim(cValtochar(aColsAux[nPosQua])), "Aviso")
				lRet :=.F.
			EndIf
		Else
			lRet :=.F.
		EndIf
	EndIf

	If lRet
		aColsAux[nPosQtd]:= nPeso
		oMsGetZZB:refresh()
	EndIf

Return lRet

/*/{Protheus.doc} fReadBal
Verifica a balança utilizada , faz conexao e le o peso.
@type function
@version 1.0 
@author Jair Matos 
@since 22/05/2024
@param cMarca, character, marca da impressora
/*/
Static Function LeBalan()
	Local nPesoRet
	Local cPorta    := ""
	Local cVelocid  := ""
	Local cParidade := ""
	Local cBits     := ""
	Local cStopBits := ""
	Local cFluxo    := ""
	Local nTempo    := ""
	Local cConfig   := ""
	Local lRet      := .T.
	Local nH        := 0
	Local cBuffer   := ""
	Local nPosFim   := 0
	Local nPosIni   := 0
	Local nX        := 0
	Local naux      := 0
	Local cPesoLido := ""
	Default cMarca  := "TOLEDO"

	//Se houver marca
	If ! Empty(cMarca)
		cMarca := Upper(Alltrim(cMarca))

		//Pegando a porta padrão da balança
		cPorta   :="COM2"// := SuperGetMV("MV_X_PORTA",.F.,"COM1")

		//Modelo Confiança
		If (cMarca=="CONFIANCA")
			cVelocid  := SuperGetMV("MV_X_VELOC", .F., "9600")   //Velocidade
			cParidade := SuperGetMV("MV_X_PARID", .F., "n")      //Paridade
			cBits     := SuperGetMV("MV_X_BITS",  .F., "8")      //Bits
			cStopBits := SuperGetMV("MV_X_SBITS", .F., "1")      //Stop Bit
			cFluxo    := SuperGetMV("MV_X_FLUXO", .F., "")       //Controle de Fluxo
			nTempo    := SuperGetMV("MV_X_TEMPO", .F., 5)        //Tempo

			//Jundiaí
		ElseIf (cMarca == "JUNDIAI")
			cVelocid  := SuperGetMV("MV_X_VELOC", .F., "9600")   //Velocidade
			cParidade := SuperGetMV("MV_X_PARID", .F., "n")      //Paridade
			cBits     := SuperGetMV("MV_X_BITS",  .F., "8")      //Bits
			cStopBits := SuperGetMV("MV_X_SBITS", .F., "0")      //Stop Bit
			cFluxo    := SuperGetMV("MV_X_FLUXO", .F., "")       //Controle de Fluxo
			nTempo    := SuperGetMV("MV_X_TEMPO", .F., 5)        //Tempo

			//Toledo
		ElseIf (cMarca == "TOLEDO")
			cVelocid  := SuperGetMV("MV_X_VELOC", .F.,"4800")    //Velocidade
			cParidade := SuperGetMV("MV_X_PARID", .F.,"N")       //Paridade
			cBits     := SuperGetMV("MV_X_BITS",  .F.,"8")       //Bits
			cStopBits := SuperGetMV("MV_X_SBITS", .F.,"1")       //Stop Bit
			cFluxo    := SuperGetMV("MV_X_FLUXO", .F.,"")        //Controle de Fluxo
			nTempo    := SuperGetMV("MV_X_TEMPO", .F.,5)         //Tempo

			//Líder
		ElseIf (cMarca == "LIDER")
			cVelocid  := SuperGetMV("MV_X_VELOC", .F.,"4800")    //Velocidade
			cParidade := SuperGetMV("MV_X_PARID", .F.,"N")       //Paridade
			cBits     := SuperGetMV("MV_X_BITS",  .F.,"8")       //Bits
			cStopBits := SuperGetMV("MV_X_SBITS", .F.,"1")       //Stop Bit
			cFluxo    := SuperGetMV("MV_X_FLUXO", .F.,"")        //Controle de Fluxo
			nTempo    := SuperGetMV("MV_X_TEMPO", .F.,5)         //Tempo

			//Qualquer balança que utilize porta serial
		Else
			cVelocid  := SuperGetMV("MV_X_VELOC", .F.,"9600")    //Velocidade
			cParidade := SuperGetMV("MV_X_PARID", .F.,"N")       //Paridade
			cBits     := SuperGetMV("MV_X_BITS",  .F.,"8")       //Bits
			cStopBits := SuperGetMV("MV_X_SBITS", .F.,"1")       //Stop Bit
			cFluxo    := SuperGetMV("MV_X_FLUXO", .F.,"")        //Controle de Fluxo
			nTempo    := SuperGetMV("MV_X_TEMPO", .F.,5)         //Tempo
		EndIf

		//Se a marca da balança for LIDER
		If cMarca == "LIDER"
			//Montando a configuração (Porta:Velocidade,Paridade,Bits,Stop)
			cConfig := cPorta+":"+cVelocid+","+cParidade+","+cBits+","+cStopBits

			//Guarda resultado se houve abertura da porta
			lRet := MSOpenPort(@nH,cConfig)

			//Se não conseguir abrir a porta, mostra mensagem e finaliza
			If !lRet
				FWAlertWarning("Falha ao conectar com a porta serial. Verifique se a balança está ligada!", "Aviso")
			Else
				//Realiza a leitura
				For nX := 1 To 50
					//Obtendo o tempo de espera antes de iniciar a leitura da balança
					Sleep(nTempo)
					MSRead(nH,@cBuffer)

					//Se a linha retornada for igual ao tamanho limite, encerra o laço
					If Len(AllTrim(cBuffer)) == MAX_BUFFER
						Exit
					EndIf
				Next nX

				//Verifica onde começa o "E" e diminui 1 caracter
				nPosFim := At("E", cBuffer) - 1

				//Obtendo apenas o peso da balança
				cPesoLido := StrTran(AllTrim(SubStr(cBuffer,2,nPosFim)),".","")
			EndIf

			//Encerra a conexão com a porta
			MSClosePort(nH,cConfig)

			//Se for a Toledo
		ElseIf cMarca == "TOLEDO"
			//Montando a configuração (Porta:Velocidade,Paridade,Bits,Stop)
			cConfig := cPorta+":"+cVelocid+","+cParidade+","+cBits+","+cStopBits

			//Guarda resultado se houve abertura da porta
			lRet := MSOpenPort(@nH,cConfig)
			lOk  := .T.

			//Se não conseguir abrir a porta, tenta mais uma vez, remapeando
			If ! lRet
				conout("erro porta")
				//Força o fechamento e abertura da porta novamente
				WaitRun("NET USE "+cPorta+": /DELETE")
				WaitRun("NET USE "+cPorta+" ")

				lOk := MSOpenPort(@nH,cConfig)

				If !lOk
					conout("Falha porta")
					FWAlertWarning("Falha ao conectar com a porta serial. Verifique se a balança está ligada!", "Aviso")
				EndIf
			EndIf

			If lOk
				//Inicializa balança
				MsWrite(nH,CHR(5))
				nTaman := 16

				//Realiza a leitura
				For nX := 1 To 50
					//Obtendo o tempo de espera antes de iniciar a leitura da balança e realiza a leitura
					Sleep(nTempo)
					MSRead(nH,@cBuffer)

					//Obtendo os caracteres inciais
					cBuffer := AllTrim(SubStr(AllTrim(cBuffer),1,nTaman))

					//Se a linha retornada for igual ao tamanho limite
					If Len(AllTrim(cBuffer)) >= nTaman .or. !Empty(cBuffer)
						Exit
					EndIf
				Next nX


				//Verifica onde começa o "q" e soma 2 espaços
				nPosIni := At("q",cBuffer)+2

				//Obtendo apenas o peso da balança
				cPesoLido := SubStr(cBuffer,nPosIni,nPosIni+3)
			EndIf

			//Encerra a conexão com a porta
			MSClosePort(nH,cConfig)
		EndIf

		//Converte o peso obtido para inteiro e o atribui a variavel de retorno
		nPesoRet := Val(cPesoLido) / 1000

		//Outras balanças
	Else
		//Montando a configuração (Porta:Velocidade,Paridade,Bits,Stop)
		cConfig := cPorta+":"+cVelocid+","+cParidade+","+cBits+","+cStopBits

		//Guarda resultado se houve abertura da porta
		lRet := msOpenPort(@nH,cConfig)

		//Se não conseguir abrir a porta, mostra mensagem e finaliza
		If(!lRet)
			//Se for barra, tentar na confiança, depois na jundiai
			MsgStop("<b>Falha</b> ao conectar com a porta serial. Detalhes:"+;
				"<br><b>Porta:</b> "        +cBPorta+;
				"<br><b>Velocidade:</b> "    +cBVeloc+;
				"<br><b>Paridade:</b> "        +cBParid+;
				"<br><b>Bits:</b> "            +cBBits+;
				"<br><b>Stop Bits:</b> "    +cBStop,"Atenção")
			cLido := 0
		EndIf

		//Se estiver OK
		If lRet
			If (cMarca == "JUNDIAI" .Or. cMarca == "CONFIANCA")
				//Mandando mensagem para a porta COM
				msWrite(nH,Chr(5))
				Sleep(nTempo)

				//Pegando o tempo final
				cSegNor:=Time()
				cSegAcr:=SubStr(Time(),1,5)+":"+cValToChar(Val(SubStr(Time(),7,2)) + nTempo)

				If (cMarca == "JUNDIAI")
					//Enquanto os tempos forem diferentes
					While(cSegNor != cSegAcr)
						//Lendo os dados
						msRead(nH,@cBuffer)

						//Se não estiver em branco
						if(!Empty(cBuffer))
							cLido := Alltrim(cBuffer)
						EndIf

						//Atualizando o tempo
						cSegNor:=SubStr(cSegNor,1,5)+":"+cValToChar(Val(SubStr(cSegNor,7,2)) + 1)
					EndDo

					//Senão, se for confiança, enquanto o tamanho for menor, ler o conteúdo
				ElseIf (cMarca == "CONFIANCA")
					cLido := ''
					nCont := 1

					//Enquanto os tempos forem diferentes
					While(Len(cLido) < 16)
						//Lendo os dados
						msRead(nH,@cBuffer)
						Sleep(200)

						//Somando o valor lido com o buffer
						cLido += cBuffer

						//Aumentando o contador
						nCont++
						If nCont >= 30
							If MsgYesNo('Houve <b>30 tentativas</b> de ler o peso, deseja parar?','Atenção')
								cLido:=Space(17)
								Exit
							Else
								nCont := 1
							EndIf
						EndIf

					EndDo
				EndIf

				cLido   := Upper(cLido)
				nPosFim := (At('K',cLido) - 1)

				//Pegando a Posição Inicial
				For nAux:=1 To Len(cLido)
					//Se o caracter atual estiver contido no intervalo de 0 a 9 e ponto
					If(SubStr(cLido,nAux,1) $ '0123456789.')
						nPosIni:=nAux
						Exit
					EndIf
				Next

				nPesoRet := Val(cLido)
			EndIf
		EndIf

		msClosePort(nH,cConfig)
	EndIf
Return nPesoRet
/*/{Protheus.doc} Impetiq
Imprime as etiquetas 1 - Entradas de produtos não pesados / 2 - Etiqueta de separação para a OP
@type function
@version 1.0
@author Jair Matos
@since 23/05/2024
/*/
Static Function Impetiq(cProdCab,cLoteCab,cFase,nPeso,cCodEtiq)

	Local nX 		:= 1
	Local nARes		:= 0
	Local xCopias 	:= 1
	Local nQTDB5 	:= 0
	Local nQTDD1 	:= 0
	Local cTpImp 	:= SuperGetMV("MV_X_IMP", .F., "000001")   //Impressora
	Local cModelo,lTipo,nPortIP,cServer,cEnv,lDrvWin,cPorta


	ZZC->(DbSetOrder(1))
	IF (ZZC->(dbSeek(xFilial("ZZC") + cCodEtiq)))

		DbSelectArea("SB5")
		SB5->(DbSetOrder(1))
		IF SB5->(DBSeek(xFilial("SB5") + ZZC->ZZC_CODPRDD))

			nQTDB5 := SB5->B5_QEI
			nQTDD1 := ZZC->ZZC_QUANT

			if nQTDB5 <> 0
				nARes := MOD(nQTDD1,nQTDB5)
				if nARes > 0
					xcopias :=  (nQTDD1/nQTDB5)
					xcopias := int(xcopias)
					xcopias++
				else
					xcopias :=	(nQTDD1/nQTDB5)

				endif
			else
				xcopias := 1
			endif

		EndIf

		dbSelectArea("CB5")
		CB5->(DbSetOrder(1))
		CB5->(DbSeek(xFilial("CB5")+cTpImp))
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


		MSCBPRINTER(cModelo,cPorta,,,lTipo,nPortIP,cServer,cEnv,nBuffer,cFila,lDrvWin,Trim(CB5->CB5_PATH))
		MSCBCHKSTATUS(CB5->CB5_VERSTA =="1")
		msCbInfoEti("", "")

		//Imprime a etiqueta 1 - Entradas de produtos não pesados
		MSCBBEGIN(1,6)
		cZPL := ""
		cZPL += "^XA""
		cZPL += "^MMT"
		cZPL += "^PW832"
		cZPL += "^LL0960"
		cZPL += "^CF0,75"
		cZPL += "^FO140,150^FD"	+ FWNoAccent(ZZC->ZZC_CODPRD) +"^FS"
		cZPL += "^CF5,30"
		cZPL += "^FO150,230^FD"	+ FWNoAccent(ZZC->ZZC_DESC) +"^FS"
		cZPL += "^CF5,25"
		cZPL += "^FO80,300^FDFORN:^FS"
		cZPL += "^CF5,25"
		cZPL += "^FO170,300^FD"+ FWNoAccent(Posicione("SA2",1,xFilial("SA2")+ZZC->ZZC_FORN+ZZC->ZZC_LOJA,"SA2->A2_NOME")) +"^FS"
		cZPL += "^CF5,25"
		cZPL += "^FO80,330^FDCONTEUDO:^FS"
		cZPL += "^CF0,25"
		cZPL += "^FO250,330^FD"	+ AllTrim( Str( ZZC->ZZC_QUANT-nPeso ) ) + "/" + AllTrim( Str( ZZC->ZZC_QTDORI ) ) + "^FS"
		cZPL += "^CF5,25"
		cZPL += "^FO80,360^FDVOLUME:^FS"
		cZPL += "^CF0,25"
		cZPL += "^FO190,530^FDE0:^FS"
		cZPL +=  "^CF0,30"
		cZPL += "^FO210,360^FD"	+ AllTrim( Str( nX ) ) + "/" + AllTrim( Str( xcopias ) ) + "^FS"
		cZPL += "^FO230,420^BY2"
		cZPL += "^BCN,135,Y,N,N,N"
		cZPL += "^FD" + cCodEtiq + "^FS"
		cZPL += "^CF5,30"
		cZPL += "^FO130,610^FDLOTE:^FS"
		cZPL += "^CF0,40"
		cZPL += "^FO80,640^FD"	+ FWNoAccent(ZZC->ZZC_LOTE) +"^FS"
		cZPL += "^CF5,30"
		cZPL += "^FO610,610^FDVAL:^FS"
		cZPL += "^CF0,40"
		cZPL += "^FO530,640^FD"	+ AllTrim( Substr( DTOS(ZZC->ZZC_DTVLD),7,2 ) ) + "-" + AllTrim( Substr( DTOS(ZZC->ZZC_DTVLD),5,2 ) ) + "-" + AllTrim( Substr( DTOS(ZZC->ZZC_DTVLD),1,4 ) ) +"^FS"
		cZPL += "^XZ"
		MscbWrite( cZPL )
		msCbEnd()

		//Imprime a etiqueta 2 - Etiqueta de separação para a OP
		MSCBBEGIN(1,6)
		cZPL := "^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^JMA^PR4,4~SD15^JUS^LRN^CI0^XZ"+CRLF
		cZPL += "^XA"+CRLF
		cZPL += "^MMT"+CRLF
		cZPL += "^PW1199"+CRLF
		cZPL += "^LL0799"+CRLF
		cZPL += "^LS0"+CRLF
		cZPL += "^FT164,91^A0N,79,74^FB947,1,0,C^FH\^FD"+FWNoAccent(ZZC->ZZC_CODPRD)+"^FS"+CRLF
		cZPL += "^FT278,157^ACN,28,28^FH\^FD" + FWNoAccent(ZZC->ZZC_DESC) + "^FS"+CRLF
		cZPL += "^FT297,206^ACN,36,20^FH\^FDPESO: ^FS"+CRLF
		cZPL += "^FT422,206^A0N,36,36^FH\^FD" + Alltrim(Str(nPeso)) + "^FS"+CRLF
		cZPL += "^FT597,206^ACN,36,20^FH\^FDFASE:^FS"+CRLF
		cZPL += "^FT707,206^A0N,36,36^FH\^FD" + cFase + "^FS"+CRLF
		cZPL += "^FT237,332^ACN,36,20^FH\^FDCOD GRANEL:^FS"+CRLF
		cZPL += "^FT503,332^A0N,36,36^FH\^FD" + FWNoAccent(AllTrim(cProdCab)) + "^FS"+CRLF
		cZPL += "^FT237,392^ACN,36,20^FH\^FDLOTE GRANEL:^FS"+CRLF
		cZPL += "^FT137,392^ACN,36,20^FH\^FDE2^FS"+CRLF
		cZPL += "^FT523,392^A0N,54,52^FH\^FD" +AllTrim(cLoteCab)+ "^FS"+CRLF
		cZPL += "^FT237,460^ACN,36,20^FH\^FDLOTE MP:^FS"+CRLF
		cZPL += "^FT433,460^A0N,54,52^FH\^FD" + FWNoAccent(ZZC->ZZC_LOTE)+ "^FS"+CRLF
		cZPL += "^BY3,3,140^FT450,680^BCN,,Y,N"+CRLF
		cZPL += "^FD>:" + cCodEtiq + "^FS"+CRLF
		cZPL += "^PQ1,0,1,Y^XZ"+CRLF
		MscbWrite( cZPL )
		msCbEnd()

	ENDIF

	msCbClosePrinter()

Return
