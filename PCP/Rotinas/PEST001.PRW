//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "topconn.ch"
#include "fileio.ch"
#include "tbiconn.ch"

//Variáveis Estáticas
Static cTitulo := "Ordem de Pesagem"

/*/{Protheus.doc} PEST001
Função que fará o cadastro e manutenção da Ordem de Pesagem
@type function
@version 1.0
@author Jair Matos
@since 25/04/2024
/*/
User Function PEST001()
	Local aArea   		:= GetArea()
	Local cCondicao 	:= ""
	Private nQtdSD4		:= 0
	Private oBrowse
	Private cProxCod	:= ""
	Private lStatZZA 	:= .T.
	Private aCab		:= {}
	Private aLin		:= {}
	Private aIteSD4 	:= {}
	Private aRotina 	:= MenuDef()
	Private aSeek 		:= {}, aFieFilter := {}, aIndex := {}, aPrdData:= {}

	//Campos que irão compor o combo de pesquisa na tela principal
	Aadd(aSeek,{"Filial+Pesagem"   , {{"","C",13,0, "ZZA_NUMPES","@!"}}, 1, .T. } )
	Aadd(aSeek,{"Filial+Num.OP"		, {{"","C",18,0, "ZZA_NUMOP" ,"@!"}}, 2, .T. } )

	//Campos que irão compor a tela de filtro
	Aadd(aFieFilter,{"ZZA_FILIAL"	, "Filial"	   , "C", 04, 0,"@!"})
	Aadd(aFieFilter,{"ZZA_NUMPES"	, "Num.Pesagem", "C", 09, 0,"@!"})
	Aadd(aFieFilter,{"ZZA_NUMOP"	, "Num.OP"	   , "C", 14, 0,"@!"})

	Aadd( aIndex, "ZZA_NUMPES" )
	Aadd( aIndex, "ZZA_NUMOP" )

	//Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()

	oBrowse:SetQueryIndex(aIndex)
	oBrowse:SetSeek(,aSeek)
	oBrowse:SetFieldFilter(aFieFilter)
	oBrowse:SetFieldFilter(aFieFilter)
	oBrowse:SetFilterDefault(cCondicao)
	oBrowse:SetDBFFilter(.T.)
	oBrowse:SetUseFilter(.T.)

	//Setando a tabela de cadastro de Autor/Interprete
	oBrowse:SetAlias("ZZA")
	//Setando _aLinha := {	} descrição da rotina
	oBrowse:SetDescription(cTitulo)

	//Legendas
	oBrowse:AddLegend( "ZZA->ZZA_STATUS == 'A'", "GREEN",	"Aguardando Pesagem" )
	oBrowse:AddLegend( "ZZA->ZZA_STATUS == 'E'", "YELLOW",	"Em Andamento" )
	oBrowse:AddLegend( "ZZA->ZZA_STATUS == 'S'", "BLUE",	"Transferencia Solicitada" )
	oBrowse:AddLegend( "ZZA->ZZA_STATUS == 'R'", "GRAY",	"Transferencia Realizada" )
	oBrowse:AddLegend( "ZZA->ZZA_STATUS == 'F'", "RED"	,	"Pesagem finalizada" )


	//Ativa a Browse
	oBrowse:Activate()

	RestArea(aArea)
Return Nil
/*/{Protheus.doc} MenuDef
Criação do menu MVC  
@type function
@version 1.0
@author Jair Matos
@since 25/04/2024
@return array, arot, retorna Arot
/*/
Static Function MenuDef()

	Local aRot 		:= {}
	Local aTransf 	:= {}
	Local aPesagem 	:= {}
	Local aRelat 	:= {}

	// adiciona opções no submenu
	ADD OPTION aPesagem TITLE 'Realizar Pesagem'    	ACTION 'U_PACD003(ZZA_NUMPES)'			OPERATION 4 ACCESS 0
	ADD OPTION aPesagem TITLE 'Refazer Pesagem'	    	ACTION 'U_PEST001R(.T.)'				OPERATION 4 ACCESS 0
	ADD OPTION aTransf  TITLE 'Gerar Transferencia'    	ACTION 'U_PEST001T()'  					OPERATION 4 ACCESS 0
	ADD OPTION aTransf  TITLE 'Excluir Transferencia'   ACTION 'U_PEST001E(.F.)'  				OPERATION 4 ACCESS 0
	ADD OPTION aRelat   TITLE 'Imp. Pesagem'    		ACTION 'U_RPEST001()'  					OPERATION 4 ACCESS 0

	//Adicionando opções
	ADD OPTION aRot TITLE 'Gerar Pesagem' 		 ACTION 'U_PEST001P'   			OPERATION 3                      ACCESS 0 //OPERATION X
	ADD OPTION aRot TITLE 'Visualizar' 			 ACTION 'VIEWDEF.PEST001'		OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Excluir'    			 ACTION 'VIEWDEF.PEST001'		OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
	ADD OPTION aRot TITLE 'Transferência'  		 ACTION aTransf 				OPERATION 9                      ACCESS 0 //OPERATION X
	ADD OPTION aRot TITLE 'Pesagem'				 ACTION aPesagem 				OPERATION 9                      ACCESS 0 //OPERATION X
	ADD OPTION aRot TITLE 'Relatorios'			 ACTION aRelat   				OPERATION 9                      ACCESS 0 //OPERATION X
	ADD OPTION aRot TITLE 'Ajuste Empenhos'		 ACTION 'U_PEST001A()'   		OPERATION 9                      ACCESS 0 //OPERATION X
	ADD OPTION aRot TITLE 'Legenda'    			 ACTION 'U_PEST001Leg'   		OPERATION 9                      ACCESS 0 //OPERATION X

Return aRot
/*/{Protheus.doc} ModelDef
Criação do modelo de dados MVC  
@type function
@version 1.0
@author Jair Matos
@since 25/04/2024
@return object, retorna modelo omodel
/*/
Static Function ModelDef()
	Local oModel 		:= Nil
	Local oStPai 		:= FWFormStruct(1, 'ZZA')
	Local oStFilho 		:= FWFormStruct(1, 'ZZB')
	Local bCommit       := { |oModel| fExcOP( oModel ) }
	Local aZZBRel		:= {}

	//Criando o modelo e os relacionamentos
	oModel := MPFormModel():New('PEST001M',,,bCommit,)
	oModel:AddFields('ZZAMASTER',,oStPai)
	oModel:AddGrid('ZZBDETAIL','ZZAMASTER',oStFilho,,,,,)  //cOwner é para quem pertence
	//Fazendo o relacionamento entre o Pai e Filho
	aAdd(aZZBRel, {'ZZB_FILIAL',	'ZZA_FILIAL'} )
	aAdd(aZZBRel, {'ZZB_NUMPES',	'ZZA_NUMPES'})

	oModel:SetRelation('ZZBDETAIL', aZZBRel, ZZB->(IndexKey(1))) //IndexKey -> quero a ordenação e depois filtrado
	//oModel:GetModel('ZZBDETAIL'):SetUniqueLine({"ZZB_FILIAL","ZZB_NUMOP"})	//Não repetir informações ou combinações {"CAMPO1","CAMPO2","CAMPOX"}
	oModel:SetPrimaryKey({})

	//Setando as descrições
	oModel:SetDescription("Itens")
	oModel:GetModel('ZZAMASTER'):SetDescription('Cabeçalho Pesagem')
	oModel:GetModel('ZZBDETAIL'):SetDescription('Itens Pesagem')

