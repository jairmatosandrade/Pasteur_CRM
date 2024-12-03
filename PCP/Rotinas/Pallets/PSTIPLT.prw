#include "totvs.ch"
#include "fwmvcdef.ch"
#include "fweditpanel.ch"
#include "topconn.ch"
#include "tbiconn.ch"

#define ROTINA_FILE		"Montagem de Pallets"

#define ALIAS_FORM0 			 	"SF2"
#define ALIAS_GRID0 				"SD2"
#define ALIAS_GRID01 				"ZZD"
#define MODELO						"PSTIPLT"
#define ID_MODEL					"VVPSTIPL"
#define TITULO_MODEL				"Montagem de Pallets"
#define TITULO_VIEW					TITULO_MODEL
#define ID_MODEL_FORM0				ALIAS_FORM0+"FORM0"
#define ID_MODEL_GRID0				ALIAS_GRID0+"GRID0"
#define ID_MODEL_GRID1				ALIAS_GRID01+"GRID1"
#define ID_VIEW_FORM0				"VIEW_FORM0"
#define ID_VIEW_GRID0				"VIEW_GRID0"
#define ID_VIEW_GRID1				"VIEW_GRID1"
#define PREFIXO_ALIAS_FORM0			Right(ALIAS_FORM0,02)
#define PREFIXO_ALIAS_GRID0			Right(ALIAS_GRID0,02)
#define PREFIXO_ALIAS_GRID1			Right(ALIAS_GRID01,03)
#define cStatusAtual			"0"

/*/{Protheus.doc} PSTIPLT
Função responsável por apresentar a tela em MVC e efetuar o cadastro dos itens na tabela SF2 E SD2
@type function
@author Vinicius Franceschi
@since 10/01/2024
@version P12
@database MSSQL,Oracle
/*/
User Function PSTIPLT()
	Local cAliasForm		:= ALIAS_FORM0
	Local cModelo			:= MODELO
	Local cTitulo			:= TITULO_VIEW
	Local lRet 				:= .T.

	Private oFwMBrowse		:= Nil
	Private oTMsgBar		:= Nil
	Private oBar			:= Nil
	Private oTGetCodBar		:= Nil

	Private  nCaixaGravada := 0

	oFwMBrowse := FWMBrowse():New()
	oFwMBrowse:SetAlias(cAliasForm)
	oFwMBrowse:SetDescription(cTitulo)
	oFwMBrowse:SetMenuDef(cModelo)

	oFwMBrowse:SetLocate()
	oFwMBrowse:SetAmbiente(.F.)
	oFwMBrowse:SetWalkthru(.T.)
	oFwMBrowse:SetDetails(.T.)
	oFwMBrowse:SetSizeDetails(60)
	oFwMBrowse:SetSizeBrowse(40)
	oFwMBrowse:SetCacheView(.T.)
	oFwMBrowse:SetAttach( .T. )
	oFwMBrowse:SetOpenChart( .T. )
	oFwMBrowse:Activate()

Return lRet

/*/{Protheus.doc} ModelDef
Função que Define o Modelo de Dados do Cadastro
@author Vinicius Franceschi
@since 10/01/2024
@version 1.0
@type function
/*/
Static Function ModelDef()
	Local cIDModel				:= ID_MODEL
	Local cTitulo				:= TITULO_MODEL
	Local cIDModelForm			:= ID_MODEL_FORM0
	Local cIDModel0Grid			:= ID_MODEL_GRID0
	Local cIDMode20Grid			:= ID_MODEL_GRID1
	Local cAliasForm 			:= ALIAS_FORM0
	Local cAlias0Grid 			:= ALIAS_GRID0
	Local cAlias1Grid 			:= ALIAS_GRID01
	Local oStructForm 			:= Nil
	Local oStructGrid			:= Nil
	Local oStruct1Grid			:= Nil
	Local oModel 				:= Nil
	Local bActivate				:= {|oModel| activeForm(oModel) }
	Local bCommit				:= {|oModel| saveForm(oModel)}
	Local bCancel   			:= {|oModel| cancForm(oModel)}
	Local bpreValidacao			:= {|oModel| preValid(oModel)}
	Local bposValidacao			:= {|oModel| posValid(oModel)}
	Local cPrefForm				:= PREFIXO_ALIAS_FORM0
	Local cPref0Grid			:= PREFIXO_ALIAS_GRID0
	Local cPref1Grid			:= PREFIXO_ALIAS_GRID1
	Local cCpoDoc				:= cPrefForm+"_DOC"
	Local cCpoFSerie			:= cPrefForm+"_SERIE"
	Local cCpoFilial			:= cPrefForm+"_FILIAL"
	Local cCpoG0Filial			:= cPref0Grid+"_FILIAL"
	Local cCpoG0Serie			:= cPref0Grid+"_SERIE"
	Local cCpoG0Documento		:= cPref0Grid+"_DOC"
	Local cCpoG0Item			:= cPref0Grid+"_ITEM"
	Local cCpoG1Filial			:= cPref1Grid+"_FILIAL"
	Local cCpoG1Documento		:= cPref1Grid+"_DOC"
	Local cCpoG1Serie   		:= cPref1Grid+"_SERIE"
	Local cCpoG1Item   			:= cPref1Grid+"_ITEM"

	oStructForm		:= FWFormStruct( 1, cAliasForm )
	oStructGrid		:= FWFormStruct( 1, cAlias0Grid )
	oStruct1Grid	:= FWFormStruct( 1, cAlias1Grid )

	oModel	:= MPFormModel():New(cIdModel,bpreValidacao,bposValidacao,bCommit,bCancel)

	//Carga por demanda devido performance
	oModel:SetOnDemand()

	oModel:AddFields( cIDModelForm, /*cOwner*/, oStructForm,/*bpreValidacao*/,/*bposValidacao*/,/*bCarga*/)

	oModel:AddGrid( cIDModel0Grid,cIDModelForm,oStructGrid,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/)
	oModel:AddGrid( cIDMode20Grid,cIDModel0Grid,oStruct1Grid,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/)

	oModel:SetRelation(cIDModel0Grid,{{cCpoG0Filial,cCpoFilial},{cCpoG0Documento,cCpoDoc},{cCpoG0Serie,cCpoFSerie}},(cAlias0Grid)->(IndexKey(1)))
	oModel:GetModel(cIDModel0Grid):SetOptional(.T.)
	oModel:GetModel(cIDModel0Grid):SetMaxLine(9999)
	oModel:GetModel(cIDModel0Grid):SetDescription("Itens da Nota Fiscal")

	oModel:SetRelation(cIDMode20Grid,{{cCpoG1Filial,cCpoFilial},{cCpoG1Documento,cCpoG0Documento},{cCpoG1Serie,cCpoG0Serie},{cCpoG1Item,cCpoG0Item}},(cAlias1Grid)->(IndexKey(4)))
	oModel:GetModel(cIDMode20Grid):SetOptional(.T.)
	oModel:GetModel(cIDMode20Grid):SetMaxLine(9999)
	oModel:GetModel(cIDMode20Grid):SetDescription("SF2")

	oModel:SetActivate(bActivate)
	oModel:SetDescription(cTitulo)
	oModel:SetPrimaryKey( { 'F2_FILIAL', 'F2_DOC', 'F2_SERIE', 'F2_CLIENTE', 'F2_LOJA' } )
	oModel:GetModel(cIDModelForm):SetDescription(cTitulo)

Return oModel

