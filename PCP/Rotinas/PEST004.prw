//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "topconn.ch"
#include "fileio.ch"
#include "tbiconn.ch"
/*/{Protheus.doc} PEST004
Desenvolvimento integração Protheus x Fluig – Processo Envase
@type function
@version 1.0    
@author Jair Matos
@since 25/06/2024
/*/
User Function PEST004()
	Local cCadastro := "Pasteur - Processo Envase"
	Private aCpoInfo    := {}
	Private aCampos     := {}
	Private aCpoData    := {}
	Private oTable      := Nil
	Private oMarkBrow   := Nil
	Private aSeek 		:= {}, aFieFilter := {}, aIndex := {},aTamX3Flds := {}

	FwMsgRun(,{ || fLoadData() }, cCadastro, 'Carregando op´s...')

	aTamX3Flds := {TamSX3("D4_FILIAL")[01]+TamSX3("D4_OP")[01]}
	aSeek := {{"Filial+Num.OP", {{"LookUp", "C", aTamX3Flds[1], 0, "",,}} , 1, .T. }}

	//Campos que irão compor a tela de filtro
	Aadd(aFieFilter,{"TMP_FILIAL"	, "Filial"	   , "C", TamSX3("D4_FILIAL")[01], 0,"@!"})
	Aadd(aFieFilter,{"TMP_NUM"		, "Num.OP"	   , "C", TamSX3("D4_OP")[01], 0,"@!"})
	Aadd(aIndex, "TMP_NUM" )

	oMarkBrow := FwMarkBrowse():New()
	oMarkBrow:SetAlias('TRB')
	oMarkBrow:SetTemporary()
	oMarkBrow:SetColumns(aCampos)
	oMarkBrow:SetFieldMark('TMP_OK')
	oMarkBrow:SetAllMark({|| A004MkAll(oMarkBrow) })
	oMarkBrow:SetMenuDef('PEST004')
	oMarkBrow:SetDescription('Processo de Envase')
	//oMarkBrow:SetQueryIndex(aIndex)
	oMarkBrow:SetSeek(,aSeek)
	oMarkBrow:SetFieldFilter(aFieFilter)
	oMarkBrow:Activate()

	If(Type('oTable') <> 'U')

		oTable:Delete()
		oTable := Nil

	Endif

Return
/*/{Protheus.doc} MenuDef
Menu
@type function
@version  1.0   
@author Jair Matos
@since 25/06/2024
@return array, retorna array com menu
/*/
Static Function MenuDef
	Local aRotina := {}

	Add Option aRotina Title 'Integrar FLUIG'  Action 'U_PEST006("TRB")'          Operation 3 Access 0