Return oModel
/*/{Protheus.doc} ViewDef
Criação da visão MVC  
@type function
@version 1.0 
@author Jair Matos
@since 29/05/2024
@return object, object, retorna objeto
/*/
Static Function ViewDef()
	Local oView		:= Nil
	Local oModel		:= FWLoadModel('PEST001')
	Local oStPai		:= FWFormStruct(2, 'ZZA')
	Local oStFilho		:= FWFormStruct(2, 'ZZB')

	//Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)

	//Adicionando os campos do Cabeçalho Pesagem e o grid dos filhos
	oView:AddField('VIEW_ZZA',oStPai,'ZZAMASTER')
	oView:AddGrid('VIEW_ZZB',oStFilho,'ZZBDETAIL')

	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC',30)
	oView:CreateHorizontalBox('GRID',70)

	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_ZZA','CABEC')
	oView:SetOwnerView('VIEW_ZZB','GRID')

	//Habilitando título
	oView:EnableTitleView('VIEW_ZZA','Cabeçalho Pesagem')
	oView:EnableTitleView('VIEW_ZZB','Itens Pesagem')

	oView:AddUserButton("Refaz.Pes.Item","MAGIC_BMP",{|| U_PEST001R(.F.)}, "Refaz pesagem do Item",,,.T.)
Return oView
/*/{Protheus.doc} PEST001Leg
Legenda
@type function
@version 1.0 
@author Jair Matos
@since 25/04/2024
/*/
User Function PEST001Leg()
	Local aLegenda := {}

	AADD(aLegenda,{"BR_VERDE" 	,"Aguardando Pesagem"})
	AADD(aLegenda,{"BR_AMARELO" ,"Em Andamento" })
	AADD(aLegenda,{"BR_AZUL"    ,"Transferencia Solicitada" })
	AADD(aLegenda,{"BR_CINZA"    ,"Transferencia Realizada" })
	AADD(aLegenda,{"BR_VERMELHO","Pesagem Finalizada"})
	BrwLegenda("Legenda", "Legenda", aLegenda)
Return Nil
/*/{Protheus.d		oc} fExcOP
	Exclui _aLinha := 	{} ordem de Pesagem e grava os empenhos na SD4
	@type function
	@version 1.0
	@author Jair Matos
	@since 03/05/2024
	@param oModel, object, modelo Model
	@return variant, retorna logico
/*/
Static Function fExcOP(oModel)
	Local aArea  			:= FWGetArea()
	Local lRet 				:= .T.
	Local _aLinha			:= {}
	Local 	cQuery			:= ""
	local 	cAliasCommit	:= getNextAlias()

	cQuery := " SELECT ZZB_NUMOP,ZZB_NUMPES,ZZB_CODPRD,ZZB_LOCAL, SUM(ZZB_QUANT) AS QTDE "
	cQuery += " FROM "+RetSQLName("ZZB")+" WHERE D_E_L_E_T_ <> '*' "
	cQuery += " AND ZZB_NUMPES ='"+ZZA->ZZA_NUMPES+"' "
	cQuery += " GROUP BY ZZB_NUMOP,ZZB_NUMPES,ZZB_CODPRD,ZZB_LOCAL"

	TCQuery cQuery New Alias &cAliasCommit
	if (cAliasCommit)->(!EOF())
		aIteSD4 := {}
		While !(cAliasCommit)->(Eof())
			_aLinha	:= {}
			aAdd(_aLinha,{"D4_OP"     ,(cAliasCommit)->ZZB_NUMOP 				,NIL})
			aAdd(_aLinha,{"D4_COD"    ,(cAliasCommit)->ZZB_CODPRD        		,NIL})
			aAdd(_aLinha,{"D4_LOCAL"  ,(cAliasCommit)->ZZB_LOCAL				,NIL})
			aAdd(_aLinha,{"D4_DATA"   ,date()									,NIL})
			aAdd(_aLinha,{"D4_QTDEORI",(cAliasCommit)->QTDE						,NIL})
			aAdd(_aLinha,{"D4_QUANT"  ,(cAliasCommit)->QTDE						,NIL})
			aAdd(_aLinha,{"D4_LOTECTL",""						             	,NIL})
			aAdd(_aLinha,{"D4_XNUMPES",""				              			,NIL})
			aAdd(aIteSD4,_aLinha)
			(cAliasCommit)->(dbSkip())
		EndDO
	EndIf
	(cAliasCommit)->(DbCloseArea())
	//zera os empenhos
	lRet := fGravaSD4(ZZA->ZZA_NUMOP,.T.)
	//corrige os empenhos
	lRet := fGravaSD4(ZZA->ZZA_NUMOP,.T.)
	If lRet
		//altera campo C2_XORDPES na tabela SC2
		SC2->(dbSetOrder(1))
		SC2->(dbSeek(xFilial("SC2")+Alltrim(ZZA->ZZA_NUMOP)))
		If SC2->(!Eof()) .And. SC2->(C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN) == xFilial("SC2")+Alltrim(ZZA->ZZA_NUMOP)
			Reclock("SC2", .F.)
			SC2->C2_XORDPES := ""
			MsUnLock()
		EndIf

		//exclui a transferencia caso exista
		U_PEST001E(.T.)

		//Aciona o commit dos dados preenchidos no formulário
		FWFormCommit(oModel)
	EndIf

	FWRestArea(aArea)

Return lRet
/*/{Protheus.doc} PEST001P
Gera a	 ordem de pesagem.
@type function
@version 1.0
@author Jair Matos	
@since 25/04/2024
@return logical, retorna lret
/*/
User Function PEST001P()
	Local 	lRet 			:= .T.
	Local	cError   		:= ""
	Local 	bError   		:= ErrorBlock({ |oError| cError := oError:Description})
	local 	cAliasP   		:= getNextAlias()
	Local 	cQuery			:= ""
	Local 	aArea 			:= FWGetArea()
	Local 	cNumOP			:= ""
	Local 	_cPerg			:= "XPOPROD"

	Begin Sequence

		nCount := 0
		CriaSx1(_cPerg)
		If Pergunte(_cPerg,.T.)
			cNumOP := MV_PAR01
			DbSelectArea("SC2")
			SC2->(dBsetOrder(1)) //C2_FILIAL + C2_NUM
			IF !SC2->(dbSeek(FWxFilial("SC2")+cNumOP))
				FWAlertWarning("Ordem de Produção "+cNumOP+" não existe ou nao foi preenchido!", "Seleção de OP")
				lRet := .F.
				Break
			EndIf

			cQuery := " SELECT ZZA_NUMPES FROM "+RetSQLName("ZZA")+" WHERE ZZA_NUMOP = '"+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+"' AND D_E_L_E_T_ <> '*'"
			TCQuery cQuery New Alias &cAliasP
			if (cAliasP)->(!EOF())
				FWAlertWarning("Ordem de Produção "+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+" já foi utilizada na Ordem de Pesagem "+(cAliasP)->ZZA_NUMPES, "Seleção de OP")
				lRet := .F.
				Break
			EndIf
			(cAliasP)->(DbCloseArea())
		Else
			Break
		EndIf

		If lRet //Continua com o processo de gravação na tabela ZZA e ZZB
			If fExecProc(cNumOP)
				FWAlertSuccess("Ordem de Pesagem "+cProxCod+" foi criada corretamente!", "Gera Pesagem")
			EndIf
		EndIf

	End Sequence

//Restaurando bloco de erro do sistema
	ErrorBlock(bError)
//Se houve erro, será mostrado ao usuário
	If !Empty(cError)
		MsgStop("Houve um erro na fórmula digitada: "+CRLF+CRLF+cError, "Atenção")
	EndIf

	FWRestArea(aArea)

	oBrowse:Refresh()