/*/{Protheus.doc} MenuDef
Função que Monta o Menu da Rotina do Cadastro
@author Vinicius Franceschi
@since 10/01/2024
@version 1.0
@type function
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE "Montagem de Pallet"		ACTION "U_MontaPallets()" 	OPERATION 3	 ACCESS 0
	ADD OPTION aRotina TITLE "Manutenção"				ACTION "u_AJUSTAZZD()"		OPERATION 4	 ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar"				ACTION "u_MNTZZD(" + cValToChar(MODEL_OPERATION_VIEW) + ")"	OPERATION 2	 ACCESS 0
	ADD OPTION aRotina TITLE 'Impressão dos Pallets'    ACTION "u_ImprimePallet()"  OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Exclusão de Montagem"		ACTION "u_EXCZZD()"			OPERATION 4	 ACCESS 0
	ADD OPTION aRotina TITLE 'Imprimir Etiqueta'    	ACTION "u_EtiquetaPallet()" OPERATION 4 ACCESS 0

Return aRotina

/*/{Protheus.doc} ViewDef
Função que Cria a Interface do Cadastro
@author Vinicius Franceschi
@since 10/01/2024
@version 1.0
@type function
/*/
Static Function ViewDef()
	Local cModelo				:= MODELO
	Local cIDModelForm			:= ID_MODEL_FORM0
	Local cIDModel0Grid			:= ID_MODEL_GRID0
	Local cIDModel1Grid			:= ID_MODEL_GRID1
	Local cIDViewForm			:= ID_VIEW_FORM0
	Local cIDView0Grid			:= ID_VIEW_GRID0
	Local cIDView1Grid			:= ID_VIEW_GRID1
	Local cAliasForm 			:= ALIAS_FORM0
	Local cAlias0Grid 			:= ALIAS_GRID0
	Local cAlias1Grid 			:= ALIAS_GRID01
	Local oModel 				:= Nil
	Local oStructForm			:= Nil
	Local oStructGrid			:= Nil
	lOCAL oStruct1Grid			:= Nil
	Local oView					:= Nil

	Local cField1 := 'F2_DOC,F2_CLIENTE,F2_LOJA,F2_EMISSAO,F2_EST,F2_FRETE,F2_VALBRUT,F2_VALMERC,F2_DESCONT,F2_VOLUME1'
	Local cField2 := ',F2_ESPECI1,F2_HORA,F2_ESPECIE,F2_PLIQUI,F2_PBRUTO,F2_TRANSP,F2_REDESP,F2_MENNOTA,F2_CLIENT,F2_LOJENT,F2_DTENTR'

	Local cItem1 := 'D2_ITEM,D2_DOC,D2_QUANT,D2_PRCVEN,D2_TOTAL,D2_TES,D2_CF,D2_LOCAL,D2_PEDIDO,D2_ITEMPV,D2_CLIENTE,D2_LOJA'
	Local cItem2 := ',D2_DOC,D2_SERIE,D2_TP,D2_EMISSAO,D2_TIPO,D2_LOTECTL,D2_DTVALID,D2_LOCALIZ,D2_DFABRIC,D2_ETQPLT'

	oModel 			:= FWLoadModel( cModelo )

	oStructForm		:= FWFormStruct( 2, cAliasForm, { |x| Alltrim(x) $ cField1+cField2 })
	oStructGrid 	:= FWFormStruct( 2, cAlias0Grid, { |x| Alltrim(x) $ cItem1+cItem2 })
	oStruct1Grid 	:= FWFormStruct( 2, cAlias1Grid)

	oView 		:= FWFormView():New()
	oPanel 		:= Nil
	oTMsgBar 	:= Nil

	oView:SetModel(oModel)

	oView:AddField(cIDViewForm,oStructForm,cIDModelForm)

	oView:SetViewProperty(cIDViewForm,"SETLAYOUT",{ FF_LAYOUT_VERT_DESCR_TOP , 5 } )

	oView:AddGrid(cIDView0Grid,oStructGrid,cIDModel0Grid)
	oView:AddGrid(cIDView1Grid,oStruct1Grid,cIDModel1Grid)

	oView:AddOtherObject("PAINEL_NAVEGACAO", {|oPanel| defBreadCrumb(oPanel)})
	oView:AddOtherObject("PAINEL_MSG", {|oPanel| defMsgBar(oPanel)})

	oView:CreateHorizontalBox('NAVEGACAO',6)
	oView:CreateHorizontalBox('SUPERIOR',91)
	oView:CreateHorizontalBox('MENSAGENS',3)

	oView:CreateFolder('FOLDER','SUPERIOR')

	oView:AddSheet('FOLDER','SHEET1','Itens da Nota Fiscal')
	oView:CreateHorizontalBox('BOXGRID0', 55, , , 'FOLDER', 'SHEET1')
	oView:CreateHorizontalBox('BOXGRID1', 45, , , 'FOLDER', 'SHEET1')

	oView:AddSheet('FOLDER','SHEET2','Cabeçalho Nota Fiscal')
	oView:CreateHorizontalBox( 'BOXFORM1', 100, , , 'FOLDER', 'SHEET2')

	oView:SetOwnerView('PAINEL_NAVEGACAO','NAVEGACAO')
	oView:SetOwnerView(cIDViewForm,'BOXFORM1')
	oView:SetOwnerView(cIDView0Grid,'BOXGRID0')
	oView:SetOwnerView(cIDView1Grid,'BOXGRID1')
	oView:SetOwnerView('PAINEL_MSG','MENSAGENS')

	oView:SetViewProperty(cIDView0Grid,"ENABLENEWGRID")
	oView:SetViewProperty(cIDView0Grid,"GRIDFILTER")
	oView:SetViewProperty(cIDView0Grid,"GRIDSEEK")

	oView:SetViewProperty(cIDView1Grid,"ENABLENEWGRID")
	oView:SetViewProperty(cIDView1Grid,"GRIDFILTER")
	oView:SetViewProperty(cIDView1Grid,"GRIDSEEK")

	oView:EnableTitleView(cIDViewForm,"Cabeçalho da Nota FIscal")
	oView:EnableTitleView(cIDView0Grid,"Itens da Nota Fiscal")
	oView:EnableTitleView(cIDView1Grid,"Montagem de Pallets")

	If ( INCLUI )
		oView:SetCloseOnOk({|| .T. })
	Else
		oView:SetCloseOnOk({|| .F. })
	Endif

Return oView

/*/{Protheus.doc} MNTZZD
Rotina para Manutenção dos dados gerados como diminuir e aumentar quantidade
@author Vinicius Franceschi
@since 10/01/2024
@version 1.0
@type function
/*/
User Function MNTZZD(nOperation)
	Local cModelo		:= MODELO
	Local cOperacao		:= ""
	Local bAcao			:= {|| }
	Local bCloseOnOK	:= {|| .F. }
	Local bOK			:= {|| .T. }
	Local lRet			:= .F.

	Private VISUALIZAR	:= .F.
	Private INCLUI		:= .F.
	Private ALTERA		:= .F.
	Private EXCLUI		:= .F.
	Private COPIA		:= .F.
	Private nRet		:= 0
	Private cFilBkp		:= cFilAnt

	If ( nOperation == MODEL_OPERATION_VIEW )
		VISUALIZAR := .T.
		cOperacao 	:= "Visualizar"
	ElseIf ( nOperation == MODEL_OPERATION_UPDATE )
		ALTERA 		:= .T.
		cOperacao 	:= "Alteração"
		bCloseOnOK	:= {|| .T. }
	ElseIf ( nOperation == MODEL_OPERATION_DELETE )
		EXCLUI 		:= .T.
		cOperacao 	:= "Exclusão"
		bCloseOnOK	:= {|| .T. }
	ElseIf ( nOperation == MODEL_OPERATION_COPY )
		COPIA 		:= .T.
		cOperacao 	:= "Cópia"
		bCloseOnOK	:= {|| .T. }
	Endif

	bAcao := {|| nRet := FWExecView(cOperacao,'VIEWDEF.' + cModelo, nOperation,  , bCloseOnOK, bOK ) }

	If ( SrvDisplay() .And. !IsBlind() )
		FwMsgRun(, bAcao, "Pasteur", "Carregando..." )
	Else
		Eval(bAcao)
	Endif

	If ( nRet == 0 )
		lRet := .T.
	Endif

	cFilAnt := cFilBkp

Return lRet

/*/{Protheus.doc} EXCZZD
Função que chama a exclusão de montagem dos pallets.
@author Jair Matos
@since 22/04/2024
@version 1.0
@type function
/*/
User Function EXCZZD()
	Local 	lRet 			:= .F.
	Local aArea 			:= FWGetArea()
	Local 	cMontagem		:= ""
	Private cPerg1			:= "XPLT1 "

	Begin Sequence

		nCount := 0

		If Pergunte(cPerg1,.T.)
			cMontagem := MV_PAR01
			DbSelectArea("ZZD")
			ZZD->(dBsetOrder(1)) //ZZD_FILIAL + ZZD_CODM
			IF !ZZD->(dbSeek(FWxFilial("ZZD")+cMontagem))
				FWAlertWarning("Codigo de Montagem "+cMontagem+" não existe ou nao foi preenchido!", "Exclusão de Pallets")
				Break
			EndIf
		Else
			Break
		EndIf

		lRet := zExcluiPallet(cMontagem)

	End Sequence

	FWRestArea(aArea)

Return lRet

/*/{Protheus.doc} activeForm
Função de Validação executada na Ativação do Modelo
@author Vinicius Franceschi
@since 10/01/2024
@version 1.0
@type function
/*/
Static Function activeForm(oModel)
	Local lRet					:= .T.

Return lRet

/*/{Protheus.doc} saveForm
	Função para Salvar os Dados do Cadastro usando MVC
