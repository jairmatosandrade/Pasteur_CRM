#Include "totvs.ch"

/*/{Protheus.doc} PSTATLOT
Gatilho executado H6_OP para o campo H6_LOTECTL na sx6.
@type function
@version 1.0
@author 
@since 
@return cLoteCTL
/*/

User Function PSTATLOT()
	Local cLoteCTL := ""
	
	IF !EMPTY(H6_OP)
		cLoteCTL := Subs(H6_OP,1,6)
	ENDIF

Return cLoteCTL