Return lRet
/*/{Protheus.doc} CriaSX1
Funcao que cria as perguntas na SX1
@type function
@version 1.0
@author Jair Matos
@since 25/04/2024
@param _cPerg, variant, nome da pergunta
/*/
Static Function CriaSX1(_cPerg)
	Local _aArea	:= FWGetArea()
	Local aRegs		:= {}
	Local nX		:= 1
	Local lLock		:= .F.

	dbSelectArea("SX1")
	dbSetOrder(1)

	_cPerg := padr(_cPerg,len(SX1->X1_GRUPO))
	Aadd(aRegs,{_cPerg,"01" ,"Ordem Produção" ,"MV_CH1" ,"C" ,TamSX3("C2_NUM")[1]	, 0, 0, "G","MV_PAR01","SC2P","","","",""})

	DbSelectArea("SX1")
	DbSetOrder(1)

	For nX := 1 To Len(aRegs)

		lLock 	:= DbSeek(aRegs[nX,1]+aRegs[nX,2])

		RecLock("SX1", !lLock )
		Replace X1_GRUPO   with aRegs[nX,01]
		Replace X1_ORDEM   with aRegs[nX,02]
		Replace X1_PERGUNT with aRegs[nX,03]
		Replace X1_VARIAVL with aRegs[nX,04]
		Replace X1_TIPO	   with aRegs[nX,05]
		Replace X1_TAMANHO with aRegs[nX,06]
		Replace X1_DECIMAL with aRegs[nX,07]
		Replace X1_PRESEL  with aRegs[nX,08]
		Replace X1_GSC	   with aRegs[nX,09]
		Replace X1_VAR01   with aRegs[nX,10]
		Replace X1_F3	   with aRegs[nX,11]
		Replace X1_DEF01   with aRegs[nX,12]
		Replace X1_DEF02   with aRegs[nX,13]
		Replace X1_DEF03   with aRegs[nX,14]
		Replace X1_VALID   with aRegs[nX,15]
		MsUnlock()

	Next nX

	FWRestArea(_aArea)

Return()
/*/{Protheus.		doc} fExecProc
	chama _aLinha := {	} regua de processamento
	@type function
	@version 1.0
	@author Jair Matos
	@since 25/04/2024
	@return logical, retorna lret
/*/
Static Function fExecProc(cNumOP)
	Local lRet			:= .F.
	Local oSay := NIL // CAIXA DE DIÁLOGO GERADA

	// GERA A TELA DE PROCESSAMENTO
	FwMsgRun(NIL, {|oSay| lRet := fGravaOP(cNumOP,oSay)}, "Aguarde", "Iniciando processo...")

