#INCLUDE "protheus.ch"
#INCLUDE "APVT100.CH"
#INCLUDE "topconn.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TBICONN.CH"
/*/{Protheus.doc} PACD001
Pasteur - Transfer para Pesagem 
@type function
@version 1.0
@author Jair Matos
@since 10/05/2024
/*/
User Function PACD001()

	Local nX			:= 0
	Private aDados      := {}
	Private cCodSolic  	:= Space(10)
	Private cCodEtiq	:= Space(10)
	Private lVolta 		:= .F.
	Private lRet 		:= .T.
	Private nTamLote    := TamSX3("B8_LOTECTL")[1]
	Private nTamSLote   := TamSX3("B8_NUMLOTE")[1]
	Private cArmOri     := Space(Tamsx3("B1_LOCPAD") [1])
	Private cEndOri     := Space(TamSX3("BF_LOCALIZ")[1])
	Private cCB0EndOri  := Space(20)
	Private cProduto    := Space(48)
	Private cXOrdPes	:= ""

	While .t.
		VTClear
		nLin:= -1
		cCodEtiq	:= Space(10)
		@ ++nLin,0 VTSAY "Transfer p/ Pesagem"
		If !lVolta
			If ! GetSolTra()
				Exit
			EndIf
		EndIf

		If !fVldEtiq()

			If len(aDados) > 0 .and. VTYesNo("Deseja finalizar a transferencia "+cCodSolic+" ?","Atencao")

				//altera a solicitação de transferencia de produtos
				If	lRet := fGravaNNT("004")

					//Efetiva a solicitação de transferencia de produtos
					IF lRet := fGravaNNT("011")
					
						//Grava os dados do armazem / Altera o STATUS das tabelas ZZA e ZZB e ZZC / altera status da ZZA
						ZZA->(dbSetOrder(1))
						ZZA->(dbSeek(xFilial("ZZA")+cXOrdPes))
						Reclock("ZZA", .F.)
						ZZA->ZZA_STATUS := "R"
						MsUnLock()

						//grava novos itens de acordo com a mata311 e altera status da ZZB
						ZZB->(dbSetOrder(1))
						ZZB->(dbSeek(xFilial("ZZB")+ZZA->ZZA_NUMPES))
						While ZZB->(!Eof()) .And. ZZB->(ZZB_FILIAL+ZZB_NUMPES) == xFilial("ZZB")+ZZA->ZZA_NUMPES

							If  Alltrim(ZZB->ZZB_STATUS) = 'Transf.Solicitada'
								Reclock("ZZB", .F.)
								ZZB->ZZB_STATUS := "Transf.Realizada"
								MsUnLock()
							EndIf
							
							ZZB->(dbSkip())
						EndDO

						//altera armaze da ZZC->zzc_local
						for nX:=1 to len(aDados)
							dbSelectArea("ZZC")
							ZZC->(dbSetOrder(1))
							If ZZC->(dbSeek(xFilial("ZZC")+aDados[nX][8][2]))
								Reclock("ZZC", .F.)
								ZZC->ZZC_LOCAL := aDados[nX][11][2]
								MsUnLock()
							EndIf
						Next nX
					EndIf

					Exit

				EndIf

			EndIf

			If VTYesNo("Deseja sair da rotina ?","Atencao")
				Exit
			EndIf

		EndIf

	End

Return
/*/{Protheus.doc} GetSolTra
Verifica o codigo da solicitação de transferencia
@type function
@version 1.0	  
@author Jair Matos	
@since 10/05/2024
@return variant, true or false
/*/
Static Function GetSolTra()
	Local lRet := .T.
	@ ++nLin,0 VtSay "Codigo Solicitacao"
	@ ++nLin,0 VTGET cCodSolic Pict "@!" F3 "NNS" Valid VldSolic() when Empty(cCodSolic)
	VTRead()

	If VTLastkey() == 27
		lRet := .F.
	EndIf

	If lRet
		VTClear(1,0,2,19)
		nLin := 0
	EndIf

Return lRet

Static Function VldSolic()
	Local lRet := .T.

	If Empty(cCodSolic)
		VtAlert("Codigo de Solicitacao invalido", "Aviso",.t.,4000,4)
		VTKeyboard(chr(20))
		lRet := .F.
	Else
		dbSelectArea("NNS")
		NNS->(DbSetOrder(1))
		If NNS->(DbSeek(xFilial("NNS")+cCodSolic))
			cXOrdPes := NNS->NNS_XORDPS
			If NNS_STATUS!="1"
				VtAlert("Solicitacao "+cCodSolic+" ja foi transferida", "Aviso",.t.,4000,4)
				lRet := .F.
			EndIf
		Else
			lRet := .F.
			VtAlert("Codigo de Solicitacao invalido", "Aviso",.t.,4000,4)
		EndIf
	EndIF

