#INCLUDE "protheus.ch"
#INCLUDE "APVT100.CH"
#INCLUDE "topconn.ch"
/*/{Protheus.doc} PACD002
Pasteur - Pesagem Balança.
@type function
@version 1.0
@author Jair Matos
@since 22/05/2024
/*/
User Function PACD002()

	Local cQuery	:= ""
	local cAliasZZB	:= getNextAlias()
	Private cReadOP  	:= Space(9)
	Private cCodEtiq	:= Space(10)
	Private lVolta 		:= .F.
	Private lRet 		:= .T.
	Private nTamLote    := TamSX3("B8_LOTECTL")[1]
	Private nTamSLote   := TamSX3("B8_NUMLOTE")[1]
	Private cArmOri     := Space(Tamsx3("B1_LOCPAD") [1])
	Private cEndOri     := Space(TamSX3("BF_LOCALIZ")[1])
	Private cCB0EndOri  := Space(20)
	Private nQtde       := 1
	Private nQtdeProd   := 1
	Private cProduto    := Space(48)
	Private lForcaQtd   :=GetMV("MV_CBFCQTD",,"2") =="1"


	While .t.
		VTClear
		nLin:= -1
		cCodEtiq	:= Space(10)
		@ ++nLin,0 VTSAY "Pesagem"
		If !lVolta
			If ! GetPes()
				Exit
			EndIf
		EndIf

		If !fVldOP()

			cQuery := " SELECT * FROM "+RetSQLName("ZZB")+" WHERE D_E_L_E_T_ <> '*' AND ZZB_FILIAL ='"+xFilial("ZZA")+"' AND ZZB_NUMPES ='"+cReadOP+"' AND ZZB_ETIQ = '' "

			TCQuery cQuery New Alias &cAliasZZB

			If (cAliasZZB)->(!EOF()) .and. VTYesNo("A pesagem foi finalizada completamente. Deseja sair da rotina ?","Atencao")

				Exit

			Else
			
				ZZA->(dbSetOrder(1))
				ZZA->(dbSeek(xFilial("ZZA")+cReadOP))
				Reclock("ZZA", .F.)
				ZZA->ZZA_DTFIM 	:= date()
				ZZA->ZZA_HORAF  := Time()
				ZZA->ZZA_STATUS := "F"
				MsUnLock()
				VtAlert("Pesagem foi finalizada!", "Aviso",.t.,4000,4)
				Exit

			EndIf

		EndIf



	End

Return
/*/{Protheus.doc} GetPes
Verifica se a etiqueta lida existe
@type function
@version 1.0	  
@author Jair Matos	
@since 22/05/2024
@return variant, true or false
/*/
Static Function GetPes()
	Local lRet := .T.
	@ ++nLin,0 VtSay "Codigo da Pesagem"
	@ ++nLin,0 VTGET cReadOP Pict "@!" F3 "ZZA1" Valid VldPesa() when Empty(cReadOP)
	VTRead()

	If VTLastkey() == 27
		lRet := .F.
	EndIf

	If lRet
		VTClear(1,0,2,19)
		nLin := 0
	EndIf

Return lRet

Static Function VldPesa()
	Local lRet := .T.

	If Empty(cReadOP)
		VtAlert("Ordem de Pesagem invalida!", "Aviso",.t.,4000,4)
		VTKeyboard(chr(20))
		lRet := .F.
	Else
		dbSelectArea("ZZA")
		ZZA->(DbSetOrder(1))
		If ZZA->(DbSeek(xFilial("ZZA")+cReadOP))
			If ZZA_STATUS!="A"
				VtAlert("Ordem de Pesagem "+cReadOP+" deve estar com Status='A'", "Aviso",.t.,4000,4)
				lRet := .F.
			EndIf
		Else
			lRet := .F.
			VtAlert("Ordem de Pesagem invalida", "Aviso",.t.,4000,4)
		EndIf
	EndIF