Return lRet
/*/{Protheus.		doc} fgravaOP
	grava _aLinha := {	} ordem de Pesagem nas tabelas ZZA e ZZB
	@type function
	@version 1.0
	@author Jair Matos
	@since 25/04/2024
/*/
Static Function fgravaOP(cNumOP,oSay)
	Local lRet 		:= .F.
	Local nX		:= 0
	Local nQtd		:= 0
	Local nItem		:= 0
	Local cLocaliz	:= ""
	Local cProdLido	:= ""
	Local cAliasGRV := GetNextAlias()
	Local cQuery 	:= ""
	Local ProdPai	:= SC2->C2_PRODUTO
	Local _aLinha	:= {}

	cLocaliz := u_PesqNNR()
	//Query referente _aLi	nha := {} tabelas SD4, SB1, SBF
	cQuery := " SELECT D4_COD,D4_LOCAL,D4_QUANT,B1_COD, B1_XDESCAL, B1_XITPES, BF_LOTECTL, BF_LOCALIZ, "
	cQuery += " BF_NUMLOTE,BF_PRODUTO,BF_LOCAL, BF_QUANT ,B8_DTVALID, "
	cQuery += " (SELECT  SUM(BF_QUANT) FROM "+RetSQLName("SBF")+" SBF1 "
	cQuery += " WHERE BF_PRODUTO = D4_COD AND BF_LOCAL = '"+cLocaliz+"'  AND SBF1.D_E_L_E_T_ =' ' AND (BF_QUANT - BF_EMPENHO) >0) AS QTDSBF
	cQuery += " FROM "+RetSQLName("SD4")+" SD4 "
	cQuery += " INNER JOIN "+RetSQLName("SB1")+" SB1  "
	cQuery += " ON SB1.D_E_L_E_T_ <> '*' AND B1_COD = D4_COD AND B1_XITPES = 'S' "
	cQuery += " LEFT JOIN "+RetSQLName("SBF")+" SBF  "
	cQuery += " ON SBF.D_E_L_E_T_ <> '*' AND BF_FILIAL = D4_FILIAL AND BF_LOCAL='"+cLocaliz+"' AND BF_PRODUTO = D4_COD AND (BF_QUANT - BF_EMPENHO) >0"
	cQuery += " LEFT JOIN "+RetSQLName("SB8")+" SB8  "
	cQuery += " ON SB8.D_E_L_E_T_ <> '*' AND B8_FILIAL = BF_FILIAL AND B8_LOCAL = BF_LOCAL AND B8_PRODUTO = BF_PRODUTO AND B8_SALDO = BF_QUANT "
	cQuery += " WHERE SD4. D_E_L_E_T_ <> '*'
	cQuery += " AND D4_FILIAL='" + FWxFilial("SD4") + "'"
	cQuery += " AND D4_OP ='" + cNumOP+SC2->C2_ITEM+SC2->C2_SEQUEN + "'"
	cQuery += " AND D4_QUANT > 0 "
	cQuery += " ORDER BY D4_COD,B8_DTVALID "

	TCQUERY cQuery NEW ALIAS &cAliasGRV

	If (cAliasGRV)->(!Eof())
		lRet := .T.
		//grava Cabeçalho
		aCab := {}
		cProxCod := GetSXENum( "ZZA", "ZZA_NUMPES" )
		AADD(aCab,{"ZZA_FILIAL" ,FWxFilial("ZZA")    				,".T."})
		AADD(aCab,{"ZZA_NUMPES" ,cProxCod  							,".T."})
		AADD(aCab,{"ZZA_NUMOP"	,cNumOP+SC2->C2_ITEM+SC2->C2_SEQUEN	,".T."})
		AADD(aCab,{"ZZA_PRDPAI"	,ProdPai   							,".T."})
		AADD(aCab,{"ZZA_PRDDES"	,POSICIONE("SB1",1,FWXFILIAL("SB1")+ProdPai,"B1_DESC"),".T."})
		AADD(aCab,{"ZZA_QTDOP"	,SC2->C2_QUANT  					,".T."})
		AADD(aCab,{"ZZA_LOTE"	,cNumOP								,".T."})
		AADD(aCab,{"ZZA_STATUS"	,"A"								,".T."})

		//Grava Itens
		aLin 	:= {}
		aIteSD4	:= {}
		While !(cAliasGRV)->(Eof())
			nX++
			oSay:SetText("Working at: " + StrZero(nX, 6)) // ALTERA O TEXTO CORRETO
			ProcessMessages() // FORÇA O DESCONGELAMENTO DO SMARTCLIENT
			_aLinha := {}
			nItem++

			If cProdLido==(cAliasGRV)->BF_PRODUTO .and. nQtdSD4 = 0
			Else
				cProdLido := (cAliasGRV)->BF_PRODUTO

				nQtd := fCalcSld(.F.,(cAliasGRV)->BF_PRODUTO,(cAliasGRV)->BF_QUANT,(cAliasGRV)->D4_QUANT,(cAliasGRV)->B8_DTVALID,(cAliasGRV)->QTDSBF)
				If nQtd > 0
					Aadd(_aLinha,{"ZZB_FILIAL" ,FWXFILIAL("ZZB")   					, Nil } )
					Aadd(_aLinha,{"ZZB_NUMPES" ,cProxCod							, Nil } )
					Aadd(_aLinha,{"ZZB_ITEM"   ,StrZero(nItem, 2)					, Nil } )
					Aadd(_aLinha,{"ZZB_NUMOP"  ,cNumOP+SC2->C2_ITEM+SC2->C2_SEQUEN	, Nil } )
					Aadd(_aLinha,{"ZZB_CODPRD" ,(cAliasGRV)->D4_COD					, Nil } )
					Aadd(_aLinha,{"ZZB_LOCAL"  ,cLocaliz							, Nil } )
					Aadd(_aLinha,{"ZZB_QUANT"  ,nQtd								, Nil } )
					Aadd(_aLinha,{"ZZB_LOTE"   ,(cAliasGRV)->BF_LOTECTL				, Nil } )
					Aadd(_aLinha,{"ZZB_END"    ,(cAliasGRV)->BF_LOCALIZ				, Nil } )
					Aadd(_aLinha,{"ZZB_DTVLD"  ,Stod((cAliasGRV)->B8_DTVALID)		, Nil } )
					Aadd(_aLinha,{"ZZB_FASE"   ,POSICIONE("SG1",1,FWXFILIAL("SG1")+ProdPai+(cAliasGRV)->D4_COD,"G1_XFASE")	, Nil } )
					Aadd(_aLinha,{"ZZB_STATUS" ,Iif((cAliasGRV)->BF_QUANT==0,(lStatZZA := .F.,"Saldo Insuficiente"),"Aguardando Pesagem")		, Nil } )
					aAdd( aLin , _aLinha )


					//Adiciona os empenhos no array para gravação da tabela SD4 - Requisicoes empenhadas
					_aLinha	:= {}
					aAdd(_aLinha,{"D4_OP"     ,cNumOP+SC2->C2_ITEM+SC2->C2_SEQUEN		,NIL})
					aAdd(_aLinha,{"D4_COD"    ,(cAliasGRV)->D4_COD            			,NIL})
					aAdd(_aLinha,{"D4_LOCAL"  ,cLocaliz          						,NIL})
					aAdd(_aLinha,{"D4_DATA"   ,date()									,NIL})
					aAdd(_aLinha,{"D4_QTDEORI",nQtd                						,NIL})
					aAdd(_aLinha,{"D4_QUANT"  ,nQtd                						,NIL})
					aAdd(_aLinha,{"D4_LOTECTL",(cAliasGRV)->BF_LOTECTL              	,NIL})
					aAdd(_aLinha,{"D4_XNUMPES",cProxCod+StrZero(nItem, 2)              	,NIL})
					aAdd(aIteSD4,_aLinha)
				EndIf

				//Verifica a quantidade de saldo e se estiver negativo inclui mais uma linha na ZZB
				nQtdSD4 := fCalcSld(.T.,(cAliasGRV)->BF_PRODUTO,(cAliasGRV)->BF_QUANT,(cAliasGRV)->D4_QUANT,(cAliasGRV)->B8_DTVALID,(cAliasGRV)->QTDSBF)
				If 	nQtdSD4 < 0
					lStatZZA := .F.
					_aLinha := {}
					nItem++
					Aadd(_aLinha,{"ZZB_FILIAL" ,FWXFILIAL("ZZB")   					, Nil } )
					Aadd(_aLinha,{"ZZB_NUMPES" ,cProxCod							, Nil } )
					Aadd(_aLinha,{"ZZB_ITEM"   ,StrZero(nItem, 2)					, Nil } )
					Aadd(_aLinha,{"ZZB_NUMOP"  ,cNumOP+SC2->C2_ITEM+SC2->C2_SEQUEN	, Nil } )
					Aadd(_aLinha,{"ZZB_CODPRD" ,(cAliasGRV)->D4_COD					, Nil } )
					Aadd(_aLinha,{"ZZB_LOCAL"  ,cLocaliz							, Nil } )
					Aadd(_aLinha,{"ZZB_QUANT"  ,nQtdSD4*-1							, Nil } )
					Aadd(_aLinha,{"ZZB_LOTE"   ,""									, Nil } )
					Aadd(_aLinha,{"ZZB_END"    ,""									, Nil } )
					Aadd(_aLinha,{"ZZB_DTVLD"  ,CTOD("  /  /    ")					, Nil } )
					Aadd(_aLinha,{"ZZB_FASE"   ,POSICIONE("SG1",1,FWXFILIAL("SG1")+ProdPai+(cAliasGRV)->D4_COD,"G1_XFASE")	, Nil } )
					Aadd(_aLinha,{"ZZB_STATUS" ,"Saldo Insuficiente"				, Nil } )
					aAdd( aLin , _aLinha )

					//Adiciona os empenhos no array para gravação da tabela SD4 - Requisicoes empenhadas
					_aLinha	:= {}
					aAdd(_aLinha,{"D4_OP"     ,cNumOP+SC2->C2_ITEM+SC2->C2_SEQUEN		,NIL})
					aAdd(_aLinha,{"D4_COD"    ,(cAliasGRV)->D4_COD            			,NIL})
					aAdd(_aLinha,{"D4_LOCAL"  ,cLocaliz          						,NIL})
					aAdd(_aLinha,{"D4_DATA"   ,date()									,NIL})
					aAdd(_aLinha,{"D4_QTDEORI",nQtdSD4*-1                				,NIL})
					aAdd(_aLinha,{"D4_QUANT"  ,nQtdSD4*-1                				,NIL})
					aAdd(_aLinha,{"D4_LOTECTL",""						              	,NIL})
					aAdd(_aLinha,{"D4_XNUMPES",cProxCod+StrZero(nItem, 2)              	,NIL})
					aAdd(aIteSD4,_aLinha)

				EndIf
			EndIf
			(cAliasGRV)->(dbSkip())
		EndDO
		(cAliasGRV)->(dbCloseArea())

		If !lStatZZA// Item com saldo insuficiente muda o status do cabeçalho para Em andamento("E")
			nPos := aScan(aCab, {|x| x[01] == "ZZA_STATUS"  })
			aCab[nPos][2] := "E"
		EndIf

	Else
		lRet 		:= .F.
		FWAlertWarning("A Op "+cNumOP+" contem itens sem empenho(Qtd. Empenho = 0) para poder realizar a Ordem de pesagem", "Aviso")
	EndIf

	If lRet

		lRet := fGravaSD4(cNumOP+SC2->C2_ITEM+SC2->C2_SEQUEN,.F.)  // execauto MATA381 opção 4 - alteração

		//Grava as tabelas ZZA e ZZB
		If lRet .and. fGravaZZA(cProxCod)
			lRet := .T.
			ConfirmSX8()
		EndIf

	EndIf

Return lRet
/*/{Protheus.doc}fGravaZZA 
	Grava as tabelas ZZA e ZZB logo após terem sidos validados todos os dados
	@type  Function
	@author Jair Matos
	@since 01/05/2024
	@version 1.0
	/*/
Static Function fGravaZZA(cProxCod)
	Local nX 		:= 0
	Local nY 		:= 0
	Local lRet		:= .T.
	Local cAliasCab	:= "ZZA"
	Local cAliasIte	:= "ZZB"
	Local cCampo	:= ""
	Local aCampos	:= {}

	dBselectarea("ZZA")
	ZZA->(dBsetOrder(1))
	if !ZZA->(dBseek(FWxFilial("ZZA")+cProxCod))
		//grava cabeçalho ZZA
		Reclock(cAliasCab, .T.)
		For nX := 1 To Len(aCab)
			cCampo	:= cAliasCab+'->'+aCab[nX,01]
			&cCampo := aCab[nX,02]
		Next nX
		MsUnLock()

		//grava Itens ZZB
		For nX := 1 To Len(aLin)
			aCampos	:= aLin[nX]
			Reclock(cAliasIte, .T.)
			For nY := 1 To Len(aCampos)
				cCampo	:= cAliasIte+'->'+aCampos[nY][1]
				&cCampo := aCampos[nY,02]
			Next nY
			MsUnLock()
		Next nX

		//altera campo C2_XORDPES na tabela SC2
		SC2->(dbSetOrder(1))
		SC2->(dbSeek(xFilial("SC2")+Alltrim(ZZA->ZZA_NUMOP)))
		If SC2->(!Eof()) .And. SC2->(C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN) == xFilial("SC2")+Alltrim(ZZA->ZZA_NUMOP)
			Reclock("SC2", .F.)
			SC2->C2_XORDPES := ZZA->ZZA_NUMPES
			MsUnLock()
		EndIf
	EndIf