@author Vinicius Franceschi
@since 10/01/2024
@version 1.0
@type function
/*/
Static Function saveForm(oModel)
	Local lRet 			:= .T.

	FWModelActive(oModel)
	lRet := FWFormCommit(oModel)

Return lRet

/*/{Protheus.doc} cancForm
Função executado no Cancelamento da Tela de Cadastro
@author Vinicius Franceschi
@since 10/01/2024
@version 1.0
@type function
/*/
Static Function cancForm(oModel)
	Local nOperation	:= oModel:GetOperation()
	Local lRet			:= .T.

	If ( nOperation == MODEL_OPERATION_INSERT )
		RollBackSX8()
	Endif

Return lRet

/*/{Protheus.doc} preValid
Função para Validar os Dados Antes da Confirmação da Tela do Cadastro
@author Vinicius Franceschi
@since 10/01/2024
@version 1.0
@type function
/*/
Static Function preValid(oModel)
	Local lRet	:= .T.

Return lRet

/*/{Protheus.doc} posValid
Função para Validar os Dados Após Confirmação da Tela de Cadastro - Verifica se pode incluir
@author Vinicius Franceschi
@since 10/01/2024
@version 1.0
@type function
/*/
Static Function posValid(oModel)
	Local lRet					:= .T.

Return lRet

/*/{Protheus.doc} setMsgBar
Apresenta a Mensagem na Barra de Status da Janela
@author Vinicius Franceschi
@since 10/01/2024
@version 1.0
@type function
/*/
Static Function setMsgBar(cMsg,lClear)

	Default cMsg 	:= ""
	Default lClear	:= .F.

	If ( !Empty(cMsg) .Or. lClear ) .And. Type("oTMsgBar") == "O"
		oTMsgBar:SetMsg(cMsg)
	Endif

Return

/*/{Protheus.doc} defBreadCrumb
Monta o Painel de Navegação de Status
@author Vinicius Franceschi
@since 10/01/2024
@version 1.0
@type function
/*/
Static Function defBreadCrumb(oPanel)
	Local oBreadCrumb 	:= Nil
	Local aLevel		:= loadLevels()

	aAdd( aLevel , {cValToChar(Len(aLevel)) , "..."} )
	oBreadCrumb := FWBreadCrumb():New(oPanel,.F.)
	oBreadCrumb:SetAction( {|x| setLevelBreadCrumb( x , aLevel, oBreadCrumb ) } )
	oBreadCrumb:Activate()
	oBreadCrumb:SetPath( aLevel )

Return

/*/{Protheus.doc} defMsgBar
Função que Monta a Barra de Mensagens
@author Vinicius Franceschi
@since 10/01/2024
@version 1.0
@type function
/*/
Static Function defMsgBar(oPanel)

	If ( Type("oTMsgBar") == "U" )
		oTMsgBar := TMsgBar():New(oPanel, "Montagem de Pallets", .F., .F., .F., .F., RGB(116,116,116),, , .F., )
	EndIf

Return

/*/{Protheus.doc} loadLevels
Carrega as Etapas do Processo
@author Vinicius Franceschi
@since 10/01/2024
@version 1.0
@type function
/*/
Static Function loadLevels()
	Local aLevel 			:= {}

	aAdd( aLevel , { "00", "Montagem de Pallets Pasteur" } )

Return aLevel

/*/{Protheus.doc} setLevelBreadCrumb
Aciona Evento no Marcador de Processo
@author Vinicius Franceschi
@since 10/01/2024
@version 1.0
@type function
/*/
Static Function setLevelBreadCrumb(cID, aLevel, oBreadcrumb)
	Local cMsg 				:= ""
	Local cActualID 		:= cStatusAtual

	If ( cID < cActualID )
		cMsg := "Etapa Anterior do Processo."
	ElseIf ( cID == cActualID )
		cMsg := "Etapa Atual do Processo."
	ElseIf ( cID > cActualID )
		cMsg := "Próxima Etapa do Processo."
	EndIf

	setMsgBar(cMsg)

Return

/*/{Protheus.doc} MontaPallets
Rotina para efetuar a montagem de pallets
@author Vinicius Franceschi
@since 10/01/2024
@version 1.0
@type function
/*/
User Function MontaPallets()
	Local aArea 	:= FWGetArea()

	Private cPergunta	:= "ETQPALLET "

	Private cDaNF 		:= ""
	Private cAteNF		:= ""
	Private cCliente	:= ""

	Private dDaDataEmissao	:=  CTOD("  /  /    ")
	Private dAteDataEmissao :=  CTOD("  /  /    ")

	Private lMontagem		:= .F.
	Private lReptPallet		:= .F.
	Private lVez			:= .T.

	Private cCodMontagem	:= ""
	Private cCodPallet		:= ""

	Private cBkpMontagem 	:= ""
	Private cBkpPallet 		:= ""

	Begin Sequence

		If  !Pergunte(cPergunta,.T.)
			Break
		Else
			cDaNF 			:= MV_PAR01
			cAteNF 			:= MV_PAR02
			dDaDataEmissao 	:= MV_PAR03
			dAteDataEmissao := MV_PAR04
			cCliente 		:= MV_PAR05
			cLoja 			:= MV_PAR06

			TelaMarkBrowse()
		EndIf

	End Sequence

	FWRestArea(aArea)
Return

/*/{Protheus.doc} TelaMarkBrowse
Monta a tela com a marcação de dados
@author Vinicius Franceschi
@since 10/01/2024
@version 1.0
@type function
/*/
Static Function TelaMarkBrowse()
	Local aArea         := FWGetArea()
	Local oTempTable := Nil
	Local aColunas := {}
	Local  aCampos := {}
	Local cFontPad    := 'Tahoma'
	Local oFontGrid   := TFont():New(cFontPad,,-14)

	//Janela e componentes
	Private oDlgMark
	Private oPanGrid
	Private oMarkBrowse
	Private cAliasTmp := GetNextAlias()
	Private aRotina   := MenuDef1() //menudef de dentro do MarkBrowse

	//Tamanho da janela
	Private aTamanho := MsAdvSize()
	Private nJanLarg := aTamanho[5]
	Private nJanAltu := aTamanho[6]
	Private cVez := 0

	If cVez == 1
		cAliasTmp := GetNextAlias()
	Endif

	If select ("QRYDADTMP") > 0
		QRYDADTMP->(DbCloseArea())
	Endif

	aAdd(aCampos, { 'OK', 'C', 2, 0}) //Flag para marcação
	aAdd(aCampos, { 'D2_DOC'	,TamSx3("D2_DOC")[3]	, TamSx3("D2_DOC")[1]		, TamSx3("D2_DOC")[2]})
	aAdd(aCampos, { 'D2_SERIE'	,TamSx3("D2_SERIE")[3]	, TamSx3("D2_SERIE")[1]		, TamSx3("D2_SERIE")[2]})
	aAdd(aCampos, { 'D2_ITEM'	,TamSx3("D2_ITEM")[3]	, TamSx3("D2_ITEM")[1]		, TamSx3("D2_ITEM")[2]})
	aAdd(aCampos, { 'D2_CLIENTE',TamSx3("D2_CLIENTE")[3], TamSx3("D2_CLIENTE")[1]	, TamSx3("D2_CLIENTE")[2]})
	aAdd(aCampos, { 'D2_LOJA'	,TamSx3("D2_LOJA")[3]	, TamSx3("D2_LOJA")[1]		, TamSx3("D2_LOJA")[2]})
	aAdd(aCampos, { 'A1_NREDUZ'	,TamSx3("A1_NREDUZ")[3]	, TamSx3("A1_NREDUZ")[1]	, TamSx3("A1_NREDUZ")[2]})
	//aAdd(aCampos, { 'ZZD_QTDCX'	,TamSx3("ZZD_QTDCX")[3]	, TamSx3("ZZD_QTDCX")[1]	, TamSx3("ZZD_QTDCX")[2]})
	aAdd(aCampos, { 'D2_QTSEGUM',TamSx3("D2_QTSEGUM")[3], TamSx3("D2_QTSEGUM")[1]	, TamSx3("D2_QTSEGUM")[2]})
	aAdd(aCampos, { 'D2_COD'	,TamSx3("D2_COD")[3]	, TamSx3("D2_COD")[1]		, TamSx3("D2_COD")[2]})
	aAdd(aCampos, { 'B1_DESC'	,TamSx3("B1_DESC")[3]	, TamSx3("B1_DESC")[1]		, TamSx3("B1_DESC")[2]})
	aAdd(aCampos, { 'D2_LOTECTL',TamSx3("D2_LOTECTL")[3], TamSx3("D2_LOTECTL")[1]	, TamSx3("D2_LOTECTL")[2]})
	aAdd(aCampos, { 'D2_DTVALID',TamSx3("D2_DTVALID")[3], TamSx3("D2_DTVALID")[1]	, TamSx3("D2_DTVALID")[2]})
	aAdd(aCampos, { 'F2_TRANSP'	,TamSx3("F2_TRANSP")[3]	, TamSx3("F2_TRANSP")[1]	, TamSx3("F2_TRANSP")[2]})
	aAdd(aCampos, { 'A4_NREDUZ'	,TamSx3("A4_NREDUZ")[3]	, TamSx3("A4_NREDUZ")[1]	, TamSx3("A4_NREDUZ")[2]})

	oTempTable:= FWTemporaryTable():New(cAliasTmp)
	oTempTable:SetFields( aCampos )
	oTempTable:Create()

	//Popula a tabela temporária
	Processa({|| PopulaMarkBrowse()}, 'Processando...')

	//Adiciona as colunas que serão exibidas no FWMarkBrowse
	aColunas := aColsMarkBrowse()

	//Criando a janela
	DEFINE MSDIALOG oDlgMark TITLE ROTINA_FILE FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
	//Dados
	oPanGrid := tPanel():New(001, 001, '', oDlgMark, , , , RGB(000,000,000), RGB(254,254,254), (nJanLarg/2)-1,     (nJanAltu/2 - 1))
	oMarkBrowse := FWMarkBrowse():New()
	oMarkBrowse:SetAlias(cAliasTmp)
	oMarkBrowse:SetDescription(ROTINA_FILE)
	oMarkBrowse:DisableFilter()
	oMarkBrowse:DisableConfig()
	oMarkBrowse:DisableSeek()
	oMarkBrowse:DisableReport()
	oMarkBrowse:DisableSaveConfig()
	oMarkBrowse:SetFontBrowse(oFontGrid)
	oMarkBrowse:SetFieldMark('OK')
	oMarkBrowse:SetTemporary(.T.)
	oMarkBrowse:SetColumns(aColunas)
	oMarkBrowse:ForceQuitButton(.T.)

	//oMarkBrowse:AllMark()
	oMarkBrowse:SetOwner(oPanGrid)
	oMarkBrowse:Activate()
	ACTIVATE MsDialog oDlgMark CENTERED

	//Deleta a temporária e desativa a tela de marcação
	oTempTable:Delete()
	oMarkBrowse:DeActivate()

	FWRestArea(aArea)
Return

/*/{Protheus.doc} MenuDef1
Botões usados no FWMarkBrowse
@author Vinicius Franceschi
@since 10/01/2024
@version 1.0
@type function
/*/
Static Function MenuDef1()
	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Continuar'  ACTION 'u_PSTIPLT02'     OPERATION 2 ACCESS 0

Return aRotina

/*/{Protheus.doc} PopulaMarkBrowse
Executa a query SQL e popula essa informação na tabela temporária usada no browse
@author Vinicius Franceschi
@since 10/01/2024
@version 1.0
@type function
/*/
Static Function PopulaMarkBrowse()
	Local cQryDados := ''
	Local nTotal := 0
	Local nAtual := 0

	cQryDados := GetProductsFromNF()
	PLSQuery(cQryDados, 'QRYDADTMP')

	DbSelectArea('QRYDADTMP')
	Count to nTotal
	ProcRegua(nTotal)
	QRYDADTMP->(DbGoTop())

	While ! QRYDADTMP->(EoF())
		nAtual++
		IncProc('Analisando registro ' + cValToChar(nAtual) + ' de ' + cValToChar(nTotal) + '...')

		RecLock(cAliasTmp, .T.)
		(cAliasTmp)->OK 		:= Space(2)
		(cAliasTmp)->D2_DOC 	:= QRYDADTMP->D2_DOC
		(cAliasTmp)->D2_SERIE 	:= QRYDADTMP->D2_SERIE
		(cAliasTmp)->D2_ITEM 	:= QRYDADTMP->D2_ITEM
		(cAliasTmp)->D2_CLIENTE := QRYDADTMP->D2_CLIENTE
		(cAliasTmp)->D2_LOJA 	:= QRYDADTMP->D2_LOJA
		(cAliasTmp)->A1_NREDUZ 	:= Alltrim(QRYDADTMP->A1_NREDUZ)
		(cAliasTmp)->D2_QTSEGUM := QRYDADTMP->D2_QTSEGUM
		(cAliasTmp)->D2_COD 	:= QRYDADTMP->D2_COD
		(cAliasTmp)->B1_DESC 	:= Alltrim(QRYDADTMP->B1_DESC)
		(cAliasTmp)->D2_LOTECTL := QRYDADTMP->D2_LOTECTL
		(cAliasTmp)->D2_DTVALID := QRYDADTMP->D2_DTVALID
		(cAliasTmp)->F2_TRANSP 	:= QRYDADTMP->F2_TRANSP
		(cAliasTmp)->A4_NREDUZ 	:= Alltrim(QRYDADTMP->A4_NREDUZ)

		(cAliasTmp)->(MsUnlock())

		QRYDADTMP->(DbSkip())
	EndDo

	(cAliasTmp)->(DbGoTop())
Return

/*/{Protheus.doc} GetProductsFromNF
Query para efetuar select dos dados da SD2
@author Vinicius Franceschi
@since 10/01/2024
@version 1.0
@type function
/*/
Static Function GetProductsFromNF()
	Local cQuery as Character
	cQuery := ""

	cQuery += "SELECT D2_DOC "+ CRLF
	cQuery += " ,D2_SERIE  "+ CRLF
	cQuery += " ,D2_COD  "+ CRLF
	cQuery += " ,B1_DESC  "+ CRLF
	cQuery += " ,D2_ITEM  "+ CRLF
	cQuery += " ,D2_CLIENTE  "+ CRLF
	cQuery += " ,D2_LOJA  "+ CRLF
	cQuery += " ,A1_NREDUZ  "+ CRLF
	cQuery += " ,D2_QTSEGUM  "+ CRLF
	cQuery += " ,D2_PEDIDO  "+ CRLF
	cQuery += " ,F2_TRANSP  "+ CRLF
	cQuery += " ,A4_NREDUZ  "+ CRLF
	cQuery += " ,D2_LOTECTL  "+ CRLF
	cQuery += " ,D2_DTVALID  "+ CRLF
	cQuery += " ,D2_LOCALIZ  "+ CRLF
	cQuery += "  ,(D2_QTSEGUM - D2_ETQPLT ) SALDOETQ "+ CRLF
	cQuery += " FROM " + CRLF
	cQuery +=  	RetSqlTab("SD2") + CRLF

	cQuery += " INNER JOIN " + retSqlName("SF2") + " SF2 " + CRLF
	cQuery +=  " ON SF2.F2_FILIAL = SD2.D2_FILIAL  "+ CRLF
	cQuery +=  " AND SF2.F2_DOC = SD2.D2_DOC" + CRLF
	cQuery +=  " AND SF2.F2_SERIE = SD2.D2_SERIE" + CRLF
	cQuery +=  " AND SF2.D_E_L_E_T_ = ''" + CRLF

	cQuery += " INNER JOIN " + retSqlName("SB1") + " SB1 " + CRLF
	cQuery +=  " ON SB1.B1_COD = SD2.D2_COD  "+ CRLF
	cQuery +=  " AND SB1.D_E_L_E_T_ = ''" + CRLF

	cQuery += " INNER JOIN " + retSqlName("SA1") + " SA1 " + CRLF
	cQuery +=  " ON SA1.A1_COD = SD2.D2_CLIENTE  "+ CRLF
	cQuery +=  " AND SA1.A1_LOJA = SD2.D2_LOJA" + CRLF
	cQuery +=  " AND SA1.D_E_L_E_T_ = ''" + CRLF

	cQuery += " LEFT JOIN " + retSqlName("SA4") + " SA4 " + CRLF
	cQuery +=  " ON SA4.A4_COD = SF2.F2_TRANSP  "+ CRLF
	cQuery +=  " AND SA4.D_E_L_E_T_ = ''" + CRLF

	cQuery += " WHERE 1=1" + CRLF
	cQuery += " AND" + RetSqlFil("SD2") + CRLF
	cQuery += " AND D2_DOC BETWEEN " +ValToSql(cDaNF) + " AND "+ ValToSql(cAteNF) + CRLF
	cQuery += "	AND D2_EMISSAO BETWEEN" + ValToSql(dDaDataEmissao) + " AND "+ ValToSql(dAteDataEmissao) + CRLF
	cQuery += "	AND D2_CLIENTE = "+ValToSql(cCliente) + CRLF
	cQuery += "	AND D2_LOJA = " + ValToSql(cLoja) + CRLF
	cQuery +="	AND" + RetSqlDel("SD2") + CRLF
	cQuery += "	AND D2_QTSEGUM > D2_ETQPLT "+ CRLF
	cQuery += " ORDER BY D2_DOC, D2_SERIE, D2_ITEM "

Return cQuery

/*/{Protheus.doc} aColsMarkBrowse
Função que gera as colunas usadas no browse (similar ao antigo aHeader)
@author Vinicius Franceschi
@since 10/01/2024
@version 1.0
@type function
/*/
Static Function aColsMarkBrowse()
	Local nAtual	:= 0
	Local aColunas	:= {}
	Local aEstrut 	:= {}
	Local oColumn

	//Adicionando campos que serão mostrados na tela
	//[1] - Campo da Temporaria
	//[2] - Titulo
	//[3] - Tipo
	//[4] - Tamanho
	//[5] - Decimais
	//[6] - Máscara
	//[7] - Editavel
	aAdd(aEstrut, { 'D2_DOC',		'Documento',		TamSx3("D2_DOC")[3]		, TamSx3("D2_DOC")[1]		, TamSx3("D2_DOC")[2]		, X3Picture("D2_DOC")		,.F.})
	aAdd(aEstrut, { 'D2_SERIE',		'Serie',		 	TamSx3("D2_SERIE")[3]	, TamSx3("D2_SERIE")[1]		, TamSx3("D2_SERIE")[2]		, X3Picture("D2_SERIE")		,.F.})
	aAdd(aEstrut, { 'D2_ITEM',		'Item.',			TamSx3("D2_ITEM")[3]	, TamSx3("D2_ITEM")[1]		, TamSx3("D2_ITEM")[2]		, X3Picture("D2_ITEM")		,.F.})
	aAdd(aEstrut, { 'D2_CLIENTE',	'Cliente',			TamSx3("D2_CLIENTE")[3]	, TamSx3("D2_CLIENTE")[1]	, TamSx3("D2_CLIENTE")[2]	, X3Picture("D2_CLIENTE")	,.F.})
	aAdd(aEstrut, { 'D2_LOJA', 		'Loja',				TamSx3("D2_LOJA")[3]	, TamSx3("D2_LOJA")[1]		, TamSx3("D2_LOJA")[2]		, X3Picture("D2_LOJA")		,.F.})
	aAdd(aEstrut, { 'A1_NREDUZ',	'Nome Fantasia',	TamSx3("A1_NREDUZ")[3]	, TamSx3("A1_NREDUZ")[1]	, TamSx3("A1_NREDUZ")[2]	, X3Picture("A1_NREDUZ")	,.F.})
	aAdd(aEstrut, { 'D2_QTSEGUM',	'Seg. Unid. Medida',TamSx3("D2_QTSEGUM")[3]	, TamSx3("D2_QTSEGUM")[1]	, TamSx3("D2_QTSEGUM")[2]	, X3Picture("D2_QTSEGUM")	,.F.})
	aAdd(aEstrut, { 'D2_COD',		'Codigo Produto', 	TamSx3("D2_COD")[3]		, TamSx3("D2_COD")[1]		, TamSx3("D2_COD")[2]		, X3Picture("D2_COD")		,.F.})
	aAdd(aEstrut, { 'B1_DESC',		'Descrição', 		TamSx3("B1_DESC")[3]	, TamSx3("B1_DESC")[1]		, TamSx3("B1_DESC")[2]		, X3Picture("B1_DESC")		,.F.})
	aAdd(aEstrut, { 'D2_LOTECTL',	'Lote', 			TamSx3("D2_LOTECTL")[3]	, TamSx3("D2_LOTECTL")[1]	, TamSx3("D2_LOTECTL")[2]	, X3Picture("D2_LOTECTL")	,.F.})
	aAdd(aEstrut, { 'D2_DTVALID',	'Dt Validade', 		TamSx3("D2_DTVALID")[3]	, TamSx3("D2_DTVALID")[1]	, TamSx3("D2_DTVALID")[2]	, X3Picture("D2_DTVALID")	,.F.})

	For nAtual := 1 To Len(aEstrut)
		oColumn := FWBrwColumn():New()
		oColumn:SetData(&('{|| ' + cAliasTmp + '->' + aEstrut[nAtual][1] +'}'))
		oColumn:SetTitle(aEstrut[nAtual][2])
		oColumn:SetType(aEstrut[nAtual][3])
		oColumn:SetSize(aEstrut[nAtual][4])
		oColumn:SetDecimal(aEstrut[nAtual][5])
		oColumn:SetPicture(aEstrut[nAtual][6])

		aAdd(aColunas, oColumn)
	Next
Return aColunas

/*/{Protheus.doc} User Function PSTIPLT02
Função acionada pelo botão continuar da rotina
@author Vinicius Franceschi
@since 10/01/2024
@version 1.0
@type function
/*/
User Function PSTIPLT02()
	Processa({|| ProcessaDados()}, 'Processando...')
Return

/*/{Protheus.doc} ProcessaDados
Função que percorre os registros da tela
@author Vinicius Franceschi
@since 10/01/2024
@version 1.0
@type function
/*/
Static Function ProcessaDados()
	Local aArea     := FWGetArea()
	Local cMarca    := oMarkBrowse:Mark()
	Local nAtual    := 0
	Local nTotal    := 0
	Private aDadosMarcados := {}

	DbSelectArea(cAliasTmp)
	(cAliasTmp)->(DbGoTop())
	Count To nTotal
	ProcRegua(nTotal)

	(cAliasTmp)->(DbGoTop())
	While ! (cAliasTmp)->(EoF())
		nAtual++
		IncProc('Analisando registro ' + cValToChar(nAtual) + ' de ' + cValToChar(nTotal) + '...')

		If oMarkBrowse:IsMark(cMarca)

			AADD(aDadosMarcados,{(cAliasTmp)->D2_DOC,;
				(cAliasTmp)->D2_SERIE,;
				(cAliasTmp)->D2_ITEM,;
				(cAliasTmp)->D2_CLIENTE,;
				(cAliasTmp)->D2_LOJA,;
				(cAliasTmp)->A1_NREDUZ,;
				(cAliasTmp)->D2_QTSEGUM,;
				(cAliasTmp)->D2_COD,;
				(cAliasTmp)->B1_DESC,;
				(cAliasTmp)->D2_LOTECTL,;
				(cAliasTmp)->D2_DTVALID})
		EndIf
		(cAliasTmp)->(DbSkip())
	EndDo
	TelaFiltrada()
	oDlgMark:End()

	FWRestArea(aArea)
Return

/*/{Protheus.doc} TelaFiltrada
Função para trazer os dados filtrados da tela anterior
@author Vinicius Franceschi
@since 10/01/2024
@version 1.0
@type function
/*/
Static Function TelaFiltrada()
	Local aArea := FWGetArea()
	Local aFields := {}

	Local cFontUti    := "Tahoma"
	Local oFontSub    := TFont():New(cFontUti,,-20)
	Local oFontBtn    := TFont():New(cFontUti,,-14)

	//Janela e componentes
	Private oDlgGrp
	Private oPanGrid
	Private oGetGrid
	Private aColunas := {}
	Private cAliasTab := getNextAlias()

	//Tamanho da janela
	Private    aTamanho := MsAdvSize()
	Private    nJanLarg := aTamanho[5]
	Private    nJanAltu := aTamanho[6]

	If cVez == 1
		cAliasTab := GetNextAlias()
	Endif

	oTempTable := FWTemporaryTable():New(cAliasTab)

	aAdd(aFields, { 'D2_DOC'	,TamSx3("D2_DOC")[3]	, TamSx3("D2_DOC")[1]		, TamSx3("D2_DOC")[2]})
	aAdd(aFields, { 'D2_SERIE'	,TamSx3("D2_SERIE")[3]	, TamSx3("D2_SERIE")[1]		, TamSx3("D2_SERIE")[2]})
	aAdd(aFields, { 'D2_ITEM'	,TamSx3("D2_ITEM")[3]	, TamSx3("D2_ITEM")[1]		, TamSx3("D2_ITEM")[2]})
	aAdd(aFields, { 'D2_CLIENTE',TamSx3("D2_CLIENTE")[3], TamSx3("D2_CLIENTE")[1]	, TamSx3("D2_CLIENTE")[2]})
	aAdd(aFields, { 'D2_LOJA'	,TamSx3("D2_LOJA")[3]	, TamSx3("D2_LOJA")[1]		, TamSx3("D2_LOJA")[2]})
	aAdd(aFields, { 'A1_NREDUZ'	,TamSx3("A1_NREDUZ")[3]	, TamSx3("A1_NREDUZ")[1]	, TamSx3("A1_NREDUZ")[2]})
	aAdd(aFields, { 'ZZD_QTDCX'	,TamSx3("ZZD_QTDCX")[3]	, TamSx3("ZZD_QTDCX")[1]	, TamSx3("ZZD_QTDCX")[2]})
	aAdd(aFields, { 'D2_QTSEGUM',TamSx3("D2_QTSEGUM")[3], TamSx3("D2_QTSEGUM")[1]	, TamSx3("D2_QTSEGUM")[2]})
	aAdd(aFields, { 'D2_ETQPLT ',TamSx3("D2_ETQPLT ")[3], TamSx3("D2_ETQPLT ")[1]	, TamSx3("D2_ETQPLT ")[2]})
	aAdd(aFields, { 'D2_COD'	,TamSx3("D2_COD")[3]	, TamSx3("D2_COD")[1]		, TamSx3("D2_COD")[2]})
	aAdd(aFields, { 'B1_DESC'	,TamSx3("B1_DESC")[3]	, TamSx3("B1_DESC")[1]		, TamSx3("B1_DESC")[2]})
	aAdd(aFields, { 'D2_LOTECTL',TamSx3("D2_LOTECTL")[3], TamSx3("D2_LOTECTL")[1]	, TamSx3("D2_LOTECTL")[2]})
	aAdd(aFields, { 'D2_DTVALID',TamSx3("D2_DTVALID")[3], TamSx3("D2_DTVALID")[1]	, TamSx3("D2_DTVALID")[2]})

	oTempTable:SetFields( aFields )
	oTempTable:AddIndex("1", {"D2_DOC"} )
	oTempTable:Create()

	MontaCabecTemporario()

	//Montando os dados, eles devem ser montados antes de ser criado o FWBrowse
	FWMsgRun(, {|oSay| MontaDadosTemporario(oSay) }, "Processando", "Buscando dados")

	DEFINE MSDIALOG oDlgGrp TITLE " " FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
	//Labels gerais
	@ 004, 003 SAY "Seleção dos Produtos para Montagem"    SIZE 200, 030 FONT oFontSub  OF oDlgGrp COLORS RGB(031,073,125) PIXEL

	//Botões
	@ 006, (nJanLarg/2-055)-(0052*01) BUTTON oBtnOk  PROMPT "Criar Pallet" SIZE 050, 018 OF oDlgGrp ACTION (CriaZZD())   FONT oFontBtn PIXEL
	@ 006, (nJanLarg/2-001)-(0052*01) BUTTON oBtnFech  PROMPT "Cancelar" SIZE 050, 018 OF oDlgGrp ACTION (oDlgGrp:End())   FONT oFontBtn PIXEL

	//Dados
	@ 023, 003 GROUP oGrpDad TO (nJanAltu/2-003), (nJanLarg/2-003) PROMPT "Preencha a 'Quantidade de Caixas' e clique em 'Criar o Pallet' para finalizar a montagem" OF oDlgGrp COLOR 0, 16777215 PIXEL
	oGrpDad:oFont := oFontBtn
	oPanGrid := tPanel():New(033, 006, "", oDlgGrp, , , , RGB(000,000,000), RGB(254,254,254), (nJanLarg/2 - 13),     (nJanAltu/2 - 45))
	oGetGrid := FWBrowse():New()
	oGetGrid:DisableFilter()
	oGetGrid:DisableConfig()
	oGetGrid:DisableReport()
	oGetGrid:DisableSeek()
	oGetGrid:DisableSaveConfig()
	oGetGrid:SetFontBrowse(oFontBtn)
	oGetGrid:SetAlias(cAliasTab)
	oGetGrid:SetDataTable()
	oGetGrid:SetEditCell(.T., {|| .T.})
	oGetGrid:lHeaderClick := .F.
	oGetGrid:AddLegend(cAliasTab + "->ZZD_QTDCX == 0"			, "YELLOW", "Quantidade Pendente de Digitação")
	oGetGrid:AddLegend(cAliasTab + "->ZZD_QTDCX >  D2_ETQPLT"	, "RED",    "Quantidade maior que Segunda Unidade Medida")
	oGetGrid:AddLegend(cAliasTab + "->ZZD_QTDCX <=  D2_ETQPLT"	, "GREEN",  "Quantidade Ok")
	oGetGrid:SetColumns(aColunas)
	oGetGrid:SetOwner(oPanGrid)
	oGetGrid:Activate()
	ACTIVATE MsDialog oDlgGrp CENTERED

	FWRestArea(aArea)
Return

/*/{Protheus.doc} MontaCabecTemporario
Monta o cabecalho da segunda tela filtrada
@author Vinicius Franceschi
@since 10/01/2024
@version 1.0
@type function
/*/
Static Function MontaCabecTemporario()
	Local nAtual
	Local aHeadAux := {}

	//Adicionando colunas
	//[1] - Campo da Temporaria
	//[2] - Titulo
	//[3] - Tipo
	//[4] - Tamanho
	//[5] - Decimais
	//[6] - Máscara
	//[7] - Editável? .T. = sim, .F. = não
	aAdd(aHeadAux, { 'D2_DOC',		'Documento',		TamSx3("D2_DOC")[3]		, TamSx3("D2_DOC")[1]		, TamSx3("D2_DOC")[2]		, X3Picture("D2_DOC")		,.F.})
	aAdd(aHeadAux, { 'D2_SERIE',	'Serie',		 	TamSx3("D2_SERIE")[3]	, TamSx3("D2_SERIE")[1]		, TamSx3("D2_SERIE")[2]		, X3Picture("D2_SERIE")		,.F.})
	aAdd(aHeadAux, { 'D2_ITEM',		'Item.',			TamSx3("D2_ITEM")[3]	, TamSx3("D2_ITEM")[1]		, TamSx3("D2_ITEM")[2]		, X3Picture("D2_ITEM")		,.F.})
	aAdd(aHeadAux, { 'D2_CLIENTE',	'Cliente',			TamSx3("D2_CLIENTE")[3]	, TamSx3("D2_CLIENTE")[1]	, TamSx3("D2_CLIENTE")[2]	, X3Picture("D2_CLIENTE")	,.F.})
	aAdd(aHeadAux, { 'D2_LOJA',		'Loja',				TamSx3("D2_LOJA")[3]	, TamSx3("D2_LOJA")[1]		, TamSx3("D2_LOJA")[2]		, X3Picture("D2_LOJA")		,.F.})
	aAdd(aHeadAux, { 'A1_NREDUZ',	'Nome Fantasia',	TamSx3("A1_NREDUZ")[3]	, TamSx3("A1_NREDUZ")[1]	, TamSx3("A1_NREDUZ")[2]	, X3Picture("A1_NREDUZ")	,.F.})
	aAdd(aHeadAux, { 'ZZD_QTDCX',	'Qtd. Caixas',		TamSx3("ZZD_QTDCX")[3]	, TamSx3("ZZD_QTDCX")[1]	, TamSx3("ZZD_QTDCX")[2]	, X3Picture("ZZD_QTDCX")	,.T.})
	aAdd(aHeadAux, { 'D2_QTSEGUM',	'Seg. Unid. Medida',TamSx3("D2_QTSEGUM")[3]	, TamSx3("D2_QTSEGUM")[1]	, TamSx3("D2_QTSEGUM")[2]	, X3Picture("D2_QTSEGUM")	,.F.})
	aAdd(aHeadAux, { 'D2_ETQPLT ',	'Saldo Caixas',		TamSx3("D2_ETQPLT ")[3]	, TamSx3("D2_ETQPLT ")[1]	, TamSx3("D2_ETQPLT ")[2]	, X3Picture("D2_ETQPLT ")	,.F.})
	aAdd(aHeadAux, { 'D2_COD',		'Codigo Produto', 	TamSx3("D2_COD")[3]		, TamSx3("D2_COD")[1]		, TamSx3("D2_COD")[2]		, X3Picture("D2_COD")		,.F.})
	aAdd(aHeadAux, { 'B1_DESC',		'Descrição', 		TamSx3("B1_DESC")[3]	, TamSx3("B1_DESC")[1]		, TamSx3("B1_DESC")[2]		, X3Picture("B1_DESC")		,.F.})
	aAdd(aHeadAux, { 'D2_LOTECTL',	'Lote', 			TamSx3("D2_LOTECTL")[3]	, TamSx3("D2_LOTECTL")[1]	, TamSx3("D2_LOTECTL")[2]	, X3Picture("D2_LOTECTL")	,.F.})
	aAdd(aHeadAux, { 'D2_DTVALID',	'Dt Validade', 		TamSx3("D2_DTVALID")[3]	, TamSx3("D2_DTVALID")[1]	, TamSx3("D2_DTVALID")[2]	, X3Picture("D2_DTVALID")	,.F.})

	For nAtual := 1 To Len(aHeadAux)
		oColumn := FWBrwColumn():New()
		oColumn:SetData(&("{|| " + cAliasTab + "->" + aHeadAux[nAtual][1] +"}"))
		oColumn:SetTitle(aHeadAux[nAtual][2])
		oColumn:SetType(aHeadAux[nAtual][3])
		oColumn:SetSize(aHeadAux[nAtual][4])
		oColumn:SetDecimal(aHeadAux[nAtual][5])
		oColumn:SetPicture(aHeadAux[nAtual][6])

		If aHeadAux[nAtual][7]
			oColumn:SetEdit(.T.)
			oColumn:SetReadVar(aHeadAux[nAtual][1])
			oColumn:SetValid({|| ValidaAcols()})
		EndIf

		aAdd(aColunas, oColumn)
	Next
Return

/*/{Protheus.doc} ValidaAcols
Funcao para validar o acols quando digita o item a quantidade de caixa
@author Vinicius Franceschi
@since 10/01/2024
@version 1.0
@type function
/*/
Static Function ValidaAcols()
	Local lRet := .T.

	Begin Sequence

		If (cAliasTab)->ZZD_QTDCX > (cAliasTab)->D2_QTSEGUM
			FWAlertError("A quantidade de 'Caixas' não pode ser superior a 'Segunda Unidade de Medida'!", "Atenção!")
			lRet := .F.
			Break
		Endif

		If (cAliasTab)->ZZD_QTDCX > (cAliasTab)->D2_ETQPLT
			FWAlertError("A quantidade de 'Caixas' não pode ser superior ao 'Saldo de Caixas' disponiveis!", "Atenção!")
			lRet := .F.
			Break
		Endif

	End Sequence

Return lRet

/*/{Protheus.doc} MontaDadosTemporario
Monta os dados temporarios com um array
@author Vinicius Franceschi
@since 10/01/2024
@version 1.0
@type function
/*/
Static Function MontaDadosTemporario(oSay)
	Local aArea   := FWGetArea()
	Local nAtual  := 0

	For nAtual := 1 To Len(aDadosMarcados)

		RecLock(cAliasTab, .T.)
		(cAliasTab)->D2_DOC 	:= aDadosMarcados[nAtual][1]
		(cAliasTab)->D2_SERIE 	:= aDadosMarcados[nAtual][2]
		(cAliasTab)->D2_ITEM 	:= aDadosMarcados[nAtual][3]
		(cAliasTab)->D2_CLIENTE := aDadosMarcados[nAtual][4]
		(cAliasTab)->D2_LOJA 	:= aDadosMarcados[nAtual][5]
		(cAliasTab)->A1_NREDUZ 	:= aDadosMarcados[nAtual][6]
		(cAliasTab)->ZZD_QTDCX 	:= 0
		(cAliasTab)->D2_ETQPLT  := RetornaSaldoEtq(nAtual)
		(cAliasTab)->D2_QTSEGUM := aDadosMarcados[nAtual][7]
		(cAliasTab)->D2_COD 	:= aDadosMarcados[nAtual][8]
		(cAliasTab)->B1_DESC 	:= aDadosMarcados[nAtual][9]
		(cAliasTab)->D2_LOTECTL := aDadosMarcados[nAtual][10]
		(cAliasTab)->D2_DTVALID := aDadosMarcados[nAtual][11]

		(cAliasTab)->(MsUnlock())
	Next

	FWRestArea(aArea)
Return

/*/{Protheus.doc} RetornaSaldoEtq
Retorna o saldo da etiqueta que esta no item da SD2
@author Vinicius Franceschi
@since 10/01/2024
@version 1.0
@type function
/*/
Static Function RetornaSaldoEtq(nAtual)
	Local nSaldo := 0

	dBselectarea("SD2")
	SD2->(dbSetOrder(3)) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM

	IF SD2->(dbSeek(FWxFilial("SD2")+aDadosMarcados[nAtual][1]+aDadosMarcados[nAtual][2]+;
			aDadosMarcados[nAtual][4]+aDadosMarcados[nAtual][5]+;
			aDadosMarcados[nAtual][8]+aDadosMarcados[nAtual][3]))

		nSaldo := (SD2->D2_QTSEGUM - SD2->D2_ETQPLT)
	Endif

Return nSaldo

/*/{Protheus.doc} CriaZZD
Funcao para criar dados na tabela ZZD
@author Vinicius Franceschi
@since 10/01/2024
@version 1.0
@type function
/*/
Static Function CriaZZD()
	Local aArea			:= FWGetArea()
	Local cUserCod		:= RetCodUsr()
	Local nOpc			:= 0
	Local cMensagem 	:= "Escolha uma das opções abaixo para continuar:"
	Local aStatusZZD 	:= {}
	Local lRet 			:= .T.
	Local cHelp			:= ""
	Local cPedido		:= ""
	Local nRecno

	Begin Sequence

		If lVez
			cCodMontagem	:= GetLastCodManutencao()
			cCodPallet		:= LastPallet()
		Endif

		DbSelectArea(cAliasTab)
		(cAliasTab)->(DbGoTop())
		While ! (cAliasTab)->(EoF())

			dBselectarea("ZZD")
			ZZD->(dBsetOrder(4)) //ZZD_FILIAL + ZZD_DOC + ZZD_SERIE + ZZD_ITEM

			If (cAliasTab)->ZZD_QTDCX > 0 .AND. (cAliasTab)->ZZD_QTDCX <= (cAliasTab)->D2_ETQPLT
				RecLock('ZZD', .T.)
				ZZD->ZZD_FILIAL	:= FWxFilial("ZZD")

				If lMontagem
					ZZD->ZZD_CODM 	:= cBkpMontagem
					ZZD->ZZD_PALLET	:= cBkpPallet
				Else
					ZZD->ZZD_CODM 	:= cCodMontagem
					ZZD->ZZD_PALLET := cCodPallet
				Endif

				cPedido := Posicione("SD2", 3, FWxFilial("SD2")+(cAliasTab)->D2_DOC+avKey((cAliasTab)->D2_SERIE,"D2_SERIE")+(cAliasTab)->D2_CLIENTE+(cAliasTab)->D2_LOJA+AvKey((cAliasTab)->D2_COD,"D2_COD")+AvKey((cAliasTab)->D2_ITEM,"D2_ITEM"), "D2_PEDIDO") //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM

				ZZD->ZZD_PEDIDO :=  cPedido
				ZZD->ZZD_DOC 	:= (cAliasTab)->D2_DOC
				ZZD->ZZD_SERIE 	:= (cAliasTab)->D2_SERIE
				ZZD->ZZD_ITEM 	:= (cAliasTab)->D2_ITEM
				ZZD->ZZD_CLIENT := (cAliasTab)->D2_CLIENTE
				ZZD->ZZD_LOJA	:= (cAliasTab)->D2_LOJA
				ZZD->ZZD_QTDCX	:= (cAliasTab)->ZZD_QTDCX
				ZZD->ZZD_USER 	:= UsrRetName(cUserCod)
				ZZD->ZZD_CODPRD	:= (cAliasTab)->D2_COD
				ZZD->ZZD_DESC	:= (cAliasTab)->B1_DESC
				ZZD->ZZD_LOTE	:= (cAliasTab)->D2_LOTECTL
				ZZD->(MsUnlock())
				nRecno := ZZD->(RecNo())

				AADD(aStatusZZD,{(cAliasTab)->D2_DOC,;
					(cAliasTab)->D2_SERIE,;
					(cAliasTab)->D2_ITEM,;
					nRecno})

				AtualizaSD2()
			Else
				If (cAliasTab)->ZZD_QTDCX > 0
					cHelp := "O Saldo digitado é maior que a quantidade disponivel!"
					Help("",1,"CriaZZD",,cHelp,1)
					lRet := .F.
					//Break
				Endif
			Endif
			(cAliasTab)->(DbSkip())
		EndDo

		If lRet
			IF (cAliasTab)->(EoF())
				nOpc := Aviso("Atenção", cMensagem, {"Finalizar manutenção", "Continuar montagem"}, 3, "")
			EndIf

			If nOpc == 1 //Finalizar Manutencao
				GravaStatus(aStatusZZD,nOpc)
				oDlgGrp:End()
				cVez := 1
				lMontagem  := .F.
				aStatusZZD := {}
				lVez := .T.

				If MsgYesNo("Deseja imprimir as etiquetas dos pallets?", "Confirma?")
					U_EtiquetaPallet(cCodMontagem,.T.)
				Endif
			
			Else //Continuar Montagem
				GravaStatus(aStatusZZD,nOpc)
				lMontagem 		:= .T.
				cBkpMontagem 	:= cCodMontagem
				cBkpPallet 		:= LastPallet()
				lVez := .F.
				oDlgGrp:End()
				cVez := 1
				TelaMarkBrowse()
			Endif
		Endif

	End Sequence

	FWRestArea(aArea)

Return

/*/{Protheus.doc} AtualizaSD2
Funcao para atualizar a quantidade de etiqueta lida no item da SD2
@author Vinicius Franceschi
@since 10/01/2024
@version 1.0
@type function
/*/
Static Function AtualizaSD2()
	Local nSaldo := 0

	dBselectarea("SD2")
	SD2->(dbSetOrder(3)) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM

	IF SD2->(dbSeek(FWxFilial("SD2")+(cAliasTab)->D2_DOC+(cAliasTab)->D2_SERIE+;
			(cAliasTab)->D2_CLIENTE+(cAliasTab)->D2_LOJA+;
			(cAliasTab)->D2_COD+(cAliasTab)->D2_ITEM))

		If (cAliasTab)->ZZD_QTDCX > 0
			nSaldo := SD2->D2_ETQPLT

			RecLock("SD2", .F.)
			SD2->D2_ETQPLT	:= nSaldo + (cAliasTab)->ZZD_QTDCX
			SD2->(MsUnlock())
		Endif
	Endif
Return

/*/{Protheus.doc} GravaStatus
Funcao para atualizar o status do Pallet na Tabela ZZD
@author Vinicius Franceschi
@since 10/01/2024
@version 1.0
@type function
/*/
Static Function GravaStatus(aStatusZZD,nTipo)
	Default aStatusZZD	:= {}
	Default nTipo		:= 0

	dBselectarea("ZZD")
	ZZD->(dBsetOrder(4)) //ZZD_FILIAL + ZZD_DOC + ZZD_SERIE + ZZD_ITEM
	IF ZZD->(dbSeek(FWxFilial("ZZD")+(cAliasTab)->D2_DOC+(cAliasTab)->D2_SERIE+(cAliasTab)->D2_ITEM))
		If	RecLock('ZZD', .F.)
			If nTipo == 1 //Finalizar Manutencao
				ZZD->ZZD_STATUS	:= "E"
			Endif
		Else //Continuar Editando
			ZZD->ZZD_STATUS	:= "A"
		Endif
		ZZD->(MsUnlock())
	Endif
Return

/*/{Protheus.doc} GetLastCodManutencao
Funcao para pegar o ultimo codigo de retorno da tabela e somar1
@author Vinicius Franceschi
@since 10/01/2024
@version 1.0
@type function
/*/
Static Function GetLastCodManutencao()
	Local aArea		:= FWGetArea()
	Local cRetorno	:= ""
	Local cQuery	:= ""
	Local nTamCampo	:= 0

	Local cTab 		:= "ZZD"
	Local cCampo	:= "ZZD_CODM"

	nTamCampo	:= TamSX3(cCampo)[01]
	cRetorno	:= StrTran(cRetorno, ' ', '0')

	cQuery := " SELECT "
	cQuery += "   ISNULL(MAX("+cCampo+"), '"+cRetorno+"') AS MAXIMO "
	cQuery += " FROM "
	cQuery += "   "+RetSQLName(cTab)+" TAB "
	cQuery := ChangeQuery(cQuery)

	TCQuery cQuery New Alias "QRY_TAB"

	If !Empty(QRY_TAB->MAXIMO)
		cRetorno := QRY_TAB->MAXIMO
	Else
		cRetorno := "000000"
	EndIf

	cRetorno := Soma1(cRetorno)

	QRY_TAB->(DbCloseArea())
	FWRestArea(aArea)

Return cRetorno

/*/{Protheus.doc} LastPallet
Funcao para pegar o ultimo codigo de retorno da tabela e somar1
@author Vinicius Franceschi
@since 10/01/2024
@version 1.0
@type function
/*/
Static Function LastPallet()
	Local aArea		:= FWGetArea()
	Local cRetorno	:= ""
	Local cQuery	:= ""
	Local nTamCampo	:= 0

	Local cTab 		:= "ZZD"
	Local cCampo	:= "ZZD_PALLET"

	nTamCampo	:= TamSX3(cCampo)[01]
	cRetorno	:= StrTran(cRetorno, ' ', '0')

	cQuery := " SELECT "
	cQuery += "   ISNULL(MAX("+cCampo+"), '"+cRetorno+"') AS MAXIMO "
	cQuery += " FROM "
	cQuery += "   "+RetSQLName(cTab)+" TAB "
	cQuery := ChangeQuery(cQuery)

	TCQuery cQuery New Alias "QRY_TAB1"

	If !Empty(QRY_TAB1->MAXIMO)
		cRetorno := QRY_TAB1->MAXIMO
	Else
		cRetorno := "0000000000"
	EndIf

	cRetorno := Soma1(cRetorno)

	QRY_TAB1->(DbCloseArea())
	FWRestArea(aArea)

Return cRetorno

/*/{Protheus.doc} AJUSTAZZD
Funcao para pegar o ultimo codigo de retorno da tabela e somar1
@author Vinicius Franceschi
@since 10/01/2024
@version 1.0
@type function
/*/
user function AJUSTAZZD()
	Local aArea	:= FWGetArea()
	Local cMontagem			:= ""
	Local lRet				:= .F.

	Private oBrowse			:= Nil
	Private cCadastro		:= "Escolha qual montagem de Pallet será alterada: "
	Private cAlias			:= ""
	Private cAlias1			:= ""
	Private oDlg			:= Nil
	Private oTFont 			:= TFont():New('Courier new',,16,.T.)
	Private oTFont1			:= TFont():New('Courier new',,20,.T.)
	Private nMarcados		:= 0
	Private cPerg1			:= "XPLT1 "

	Begin Sequence

		nCount := 0

		If Pergunte(cPerg1,.T.)
			cMontagem := MV_PAR01
			DbSelectArea("ZZD")
			ZZD->(dBsetOrder(1)) //ZZD_FILIAL + ZZD_CODM
			IF !ZZD->(dbSeek(FWxFilial("ZZD")+cMontagem))
				FWAlertWarning("Codigo de Montagem "+cMontagem+" não existe ou nao foi preenchido!", "Impressão Pallets")
				Break
			EndIf
		Else
			Break
		EndIf

		lRet := GeraAlteracao(cMontagem)

	End Sequence

	FWRestArea(aArea)

Return lRet

/*/{Protheus.doc} MarcaDesmarca
Função para marcar/desmarcar todos os registros do grid
@author Vinicius Franceschi
@since 10/01/2024
@version 1.0
@type function
/*/
Static Function MarcaDesmarca(cMarca,lMarcar)
	Local aArea := FWGetArea()
	Local lRet := .T.

	dbSelectArea(cAlias)
	(cAlias)->( dbGoTop() )
	While !(cAlias)->( Eof() )
		RecLock( (cAlias), .F. )
		(cAlias)->TR_OK := IIf( lMarcar, cMarca, '  ' )
		(cAlias)->(MsUnlock() )
		(cAlias)->( dbSkip() )
		If lMarcar
			nMarcados ++
		Endif
	EndDo
	FWRestArea(aArea)
Return lRet

/*/{Protheus.doc} MostraItens
Função para marcar/desmarcar os registros do grid
@author Vinicius Franceschi
@since 10/01/2024
@version 1.0
@type function
/*/
Static Function MostraItens(cMarca,lMarcar)
	Local aArea := FWGetArea()
	Local lRet := .T.

	RecLock( (cAlias), .F. )
	If oBrowse:IsMark()
		(cAlias)->TR_OK := cMarca
		nMarcados ++
	Else
		(cAlias)->TR_OK := '  '
		nMarcados --
	Endif
	(cAlias)->(MsUnlock())
	FWRestArea(aArea)
Return lRet

/*/{Protheus.doc} AdicionaColuna
Função para criar as colunas do grid
@author Vinicius Franceschi
@since 10/01/2024
@version 1.0
@type function
/*/
Static Function AdicionaColuna(cCampo,cTitulo,nArrData,cPicture,nAlign,nSize,nDecimal)
	Local bData 		:= {||}
	Local aColumn		:= {}

	Default nAlign		:= 1
	Default nSize		:= 20
	Default nDecimal	:= 0
	Default nArrData	:= 0

	If nArrData > 0
		bData := &("{||" + cCampo +"}")
	Endif

	aColumn := {cTitulo,bData,,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}
Return{aColumn}


/*/{Protheus.doc} GeraAlteracao
Função para realizar a alteração do Fornecedor + Loja na SB1 e gerar a requisicao com o fornecedor correto
@author Vinicius Franceschi
@since 10/01/2024
@version 1.0
@type function
/*/
Static Function GeraAlteracao(cMontagem)
	Local aArea	:= FWGetArea()
	Local lRet := .F.
	Local cCodigoMontagem := cMontagem

	Begin Sequence

		lRet := u_zGrid(cCodigoMontagem)
	End Sequence
	FWRestArea(aArea)

Return lRet

/*/{Protheus.doc} zExcluiPallet
Rotina para efetivar a exclusao do Pallet
@author Vinicius Franceschi
@since 10/01/2024
@version 1.0
@type function
/*/
Static Function zExcluiPallet(cCodigoMontagem)
	Local cAlias	:= ""
	Local cQuery	:= ""
	Local cDoc		:= ""
	Local cSerie 	:= ""
	Local cItem		:= ""
	Local cCliente	:= ""
	Local cLoja		:= ""
	Local cProduto 	:= ""
	Local cPallet	:= ""
	Local cNomeFantasia := ""
	Local cDescri		:= ""

	Local nSizeDoc		:= 0
	Local nSizeSerie	:= 0
	Local nSizeItem		:= 0
	Local nSizeClient	:= 0
	Local nSizeLoja		:= 0
	Local nSizePrd		:= 0
	Local nSizeNomeCli	:= 0
	Local nSizeDescri	:= 0

	Local nSaldoGravado	:= 0
	Local nItens		:= 0
	Local cVez			:= "1"

	Local aExcluidos	:= {}

	Local nAtIni		:= 1
	Local oListBox
	Local oDlg
	Local oBold

	Local lRet 		:= .F.
	Local lDeletou  := .F.
	Local lExclui	:= .F.

	Default cCodigoMontagem := ""
	Default cPalletMontado	:= ""

	cQuery := getQryExclusao(cCodigoMontagem)

	TCQUERY cQuery NEW ALIAS (cAlias := GetNextAlias())
	DBSelectArea(cAlias)
	(cAlias)->( DBGoTop() )

	nCaixaGravada := 0

	While !(cAlias)->( Eof() )

		cDoc		:= (cAlias)->ZZD_DOC
		cSerie		:= (cAlias)->ZZD_SERIE
		cItem		:= (cAlias)->ZZD_ITEM
		cCliente	:= (cAlias)->ZZD_CLIENT
		cLoja		:= (cAlias)->ZZD_LOJA
		cProduto	:= (cAlias)->ZZD_CODPRD
		cPallet		:= (cAlias)->ZZD_PALLET

		if cVez == "1"
			nSizeDoc 	:= TamSx3("D2_DOC")[1]
			nSizeSerie	:= TamSx3("ZZD_SERIE")[1]
			nSizeItem	:= TamSx3("ZZD_ITEM")[1]
			nSizeClient	:= TamSx3("ZZD_CLIENT")[1]
			nSizeLoja	:= TamSx3("ZZD_LOJA")[1]
			nSizePrd	:= TamSx3("ZZD_CODPRD")[1]
			nSizeNomeCli:= TamSx3("A1_NREDUZ")[1]
			nSizeDescri	:= TamSx3("B1_DESC")[1]
		Endif

		cNomeFantasia 	:= Posicione("SA1",1,FWxFilial("SA1")+ cCliente + cLoja,"SA1->A1_NREDUZ")
		cDescri			:= Posicione("SB1",1,FWxFilial("SB1")+ cProduto,"SB1->B1_DESC")

		aAdd(aExcluidos,{TransForm(cPallet,PesqPict("ZZD","ZZD_PALLET")),;
			TransForm(cProduto,PesqPict("ZZD","ZZD_CODPRD")),;
			TransForm(cDescri,PesqPict("SB1","B1_DESC")),;
			TransForm(cDoc,PesqPict("ZZD","ZZD_DOC")),;
			TransForm(cSerie,PesqPict("ZZD","ZZD_SERIE")),;
			TransForm(cItem,PesqPict("ZZD","ZZD_ITEM")),;
			TransForm(cCliente,PesqPict("ZZD","ZZD_CLIENT")),;
			TransForm(cLoja,PesqPict("ZZD","ZZD_LOJA")),;
			TransForm(cNomeFantasia,PesqPict("SA1","A1_NREDUZ"))})

		cVez := soma1(cVez)
		(cAlias)->( DBSkip() )
	EndDo

	If !Empty(aExcluidos)

		DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD
		DEFINE MSDIALOG oDlg FROM 000,000  TO 250,605 TITLE "Exclusão Montagem : "+Alltrim(cCodigoMontagem)+ " " Of oMainWnd PIXEL

		@ 023,004 To 24,296 Label "" of oDlg PIXEL

		oListBox := TWBrowse():New( 38,2,340,90,,{RetTitle("ZZD_PALLET"),RetTitle("ZZD_CODPRD"),RetTitle("B1_DESC"),RetTitle("ZZD_DOC"),;
			RetTitle("ZZD_SERIE"),RetTitle("ZZD_ITEM"),RetTitle("ZZD_CLIENT"),RetTitle("ZZD_LOJA"),RetTitle("A1_NREDUZ")},;
			{nSizeItem,nSizePrd,/*nSizeDescri*/75,nSizeDoc,nSizeSerie,nSizeClient,nSizeLoja,nSizeNomeCli},oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)

		oListBox:SetArray(aExcluidos)
		oListBox:bLine := { || aExcluidos[oListBox:nAT]}
		oListBox:nAt   := Max(1,nAtIni)

		@ 004,010 SAY SM0->M0_CODIGO+"/"+FWCodFil()+" - "+Alltrim(SM0->M0_FILIAL)+"/"+Alltrim(SM0->M0_NOME)  Of oDlg PIXEL SIZE 245,009
		@ 014,010 SAY "Clique em 'Confirmar' para efetivar a Exclusão, ou 'Fechar' para Cancelar." Of oDlg PIXEL SIZE 245,009 FONT oBold

		@ 004,258  BUTTON "Fechar" 		SIZE 045,010  	FONT oDlg:oFont ACTION (oDlg:End())  OF oDlg PIXEL
		@ 004,212  BUTTON "Confirmar"	SIZE 045,010  	FONT oDlg:oFont ACTION (lExclui := .T.,	oDlg:End())  OF oDlg PIXEL

		ACTIVATE MSDIALOG oDlg CENTERED
	EndIf

	IF lExclui
		For nItens := 1 To Len(aExcluidos)
			DbSelectArea("ZZD")
			ZZD->(dBsetOrder(4)) //ZZD_FILIAL + ZZD_DOC + ZZD_SERIE + ZZD_ITEM
			IF ZZD->(dbSeek(FWxFilial("ZZD")+aExcluidos[nItens][4] + aExcluidos[nItens][5] + aExcluidos[nItens][6]))
				nCaixaGravada	:= ZZD->ZZD_QTDCX

				RecLock("ZZD", .F.)
				ZZD->(DbDelete())
				ZZD->(MsUnlock())
			Endif

			dBselectarea("SD2")
			SD2->(dbSetOrder(3)) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
			IF SD2->(dbSeek(FWxFilial("SD2")+ aExcluidos[nItens][4] + aExcluidos[nItens][5] + aExcluidos[nItens][7] + ;
					aExcluidos[nItens][8] + aExcluidos[nItens][2] + aExcluidos[nItens][6] ))
				nSaldoGravado := SD2->D2_ETQPLT

				RecLock("SD2", .F.)
				SD2->D2_ETQPLT  := nSaldoGravado - nCaixaGravada
				SD2->(MsUnlock())
				lDeletou := .T.
			Endif

			If lDeletou
				lRet := .T.
			Endif
		Next
		If lRet
			FWAlertWarning("Codigo de Montagem "+cCodigoMontagem+" foi excluído corretamente!", "Exclusão de Pallets")
		EndIf

	Endif
	(cAlias)->(DBCloseArea())

