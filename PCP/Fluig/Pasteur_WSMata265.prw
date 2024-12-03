#include "protheus.ch"
#include "fwmvcdef.ch"
#include "restful.ch"
#Include "TBICONN.ch"
#INCLUDE "topconn.ch"
/*/{Protheus.doc} WSMATA265
Fonte que sera responsavel pela gravacao dos dados vindos do FLUIG para gerar Rotina Automática de Endereçamento
@type function
@version 1.0
@author Jair Matos  
@since 17/06/2024
@param aVetor, array, array com os dados
@return variant, array com o retorno.
/*/
WSRESTFUL WsEnderecamento DESCRIPTION "Serviço REST para manipulação de Endereçamento de produtos"

	WSDATA CodPrd As String
	WSDATA cLocal As String
	WSDATA cLoteCTL As String

	WSMETHOD GET  DESCRIPTION "Retorna o endereçamento do produto informado" WSSYNTAX "/WsEnderecamento"
	WSMETHOD POST DESCRIPTION "Grava o endereçamento do produto informado" WSSYNTAX "/WsEnderecamento"

END WSRESTFUL

/*/{Protheus.doc} GET
Funcao que busca os dados de endereçamento
@type function
@version  1.0   
@author Jair Matos
@since 20/06/2024
@param CodPrd, variant, variavel que contem o codigo do produto
/*/
WSMETHOD GET WSRECEIVE CodPrd,cLocal,cLoteCTL WSSERVICE WsEnderecamento
	local aAreaSDA as array
	Local aObjPrd as array
	Local aArea as array
	Local cJson as char
	Local jObjProd

	aArea := GetArea()
	aAreaSDA := SDA->( GetArea() )

	::SetContentType("application/json")

	DbSelectArea("SDA")
	SDA->( DbSetOrder(2) )

	if SDA->( DbSeek( xFilial("SDA") + PadR(Self:CodPrd,15)+Self:cLocal+Self:cLoteCTL ))
		aObjPrd := {}

		aAdd( aObjPrd,  JsonObject():New() )

		aObjPrd[1]["Produto"] 	:= SDA->DA_PRODUTO
		aObjPrd[1]["Armazem"] 	:= SDA->DA_LOCAL
		aObjPrd[1]["Sequencial"]:= SDA->DA_NUMSEQ
		aObjPrd[1]["Qtd.Ori."] 	:= SDA->DA_QTDORI
		aObjPrd[1]["Saldo"] 	:= SDA->DA_SALDO
		aObjPrd[1]["Lote"]	 	:= SDA->DA_LOTECTL
		aObjPrd[1]["Data"] 		:= DTOC(SDA->DA_DATA)

		jObjProd :=  JsonObject():New()
		jObjProd["WsEnderecamento"] := aObjPrd

		cJson := jObjProd:toJson()
		::setResponse(cJson)
	else
		SetRestFault(400,"Enderecamento nao existe: " + Self:CodPrd)
		return .F.
	endIf

	RestArea(aAreaSDA)
	RestArea(aArea)

return .T.
/*/{Protheus.doc} POST
Funcao que grava os dados do endereçamento
@type function
@version  1.0   
@author Jair Matos
@since 20/06/2024
/*/
WSMETHOD POST WSRECEIVE NULLPARAM WSSERVICE WsEnderecamento
	Local cMsg          := ""
	Local cQuery		:= ""
	Local cNumseq		:= ""
	local cAliasSD3		:= getNextAlias()
	Local cPathTmp		:= "\wsfluigerrors\"
	Local cArqTmp 		:= "WSIncluiSDA_" + DToS( Date( ) ) + "_" + StrTran( Time( ), ":", "" ) + "_.txt"
	Local aCabSDA       := {}
	Local aItSDB        := {}
	Local _aItensSDB    := {}
	Local cError as char
	Local cJson as char
	Local cRetJson as char
	Local cAlias as char
	Local lOk as logical
	Local aAreaSDA as array
	private lMsErroAuto := .F.
	Private lMsHelpAuto :=.T.

	Self:SetContentType("application/json")

	cJson := JsonObject():New()
	cError := cJson:fromJson( self:getContent() )
	lOk := .F.

	if Empty(cError)
		cAlias := Alias()
		aAreaSDA := SDA->( GetArea() )

		cQuery := " SELECT  D3_NUMSEQ "
		cQuery += " FROM "+RetSQLName("SD3")+ " SD3 WHERE SD3.D_E_L_E_T_ <> '*' 
		cQuery += " INNER JOIN "+RetSQLName("SH6")+ " SH6 "
		cQuery += " ON  H6_IDENT = D3_IDENT AND D3_COD = H6_PRODUTO AND SH6.D_E_L_E_T_ <> '*' "
		cQuery += " AND D3_OP ='"+cJson["OP"]+"' "
		cQuery += " AND D3_COD = '"+cJson["PRODUTO"]+"' "
		cQuery += " AND D3_CF = 'PR0'

		TCQuery cQuery New Alias &cAliasSD3
		If (cAliasSD3)->(!EOF())
			cNumseq := (cAliasSD3)->D3_NUMSEQ
		EndIf
		(cAliasSD3)->(DbCloseArea())

		DbSelectArea("SDA")
		SDA->(dBsetOrder(1)) //DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_NUMSEQ
		If SDA->( DbSeek( xFilial("SDA") + cJson["PRODUTO"]+  cArmazem+cNumseq) ) //arrumar consulta SH6->SD3->SDA COM NUMSEQ igual

			//Cabecalho com a informaçãoo do item e NumSeq que sera endereçado.
			aCabSDA :=  {{"DA_PRODUTO" ,cJson["PRODUTO"],Nil},;
				{"DA_LOCAL"  ,SDA->DA_LOCAL,Nil},;
				{"DA_NUMSEQ"  ,SDA->DA_NUMSEQ,Nil}}

			//Dados do item que será endereçado
			aItSDB := {{"DB_ITEM"       ,PADL(1,TamSX3("DB_ITEM")[01],"0")  ,Nil},;
				{"DB_ESTORNO"           ,""            						,Nil},;
				{"DB_LOCALIZ"           ,""		        					,Nil},;
				{"DB_DATA"              ,dDataBase      					,Nil},;
				{"DB_HRINI" 			,Time() 							,Nil},;
				{"DB_DATA" 				,Date() 							,Nil},;
				{"DB_QUANT"             ,cJson["QUANT"]  					,Nil}}
			aadd(_aItensSDB,aitSDB)

			//Executa o endere?amento do item
			MATA265( aCabSDA, _aItensSDB, 3)

			If lMsErroAuto
				U_fCriaDir( cPathTmp )
				MostraErro( cPathTmp, cArqTmp )
				cMsg += " " + MemoRead( cPathTmp + cArqTmp )
				SetRestFault(400, cMsg)
				lRet := .F.
				DisarmTransaction()
			Else
				cRetJson := '{"PRODUTO":"' + SDA->DA_PRODUTO + '"';
					+ ',"msg":"'  + "Enderecado com Sucesso"          + '"';
					+'}'
				::SetResponse(cRetJson)
			Endif
		else
			SetRestFault(400, "Endereçamento já cadastrado: " + SDA->H6_OP)
		endif

		RestArea(aAreaSDA)

		if !Empty(cAlias)
			DBSelectArea(cAlias)
		endif
	else
		ConErr(cError)
		setRestFault(400)
	endif

Return