/*/{Protheus.doc} fGravaSD4
Grava alteração dos empenhos na tabela SD4
@type function
@version 1.0
@author Jair Matos
@since 03/05/2024
@param cNumOP, character, Numero da ordem de pesagem
@return variant, retorna true ou false
/*/Return lRet
Static Function fGravaSD4(cNumOP,lExcZZA)
	Local lRet 		:= .T.
	Local lContinua	:= .T.
	Local lGrvPrim	:= .F.
	Local nX        := 0
	Local nY        := 0
	Local aArea     := GetArea()
	Local aCabSD4	:= {}
	Local aLine     := {}
	Local aItens    := {}

	PRIVATE lMsErroAuto := .F.

	//Monta o cabeçalho com o número da OP que será alt		erada.
	//Necessário utilizar o índice 2 para efetuar _aLinha 	:= {} alteração.
	aCabSD4 := {{"D4_OP",cNumOP,NIL},;
		{"INDEX",2,Nil}}

	//Seta o índice da SDC
	SDC->(dbSetOrder(2))

	//Busca os empenhos da SD4 para alterar/excluir.
	SD4->(dbSetOrder(2))
	SD4->(dbSeek(FWXFILIAL("SD4")+PadR(cNumOP,Len(SD4->D4_OP))))

	While SD4->(!Eof()) .And. SD4->(D4_FILIAL+D4_OP) == FWXFILIAL("SD4")+PadR(cNumOP,Len(SD4->D4_OP))
		lGrvPrim := .F.
		lContinua := .T.
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

			If lExcZZA
				nY := aScan(aItens,{|x| x[1][2] == SD4->D4_COD})
				If nY > 0
					aAdd(aLine,{"AUTDELETA","S",Nil})
					//Adiciona as informações do empenho no array de itens.
					aAdd(aItens,aLine)
					lContinua := .F.
				EndIf
			EndIf

			If lContinua
				For nX := 1 to len(aIteSD4)

					If aIteSD4[nX][2][2] == SD4->D4_COD

						If !lGrvPrim
							nY := aScan(aLine,{|x| x[1] == "D4_QTDEORI"})
							If 		nY > 0
								//	Encontrou o valor da quantidade. Faz a alteração do valor.
								aLine[nY,2] := aIteSD4[nX][5][2]
							EndIf

							//Altera também o saldo do empenho
							nY := aScan(aLine,{|x| x[1] == "D4_QUANT"})
							If 		nY > 0
								//	Encontrou o valor da quantidade. Faz a alteração do valor.
								aLine[nY,2] := aIteSD4[nX][5][2]
							EndIf

							//Altera Local
							nY := aScan(aLine,{|x| x[1] == "D4_LOCAL"})
							If 		nY > 0
								//	Encontrou o valor da quantidade. Faz a alteração do valor.
								aLine[nY,2] := aIteSD4[nX][3][2]
							EndIf

							If lExcZZA
								//Altera Lotectl
								nY := aScan(aLine,{|x| x[1] == "D4_LOTECTL"})
								If 		nY > 0
									//	Encontrou o valor da quantidade. Faz a alteração do valor.
									aLine[nY,2] := ""
								EndIf

								//Altera Numero / Item da Pesagem
								nY := aScan(aLine,{|x| x[1] == "D4_XNUMPES"})
								If 		nY > 0
									//	Encontrou o valor da quantidade. Faz a alteração do valor.
									aLine[nY,2] := ""
								EndIf
							Else
								//Altera Lotectl
								nY := aScan(aLine,{|x| x[1] == "D4_LOTECTL"})
								If 		nY > 0
									//	Encontrou o valor da quantidade. Faz a alteração do valor.
									aLine[nY,2] := aIteSD4[nX][7][2]
								EndIf

								//Altera Lotectl
								nY := aScan(aLine,{|x| x[1] == "D4_XNUMPES"})
								If 		nY > 0
									//	Encontrou o valor da quantidade. Faz a alteração do valor.
									aLine[nY,2] := aIteSD4[nX][8][2]
								EndIf

							EndIf
							//Adiciona as informações do empenho no array de itens.
							aAdd(aItens,aLine)
							lGrvPrim := .T.
						Else
							//ADICIONA OS NOVOS ITENS DA TABELA ZZA e ZZB
							aAdd( aItens , aIteSD4[nx] )
						EndIf

					EndIf

				Next nX
			EndIf

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

/*/{Protheus.doc} fCalcSld
Calcula Saldo 
@type function
@version 1.0 
@author Jair Matos 
@since 26/04/2024
@return numeric, retorna saldo
/*/
Static Function fCalcSld(lCalcSD4,cProdSBF,nBFQuant,nD4Quant,dtValid,QTDSBF)
	Local nX 		:= 0
	Local nTotRet	:= 0
	Local nTotal	:= 0

	If lCalcSD4
		If nD4Quant > QTDSBF
			for nX := 1 to len(aPrdData)
				If aPrdData[nX][1]==cProdSBF
					nTotal += aPrdData[nX][3]
				EndIf
			next nX

			If nTotal <> 0
				nTotRet := nTotal - nD4Quant
			EndIf
		EndIf
	Else
		If aScan(aPrdData, {|x| x[01] == cProdSBF .and. x[2] == Stod(dtValid) }) = 0
			aAdd(aPrdData, {cProdSBF,  Stod(dtValid),nBFQuant})
		EndIf

		for nX := 1 to len(aPrdData)
			If aPrdData[nX][1]==cProdSBF
				nTotal += aPrdData[nX][3]
			EndIf
		next nX

		If nTotal < nD4Quant
			If nTotal == 0
				nTotRet := nD4Quant
			Else
				nTotRet := nBFQuant
			EndIf
		Else
			nTotRet := nD4Quant -(nTotal - nBFQuant)
		EndIf
	EndIf

Return nTotRet

/*/{Protheus.doc} PEST001T
	Tratamento de pesagem com saldo insuficiente
	@type  Function
	@author Jair Matos
	@since 07/05/2024
	@version 1.0	
	@param cNumOP, character, numero da OP posicionada
	@return variant, logical, true ou false
	/*/
