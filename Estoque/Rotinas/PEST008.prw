#INCLUDE "TOTVS.CH"

#INCLUDE "PROTHEUS.CH"
#include "TbiConn.ch"
#INCLUDE "topconn.ch"
/*/{Protheus.doc} PEST007
Wizard de impressão para etiquetas AVULSAS - modulo ESTOQUE
@type function
@version 1.0
@author Jair Matos
@since 09/07/2024
/*/
User function PEST008()

	Local oNewPag
	Local cNf       := ""
	Local cSer      := ""
	Local cFornec   := ""
	Local cLoja     := ""
	Local cProduto  := ""
	Local cCombo1   := ""
	Local nRadio    := ""
	Local oStepWiz  := nil
	Local oDlg      := nil
	Local oPanelBkg
	Private nCount  := 0
	Private lGerEtiq:= .F.
	Private lNewEtiq:= .F.

	oDlg := MSDialog():New(0,0,650, 800,'Wizard de Impressão de Etiquetas',,,,nOr(WS_VISIBLE,WS_POPUP),CLR_BLACK,CLR_WHITE,,,.T.,,,,.F.)
	oPanelBkg:= tPanel():New(20,70,"",oDlg,,,,,,300,300)
	oStepWiz:= FWWizardControl():New(oPanelBkg)//Instancia a classe FWWizard
	oStepWiz:ActiveUISteps()
//----------------------
// Pagina 1
//----------------------
	oNewPag := oStepWiz:AddStep("1")
	oNewPag:SetStepDescription("Primeiro passo")
	oNewPag:SetConstruction({|Panel|cria_pg1(Panel,@cCombo1)})
	oNewPag:SetNextAction({||valida_pg1(@cCombo1)})
	oNewPag:SetCancelAction({||oDlg:end(), .T.})
//----------------------
// Pagina 2
//----------------------
	oNewPag := oStepWiz:AddStep("2", {|Panel|cria_pg2(Panel, @nRadio)})
	oNewPag:SetStepDescription("Segundo passo")
	oNewPag:SetNextAction({||valida_pg2(@nRadio)})
	oNewPag:SetCancelAction({||oDlg:end(), .T.})
//----------------------
// Pagina 3
//----------------------
	oNewPag := oStepWiz:AddStep("3", {|Panel|cria_pg3(Panel,@cNf,@cSer,@cFornec,@cLoja,@cProduto)})
	oNewPag:SetStepDescription("Terceiro passo")
	oNewPag:SetNextAction({||valida_pg3(@cNf, @cSer, @cFornec, @cLoja,@cProduto)})
	oNewPag:SetCancelAction({||oDlg:end(), .T.})
//----------------------
// Pagina 4 FIM
//----------------------	    
	oNewPag := oStepWiz:AddStep("4", {|Panel|cria_pg4(Panel)})
	oNewPag:SetStepDescription("Quarto passo")
	oNewPag:SetNextAction({||oDlg:end(),.T.})
	oStepWiz:Activate()
	Activate MsDialog oDlg Center
	oStepWiz:Destroy()
Return
/*/{Protheus.doc} cria_pg1
Construção da página 1
@type function
@version 1.0
@author Jair Matos
@since 09/07/2024
@param oPanel, object, objeto painel
@param cCombo1, character, campo Sim / Não
@return variant, lret, true ou false
/*///--------------------------
Static Function cria_pg1(oPanel,cCombo1)

	Local lRet := .T.
	Local aItemEti := {'Sim','Não'}
	Local oCombo1
	cCombo1:= aItemEti[1]

	oSay1:= TSay():New(10,10,{||'Bem Vindo...'},oPanel,,,,,,.T.,,,200,20)
	oSay2:= TSay():New(30,10,{||'Esta rotina tem por objetivo realizar a impressão das etiquetas termicas de identificação de produto no padrão codigo natural/EAN conforme opções disponiveis a seguir.'},oPanel,,,,,,.T.,,,280,20)
	oSay3:= TSay():New(60,10,{||'Etiqueta nova?'},oPanel,,,,,,.T.,,,200,20)
	oCombo1 := TComboBox():New(70,15,{|u|if(PCount()>0,cCombo1:=u,cCombo1)},aItemEti,100,20,oPanel,,{|| },,,,.T.,,,,,,,,,'cCombo1')

Return lRet
/*/{Protheus.doc} valida_pg1
// Validação do botão Próximo da página 1
@type function
@version 1.0
@author Jair Matos
@since 09/07/2024
@param cCombo1, character, campo Sim / Não
@return variant, lret, true ou false
/*///--------------------------
Static Function valida_pg1(cCombo1)
	Local lRet := .T.
	If cCombo1 == 'Sim'
		lNewEtiq := .T.
	EndIf
Return lRet
/*/{Protheus.doc} cria_pg2
Construção da página 2
@type function
@version 1.0
@author Jair Matos
@since 09/07/2024
@param oPanel, object, objeto painel
@param cCombo1, character, campo RADIO 
@return variant, lret, true ou false
/*///--------------------------
Static Function cria_pg2(oPanel, nRadio)

	Local lRet := .T.
	aItemRad := {'Nota Fiscal','Ordem Produção','Separação'}
	nRadio := 1
	oRadio := TRadMenu():New (01,01,aItemRad,,oPanel,,,,,,,,100,12,,,,.T.)
	oRadio:bSetGet := {|u|Iif (PCount()==0,nRadio,nRadio:=u)}

