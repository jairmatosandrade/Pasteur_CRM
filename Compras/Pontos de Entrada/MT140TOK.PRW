#Include "totvs.ch"


User Function MT140TOK()
	Local lRet     := PARAMIXB[1]

	If lRet //.and. IsInCallStack('U_XXXX')
		If !Empty(aCols)
			lRet := PSTATRST()
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} PSTATRST
rotina de pre-notaXML
@type function
@version 1.0
@author 
@since 
@return
/*/

Static Function PSTATRST()
	Local aArea     := GetArea()
	Local nPosCOD  	:= Ascan(aHeader, {|x| Alltrim(x[2]) == "D1_COD" 		})
	Local nPosLOT  	:= Ascan(aHeader, {|x| Alltrim(x[2]) == "D1_LOTECTL" 		})
	//Local nPosMARC 	:= Ascan(aHeader, {|x| Alltrim(x[2]) == "D1_XMARCA" 		})
	Local nxA      	:= 0
	Local lRet 		:= .T.

	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	For nxA := 1 to Len(aCols)

		If SB1->(DbSeek(xFilial("SB1")+aCols[nxA][nPosCOD]))
			//nRecnoSB1 := SB1->(Recno())
			if B1_RASTRO == 'L'
				If Empty(aCols[nxA][nPosLOT])//Se campo D1_LOTECTL estiver em branco , cria o lote , senão mantem o que está na D1_LOTECTL 17/07/24
					cLoteCTL := NextLote()
					aCols[nxA][nPosLOT] := cLoteCTL
				EndIf
			ENDIF
		EndIf

		//aCols[nxA][nPosMARC] := " " comentado jair 10-07-2024

	Next nxA

	RestArea(aArea)

Return(lRet)
