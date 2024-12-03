#include "protheus.ch"
#include "fwmvcdef.ch"
#include "restful.ch"
#Include "TBICONN.ch"
//
WSRESTFUL WSBaixaCQ DESCRIPTION "Serviço REST para Baixas do CQ (MATA175 - SIGAEST)"

	WSDATA cNumero As String

	WSMETHOD GET  DESCRIPTION "Retorna o numero da movimentacao informada" WSSYNTAX "/WSBaixaCQ"
	WSMETHOD PUT DESCRIPTION "Grava a movimentacao de CQ informada " WSSYNTAX "/WSBaixaCQ"

END WSRESTFUL

WSMETHOD GET WSRECEIVE cNumero WSSERVICE WSBaixaCQ
	local aAreaSD7 as array
	Local aObjCQ as array
	Local aArea as array
	Local cNumero as char
	Local oJson as char
	Local jObjProd

	cNumero := Self:cNumero
	aArea := GetArea()
	aAreaSD7 := SD7->( GetArea() )

	::SetContentType("application/json")

	DbSelectArea("SD7")
	SD7->( DbSetOrder(1) )//D7_FILIAL+D7_NUMERO+D7_PRODUTO

	if SD7->( DbSeek( xFilial("SD7") + PadR(cNumero,tamSx3("D7_NUMERO")[1]) ) )
		aObjCQ := {}

		aAdd( aObjCQ,  JsonObject():New() )

		aObjCQ[1]["NUMERO"] 	:= cNumero
		aObjCQ[1]["TIPO"] 	    := SD7->D7_TIPO
		aObjCQ[1]["PRODUTO"]    := SD7->D7_PRODUTO
		aObjCQ[1]["DATA"] 	    := DTOC(SD7->D7_DATA)
		aObjCQ[1]["QTD"]    	:= SD7->D7_QTDE
		aObjCQ[1]["QTDSEGUM"]  	:= SD7->D7_QTSEGUM
		aObjCQ[1]["MOTREJE"] 	:= SD7->D7_MOTREJE
		aObjCQ[1]["LOCDEST"] 	:= SD7->D7_LOCDEST
		aObjCQ[1]["SALDO"]    	:= SD7->D7_SALDO
		aObjCQ[1]["ESTORNO"]   	:= SD7->D7_ESTORNO

		jObjProd :=  JsonObject():New()
		jObjProd["WSBaixaCQ"] := aObjCQ

		oJson := jObjProd:toJson()
		::setResponse(oJson)
	else
		SetRestFault(400,"Movimento de CQ nao existe: " + cNumero)
		return .F.
	endIf

	RestArea(aAreaSD7)
	RestArea(aArea)

return .T.

WSMETHOD PUT WSRECEIVE NULLPARAM WSSERVICE WSBaixaCQ

	Local lRet 	    := .T.
	Local cMsg      := ""
	Local nOpc      := 4 //alterar
	Local cPathTmp	:= "\wsfluigerrors\"
	Local cArqTmp 	:= "WSINCLUISD7_" + DToS( Date( ) ) + "_" + StrTran( Time( ), ":", "" ) + "_.txt"
	Local cNumero   := ""
	Local cProd     := ""
	Local cLocal    := GETMV("MV_CQ")
	Local cLocDest  := ""
	Local cMotRej	:= ""
	Local cError as char
	Local oJson as char
	Local cRetJson as char
	Local cAlias as char
	Local lOk as logical
	Local aAreaSD7 as array
	Local aVetor := {}, aLibera := {}
	private lMsErroAuto := .F.
	Private lMsHelpAuto :=.T.
	

	Self:SetContentType("application/json")

	oJson := JsonObject():New()
	cError := oJson:fromJson( self:getContent() )
	lOk := .F.

	if Empty(cError)
		cAlias := Alias()
		aAreaSD7 := SD7->( GetArea() )
		cNumero := oJson['NUMERO']
		cProd   := oJson['PRODUTO']
		If oJson["TIPO"] == 1
			cLocDest  := Posicione("SB1",1,FWxFilial("SB1")+ oJson["PRODUTO"],"B1_LOCPAD")
		Else
            cLocDest  := GETMV("MV_XLOCREJ")
			cMotRej	  := oJson["MOTREJE"]
		EndIf

		If SD7->( DbSeek( xFilial("SD7") + cNumero+cProd+cLocal) )

			aVetor := {;
				{"D7_TIPO"      , oJson["TIPO"]         ,NIL},;
				{"D7_PRODUTO"   , oJson["PRODUTO"]      ,NIL},;
				{"D7_DATA"      , dDatabase             ,NIL},;
				{"D7_QTDE"      , oJson["QTD"]          ,NIL},;
				{"D7_QTDSEGUM"  , oJson["QTDSEGUM"]     ,NIL},;
				{"D7_OBS"       , oJson["OBS"]          ,NIL},;
				{"D7_MOTREJE"   , If(cMotRej=="",Nil,cMotRej),NIL},;
				{"D7_LOCDEST"   , cLocDest			    ,NIL},;
				{"D7_SALDO"     , Nil       			,NIL},;
				{"D7_ESTORNO"   , NIL				    ,NIL},;
                {"D7_LOCALIZ"   , GETMV("MV_DISTAUT")   ,NIL}}

			aAdd(aLibera,aVetor)	

			MSExecAuto({|x,y| mata175(x,y)},aLibera,nOpc)

			If lMsErroAuto
				U_fCriaDir( cPathTmp )
				MostraErro( cPathTmp, cArqTmp )
				cMsg += " " + MemoRead( cPathTmp + cArqTmp )
				SetRestFault(400, cMsg)
				lRet := .F.
				DisarmTransaction()
			Else
				cRetJson := '{"ONUMERO":"' + SD7->D7_NUMERO + '"';
					+ ',"msg":"'  + "Sucesso"          + '"';
					+'}'
				::SetResponse(cRetJson)
			Endif
		else
			SetRestFault(400, "Movimento de CQ não encontrado " + cNumero)
			lRet := .F.
		endif

		RestArea(aAreaSD7)

		if !Empty(cAlias)
			DBSelectArea(cAlias)
		endif
	else
		ConErr(cError)
		setRestFault(400)
	endif

Return lRet