Return(aRotina)
/*/{Protheus.doc} fLoadData
Carrega os dados da tabela SC2
@type function
@version 1.0
@author Jair Matos
@since 25/06/2024
/*/
Static Function fLoadData
	Local nI        := 0
	Local _cAlias   := GetNextAlias()
	Local cQuery	:= ""


	If(Type('oTable') <> 'U')

		oTable:Delete()
		oTable := Nil

	Endif

	oTable     := FwTemporaryTable():New('TRB')

	aCampos     := {}
	aCpoInfo := {}
	aCpoData := {}

	aAdd(aCpoInfo, {'Marcar'            , '@!'                         , 1})
	aAdd(aCpoInfo, {'Filial'            , '@!'                         , 1})
	aAdd(aCpoInfo, {'Numero OP'         , '@!'                         , 1})
	aAdd(aCpoInfo, {'Item'              , '@!'                         , 1})
	aAdd(aCpoInfo, {'Sequencia'         , '@!'                         , 1})
	aAdd(aCpoInfo, {'Produto'           , '@!'                         , 1})
	aAdd(aCpoInfo, {'Descrição'         , '@!'                         , 1})
	aAdd(aCpoInfo, {'Local'             , '@!'                         , 1})
	aAdd(aCpoInfo, {'Quant.'            , '@E 999,999,999,999.99'      , 1})
	aAdd(aCpoInfo, {'Um.'               , '@!'                         , 1})
	aAdd(aCpoInfo, {'Prev.Ini'          , '@!'                         , 1})
	aAdd(aCpoInfo, {'Entrega'           , '@!'                         , 1})
	aAdd(aCpoInfo, {'Dt.Emissao'        , '@!'                         , 1})
	aAdd(aCpoInfo, {'Ordem Pesagem'     , '@!'                         , 1})

	aAdd(aCpoData, {'TMP_OK'    , 'C'                    , 2                      , 0})
	aAdd(aCpoData, {'TMP_FILIAL', TamSx3('C2_FILIAL')[3] , TamSx3('C2_FILIAL')[1] , 0})
	aAdd(aCpoData, {'TMP_NUM'   , TamSx3('C2_NUM')[3]    , TamSx3('C2_NUM')[1]    , 0})
	aAdd(aCpoData, {'TMP_ITEM'  , TamSx3('C2_ITEM')[3]   , TamSx3('C2_ITEM')[1]   , 0})
	aAdd(aCpoData, {'TMP_SEQ'   , TamSx3('C2_SEQUEN')[3] , TamSx3('C2_SEQUEN')[1] , 0})
	aAdd(aCpoData, {'TMP_PROD'  , TamSx3('C2_PRODUTO')[3], TamSx3('C2_PRODUTO')[1], 0})
	aAdd(aCpoData, {'TMP_DESC'  , TamSx3('B1_DESC')[3],    30/*TamSx3('B1_DESC')[1]*/,0})
	aAdd(aCpoData, {'TMP_LOCAL' , TamSx3('C2_LOCAL')[3]  , TamSx3('C2_LOCAL')[1]  , 0})
	aAdd(aCpoData, {'TMP_QUANT' , TamSx3('C2_QUANT')[3]  , TamSx3('C2_QUANT')[1]  , 0})
	aAdd(aCpoData, {'TMP_UM'    , TamSx3('C2_UM')[3]     , TamSx3('C2_UM')[1]     , 0})
	aAdd(aCpoData, {'TMP_DTINI' , TamSx3('C2_DATPRI')[3] , TamSx3('C2_DATPRI')[1] , 0})
	aAdd(aCpoData, {'TMP_DTENT' , TamSx3('C2_DATPRF')[3] , TamSx3('C2_DATPRF')[1] , 0})
	aAdd(aCpoData, {'TMP_DTEMI' , TamSx3('C2_EMISSAO')[3], TamSx3('C2_EMISSAO')[1], 0})
	aAdd(aCpoData, {'TMP_ORPES' , TamSx3('C2_XORDPES')[3], TamSx3('C2_XORDPES')[1], 0})

	For nI := 1 To Len(aCpoData)

		If(aCpoData[nI][1] <> 'TMP_OK' .and. aCpoData[nI][1] <> 'TMP_RECNO')

			aAdd(aCampos, FwBrwColumn():New())

			aCampos[Len(aCampos)]:SetData( &('{||' + aCpoData[nI,1] + '}') )
			aCampos[Len(aCampos)]:SetTitle(aCpoInfo[nI,1])
			aCampos[Len(aCampos)]:SetPicture(aCpoInfo[nI,2])
			aCampos[Len(aCampos)]:SetSize(aCpoData[nI,3])
			aCampos[Len(aCampos)]:SetDecimal(aCpoData[nI,4])
			aCampos[Len(aCampos)]:SetAlign(aCpoInfo[nI,3])

		EndIf

	Next nI

	oTable:SetFields(aCpoData)
	oTable:addIndex("1", {"TMP_NUM"})
	oTable:Create()

	cQuery := " SELECT SC2.C2_FILIAL,SC2.C2_NUM,SC2.C2_ITEM,SC2.C2_SEQUEN,SC2.C2_PRODUTO,SC2.C2_LOCAL, "
	cQuery += " SC2.C2_QUANT,SC2.C2_UM,SC2.C2_DATPRI,SC2.C2_DATPRF,SC2.C2_EMISSAO,SC2.C2_XORDPES,SB1.B1_DESC,C2_DATRF "
	cQuery += " FROM "+ RetSqlName("SC2") +" SC2 "
	cQuery += " INNER JOIN "+ RetSqlName("SB1") +" SB1 ON SB1.D_E_L_E_T_ <>  '*'  AND B1_FILIAL ='" + FWxFilial("SB1") + "'"
	cQuery += " AND B1_COD = SC2.C2_PRODUTO "
	cQuery += " LEFT JOIN "+ RetSqlName("SG2") +" SG2 ON SG2.D_E_L_E_T_ <>  '*'  AND G2_FILIAL ='" + FWxFilial("SG2") + "'"
	cQuery += " AND G2_PRODUTO = SC2.C2_PRODUTO AND G2_CODIGO = SC2.C2_ROTEIRO AND SG2.G2_XTPOPER='E' "
	cQuery += " WHERE C2_FILIAL ='" + FWxFilial("SC2") + "'"
	cQuery += " AND SC2.C2_DATRF = '' "
	cQuery += " AND C2_XIFLUIG != 'S' "
	cQuery += " AND SC2.D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY C2_NUM "

	TCQUERY cQuery NEW ALIAS &_cAlias

	dbSelectArea(_cAlias)
	(_cAlias)->(DBGoTop())

	DbSelectArea('TRB')

	While(!(_cAlias)->(EoF()))

		RecLock('TRB', .T.)

		TRB->TMP_FILIAL := (_cAlias)->C2_FILIAL
		TRB->TMP_NUM    := (_cAlias)->C2_NUM
		TRB->TMP_ITEM   := (_cAlias)->C2_ITEM
		TRB->TMP_SEQ    := (_cAlias)->C2_SEQUEN
		TRB->TMP_PROD   := (_cAlias)->C2_PRODUTO
		TRB->TMP_DESC   := (_cAlias)->B1_DESC
		TRB->TMP_LOCAL  := (_cAlias)->C2_LOCAL
		TRB->TMP_QUANT  := (_cAlias)->C2_QUANT
		TRB->TMP_UM     := (_cAlias)->C2_UM
		TRB->TMP_DTINI  := stod((_cAlias)->C2_DATPRI)
		TRB->TMP_DTENT  := stod((_cAlias)->C2_DATPRF)
		TRB->TMP_DTEMI  := stod((_cAlias)->C2_EMISSAO)
		TRB->TMP_ORPES  := (_cAlias)->C2_XORDPES

		TRB->(MsUnlock())

		(_cAlias)->(DbSkip())

	EndDo

	TRB->(DbGoTop())

	(_cAlias)->(DbCloseArea())

Return
/*/{Protheus.doc} A004MkAll
Marca todos.
@type function
@author Jair Matos
@since 25/06/2024
/*/
Static Function A004MkAll(oMrkBrowse)

	Local cAlias		:= oMrkBrowse:Alias()
	Local aArea   	:= GetArea(cAlias)

	(cAlias)->(DBGoTop())
	While (cAlias)->(!Eof())
		oMrkBrowse:MarkRec()
		(cAlias)->(DbSkip())
	End
	(cAlias)->(DBGoTop())
	oMrkBrowse:Refresh()
	RestArea(aArea)

Return .T.