Return lRet
/*/{Protheus.doc} fVldOP
Valida o codigo da etiqueta que será lida pelo leitor ou digitada pelo usuario
@type function
@version 1.0
@author Jair Matos
@since 10/05/2024
@return variant, lret
/*/
Static function fVldOP()
	Local lRet 		:= .F.
	Local nCount	:= 0
	Local nCont		:= 1
	Local cQuery	:= ""
	local cAliasZZB	:= getNextAlias()
	cQuery := " SELECT * FROM "+RetSQLName("ZZA")+" ZZA"
	cQuery += " INNER JOIN "+RetSQLName("ZZB")+" ZZB ON ZZB_FILIAL = ZZA_FILIAL AND ZZB_NUMPES = ZZA_NUMPES AND ZZB.D_E_L_E_T_ <> '*' "
	cQuery += " WHERE ZZA.D_E_L_E_T_ <> '*' AND ZZA_FILIAL ='"+xFilial("ZZA")+"' "
	cQuery += "AND ZZA_NUMPES ='"+cReadOP+"' "
	cQuery += "AND ZZB_STATUS ='Aguardando Pesagem' "
	cQuery += "ORDER BY ZZB_CODPRD "

	TCQuery cQuery New Alias &cAliasZZB
	If (cAliasZZB)->(!EOF())
		Count To nCount
		(cAliasZZB)->(DbGoTop())
		While (cAliasZZB)->(!Eof())
			@ ++nLin,0 VtSay "Item.:"+cValtochar(nCont)
			@ ++nLin,0 VtSay "Prod.:"+(cAliasZZB)->ZZB_CODPRD
			@ ++nLin,0 VtSay "Arm.:"+(cAliasZZB)->ZZB_LOCAL
			@ ++nLin,0 VtSay "Lote.:"+(cAliasZZB)->ZZB_LOTE
			@ ++nLin,0 VtSay "Quant.:"+cValtochar((cAliasZZB)->ZZB_QUANT)
			@ ++nLin,0 VtSay "Leia a Etiqueta"
			@ ++nLin,0 VTGet cCodEtiq pict '@!' Valid lRet := fRetEtiq(cAliasZZB,cValtochar(nCont),@nCont) when Empty(cCodEtiq)
			VTRead()


			If nCount != nCont
				If VTLastkey() == 27
					If	VTYesNo("Deseja mudar o produto?","Atencao")
						VTClear
						nLin:= -1
						nCont++
						@ ++nLin,0 VTSAY "Pesagem"
						(cAliasZZB)->(dbSkip())
					EndIf
				EndIf
			else
				lRet := .F.
				VTClear
				Exit
			EndIf

			nLin:= -1
			cCodEtiq := Space(10)
			@ ++nLin,0 VTSAY "Pesagem"

		EndDO
		(cAliasZZB)->(DbCloseArea())
	EndIf

