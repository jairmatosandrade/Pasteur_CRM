#include "protheus.ch"
#include "fwmvcdef.ch"
#include "restful.ch"
#Include "TBICONN.ch"
#INCLUDE "topconn.ch"
/*/{Protheus.doc} WSMATA381
Fonte que serA responsavel pela gravacao dos dados vindos do FLUIG para alterar a rotina de Empenho Multiplo MATA381
@type function
@version 1.0
@author Jair Matos  
@since 19/06/2024
@param aIteSD4, array, array com os dados
@return ARRAY, array com o retorno.
/*/
WSRESTFUL WsEmpenhoMultiplo DESCRIPTION "Serviço REST para manipulação de Empenho Multiplo."

	WSDATA CodSD4 As String

	WSMETHOD GET  DESCRIPTION "Retorna o empenho informado" WSSYNTAX "/WsEmpenhoMultiplo"
	WSMETHOD PUT DESCRIPTION "Edição do empenho informado " WSSYNTAX "/WsEmpenhoMultiplo"

END WSRESTFUL
/*/{Protheus.doc}METODO GET 
Função que sera responsavel pela pesquisa GET feita na tabela SD4
@type function
@version 1.0
@author Jair Matos  
@since 19/06/2024
@param aIteSD4, array, array com os dados
@return ARRAY, array com o retorno.
/*/
WSMETHOD GET WSRECEIVE CodSD4 WSSERVICE WsEmpenhoMultiplo
	local aAreaSD4 as array
	Local aObjSD4 as array
	Local aArea as array
	Local cCodSD4 as char
	Local cJson as char
	Local jObjProd

	cCodSD4 := Self:CodSD4
	aArea := GetArea()
	aAreaSD4 := SD4->( GetArea() )

	::SetContentType("application/json")

	DbSelectArea("SD4")
	SD4->( DbSetOrder(2) )

	if SD4->( DbSeek( xFilial("SD4") + PadR(cCodSD4,tamSx3("D4_OP")[1]) ) )
		aObjSD4 := {}

		aAdd( aObjSD4,  JsonObject():New() )

		aObjSD4[1]["Codigo"] 		:= cCodSD4
		aObjSD4[1]["Armazem"] 		:= SD4->D4_LOCAL
		aObjSD4[1]["OP"] 			:= SD4->D4_OP
		aObjSD4[1]["Data"] 			:= DTOC(SD4->D4_DATA)
		aObjSD4[1]["Qtd.Ori."] 		:= SD4->D4_QTDEORI
		aObjSD4[1]["Quant."] 		:= SD4->D4_QUANT

		jObjProd :=  JsonObject():New()
		jObjProd["WsEmpenhoMultiplo"] := aObjSD4

		cJson := jObjProd:toJson()
		::setResponse(cJson)
	else
		SetRestFault(400,"OP nao existe: " + cCodSD4)
		return .F.
	endIf

	RestArea(aAreaSD4)
	RestArea(aArea)

return .T.

