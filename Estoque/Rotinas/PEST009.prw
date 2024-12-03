//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

//Variáveis Estáticas
Static cTitulo := "Etiquetas"
/*/{Protheus.doc} PEST009
Função que mostra os dados da tabela ZZC para Visualização e Pesquisa
@type function
@version 1.0
@author Jair Matos
@since 17/07/2024
/*/
User Function PEST009()
	Local aArea   := GetArea()
	Local oBrowse
    
    Private aRotina 	:= MenuDef()

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZZC")
	oBrowse:SetDescription(cTitulo)
	oBrowse:Activate()

	RestArea(aArea)
Return Nil 
Static Function MenuDef()
    Local aRot := {}

    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.PEST009' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 2
 
Return aRot 
Static Function ModelDef()
    Local oModel := Nil
    Local oStZZC := FWFormStruct(1, "ZZC")
     
    oModel := MPFormModel():New("PEST009M",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/)      
    oModel:AddFields("FORMZZC",/*cOwner*/,oStZZC)     
    oModel:SetPrimaryKey({'ZZC_FILIAL','ZZC_CODETI'})     
    oModel:SetDescription(cTitulo)     
    oModel:GetModel("FORMZZC"):SetDescription(cTitulo)

Return oModel 
Static Function ViewDef()
    Local oModel := FWLoadModel("PEST009")
    Local oStZZC := FWFormStruct(2, "ZZC")  
    Local oView := Nil
 
    oView := FWFormView():New()
    oView:SetModel(oModel)     
    oView:AddField("VIEW_ZZC", oStZZC, "FORMZZC")    
    oView:CreateHorizontalBox("TELA",100)     
    oView:EnableTitleView('VIEW_ZZC', 'Dados da Etiqueta' )       
    oView:SetCloseOnOk({||.T.})     
    oView:SetOwnerView("VIEW_ZZC","TELA")

Return oView