User Function PEST001T()
	Local aArea 		:= FWGetArea()
	Local lRet 			:= .T.
	Local lSai 			:= Nil
	Local nQtdSBF		:= 0
	Local nQuantZZB		:= 0
	Local cAliasT 		:= GetNextAlias()
	Local cQuery 		:= ""
	Local aCabec 		:= {}
	Local aItens 		:= {}
	Local aLinha 		:= {}
	Local oModel
	LOCAL cLocDes 		:= SUPERGETMV('MV_XLOCDES', .T., "PES02")
	Private lMsErroAuto := .F.
	Private L311GTL		:= .F.

	If ZZA->ZZA_STATUS !='E'
		FWAlertWarning("A ordem de pesagem "+ZZA_NUMPES+" já contem saldo suficiente para todos os itens.", "Gerar Transferencia")
		Return lRet
	EndIf

	If FWAlertYesNo( "A ordem de pesagem "+ZZA_NUMPES+" tem itens com saldo insuficiente e será efetuado a transferencia de saldo. Deseja continuar?", "Gerar Transferencia" )

		//Cabeçalho da solicitacao
		aadd(aCabec,{"NNS_CLASS" ,"1",.T.})
		aadd(aCabec,{"NNS_ESPECI" ," ",.T.})
		aadd(aCabec,{"NNS_XORDPS" ,ZZA->ZZA_NUMPES,.T.})

		//Busca os empenhos da ZZB para alterar/excluir.
		ZZB->(dbSetOrder(1))
		ZZB->(dbSeek(xFilial("ZZB")+ZZA->ZZA_NUMPES))
		While ZZB->(!Eof()) .And. ZZB->(ZZB_FILIAL+ZZB_NUMPES) == xFilial("ZZB")+ZZA->ZZA_NUMPES
			If ZZB->ZZB_STATUS = "Saldo Insuficiente" .AND. lRet
				lSai := .F.
				nQuantZZB := 0
				nQtdSBF	:= 0
				//Query re	ferente a tabelas SB1, SBF, SB8
				cQuery := " SELECT B1_DESC,B1_XDESCAL, B1_LOCPAD,BF_LOCALIZ,BF_LOTECTL, (BF_QUANT - BF_EMPENHO) AS QTDSBF ,(SELECT  SUM(BF_QUANT) FROM "+RetSQLName("SBF")+" SBF1 "
				cQuery += " WHERE SBF1.BF_PRODUTO =SBF.BF_PRODUTO AND SBF1.BF_LOCAL = SBF.BF_LOCAL  AND SBF1.D_E_L_E_T_ =' ' AND (SBF1.BF_QUANT - SBF1.BF_EMPENHO) >0) AS QTDTOTAL
				cQuery += " FROM "+RetSQLName("SBF")+" SBF "
				cQuery += " INNER JOIN "+RetSQLName("SB1")+" SB1  "
				cQuery += " ON SB1.D_E_L_E_T_ <> '*' AND B1_COD = BF_PRODUTO AND B1_XITPES = 'S' "
				cQuery += " LEFT JOIN "+RetSQLName("SB8")+" SB8  "
				cQuery += " ON SB8.D_E_L_E_T_ <> '*' AND B8_FILIAL = BF_FILIAL AND B8_LOCAL = BF_LOCAL AND B8_PRODUTO = BF_PRODUTO AND B8_LOTECTL = BF_LOTECTL "
				cQuery += " WHERE SBF.D_E_L_E_T_ <> '*'
				cQuery += " AND BF_FILIAL='" + FWxFilial("SBF") + "'"
				cQuery += " AND BF_PRODUTO ='" + ZZB->ZZB_CODPRD + "'"
				cQuery += " AND BF_LOCAL = B1_LOCPAD "
				cQuery += " AND (BF_QUANT - BF_EMPENHO) > 0 "
				cQuery += " ORDER BY B8_DTVALID "

				TCQUERY cQuery NEW ALIAS &cAliasT

				If (cAliasT)->(!Eof())

					While !(cAliasT)->(Eof())

						If (cAliasT)->QTDTOTAL < ZZB->ZZB_QUANT//Verifica o total na SBF. Se o total forn menor que ZZB_QUANT, Não antende o requisito e sai
							FWAlertWarning("Não existe saldo suficiente para efetuar a transferencia. Verificar saldo dos produtos com status = 'SALDO INSUFICIENTE'", "Gerar Transferencia")
							lRet := .F.
							Exit
						EndIf
						//Itens da solicitação- produto e local de origem
						If ZZB->ZZB_QUANT < (cAliasT)->QTDSBF
							nQtdSBF := ZZB->ZZB_QUANT
							lSai := .T.
						Else
							nQtdSBF := (cAliasT)->QTDSBF
							nQuantZZB += nQtdSBF
							If nQuantZZB >= ZZB->ZZB_QUANT
								nQtdSBF := ZZB->ZZB_QUANT - (nQuantZZB-nQtdSBF)
								lSai := .T.
							EndIf
						EndIf

						aLinha := {}
						aadd(aLinha,{"NNT_FILORI"	,ZZB->ZZB_FILIAL		,Nil})
						aadd(aLinha,{"NNT_PROD"		,ZZB->ZZB_CODPRD		,Nil})
						aadd(aLinha,{"NNT_LOCAL"	,(cAliasT)->B1_LOCPAD	,Nil})
						aadd(aLinha,{"NNT_QUANT"	,nQtdSBF				,Nil})
						aadd(aLinha,{"NNT_FILDES"	,ZZB->ZZB_FILIAL		,Nil})
						aadd(aLinha,{"NNT_PRODD"	,ZZB->ZZB_CODPRD		,Nil})
						aadd(aLinha,{"NNT_LOCLD"	,ZZB->ZZB_LOCAL			,Nil})
						aadd(aLinha,{"NNT_LOCALI"	,(cAliasT)->BF_LOCALIZ	,Nil})
						aadd(aLinha,{"NNT_LOTECT"	,(cAliasT)->BF_LOTECTL	,Nil})
						aadd(aLinha,{"NNT_LOCDES"	,cLocDes				,Nil})
						aadd(aLinha,{"NNT_LOTED"	,(cAliasT)->BF_LOTECTL	,Nil})
						aadd(aItens,aLinha)

						If lSai
							Exit
						EndIf

						(cAliasT)->(dbSkip())
					EndDO
				else
					FWAlertWarning("Verifique se existe saldo para o produto:"+Alltrim(ZZB->ZZB_CODPRD)+" ou se este produto pode ser pesado(B1_XITPES='S').", "Gerar Transferencia")
					lRet := .F.
					Exit
				EndIf
				(cAliasT)->(dbCloseArea())
			EndIf
			//Próximo registro da zzb.
			ZZB->(dbSkip())
		EndDO



		If lSai <> Nil .and. lRet
			oModel := FwLoadModel ("MATA311")

			FWMVCRotAuto(oModel,"NNS",3,{{"NNSMASTER",aCabec},{"NNTDETAIL",aItens}})

			If !lMsErroAuto

				//altera status da ZZA
				Reclock("ZZA", .F.)
				ZZA->ZZA_STATUS := "S"
				MsUnLock()

				//altera status da ZZB
				ZZB->(dbSetOrder(1))
				ZZB->(dbSeek(xFilial("ZZB")+ZZA->ZZA_NUMPES))
				While ZZB->(!Eof()) .And. ZZB->(ZZB_FILIAL+ZZB_NUMPES) == xFilial("ZZB")+ZZA->ZZA_NUMPES
					If ZZB->ZZB_STATUS = 'Saldo Insuficiente'
						Reclock("ZZB", .F.)
						ZZB->ZZB_STATUS := "Transf.Solicitada"
						MsUnLock()
					EndIf
					ZZB->(dbSkip())
				EndDO

				FWAlertSuccess("Solicitação de transferencia foi criada corretamente!", "Gerar Transferencia")

			Else
				MostraErro()
			EndIf

		EndIf

	EndIf

	FWRestArea(aArea)

	oBrowse:Refresh()

