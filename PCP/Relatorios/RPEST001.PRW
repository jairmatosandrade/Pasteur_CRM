#Include 'Protheus.ch'
#INCLUDE 'TOPCONN.CH'
/*/{Protheus.doc} RPEST001
Relatorio de Ordem de pesagem
@type function
@version 1.0 
@author Jair Matos
@since 21/05/2024
/*/
User Function RPEST001()
	Local oReport := nil
	Local cPerg:= Padr("RPEST001",10)

	CriaSx1(cPerg)
	If !Pergunte(cPerg,.t.)
		Return()
	EndIf
	//gero a pergunta de modo oculto, ficando disponível no botão ações relacionadas
	Pergunte(cPerg,.F.)

	oReport := RptDef(cPerg)
	oReport:PrintDialog()
Return

Static Function RptDef(cNome)
	Local oReport := Nil
	Local oSection1:= Nil
	Local oSection2:= Nil

	/*Sintaxe: TReport():New(cNome,cTitulo,cPerguntas,bBlocoCodigo,cDescricao)*/
	oReport := TReport():New(cNome,"Relatório de Ordem de Pesagem",cNome,{|oReport| ReportPrint(oReport)},"Relatório de Ordem de Pesagem")
	oReport:SetPortrait()
	//oReport:SetTotalInLine(.F.)

	//Monstando a primeira seção
	//Neste exemplo, a primeira seção será composta por duas colunas, código da NCM e sua descrição
	//Iremos disponibilizar para esta seção apenas a tabela ZZA, pois quando você for em personalizar
	//e entrar na primeira seção, você terá todos os outros campos disponíveis, com isso, será
	//permitido a inserção dos outros campos
	//Neste exemplo, também, já deixarei definido o nome dos campos, mascara e tamanho, mas você
	//terá toda a liberdade de modificá-los via relatorio.
	oSection1:= TRSection():New(oReport, "OP", {"ZZA"}, , .F., .T.)
	TRCell():New(oSection1,"DDATA"	    ,"TRBNCM","Data"  	            ,"@!",40)
    TRCell():New(oSection1,"ZZA_NUMPES"	,"TRBNCM","Ordem de Pesagem"  	,"@!",40)
	TRCell():New(oSection1,"ZZA_NUMOP"  ,"TRBNCM","Ordem de Produção"	,"@!",40)
    TRCell():New(oSection1,"ZZA_PRDPAI" ,"TRBNCM","Produto Pai"	        ,"@!",100)
    TRCell():New(oSection1,"ZZA_LOTE"   ,"TRBNCM","Lote"	            ,"@!",40)

	//A segunda seção, será apresentado os produtos, neste exemplo, estarei disponibilizando apenas a tabela
	//ZZB,poderia ter deixado também a tabela de NCM, com isso, você poderia incluir os campos da tabela
	//ZZA.Semelhante a seção 1, defino o titulo e tamanho das colunas
	oSection2:= TRSection():New(oReport, "Produtos", {"ZZB"}, NIL, .F., .T.)
	TRCell():New(oSection2,"ZZB_CODPRD"   	,"TRBNCM","Produto"		,"@!",100)
	TRCell():New(oSection2,"ZZB_QUANT"	    ,"TRBNCM","Quant"		,"@!",20)
    TRCell():New(oSection2,"B1_UM"	        ,"TRBNCM","UM"  		,"@!",20)
    TRCell():New(oSection2,"RESPPES"	    ,"TRBNCM","Resp.Pes."	,"@!",30)
    TRCell():New(oSection2,"RESPCONF"	    ,"TRBNCM","Resp.Conf."	,"@!",30)
    TRCell():New(oSection2,"RESPADIC"	    ,"TRBNCM","Resp.Adic"	,"@!",30)

	//TRFunction():New(oSection2:Cell("ZZB_CODPRD"),NIL,"COUNT",,,,,.F.,.T.)

	//oReport:SetTotalInLine(.F.)

	//Aqui, farei uma quebra  por seção
	oSection1:SetPageBreak(.T.)
	//oSection1:SetTotalText(" ")
Return(oReport)

