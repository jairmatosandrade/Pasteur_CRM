#include "protheus.ch"
#include "fwmvcdef.ch"
#include "restful.ch"
#Include "TBICONN.ch"
//
WSRESTFUL WsApontamentoProd DESCRIPTION "Serviço REST para manipulação de OPs"

	WSDATA CodOP As String

	WSMETHOD GET  DESCRIPTION "Retorna o OP informada" WSSYNTAX "/WsApontamentoProd"
	WSMETHOD POST DESCRIPTION "Grava a OP informada " WSSYNTAX "/WsApontamentoProd"

END WSRESTFUL

WSMETHOD GET WSRECEIVE CodOP WSSERVICE WsApontamentoProd
	local aAreaSH6 as array
	Local aObjOP as array
	Local aArea as array
	Local cCodOP as char
	Local cJson as char
	Local jObjProd

	cCodOP := Self:CodOP
	aArea := GetArea()
	aAreaSH6 := SH6->( GetArea() )

	::SetContentType("application/json")

	DbSelectArea("SH6")
	SH6->( DbSetOrder(1) )

	if SH6->( DbSeek( xFilial("SH6") + PadR(cCodOP,14) ) )
		aObjOP := {}

		aAdd( aObjOP,  JsonObject():New() )

		aObjOP[1]["OP"] 		:= cCodOP
		aObjOP[1]["Produto"] 	:= SH6->H6_PRODUTO
		aObjOP[1]["Operacao"] 	:= SH6->H6_OPERAC
		aObjOP[1]["Recurso"] 	:= SH6->H6_RECURSO
		aObjOP[1]["Dt.Ini"] 	:= DTOC(SH6->H6_DATAINI)
		aObjOP[1]["Hr.Ini"] 	:= SH6->H6_HORAINI
		aObjOP[1]["Dt.Fim"] 	:= DTOC(SH6->H6_DATAFIN)
		aObjOP[1]["Hr.Fim"] 	:= SH6->H6_HORAFIN
		aObjOP[1]["Qtd.Prod."] 	:= SH6->H6_QTDPROD

		jObjProd :=  JsonObject():New()
		jObjProd["WsApontamentoProd"] := aObjOP

		cJson := jObjProd:toJson()
		::setResponse(cJson)
	else
		SetRestFault(400,"OP nao existe: " + cCodOP)
		return .F.
	endIf

	RestArea(aAreaSH6)
	RestArea(aArea)

return .T.

WSMETHOD POST WSRECEIVE NULLPARAM WSSERVICE WsApontamentoProd

	Local lRet 	        := .T.
	Local cMsg          := ""
	Local nOpc          := 3 //Incluir
	Local cPathTmp		:= "\wsfluigerrors\"
	Local cArqTmp 		:= "WSINCLUISH6_" + DToS( Date( ) ) + "_" + StrTran( Time( ), ":", "" ) + "_.txt"
	Local cArmazem		:= ""
	Local cError as char
	Local cJson as char
	Local cRetJson as char
	Local cAlias as char
	Local lOk as logical
	Local aAreaSH6 as array
	private lMsErroAuto := .F.
	Private lMsHelpAuto :=.T.
	Private aVetor      := {}

	Self:SetContentType("application/json")

	cJson := JsonObject():New()
	cError := cJson:fromJson( self:getContent() )
	lOk := .F.

	if Empty(cError)
		cAlias := Alias()
		aAreaSH6 := SH6->( GetArea() )

		If  cJson["OPCAO"]=="RETRABALHO"
			cArmazem := SuperGetMV("MV_XRETRAB", .F., "02")
		ElseIf cJson["OPCAO"]=="DESCARTE"
			cArmazem := SuperGetMV("MV_XDESCAR", .F., "03")
		else//PRODUCAO
			cArmazem := cJson["ARMAZEM"]
		EndIf


		if !SH6->( DbSeek( xFilial("SH6") + cJson["OPRODUCAO"]) )

			aVetor := {;
				{"H6_OP"      , cJson["OPRODUCAO"]       ,NIL},;
				{"H6_PRODUTO" , cJson["CODPROD"]         ,NIL},;
				{"H6_OPERAC"  , cJson["OPERACAO"]        ,NIL},;
				{"H6_RECURSO" , cJson["RECURSO"]         ,NIL},;
				{"H6_DTAPONT" , cTod(cJson["DTAPONT"])   ,NIL},;
				{"H6_DATAINI" , ctod(cJson["DTINICIAL"]) ,NIL},;
				{"H6_HORAINI" , cJson["HRINICIAL"]       ,NIL},;
				{"H6_DATAFIN" , cTod(cJson["DTFINAL"])   ,NIL},;
				{"H6_HORAFIN" , cJson["HRFINAL"]         ,NIL},;
				{"H6_PT"      , cJson["PRODPT"]          ,NIL},;
				{"H6_LOCAL"   , cJson["ARMAZEM"]         ,NIL},;
				{"H6_QTDPROD" , cJson["QTDPROD"]         ,NIL},;
				{"H6_LOTECTL" , cJson["LOTECTL"]         ,NIL}}


			MSExecAuto({|x| mata681(x)},aVetor, nOpc)

			If lMsErroAuto
				U_fCriaDir( cPathTmp )
				MostraErro( cPathTmp, cArqTmp )
				cMsg += " " + MemoRead( cPathTmp + cArqTmp )
				SetRestFault(400, cMsg)
				lRet := .F.
				DisarmTransaction()
			Else
				cRetJson := '{"OPRODUCAO":"' + SH6->H6_OP + '"';
					+ ',"msg":"'  + "Sucesso"          + '"';
					+'}'
				::SetResponse(cRetJson)
			Endif
		else
			SetRestFault(400, "Ordem de Produção já cadastrado: " + SH6->H6_OP)
			lRet := .F.
		endif

		RestArea(aAreaSH6)

		if !Empty(cAlias)
			DBSelectArea(cAlias)
		endif
	else
		ConErr(cError)
		setRestFault(400)
	endif

Return lRet