Return lRet
/*/{Protheus.do		c} PEST001E
	Excluir _aLinha :=	 {} Transferencia de Saldo da ordem de pesagem
	@type function
	@version 1.0
	@author Jair Matos
	@since 09/05/2024
	@return variant, retorna t ou f
/*/
User Function PEST001E(lExcZZA)
	Local aArea 		:= FWGetArea()
	Local lRet 			:= .T.
	Local aCab   		:= {}
	Local aItens 		:= {}
	Local cQuery		:= ""
	Local nCodNNS		:= ""
	local cAliasCommit	:= getNextAlias()
	Local oModel
	Private lMsErroAuto := .F.

	If !lExcZZA
		If !FWAlertYesNo( "Solicitação de transferência de saldo será excluida. Deseja continuar?", "Excluir Transfêrencia" )
			Return
		EndIf
	EndIf
	//	Localizar a transferencia de acordo com o campo NNS_XORDPS
	cQuery := " SELECT NNS_COD FROM "+RetSQLName("NNS")+" WHERE D_E_L_E_T_ <> '*' "
	cQuery += " AND NNS_XORDPS ='"+ZZA->ZZA_NUMPES+"' "

	TCQuery cQuery New Alias &cAliasCommit
	if (cAliasCommit)->(!EOF())
		nCodNNS := (cAliasCommit)->NNS_COD
	EndIf

	(cAliasCommit)->(dbCloseArea())

	If !Empty(nCodNNS)
		AADD(aCab,{"NNS_FILIAL" ,FWxFilial("ZZA") ,".T."})
		AADD(aCab,{"NNS_COD" ,nCodNNS  			  ,".T."})

		oModel := FwLoadModel ("MATA311")

		FWMVCRotAuto(oModel,"NNS",5,{{"NNSMASTER",aCab},{"NNTDETAIL",aItens}})

		If !lMsErroAuto
			//altera status da ZZA
			Reclock("ZZA", .F.)
			ZZA->ZZA_STATUS := "E"
			MsUnLock()

			//altera status da ZZB
			ZZB->(dbSetOrder(1))
			ZZB->(dbSeek(xFilial("ZZB")+ZZA->ZZA_NUMPES))
			While ZZB->(!Eof()) .And. ZZB->(ZZB_FILIAL+ZZB_NUMPES) == xFilial("ZZB")+ZZA->ZZA_NUMPES
				If 	ZZB->ZZB_STATUS = 'Transf.Solicitada'
					Reclock("ZZB", .F.)
					ZZB->ZZB_STATUS := "Saldo Insuficiente"
					MsUnLock()
				EndIf
				ZZB->(dbSkip())
			EndDO

			If !lExcZZA
				FWAlertSuccess("Transferencia de saldo foi excluida corretamente!", "Excluir Transferencia")
			EndIf

		Else
			MostraErro()
		EndIf

	EndIf

	FWRestArea(aArea)

	oBrowse:Refresh()

Return lRet
/*/{Protheus.doc} PEST001A
Ajuste Empenho - rotina de pesagem após transferencia de saldo(Status da ZZB=trans.Realizada)
@type function
@version 1.0
@author Jair Matos
@since 20/05/2024
@return variant, retorna true ou false
/*/
User function PEST001A()
	Local lRet	:= .F.
	Local oSay 	:= NIL

	If ZZA->ZZA_STATUS!="R"
		FWAlertWarning("Ajuste de Empenho para a ordem de pesagem "+ZZA->ZZA_NUMPES+" já foi realizado.", "Atenção")
		Return lRet
	EndIf

	If FWAlertYesNo( "Deseja realizar ajuste de empenho para a ordem de pesagem "+ZZA->ZZA_NUMPES+" ?", "Ajuste Empenho" )
		FwMsgRun(NIL, {|oSay| lRet := fGeraEmp(oSay)}, "Aguarde", "Iniciando processo...")
	endIf

/*/{Protheus.doc} fGeraEmp
Function que ajusta os epenhos.
@type function
@version 1.0
@author Jair Matos
@since 10/06/2024
@param oSay, object, chama a regua
@return variant, retorna true ou false
/*/Return lRet
Static Function fGeraEmp(oSay)
	Local lRet 		:= .F.
	Local nX		:= 0
	Local nY		:= 0
	Local cQuery 	:= ""
	Local cAliasIte	:= "ZZB"
	Local cAlias	:= getNextAlias()
	Local _aEmp 	:= {}, _aEmpLin := {}, _aEmpCam :={}
	Local cLocaliz 	:= u_PesqNNR()

	cQuery := " SELECT MAX(ZZB_ITEM) ZZB_ITEM FROM "+RetSQLName("ZZB")+ " WHERE D_E_L_E_T_ <> '*' AND ZZB_NUMPES ='"+ZZA->ZZA_NUMPES+"' "
	TCQuery cQuery New Alias &cAlias
	If (cAlias)->(!EOF())
		cItZZB := (cAlias)->ZZB_ITEM
	EndIf
	(cAlias)->(DbCloseArea())

	ZZB->(dBsetOrder(1))
	If ZZB->(dBseek(FWxFilial("ZZB")+ZZA->ZZA_NUMPES))
		While ZZB->(!Eof()) .And. ZZB->(ZZB_FILIAL+ZZB_NUMPES) == ZZA->ZZA_FILIAL+ZZA->ZZA_NUMPES
			nX++
			oSay:SetText("Working at: " + StrZero(nX, 6)) // ALTERA O TEXTO CORRETO
			ProcessMessages() // FORÇA O DESCONGELAMENTO DO SMARTCLIENT

			If Alltrim(ZZB->ZZB_STATUS)=="Transf.Realizada"
				aIteSD4 := {}

				cQuery := " SELECT D4_FILIAL,D4_COD,D4_LOCAL,D4_QUANT,B1_COD, B1_XDESCAL, B1_XITPES, BF_LOTECTL, BF_LOCALIZ, "
				cQuery += " BF_NUMLOTE,BF_PRODUTO,BF_LOCAL, BF_QUANT ,B8_DTVALID, "
				cQuery += " (SELECT  SUM(BF_QUANT) FROM "+RetSQLName("SBF")+" SBF1 "
				cQuery += " WHERE BF_PRODUTO = D4_COD AND BF_LOCAL = '"+cLocaliz+"'  AND SBF1.D_E_L_E_T_ =' ' AND (BF_QUANT - BF_EMPENHO) >0) AS QTDSBF
				cQuery += " FROM "+RetSQLName("SD4")+" SD4 "
				cQuery += " INNER JOIN "+RetSQLName("SB1")+" SB1  "
				cQuery += " ON SB1.D_E_L_E_T_ <> '*' AND B1_COD = D4_COD AND B1_XITPES = 'S' "
				cQuery += " LEFT JOIN "+RetSQLName("SBF")+" SBF  "
				cQuery += " ON SBF.D_E_L_E_T_ <> '*' AND BF_FILIAL = D4_FILIAL AND BF_LOCAL='"+cLocaliz+"' AND BF_PRODUTO = D4_COD AND (BF_QUANT - BF_EMPENHO) >0"
				cQuery += " LEFT JOIN "+RetSQLName("SB8")+" SB8  "
				cQuery += " ON SB8.D_E_L_E_T_ <> '*' AND B8_FILIAL = BF_FILIAL AND B8_LOCAL = BF_LOCAL AND B8_PRODUTO = BF_PRODUTO AND B8_SALDO = BF_QUANT "
				cQuery += " WHERE SD4. D_E_L_E_T_ <> '*'
				cQuery += " AND D4_FILIAL='" + FWxFilial("SD4") + "'"
				cQuery += " AND D4_OP ='" + ZZB->ZZB_NUMOP + "'"
				cQuery += " AND D4_COD ='" + ZZB->ZZB_CODPRD + "'"
				cQuery += " AND D4_QUANT > 0 "
				cQuery += " ORDER BY D4_COD,B8_DTVALID "

				TCQUERY cQuery NEW ALIAS &cAlias

				If (cAlias)->(!Eof())
					nCont := 1
					While !(cAlias)->(Eof())

						nQtd := fCalcSld(.F.,(cAlias)->BF_PRODUTO,(cAlias)->BF_QUANT,(cAlias)->D4_QUANT,(cAlias)->B8_DTVALID,(cAlias)->QTDSBF)
						If nQtd > 0
							_aEmp := {}
							If nCont==1
								Aadd(_aEmp,{"ZZB_FILIAL" ,ZZB->ZZB_FILIAL   					, Nil } )
								Aadd(_aEmp,{"ZZB_NUMPES" ,ZZB->ZZB_NUMPES						, Nil } )
								Aadd(_aEmp,{"ZZB_ITEM"   ,ZZB->ZZB_ITEM							, Nil } )
								Aadd(_aEmp,{"ZZB_NUMOP"  ,ZZB->ZZB_NUMOP						, Nil } )
								Aadd(_aEmp,{"ZZB_CODPRD" ,ZZB->ZZB_CODPRD						, Nil } )
								Aadd(_aEmp,{"ZZB_LOCAL"  ,(cAlias)->D4_LOCAL					, Nil } )
								Aadd(_aEmp,{"ZZB_QUANT"  ,nQtd									, Nil } )
								Aadd(_aEmp,{"ZZB_LOTE"   ,(cAlias)->BF_LOTECTL					, Nil } )
								Aadd(_aEmp,{"ZZB_END"    ,(cAlias)->BF_LOCALIZ					, Nil } )
								Aadd(_aEmp,{"ZZB_DTVLD"  ,Stod((cAlias)->B8_DTVALID)			, Nil } )
								aAdd( _aEmpLin , _aEmp )
							Else

								Aadd(_aEmp,{"ZZB_FILIAL" ,(cAlias)->D4_FILIAL					, Nil } )
								Aadd(_aEmp,{"ZZB_NUMPES" ,ZZA->ZZA_NUMPES						, Nil } )
								Aadd(_aEmp,{"ZZB_ITEM"   ,Soma1(cItZZB)							, Nil } )
								Aadd(_aEmp,{"ZZB_NUMOP"  ,ZZA->ZZA_NUMOP						, Nil } )
								Aadd(_aEmp,{"ZZB_CODPRD" ,(cAlias)->D4_COD						, Nil } )
								Aadd(_aEmp,{"ZZB_LOCAL"  ,(cAlias)->D4_LOCAL					, Nil } )
								Aadd(_aEmp,{"ZZB_QUANT"  ,nQtd									, Nil } )
								Aadd(_aEmp,{"ZZB_LOTE"   ,(cAlias)->BF_LOTECTL					, Nil } )
								Aadd(_aEmp,{"ZZB_END"    ,(cAlias)->BF_LOCALIZ					, Nil } )
								Aadd(_aEmp,{"ZZB_DTVLD"  ,Stod((cAlias)->B8_DTVALID)			, Nil } )
								Aadd(_aEmp,{"ZZB_FASE"   ,POSICIONE("SG1",1,FWXFILIAL("SG1")+ZZA->ZZA_PRDPAI+(cAlias)->D4_COD,"G1_XFASE")	, Nil } )
								Aadd(_aEmp,{"ZZB_STATUS" ,"Transf.Realizada"					, Nil } )
								aAdd( _aEmpLin , _aEmp )
							EndIf

							_aEmp	:= {}
							aAdd(_aEmp,{"D4_OP"     ,ZZB->ZZB_NUMOP								,NIL})
							aAdd(_aEmp,{"D4_COD"    ,ZZB->ZZB_CODPRD            				,NIL})
							aAdd(_aEmp,{"D4_LOCAL"  ,ZZB->ZZB_LOCAL      						,NIL})
							aAdd(_aEmp,{"D4_DATA"   ,date()										,NIL})
							aAdd(_aEmp,{"D4_QTDEORI",nQtd              							,NIL})
							aAdd(_aEmp,{"D4_QUANT"  ,nQtd            							,NIL})
							aAdd(_aEmp,{"D4_LOTECTL",(cAlias)->BF_LOTECTL	              		,NIL})
							aAdd(_aEmp,{"D4_XNUMPES",ZZB->ZZB_NUMPES+ZZB->ZZB_ITEM          	,NIL})
							aAdd(aIteSD4,_aEmp)
						EndIF
						nCont++
						(cAlias)->(dbSkip())
					EndDO
					(cAlias)->(dbCloseArea())
				endIf
			EndIf
			ZZB->(dbSkip())
		EndDO
	EndIf

	lRet := fGravaSD4(ZZA->ZZA_NUMOP,.F.)

	If lRet
		//altera status da ZZA
		Reclock("ZZA", .F.)
		ZZA->ZZA_STATUS := "A"//altera o STATUS para Aguardando Pesagem
		MsUnLock()

		//grava ZZB
		For nX := 1 To Len(_aEmpLin)
			_aEmpCam	:= _aEmpLin[nX]
			If Len(_aEmpCam)==10
				ZZB->(dBseek(FWxFilial("ZZB")+_aEmpCam[2][2]+_aEmpCam[5][2]))
				Reclock(cAliasIte, .F.)
			Else
				Reclock(cAliasIte, .T.)
			EndIf
			For nY := 1 To Len(_aEmpCam)
				cCampo	:= cAliasIte+'->'+_aEmpCam[nY][1]
				&cCampo := _aEmpCam[nY,02]
			Next nY
			MsUnLock()
		Next nX

		FWAlertSuccess("Ajuste de Empenho para a pesagem "+ZZA->ZZA_NUMPES+" gerada corretamente!", "Ajuste Empenho")
	EndIf