Return lRet
Static Function Informa()
Return
/*/{Protheus.doc} fVldEtiq
Valida o codigo da etiqueta que será lida pelo leitor ou digitada pelo usuario
@type function
@version 1.0
@author Jair Matos
@since 10/05/2024
@return variant, lret
/*/
Static function fVldEtiq()
	Local lRet 		:= .F.
	Local nCount	:= 0
	Local nCont		:= 1
	Local cQuery	:= ""
	local cAliasNNT	:= getNextAlias()
	cQuery := " SELECT * FROM "+RetSQLName("NNT")
	cQuery += " WHERE D_E_L_E_T_ <> '*' AND NNT_FILIAL ='"+xFilial("NNT")+"' "
	cQuery += "AND NNT_COD ='"+cCodSolic+"' "

	TCQuery cQuery New Alias &cAliasNNT
	If (cAliasNNT)->(!EOF())
		Count To nCount
		(cAliasNNT)->(DbGoTop())
		While (cAliasNNT)->(!Eof())
			@ ++nLin,0 VtSay "Item.:"+cValtochar(nCont)
			@ ++nLin,0 VtSay "Prod.:"+(cAliasNNT)->NNT_PROD
			@ ++nLin,0 VtSay "Arm.:"+(cAliasNNT)->NNT_LOCAL
			@ ++nLin,0 VtSay "Lote.:"+(cAliasNNT)->NNT_LOTECT
			@ ++nLin,0 VtSay "Ende.:"+(cAliasNNT)->NNT_LOCALI
			@ ++nLin,0 VtSay "Cod.Etiqueta"
			@ ++nLin,0 VTGet cCodEtiq pict '@!' Valid fRetEtiq(cAliasNNT,cValtochar(nCont)) when Empty(cCodEtiq)
			VTRead()


			If VTLastkey() == 27
				If nCount != nCont .and. len(aDados) >0
					If	VTYesNo("Deseja mudar o produto?","Atencao")
						VTClear
						nLin:= -1
						nCont++
						@ ++nLin,0 VTSAY "Transfer p/ Pesagem"
						(cAliasNNT)->(dbSkip())
					EndIf
				else
					Exit
				EndIf
			EndIf

			nLin:= -1
			cCodEtiq := Space(10)
			@ ++nLin,0 VTSAY "Transfer p/ Pesagem"

		EndDO
		(cAliasNNT)->(DbCloseArea())
	EndIf

Return lRet
Static Function fRetEtiq(cAliasNNT,cItemNNT)
	Local aArea 		:= FWGetArea()
	Local lRet			:= .T.
	Local cQuery		:= ""
	local cAliasZZC	:= getNextAlias()

	If len(aDados) > 0

		If aScan(aDados, {|x| x[8][2] == cCodEtiq  }) >0
			VtAlert("Etiqueta "+cCodEtiq+" ja foi inserida!", "Aviso",.t.,1000,2)
			lRet := .F.
		EndIf
	EndIf

	If lRet

		cQuery := " SELECT * FROM "+RetSQLName("ZZC")
		cQuery += " WHERE D_E_L_E_T_ <> '*' AND ZZC_FILIAL ='"+xFilial("ZZC")+"' "
		cQuery += " AND ZZC_CODETI ='"+cCodEtiq+"' "
		cQuery += " AND ZZC_CODPRD ='"+(cAliasNNT)->NNT_PROD+"' "
		cQuery += " AND ZZC_LOCAL  ='"+(cAliasNNT)->NNT_LOCAL+"' "
		cQuery += " AND ZZC_LOTE   ='"+(cAliasNNT)->NNT_LOTECT+"' "

		TCQuery cQuery New Alias &cAliasZZC
		If (cAliasZZC)->(!EOF())

			GetNNT(cAliasZZC,cAliasNNT,cItemNNT)

			(cAliasZZC)->(DbCloseArea())

			VtAlert("Etiqueta "+cCodEtiq+" inserida!", "Aviso",.t.,1000,2)

		Else
			VtAlert("Etiqueta "+cCodEtiq+" nao existe na tabela ZZC!", "Aviso",.t.,1000,2)
			lRet := .F.
		EndIf

	EndIf

	FWRestArea(aArea)

Return lRet
Static Function GetNNT(cAliasZZC,cAliasNNT,cItemNNT)
	Local lRet 		:= .T.
	Local aLinha	:= {}

	//grava os dados em um array
	AADD(aLinha,{"NNT_FILIAL" 	,(cAliasNNT)->NNT_FILIAL,		Nil	})
	AADD(aLinha,{"NNT_COD" 		,(cAliasNNT)->NNT_COD,			Nil })
	AADD(aLinha,{"NNT_PROD" 	,(cAliasNNT)->NNT_PROD,			Nil })
	AADD(aLinha,{"NNT_LOCAL"	,(cAliasNNT)->NNT_LOCAL,		Nil	})
	aadd(aLinha,{"NNT_QUANT"	,(cAliasNNT)->NNT_QUANT,		Nil	})
	AADD(aLinha,{"NNT_LOCALI"	,(cAliasNNT)->NNT_LOCALI,		Nil	})
	AADD(aLinha,{"NNT_LOTECT"	,(cAliasNNT)->NNT_LOTECT,		Nil	})
	AADD(aLinha,{"ZZC_CODETI"	,(cAliasZZC)->ZZC_CODETI,		Nil })
	AADD(aLinha,{"ZZC_QUANT"	,(cAliasZZC)->ZZC_QUANT,		Nil })
	AADD(aLinha,{"ZZC_ITEM"		,cItemNNT,						Nil })
	AADD(aLinha,{"NNT_LOCLD"	,(cAliasNNT)->NNT_LOCLD,		Nil })
	aadd(aDados,aLinha)
	VTClear()