Return lRet
/*/{Protheus.doc} valida_pg2
// Validação do botão Próximo da página 2
@type function
@version 1.0
@author Jair Matos
@since 09/07/2024
@param nRadio, character, campo radio
@return variant, lret, true ou false
/*///--------------------------
Static Function valida_pg2(nRadio)

	Local lRet := .T.
	If nRadio != 1
		FWAlertWarning("Esta opção ainda está em desenvolvimento", "Imprimir Etiqueta")
		lRet := .F.
	EndIf

Return lRet
/*/{Protheus.doc} cria_pg3
Construção da página 3
@type function
@version 1.0
@author Jair Matos
@since 09/07/2024
@param oPanel, object, objeto painel
@return variant, lret, true ou false
/*///--------------------------
Static Function cria_pg3(oPanel,cNf,cSer,cFornec,cLoja,cProduto)

	Local lRet := .T.
	Local oTGet1
	Local oTGet2
	oSay1:= TSay():New(10,10,{||'Nota Fiscal'},oPanel,,,,,,.T.,,,200,20)
	cNf := Space(TamSx3("D1_DOC")[1])
	oTGet1 := TGet():New( 20,10,{|u| if( PCount() > 0, cNf := u, cNf ) } ,oPanel,096,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cNf,,,, )
	oTGet1:cF3:= 'SF1'
	oSay2:= TSay():New(40,10,{||'Serie'},oPanel,,,,,,.T.,,,50,20)
	cSer := Space(TamSx3("D1_SERIE")[1])
	oTGet2 := TGet():New( 50,10,{|u| if( PCount() > 0, cSer := u, cSer ) },oPanel,026,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cSer,,,, )
	oSay3:= TSay():New(70,10,{||'Fornecedor'},oPanel,,,,,,.T.,,,100,20)
	cFornec := Space(TamSx3("D1_FORNECE")[1])
	oTGet3 := TGet():New( 80,10,{|u| if( PCount() > 0, cFornec := u, cFornec ) },oPanel,052,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cFornec,,,, )
	//oTGet3:cF3:= 'SA2'
	oSay4:= TSay():New(100,10,{||'Loja'},oPanel,,,,,,.T.,,,50,20)
	cLoja := Space(TamSx3("D1_LOJA")[1])
	oTGet4 := TGet():New( 110,10,{|u| if( PCount() > 0, cLoja := u, cLoja ) },oPanel,026,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cLoja,,,, )
	oSay5:= TSay():New(130,10,{||'Produto'},oPanel,,,,,,.T.,,,200,20)
	cProduto := Space(TamSx3("D1_COD")[1])
	oTGet4 := TGet():New( 140,10,{|u| if( PCount() > 0, cProduto := u, cProduto ) },oPanel,096,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cProduto,,,, )
	oTGet4:cF3:= 'SB1'

Return lRet
/*/{Protheus.doc} valida_pg3
// Validação do botão Próximo da página 3
@type function
@version 1.0
@author Jair Matos
@since 09/07/2024
@return variant, lret, true ou false
/*///--------------------------
Static Function valida_pg3(cNf,cSer,cFornec,cLoja,cProduto)

	Local lRet  := .T.
	Local cQuery	:= ""
	local cAliasZZC	:= getNextAlias()

	If Empty(cNf)
		FWAlertWarning("Preencha o campo Nota Fiscal para prosseguir.", "Atenção")
		Return lRet := .F.
	EndIf

	cQuery := " SELECT  ZZC_CODETI FROM "+RetSQLName("ZZC")+" WHERE D_E_L_E_T_ <> '*' AND ZZC_NFENT ='"+cNf+"' "
	cQuery += " AND ZZC_NFSER ='"+cSer+"' AND ZZC_FORN ='"+cFornec+"' AND ZZC_LOJA ='"+cLoja+"' "

	TCQuery cQuery New Alias &cAliasZZC

	If (cAliasZZC)->(!EOF())
		lNewEtiq := .F.
	EndIf

	(cAliasZZC)->(DbCloseArea())


	If MsgYesNo("Deseja gerar a impressão das etiquetas do documento <b>"+cNf+"</b>?", "Atenção")
		nCount := 0

		dbSelectArea("SB1")
		SB1->(dbSetOrder(1))

		dbSelectArea("SD1")
		SD1->(dbsetorder(1))
		SD1->(DBSEEK(FWXFILIAL("SD1")+cNf+cSer+cFornec+cLoja))

		While SD1->(!Eof()) .And. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == FWXFILIAL("SD1")+cNf+cSer+cFornec+cLoja

			If !Empty(cProduto) .and. cProduto==SD1->D1_COD
				U_PEMP0201(lNewEtiq)
				lGerEtiq := .T.
				nCount++
			Else
				SB1->(DbSeek(FWXFILIAL("SB1")+SD1->D1_COD))
				U_PEMP0201(lNewEtiq)
				lGerEtiq := .T.
				nCount++
			EndIf

			SD1->(dbskip())

		EndDo

	EndIf

Return lRet
/*/{Protheus.doc} cria_pg4
Construção da página 4
@type function
@version 1.0
@author Jair Matos
@since 09/07/2024
@param oPanel, object, objeto painel
@return variant, lret, true ou false
/*///--------------------------
Static Function cria_pg4(oPanel)

	Local lRet := .T.

	If lGerEtiq
		oSay1:= TSay():New(30,10,{||'Esta rotina foi finalizada com '+cValtochar(nCount)+' registros impressos.'},oPanel,,,,,,.T.,,,280,20)
	Else
		oSay1:= TSay():New(30,10,{||'Rotina foi finalizada com 0 registros impressos.'},oPanel,,,,,,.T.,,,280,20)
	EndIf

Return lRet
