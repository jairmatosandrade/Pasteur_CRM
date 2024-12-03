#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} CBRETEAN

Ponto de entrada para possibilitar a leitura dos codigos de barras

@type function
@version 1.0
@author jair Matos
@since 22/07/2024
@see CBRETEAN
/*/
User Function CBRETEAN()
	Local aRet  As Array
	Local cId   As Character
	cId  := PARAMIXB[1]
	aRet := RetornaDados(cId)


Return(aRet)


/*/{Protheus.doc} RetornaDados
Retorna dados num array para ser devolvido no ponto de entrada CBRETEAN
@type function
@version 1.0
@author Jair Matos
@since 22/07/2024
/*/
Static Function RetornaDados(cId)
	Local aRet  	As Array
	Local cTip  	As Character
	Local cPrd  	As Character
	Local cLot  	As Character
	Local cLoc  	As Character
	Local nQE   	As Numeric
	Local nTamPrd 	As Numeric
	Local nTamLot	As Numeric
	Local nTamLocal	As Numeric
	Local nTamQuant	As Numeric
	Local dDT  		As Data

	nTamPrd	    := GetSX3Cache("ZZC_CODPRD"	, "X3_TAMANHO")
	nTamLocal   := GetSX3Cache("ZZC_LOCAL"	, "X3_TAMANHO")
	nTamLot	    := GetSX3Cache("ZZC_LOTE"	, "X3_TAMANHO")
	nTamQuant   := GetSX3Cache("ZZC_QUANT"	, "X3_TAMANHO")
	nTamSer   	:= GetSX3Cache("ZZC_NFSER"	, "X3_TAMANHO")
	//dDT   		:= GetSX3Cache("ZZC_DTVLD"	, "X3_TAMANHO")

	cTip := ""
	cPrd := Left(cId, nTamPrd)
	cLot := ""
	nQE  := 0

	ZZC->(DbSetOrder(1)) //P26_FILIAL+P26_ID
	If ZZC->(dbSeek(FWxFilial("ZZC") + AllTrim(cId)))
		cPrd := ZZC->ZZC_CODPRD
		cLot := ZZC->ZZC_LOTE
		cLoc := ZZC->ZZC_LOCAL
		nQE  := ZZC->ZZC_QUANT
		dDT  := ZZC->ZZC_DTVLD
		// (ACDV035)-Inventário
		If FunName() == "ACDV035"
			//nQE := 0
			nQE := CBQEmb()

			//Grava dados na ZZE
			dbSelectArea("ZZE")
			ZZE->(DbSetOrder(2)) //ZZE_FILIAL, ZZE_CODINV, ZZE_NUM, ZZE_CODPRD
			If !ZZE->(dbSeek(FWxFilial("ZZE") + CBB->CBB_CODINV+CBB->CBB_NUM+AllTrim(cId)))
				Reclock("ZZE",.T.)
				ZZE->ZZE_CODINV := CBB->CBB_CODINV
				ZZE->ZZE_NUM 	:= CBB->CBB_NUM
				ZZE->ZZE_CODETI := cId
				ZZE->ZZE_CODPRD := cPrd
				ZZE->ZZE_LOTECT	:= cLot
				ZZE->ZZE_LOCAL 	:= cLoc
				ZZE->ZZE_INVENT := "N"
				ZZE->ZZE_LOCALI := Space(Tamsx3("ZZE_LOCALI") [1])
				ZZE->(MSUnlock())
			EndIf

		EndIf


	EndIf

	aRet := {}

	aAdd( aRet, PadR(cPrd, nTamPrd) )   // ARET[1] Codigo do Produto
	aAdd( aRet, nQE                 )   // ARET[2] Calculo de quantidade por embalagem
	aAdd( aRet, PadR(cLot, nTamLot) )   // ARET[3] Lote
	//aAdd( aRet, CToD("//") 		    )   // ARET[4] Data de Validade
	aAdd( aRet, dDT		    		)   // ARET[4] Data de Validade
	aAdd( aRet, Space(nTamSer)      )   // ARET[5] Numero de Serie
	aAdd( aRet, Space(nTamLocal)    )   // ARET[6] Endereco Destino

Return(aRet)
/*/{Protheus.doc} CBRETTIPO
Ponto de entrada utilizado no coletor no momento da leitura do produto para ativar o ponto de entrada CBRETEAN.
@type function
@version V.12.1.27
@author Reinaldo Dias
@since 08/04/2021
@see CBRETEAN
/*/
User Function CBRETTIPO()
	Local lRet as Logical

	lRet := .T.

Return lRet