Return lRet
Static Function fGravaNNT(cOpID)
	Local aArea 		:= FWGetArea()
	Local lRet 			:= .T.
	Local nQtdNNT		:= 0
	Local nX			:= 0
	Local nTotLin		:= 0
	Local nLin			:= 0
	Local cEtqNNT		:= ""
	Local oModel
	Local cProd, cLocal, cLocali, cLoteCT := ""
	Local nQtde			:= 0
	Private lMsErroAuto := .F.
	Private aRotina 	:= MenuDef()
	Private cOpId311    := cOpID // DECLARACAO PARA O REALIZAR A ALTERACAO DA SOLICITACAO - 1 DIA INTEIRO PRA SABER QUE ESTE CAMPO DESBLOQUEIA A ALTERACAO
	Private l311Gtl    := .F.

	dbSelectArea("NNS")
	NNS->(DbSetOrder(1))
	If NNS->(DbSeek(xFilial("NNS") + cCodSolic))

		//carrega o model
		oModel   := FWLoadModel( "MATA311" )

		//Define operação do modelo
		oModel:SetOperation( MODEL_OPERATION_UPDATE )

		//Ativa??o do modelo
		oModel:Activate()

		//-- Preenchimento dos campos da NNT da 1a linha
		oModelGrid := oModel:GetModel( "NNTDETAIL" )

		nTotLin := oModelGrid:Length( .F. )

		If cOpID=="004"

			For nLin := 1 To nTotLin
				//oModelGrid:SetLine(nLin)
				oModelGrid:goLine(nLin)
				nQtde 	:= oModel:GetValue( "NNTDETAIL","NNT_QUANT")
				cProd 	:= oModel:GetValue( "NNTDETAIL","NNT_PROD")
				cLocal 	:= oModel:GetValue( "NNTDETAIL","NNT_LOCAL")
				cLocali := oModel:GetValue( "NNTDETAIL","NNT_LOCALI")
				cLoteCT := oModel:GetValue( "NNTDETAIL","NNT_LOTECT")

				for nX := 1 to len(aDados)
					If aDados[nX][3][2] ==cProd .and.  aDados[nX][4][2]=cLocal .and.  aDados[nX][6][2]=cLocali .and. aDados[nX][7][2]==cLoteCT
						nQtdNNT += 	aDados[nX][9][2]
						cEtqNNT := 	aDados[nX][8][2]
					EndIf
				Next nX

				If Empty(cEtqNNT)
					VtAlert("Produto "+(alltrim(cProd)+"-"+cLocal+"-"+alltrim(cLocali))+" sem etiqueta!", "Aviso",.F.,4000,4)
					lRet := .F.
					Exit
				EndIF

				//Encontrou o valor da quantidade. Faz a alteração do valor.
				If nQtdNNT < nQtde
					VtAlert("Produto "+(alltrim(cProd)+"-"+cLocal+"-"+alltrim(cLocali))+" insuficiente. Qtde lida:"+Alltrim(cValtochar(nQtdNNT))+" ,Qtde necessaria:"+ AllTrim(cValtochar(nQtde)), "Aviso",.F.,5000,4)
					lRet := .F.
					Exit
				EndIf

				oModelGrid:SetValue("NNT_QUANT", nQtdNNT)
				oModelGrid:SetValue("NNT_XCDETI", cEtqNNT)

				nQtdNNT := 	0
				cEtqNNT	:= 	""
			Next nLin

		EndIf

		If lRet

			If ( lRet := oModel:VldData() )
				// Se o dados foram validados faz-se a gravação efetiva dos dados (commit)
				lRet := oModel:CommitData()
			EndIf

			If !lRet
				aLog := oModel:GetErrorMessage() //Recupera o erro do model quando nao passou no VldData
				cMensLog := ''
				//laco para gravar em string cLog conteudo do array aLog
				For nX := 1 to Len(aLog)
					If !Empty(aLog[nX])
						cMensLog += Alltrim(aLog[nX]) + " - "
					EndIf
				Next nX

				lMsErroAuto := .T. //seta variavel private como erro
				conout( cMensLog )
				VTALERT(cMensLog,"Erro",.T.,4000)
				lRet := .F.

			Else
				If cOpID=="004"
					VtAlert("Transferencia de saldo foi gerada corretamente!", "Aviso",.t.,4000,4)
				EndIf
			EndIf

		EndIf

	EndIf

	oModel:DeActivate()
	oModel:Destroy()
	FWRestArea(aArea)

Return lRet