Return lRet
Static Function fRetEtiq(cAliasZZB,cItemNNT,nCont)
	Local aArea 		:= FWGetArea()
	Local lRet			:= .T.
	Local nPesolido		:= 0
	Local cQuery		:= ""
	Local nQtdZZB		:= (cAliasZZB)->ZZB_QUANT
	local cAliasZZC		:= getNextAlias()

	If (cAliasZZB)->ZZB_QTDPES > 0
		VtAlert("Este Item ja foi pesado!", "Aviso",.t.,1000,2)
		Return .F.
	EndIf

	cQuery := " SELECT * FROM "+RetSQLName("ZZC")
	cQuery += " WHERE D_E_L_E_T_ <> '*' AND ZZC_FILIAL ='"+xFilial("ZZC")+"' "
	cQuery += " AND ZZC_CODETI ='"+cCodEtiq+"' "
	cQuery += " AND ZZC_CODPRD ='"+(cAliasZZB)->ZZB_CODPRD+"' "
	cQuery += " AND ZZC_LOCAL  ='"+(cAliasZZB)->ZZB_LOCAL+"' "
	cQuery += " AND ZZC_LOTE   ='"+(cAliasZZB)->ZZB_LOTE+"' "

	TCQuery cQuery New Alias &cAliasZZC
	If (cAliasZZC)->(EOF())
		VtAlert("Etiqueta "+cCodEtiq+" nao existe para os dados da pesagem!", "Aviso",.t.,2000,2)
		lRet := .F.
	EndIf

	If lRet

		VTMSG("Aguarde pesagem")
		nPesolido := LeBalan()
		If nPesolido = 0
			VtAlert("Balanca esta desligada", "Aviso",.t.,2000,2)
		Else

			nPesolido := nQtdZZB
			//verifica se a quantidade pesada <> ZZB_QUANT
			If nPesolido > nQtdZZB
				VtAlert("Quantidade maior do que o empenho, favor ajustar! Qtde pesada:"+Alltrim(transform(nPesolido,"@E 999.999"))+" ,Qtde necessaria:"+ AllTrim(cValtochar(nQtdZZB)),"Aviso",.t.,4000,2)
				lRet :=.F.
				//VTClear
			elseIf nPesolido < nQtdZZB
				VtAlert("Quantidade menor do que o empenho, favor ajustar!Qtde pesada:"+Alltrim(transform(nPesolido,"@E 999.999"))+" ,Qtde necessaria:"+ AllTrim(cValtochar(nQtdZZB)), "Aviso",.t.,4000,2)
				lRet :=.F.
				//VTClear
			EndIf

			If !lRet
				VTClear
				nLin:= -1
				@ ++nLin,0 VTSAY "Pesagem"
				@ ++nLin,0 VtSay "Item.:"+cValtochar(nCont)
				@ ++nLin,0 VtSay "Prod.:"+(cAliasZZB)->ZZB_CODPRD
				@ ++nLin,0 VtSay "Arm.:"+(cAliasZZB)->ZZB_LOCAL
				@ ++nLin,0 VtSay "Lote.:"+(cAliasZZB)->ZZB_LOTE
				@ ++nLin,0 VtSay "Quant.:"+cValtochar((cAliasZZB)->ZZB_QUANT)
				@ ++nLin,0 VtSay "Leia a Etiqueta"
			Else
				//Grava a quantidade pesada(ZZB_QTDPES), data ini(ZZA_DTINI) e hora ini(ZZA_HORAIN)
				ZZA->(dbSetOrder(1))
				If ZZA->(dbSeek(xFilial("ZZA")+(cAliasZZB)->ZZA_NUMPES))
					Reclock("ZZA", .F.)
					ZZA->ZZA_DTINI 	:= date()
					ZZA->ZZA_HORAIN := Time()
					MsUnLock()

					ZZB->(dbSetOrder(1))
					If ZZB->(dbSeek(xFilial("ZZB")+(cAliasZZB)->ZZA_NUMPES))
						While ZZB->(!Eof()) .And. ZZB->(ZZB_FILIAL+ZZB_NUMPES) == xFilial("ZZB")+(cAliasZZB)->ZZA_NUMPES
							If ZZB->ZZB_CODPRD = (cAliasZZB)->ZZB_CODPRD .and. ZZB->ZZB_LOCAL==(cAliasZZB)->ZZB_LOCAL .and. ZZB->ZZB_END==(cAliasZZB)->ZZB_END .and. ZZB->ZZB_QUANT==(cAliasZZB)->ZZB_QUANT
								Reclock("ZZB", .F.)
								ZZB->ZZB_QTDPES := nPesolido
								ZZB->ZZB_ETIQ := (cAliasZZC)->ZZC_CODETI
								ZZB->ZZB_STATUS := "Pesagem Realizada"
								ZZB->ZZB_USER := __cUserID
								MsUnLock()
							EndIf
							ZZB->(dbSkip())
						EndDO
					EndIf
				EndIf

				//Imprime as Etiqueta
				VTClear
				VTMSG("Imp. etiquetas")
				Impetiq((cAliasZZB)->ZZA_PRDPAI,(cAliasZZB)->ZZA_LOTE,(cAliasZZB)->ZZB_FASE,nPesolido)
				VTClear
			EndIf
		EndIf
	EndIf

	FWRestArea(aArea)

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
				VtAlert("Falha ao conectar com a porta serial!", "Aviso",.t.,4000,4)
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
					VtAlert("Falha ao conectar com a porta serial!", "Aviso",.t.,4000,4)
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
Static Function Impetiq(cProdCab,cLoteCab,cFase,nPesolido)

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
		cZPL += "^FO250,330^FD"	+ AllTrim( Str( ZZC->ZZC_QUANT-nPesolido ) ) + "/" + AllTrim( Str( ZZC->ZZC_QTDORI ) ) + "^FS"
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
		cZPL += "^FT422,206^A0N,36,36^FH\^FD" + Alltrim(Str(nPesolido)) + "^FS"+CRLF
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