Return lRet

/*/{Protheus.doc} getQryExclusao
Rotina responsável por montar query para buscar os registros que serao deletados
@author Vinicius Franceschi
@since 10/01/2024
@version 1.0
@type function
/*/
Static Function getQryExclusao(cCodigoMontagem)
	Local cQuery 			:= ""
	Default cCodigoMontagem := ""

	cQuery := " SELECT  " + CRLF
	cQuery +=  " *" + CRLF
	cQuery += " FROM "  + RetSqlName("ZZD") + " ZZD " + CRLF
	cQuery += " WHERE 1=1  " + CRLF
	cQuery += " AND ZZD.ZZD_FILIAL ='" + FWxFilial("ZZD") + "'" + CRLF
	cQuery += " AND ZZD.ZZD_CODM ='" + cCodigoMontagem + "'" + CRLF
	cQuery += " AND ZZD.D_E_L_E_T_ = '' " + CRLF

Return cQuery

/*/{Protheus.doc} getQryDados
Rotina responsável por montar query para buscar pedido em aberto
@author Vinicius Franceschi
@since 10/01/2024
@version 1.0
@type function
/*/
Static Function getQryDados(cMontagem)
	Local cQuery := ""
	Default cMontagem := ""

	cQuery := " SELECT DISTINCT " + CRLF
	cQuery +=  " ZZD_CODM, ZZD_PALLET, ZZD_CLIENT, ZZD_LOJA " + CRLF
	cQuery += " FROM "  + RetSqlName("ZZD") + " ZZD " + CRLF
	cQuery += " WHERE ZZD.ZZD_FILIAL ='" + FWxFilial("ZZD") + "'" + CRLF
	If !Empty(cMontagem)
		cQuery += " AND ZZD.ZZD_CODM  ='" + cMontagem + "'" + CRLF
	Endif
	cQuery += " AND ZZD.D_E_L_E_T_ = '' " + CRLF

Return cQuery