/*/{Protheus.doc} METODO PUT
Funçao responsavel pela execução do metodo PUT - Edição da rotina automatica MATA381.
@type function
@version 1.0
@author jair Matos
@since 05/06/2024
@param aIteSD4, array, array com os dados para serem utilizados na alteração
@return array, array com dados da gravação.
/*/
WSMETHOD PUT WSRECEIVE NULLPARAM WSSERVICE WsEmpenhoMultiplo
	Local cError 		as char
	Local cJson 		as char
	Local cRetJson 		as char
	Local cAlias 		as char
	Local lOk 			as logical
	Local aAreaSD4 		as array
	Local lRet 	        := .T.
	Local cMsg          := ""
	Local cNumPes		:= ""
	Local nX        	:= 0
	Local nY        	:= 0
	Local cItZZB		:= ""
	Local cQuery		:= ""
	local cAliasZZB		:= getNextAlias()
	Local aCabSD4		:= {}
	Local aItens    	:= {}
	Local _aEmp:={},_aLinha:= {},_aEmpLin:= {}, _aEmpCam:= {}
	Local nOpc          := 4 //Alterar
	Local cPathTmp		:= "\wsfluigerrors\"
	Local cArqTmp 		:= "WSALTERASD4_" + DToS( Date( ) ) + "_" + StrTran( Time( ), ":", "" ) + "_.txt"
	Local cCodSD4		:= Self:CodSD4
	Local cLocaliz 		:= u_PesqNNR()
	private lMsErroAuto := .F.
	Private lMsHelpAuto :=.T.
	Private aVetor      := {}
	Default aIteSD4     := {}

	Self:SetContentType("application/json")

	cJson := JsonObject():New()
	cError := cJson:fromJson( self:getContent() )
	lOk := .F.

	if Empty(cError)
		cAlias := Alias()
		aAreaSD4 := SD4->( GetArea() )

		SD4->( DbSetOrder(2) )
		if SD4->( DbSeek( xFilial("SD4") + PadR(cCodSD4,tamSx3("D4_OP")[1]) ) )
			cNumPes := Substr(SD4->D4_XNUMPES,1,TamSX3("ZZA_NUMPES")[1])
			cQuery := " SELECT MAX(ZZB_ITEM) ZZB_ITEM FROM "+RetSQLName("ZZB")+ " WHERE D_E_L_E_T_ <> '*' AND ZZB_NUMPES ='"+cNumPes+"' "
			TCQuery cQuery New Alias &cAliasZZB
			If (cAliasZZB)->(!EOF())
				cItZZB := (cAliasZZB)->ZZB_ITEM
			EndIf
			(cAliasZZB)->(DbCloseArea())
			
			For nX := 1 to len(cJson['Items'])
				_aLinha	:= {}
				aAdd(_aLinha,{"D4_OP"     ,cJson['Items'][nX]['OP'] 				,NIL})
				aAdd(_aLinha,{"D4_COD"    ,cJson['Items'][nX]['PRODUTO'] 	        ,NIL})
				aAdd(_aLinha,{"D4_LOCAL"  ,cLocaliz									,NIL})
				aAdd(_aLinha,{"D4_DATA"   ,ctod(cJson['Items'][nX]['DATA']) 		,NIL})
				aAdd(_aLinha,{"D4_QTDEORI",cJson['Items'][nX]['QTDORI'] 			,NIL})
				aAdd(_aLinha,{"D4_QUANT"  ,cJson['Items'][nX]['QUANT'] 				,NIL})
				aAdd(_aLinha,{"D4_LOTECTL",cJson['Items'][nX]['LOTECTL'] 			,NIL})
				aAdd(_aLinha,{"D4_XNUMPES",cJson['Items'][nX]['XNUMPES'] 			,NIL})
				aAdd(aIteSD4,_aLinha)

				_aEmp := {}
				Aadd(_aEmp,{"ZZB_FILIAL" ,SD4->D4_FILIAL   						, Nil } )
				Aadd(_aEmp,{"ZZB_NUMPES" ,SD4->D4_XNUMPES						, Nil } )
				Aadd(_aEmp,{"ZZB_ITEM"   ,Soma1(cItZZB)							, Nil } )
				Aadd(_aEmp,{"ZZB_NUMOP"  ,cJson['Items'][nX]['OP']				, Nil } )
				Aadd(_aEmp,{"ZZB_CODPRD" ,cJson['Items'][nX]['PRODUTO'] 		, Nil } )
				Aadd(_aEmp,{"ZZB_LOCAL"  ,cLocaliz								, Nil } )
				Aadd(_aEmp,{"ZZB_QUANT"  ,cJson['Items'][nX]['QUANT']			, Nil } )
				Aadd(_aEmp,{"ZZB_STATUS" ,"Aguardando Pesagem"					, Nil } )
				aAdd( _aEmpLin , _aEmp )
			Next nX

			//Monta o cabeçalho com o número da OP que será alterada.
			//Necessário utilizar o índice 2 para efetuar _aLinha 	:= {} alteração.
			aCabSD4 := {{"D4_OP",cCodSD4,NIL},;
				{"INDEX",2,Nil}}

			For nX := 1 to len(aIteSD4)
				aAdd( aItens , aIteSD4[nx] )
			Next nX

			SetModulo("SIGAPCP","PCP")
			MSExecAuto({|x,y,z| mata381(x,y,z)}, aCabSD4, aItens, nOpc)

			If lMsErroAuto
				U_fCriaDir( cPathTmp )
				MostraErro( cPathTmp, cArqTmp )
				cMsg += " " + MemoRead( cPathTmp + cArqTmp )
				SetRestFault(400, cMsg)
				lRet := .F.
				DisarmTransaction()
			Else
				//altera status da ZZA
				dBselectarea("ZZA")
				ZZA->(dBsetOrder(1))
				if ZZA->(dBseek(FWxFilial("ZZA")+cNumPes))

					Reclock("ZZA", .F.)
					ZZA->ZZA_STATUS := "A"//altera o STATUS para Aguardando Pesagem
					MsUnLock()

					//grava ZZB
					For nX := 1 To Len(_aEmpLin)
						_aEmpCam	:= _aEmpLin[nX]
						Reclock("ZZB", .T.)
						For nY := 1 To Len(_aEmpCam)
							cCampo	:= "ZZB"+'->'+_aEmpCam[nY][1]
							&cCampo := _aEmpCam[nY,02]
						Next nY
						MsUnLock()
					Next nX
				EndIf

				cRetJson := '{"OPRODUCAO":"' + SD4->D4_OP + '"';
					+ ',"msg":"'  + "OP Editada com sucesso"          + '"';
					+'}'
				::SetResponse(cRetJson)
			Endif
		else
			SetRestFault(400, "OP não cadastrada: " + SD4->D4_OP)
			lRet := .F.
		endif

		RestArea(aAreaSD4)

		if !Empty(cAlias)
			DBSelectArea(cAlias)
		endif
	else
		ConErr(cError)
		setRestFault(400)
	endif

Return lRet