Static Function ReportPrint(oReport)
	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(2)
	Local cQuery    := ""
	Local cNcm      := ""

	//Monto minha consulta conforme parametros passado
	cQuery := "	SELECT ZZA.* ,ZZB.*, B1_DESC, B1_XDESCAL, B1_UM FROM "+RETSQLNAME("ZZA")+" ZZA "
	cQuery += "	INNER JOIN "+RETSQLNAME("ZZB")+" ZZB ON ZZB.D_E_L_E_T_=' ' AND ZZB_FILIAL=ZZA_FILIAL AND  ZZB_NUMPES = ZZA_NUMPES "
    cQuery += "	INNER JOIN "+RETSQLNAME("SB1")+" SB1 ON SB1.D_E_L_E_T_=' ' AND B1_COD = ZZB_CODPRD "
	cQuery += "	WHERE ZZA.D_E_L_E_T_=' ' "
	cQuery += "	AND ZZA_FILIAL='"+xFilial("ZZA")+"' "
	cQuery += " AND ZZA_NUMPES BETWEEN '"+mv_par01+"' AND '"+mv_par02+"'"
	cQuery += "	ORDER BY ZZA_NUMPES "

	//Se o alias estiver aberto, irei fechar, isso ajuda a evitar erros
	IF Select("TRBNCM") <> 0
		DbSelectArea("TRBNCM")
		DbCloseArea()
	ENDIF

	//crio o novo alias
	TCQUERY cQuery NEW ALIAS "TRBNCM"

	dbSelectArea("TRBNCM")
	TRBNCM->(dbGoTop())

	oReport:SetMeter(TRBNCM->(LastRec()))

	//Irei percorrer todos os meus registros
	While !Eof()

		If oReport:Cancel()
			Exit
		EndIf

		//inicializo a primeira seção
		oSection1:Init()

		oReport:IncMeter()

		cNcm 	:= TRBNCM->ZZA_NUMPES
		IncProc("Imprimindo Pesagem "+alltrim(TRBNCM->ZZA_NUMPES))

		//imprimo a primeira seção
		oSection1:Cell("DDATA"):SetValue(DATE())
        oSection1:Cell("ZZA_NUMPES"):SetValue(TRBNCM->ZZA_NUMPES)
		oSection1:Cell("ZZA_NUMOP"):SetValue(TRBNCM->ZZA_NUMOP)
        oSection1:Cell("ZZA_PRDPAI"):SetValue(alltrim(TRBNCM->ZZA_PRDPAI)+" - "+Alltrim(TRBNCM->ZZA_PRDDES))
        oSection1:Cell("ZZA_LOTE"):SetValue(TRBNCM->ZZA_LOTE)
		oSection1:Printline()

		//inicializo a segunda seção
		oSection2:init()

		//verifico se o codigo da NCM é mesmo, se sim, imprimo o produto
		While TRBNCM->ZZA_NUMPES == cNcm
			oReport:IncMeter()

			IncProc("Imprimindo itens "+alltrim(TRBNCM->ZZB_ITEM))
			oSection2:Cell("ZZB_CODPRD"):SetValue(alltrim(TRBNCM->ZZB_CODPRD)+" - "+alltrim(TRBNCM->B1_DESC))
			oSection2:Cell("ZZB_QUANT"):SetValue(TRBNCM->ZZB_QUANT)
            oSection2:Cell("B1_UM"):SetValue(TRBNCM->B1_UM)
            oSection2:Cell("RESPPES"):SetValue(StrTran(SPACE(20), ' ', '_'))
            oSection2:Cell("RESPCONF"):SetValue(StrTran(SPACE(20), ' ', '_'))
            oSection2:Cell("RESPADIC"):SetValue(StrTran(SPACE(20), ' ', '_'))
			oSection2:Printline()

			TRBNCM->(dbSkip())
		EndDo
		//finalizo a segunda seção para que seja reiniciada para o proximo registro
		oSection2:Finish()
		//imprimo uma linha para separar uma NCM de outra
		oReport:ThinLine()
		//finalizo a primeira seção
		oSection1:Finish()
	Enddo
Return
/*/{Protheus.doc} CriaSX1
Tela com as perguntas
@type function
@version 1.0 
@author jair.andrade
@since 29/03/2023
@param cPerg, variant, nome da pergunta
@return variant, retorna verdadeiro
/*/
Static Function CriaSX1(cPerg)
	Local _aArea	:= GetArea()
	Local aRegs		:= {}
	Local _i		:= 1
	Local lLock		:= .F.
	// Local l
	// Local cVldCNPJ	:= ""

	_sAlias := Alias()

	dbSelectArea("SX1")
	dbSetOrder(1)

	cPerg := padr(cPerg,len(SX1->X1_GRUPO))

	Aadd(aRegs,{cPerg,"01" ,"Pesagem de "	,"mv_ch1" ,"C" ,tamSx3("ZZA_NUMPES")[1], 0, 0, "G","mv_par01","ZZA","","","", ""})
	Aadd(aRegs,{cPerg,"02" ,"Pesagem ate "	,"mv_ch2" ,"C" ,tamSx3("ZZA_NUMPES")[1], 0, 0, "G","mv_par02","ZZA","","","", ""})

	DbSelectArea("SX1")
	DbSetOrder(1)

	For _i := 1 To Len(aRegs)

		lLock 	:= DbSeek(aRegs[_i,1]+aRegs[_i,2])

		RecLock("SX1", !lLock )
		Replace X1_GRUPO   with aRegs[_i,01]
		Replace X1_ORDEM   with aRegs[_i,02]
		Replace X1_PERGUNT with aRegs[_i,03]
		Replace X1_VARIAVL with aRegs[_i,04]
		Replace X1_TIPO	   with aRegs[_i,05]
		Replace X1_TAMANHO with aRegs[_i,06]
		Replace X1_DECIMAL with aRegs[_i,07]
		Replace X1_PRESEL  with aRegs[_i,08]
		Replace X1_GSC	   with aRegs[_i,09]
		Replace X1_VAR01   with aRegs[_i,10]
		Replace X1_F3	   with aRegs[_i,11]
		Replace X1_DEF01   with aRegs[_i,12]
		Replace X1_DEF02   with aRegs[_i,13]
		Replace X1_DEF03   with aRegs[_i,14]
		Replace X1_VALID   with aRegs[_i,15]
		MsUnlock()

	Next _i

	RestArea(_aArea)
Return()