Return lRet
/*/{Protheus.doc} PEST001R
Função que refaz a pesagem completa ou fracionada.
@type function
@version 1.0
@author Jair Matos
@since 29/05/2024
@return variant, lret, retorna true ou false
/*/
User Function PEST001R(lGera)
	Local lRet 		:= .T.
	Local oModel     := FwModelActive()
	Local oModelGrid := Nil
	Local nLinha
	Local cMsg		 := ""

	If !lGera//Gera pesagem parcial por item .F.
		oModelGrid:= oModel:getModel("ZZBDETAIL")
		nLinha := PADL(Alltrim(cValtochar(oModelGrid:GetLine())),TamSX3("ZZB_ITEM")[1],"0")
		cMsg := "Deseja excluir a pesagem para o Item "+PADL(Alltrim(cValtochar(nLinha)),TamSX3("ZZB_ITEM")[1],"0")+" da ordem de pesagem "+ZZA_NUMPES+" ?"
	Else
		cMsg := "Deseja excluir todas as pesagens efetuadas na ordem de pesagem "+ZZA_NUMPES+" ?"
	EndIf

	If ZZA->ZZA_STATUS !='F'
		FWAlertWarning("Refazer Pesagem só poderá ser gerada com Status 'F' - Pesagem Finalizada", "Refazer Pesagem")
		Return lRet
	EndIf

	If FWAlertYesNo( cMsg, "Refazer pesagem" )
		ZZA->(dbSetOrder(1))
		If ZZA->(dbSeek(xFilial("ZZA")+ZZA->ZZA_NUMPES))
			Reclock("ZZA", .F.)
			ZZA->ZZA_STATUS := "A"
			ZZA->ZZA_DTINI 	:= StoD(" ")
			ZZA->ZZA_HORAIN := ""
			ZZA->ZZA_DTFIM 	:= StoD(" ")
			ZZA->ZZA_HORAF 	:= ""
			MsUnLock()

			ZZB->(dbSetOrder(1))
			If ZZB->(dbSeek(xFilial("ZZB")+ZZA->ZZA_NUMPES))
				While ZZB->(!Eof()) .And. ZZB->(ZZB_FILIAL+ZZB_NUMPES) == ZZA->ZZA_FILIAL+ZZA->ZZA_NUMPES
					If lGera
						Reclock("ZZB", .F.)
						ZZB->ZZB_QTDPES := 0
						ZZB->ZZB_USER := ""
						ZZB->ZZB_ETIQ := ""
						ZZB->ZZB_STATUS := "Aguardando Pesagem"
						MsUnLock()
					Else
						If nLinha==ZZB->ZZB_ITEM
							Reclock("ZZB", .F.)
							ZZB->ZZB_QTDPES := 0
							ZZB->ZZB_USER := ""
							ZZB->ZZB_ETIQ := ""
							ZZB->ZZB_STATUS := "Aguardando Pesagem"
							MsUnLock()
							If oModel:IsActive()
								oModel:DeActivate()
							EndIf
							oModel:Activate()
						EndIf
					EndIf
					ZZB->(dbSkip())
				EndDO
			EndIf
		endIf
		oBrowse:Refresh()
	EndIf

Return lRet
