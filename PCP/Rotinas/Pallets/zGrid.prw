#include "Protheus.ch"
#include "FwMvcDef.CH"
#include "FwBrowse.CH"
#include "TOPCONN.CH"

Static cTitle := "Manutenção de Pallets "
Static cKey    := "FAKE"
Static nTamFake := 15

/*
Rotina em MVC que lista os grids baseados no markbrowse escolhido pelo usuário
@type  Function
@author Vinicius Franceschi
@since  21/02/2024
@version version
@see zGridM
@see PSTIPLT
*/

User function zGrid(cCodigoMontagem)
	Local aArea := FWGetArea()
	Local aFields := {}

	Private cAliasTmp := getNextAlias()
	Private oTempTable
	Private cLoadMontagem := ""

	Default cCodigoMontagem := ""

	cLoadMontagem := cCodigoMontagem

	oTempTable := FWTemporaryTable():New(cAliasTmp)

	aAdd(aFields, { 'ZZD_CODM  '	,TamSx3("ZZD_CODM  ")[3]	, TamSx3("ZZD_CODM  ")[1]	, TamSx3("ZZD_CODM  ")[2]})
	aAdd(aFields, { 'ZZD_PALLET'	,TamSx3("ZZD_PALLET")[3]	, TamSx3("ZZD_PALLET")[1]	, TamSx3("ZZD_PALLET")[2]})
	aAdd(aFields, { 'ZZD_ITEM  '	,TamSx3("ZZD_ITEM  ")[3]	, TamSx3("ZZD_ITEM  ")[1]	, TamSx3("ZZD_ITEM  ")[2]})
	aAdd(aFields, { 'ZZD_CODPRD'	,TamSx3("ZZD_CODPRD")[3]	, TamSx3("ZZD_CODPRD")[1]	, TamSx3("ZZD_CODPRD")[2]})
	aAdd(aFields, { 'ZZD_DESC  '	,TamSx3("ZZD_DESC  ")[3]	, TamSx3("ZZD_DESC  ")[1]	, TamSx3("ZZD_DESC  ")[2]})
	aAdd(aFields, { 'ZZD_QTDCX '	,TamSx3("ZZD_QTDCX")[3]		, TamSx3("ZZD_QTDCX ")[1]	, TamSx3("ZZD_QTDCX ")[2]})
	aAdd(aFields, { 'D2_ETQPLT '	,TamSx3("D2_ETQPLT")[3]		, TamSx3("D2_ETQPLT ")[1]	, TamSx3("D2_ETQPLT ")[2]})
	aAdd(aFields, { 'ZZD_STATUS'	,TamSx3("ZZD_STATUS")[3]	, TamSx3("ZZD_STATUS")[1]	, TamSx3("ZZD_STATUS")[2]})
	aAdd(aFields, { 'ZZD_CLIENT'	,TamSx3("ZZD_CLIENT")[3]	, TamSx3("ZZD_CLIENT")[1]	, TamSx3("ZZD_CLIENT")[2]})
	aAdd(aFields, { 'ZZD_LOJA'		,TamSx3("ZZD_LOJA")[3]		, TamSx3("ZZD_LOJA")[1]		, TamSx3("ZZD_LOJA")[2]})
	aAdd(aFields, { 'ZZD_DOC'		,TamSx3("ZZD_DOC")[3]		, TamSx3("ZZD_DOC")[1]		, TamSx3("ZZD_DOC")[2]})
	aAdd(aFields, { 'ZZD_SERIE'		,TamSx3("ZZD_SERIE")[3]		, TamSx3("ZZD_SERIE")[1]	, TamSx3("ZZD_SERIE")[2]})

	//Define as colunas usadas, adiciona indice e cria a temporaria no banco
	oTempTable:SetFields( aFields )
	oTempTable:AddIndex("1", {"ZZD_CODM"} )
	oTempTable:Create()

	//Executa a inclusao na tela
	FWExecView(cTitle, "VIEWDEF.zGrid", MODEL_OPERATION_UPDATE, , { || .T. }, , 30)

	oTempTable:Delete()

	FWRestArea(aArea)
Return .T.

/*
Montagem do ModelDef
*/
Static Function ModelDef()
	Local oModel  	As Object
	Local oStrField As Object
	Local oStrGrid 	As Object

	Local bLoad		:= {|oModel| xGridx(oModel)}
	Local bVldPos	:= {|| u_ValidCaixa() }

	//Estrutura falsa que sera uma tabela que ficara escondida no cabecalho
	oStrField := FWFormModelStruct():New()
	oStrField:AddTable('' , { 'XXTABKEY' } , cTitle, {|| ''})
	oStrField:AddField('String 01' , 'Campo de texto' , 'XXTABKEY' , 'C' , nTamFake)

	//Estrutura da grid FALSA
	oStrGrid := FWFormModelStruct():New()
	oStrGrid:AddTable(cAliasTmp, {'XXTABKEY', 'ZZD_CODM', 'ZZD_PALLET', 'ZZD_ITEM', 'ZZD_CODPRD',;
		'ZZD_DESC' ,'ZZD_QTDCX', 'D2_ETQPLT' , 'ZZD_STATUS' }, "Temporaria")

	//Adiciona os campos da estrutura -> mesmos do aFields
	oStrGrid:AddField(;
		"Codigo Montagem",;		// [01]  C   Titulo do campo
	"Codigo Montagem",;			// [02]  C   ToolTip do campo
	"ZZD_CODM",;				// [03]  C   Id do Field
	TamSx3("ZZD_CODM  ")[3],;	// [04]  C   Tipo do campo
	TamSx3("ZZD_CODM")[1],;		// [05]  N   Tamanho do campo
	0,;							// [06]  N   Decimal do campo
	Nil,;						// [07]  B   Code-block de validação do campo
	Nil,;						// [08]  B   Code-block de validação When do campo
	{},;						// [09]  A   Lista de valores permitido do campo
	.T.,;						// [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, ''  ),;	// [11]  B   Code-block de inicializacao do campo
	.T.,;						// [12]  L   Indica se trata-se de um campo chave
	.F.,;						// [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)    					// [14]  L   Indica se o campo é virtual

	oStrGrid:AddField(;
		"Codigo Pallet",;		// [01]  C   Titulo do campo
	"Codigo Pallet",;			// [02]  C   ToolTip do campo
	"ZZD_PALLET",;				// [03]  C   Id do Field
	TamSx3("ZZD_PALLET  ")[3],;	// [04]  C   Tipo do campo
	TamSx3("ZZD_PALLET")[1],;	// [05]  N   Tamanho do campo
	0,;							// [06]  N   Decimal do campo
	Nil,;						// [07]  B   Code-block de validação do campo
	Nil,;						// [08]  B   Code-block de validação When do campo
	{},;						// [09]  A   Lista de valores permitido do campo
	.T.,;						// [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasTmp+"->ZZD_PALLET" ),;	// [11]  B   Code-block de inicializacao do campo
	.T.,;						// [12]  L   Indica se trata-se de um campo chave
	.F.,;						// [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)						// [14]  L   Indica se o campo é virtual

	oStrGrid:AddField(;
		"Item NF",;				// [01]  C   Titulo do campo
	"Item NF",;					// [02]  C   ToolTip do campo
	"ZZD_ITEM",;				// [03]  C   Id do Field
	TamSx3("ZZD_ITEM  ")[3],;	// [04]  C   Tipo do campo
	TamSx3("ZZD_ITEM")[1],;		// [05]  N   Tamanho do campo
	0,;							// [06]  N   Decimal do campo
	Nil,;						// [07]  B   Code-block de validação do campo
	Nil,;						// [08]  B   Code-block de validação When do campo
	{},;						// [09]  A   Lista de valores permitido do campo
	.T.,;						// [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasTmp+"->ZZD_ITEM" ),;	// [11]  B   Code-block de inicializacao do campo
	.T.,;						// [12]  L   Indica se trata-se de um campo chave
	.F.,;						// [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)						// [14]  L   Indica se o campo é virtual

	oStrGrid:AddField(;
		"Produto",;				// [01]  C   Titulo do campo
	"Produto",;					// [02]  C   ToolTip do campo
	"ZZD_CODPRD",;				// [03]  C   Id do Field
	TamSx3("ZZD_CODPRD  ")[3],;	// [04]  C   Tipo do campo
	TamSx3("ZZD_CODPRD  ")[1],;	// [05]  N   Tamanho do campo
	0,;							// [06]  N   Decimal do campo
	Nil,;						// [07]  B   Code-block de validação do campo
	Nil,;						// [08]  B   Code-block de validação When do campo
	{},;						// [09]  A   Lista de valores permitido do campo
	.T.,;						// [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasTmp+"->ZZD_CODPRD" ),;	// [11]  B   Code-block de inicializacao do campo
	.T.,;						// [12]  L   Indica se trata-se de um campo chave
	.F.,;						// [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)						// [14]  L   Indica se o campo é virtual

	oStrGrid:AddField(;
		"Descrição",;			// [01]  C   Titulo do campo
	"Descrição",;				// [02]  C   ToolTip do campo
	"ZZD_DESC",;				// [03]  C   Id do Field
	TamSx3("ZZD_DESC  ")[3],;	// [04]  C   Tipo do campo
	TamSx3("ZZD_DESC  ")[1],;	// [05]  N   Tamanho do campo
	0,;							// [06]  N   Decimal do campo
	Nil,;						// [07]  B   Code-block de validação do campo
	Nil,;						// [08]  B   Code-block de validação When do campo
	{},;						// [09]  A   Lista de valores permitido do campo
	.T.,;						// [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasTmp+"->ZZD_DESC" ),;	// [11]  B   Code-block de inicializacao do campo
	.T.,;						// [12]  L   Indica se trata-se de um campo chave
	.F.,;						// [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)						// [14]  L   Indica se o campo é virtual

	oStrGrid:AddField(;
		"Qtd Caixas",;			// [01]  C   Titulo do campo
	"Qtd Caixas",;				// [02]  C   ToolTip do campo
	"ZZD_QTDCX",;				// [03]  C   Id do Field
	"N",;	// [04]  C   Tipo do campo
	TamSx3("ZZD_QTDCX  ")[1],;	// [05]  N   Tamanho do campo
	2,;							// [06]  N   Decimal do campo
	Nil,;						// [07]  B   Code-block de validação do campo
	Nil,;						// [08]  B   Code-block de validação When do campo
	{},;						// [09]  A   Lista de valores permitido do campo
	.T.,;						// [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasTmp+"->ZZD_QTDCX" ),;	// [11]  B   Code-block de inicializacao do campo
	.T.,;						// [12]  L   Indica se trata-se de um campo chave
	.T.,;						// [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)						// [14]  L   Indica se o campo é virtual

	oStrGrid:AddField(;
		"Saldo Caixas",;			// [01]  C   Titulo do campo
	"Saldo Caixas",;				// [02]  C   ToolTip do campo
	"D2_ETQPLT",;				// [03]  C   Id do Field
	"N",;	// [04]  C   Tipo do campo
	TamSx3("D2_ETQPLT  ")[1],;	// [05]  N   Tamanho do campo
	2,;							// [06]  N   Decimal do campo
	Nil,;						// [07]  B   Code-block de validação do campo
	Nil,;						// [08]  B   Code-block de validação When do campo
	{},;						// [09]  A   Lista de valores permitido do campo
	.F.,;						// [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasTmp+"->D2_ETQPLT" ),;	// [11]  B   Code-block de inicializacao do campo
	.F.,;						// [12]  L   Indica se trata-se de um campo chave
	.T.,;						// [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)						// [14]  L   Indica se o campo é virtual

	oStrGrid:AddField(;
		"Status",;				// [01]  C   Titulo do campo
	"Status",;					// [02]  C   ToolTip do campo
	"ZZD_STATUS",;				// [03]  C   Id do Field
	TamSx3("ZZD_STATUS  ")[3],;	// [04]  C   Tipo do campo
	10,;						// [05]  N   Tamanho do campo
	0,;							// [06]  N   Decimal do campo
	Nil,;						// [07]  B   Code-block de validação do campo
	Nil,;						// [08]  B   Code-block de validação When do campo
	{},;						// [09]  A   Lista de valores permitido do campo
	.F.,;						// [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasTmp+"->ZZD_STATUS" ),;	// [11]  B   Code-block de inicializacao do campo
	.F.,;						// [12]  L   Indica se trata-se de um campo chave
	.T.,;						// [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)						// [14]  L   Indica se o campo é virtual

	oStrGrid:AddField(;
		"Cliente",;				// [01]  C   Titulo do campo
	"Cliente",;					// [02]  C   ToolTip do campo
	"ZZD_CLIENT",;				// [03]  C   Id do Field
	TamSx3("ZZD_CLIENT  ")[3],;	// [04]  C   Tipo do campo
	TamSx3("ZZD_CLIENT  ")[1],;						// [05]  N   Tamanho do campo
	0,;							// [06]  N   Decimal do campo
	Nil,;						// [07]  B   Code-block de validação do campo
	Nil,;						// [08]  B   Code-block de validação When do campo
	{},;						// [09]  A   Lista de valores permitido do campo
	.T.,;						// [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasTmp+"->ZZD_CLIENT" ),;	// [11]  B   Code-block de inicializacao do campo
	.T.,;						// [12]  L   Indica se trata-se de um campo chave
	.F.,;						// [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)						// [14]  L   Indica se o campo é virtual

	oStrGrid:AddField(;
		"Loja",;				// [01]  C   Titulo do campo
	"Loja",;					// [02]  C   ToolTip do campo
	"ZZD_LOJA",;				// [03]  C   Id do Field
	TamSx3("ZZD_LOJA  ")[3],;	// [04]  C   Tipo do campo
	TamSx3("ZZD_LOJA  ")[1],;						// [05]  N   Tamanho do campo
	0,;							// [06]  N   Decimal do campo
	Nil,;						// [07]  B   Code-block de validação do campo
	Nil,;						// [08]  B   Code-block de validação When do campo
	{},;						// [09]  A   Lista de valores permitido do campo
	.T.,;						// [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasTmp+"->ZZD_LOJA" ),;	// [11]  B   Code-block de inicializacao do campo
	.T.,;						// [12]  L   Indica se trata-se de um campo chave
	.F.,;						// [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)						// [14]  L   Indica se o campo é virtual

	oStrGrid:AddField(;
		"NF",;				// [01]  C   Titulo do campo
	"NF",;					// [02]  C   ToolTip do campo
	"ZZD_DOC",;				// [03]  C   Id do Field
	TamSx3("ZZD_DOC  ")[3],;	// [04]  C   Tipo do campo
	TamSx3("ZZD_DOC  ")[1],;					// [05]  N   Tamanho do campo
	0,;							// [06]  N   Decimal do campo
	Nil,;						// [07]  B   Code-block de validação do campo
	Nil,;						// [08]  B   Code-block de validação When do campo
	{},;						// [09]  A   Lista de valores permitido do campo
	.T.,;						// [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasTmp+"->ZZD_DOC" ),;	// [11]  B   Code-block de inicializacao do campo
	.T.,;						// [12]  L   Indica se trata-se de um campo chave
	.F.,;						// [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)						// [14]  L   Indica se o campo é virtual

	oStrGrid:AddField(;
		"Serie",;				// [01]  C   Titulo do campo
	"Serie",;					// [02]  C   ToolTip do campo
	"ZZD_SERIE",;				// [03]  C   Id do Field
	TamSx3("ZZD_SERIE  ")[3],;	// [04]  C   Tipo do campo
	TamSx3("ZZD_SERIE  ")[1],;						// [05]  N   Tamanho do campo
	0,;							// [06]  N   Decimal do campo
	Nil,;						// [07]  B   Code-block de validação do campo
	Nil,;						// [08]  B   Code-block de validação When do campo
	{},;						// [09]  A   Lista de valores permitido do campo
	.T.,;						// [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasTmp+"->ZZD_SERIE" ),;	// [11]  B   Code-block de inicializacao do campo
	.T.,;						// [12]  L   Indica se trata-se de um campo chave
	.F.,;						// [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.F.)						// [14]  L   Indica se o campo é virtual

	//Agora criamos o modelo de dados da nossa tela
	oModel := MPFormModel():New('zGridM',,bVldPos)
	oModel:AddFields('CABID', , oStrField, , , bLoad)
	oModel:AddGrid('GRIDID', 'CABID', oStrGrid, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPos*/, bLoad)
	oModel:SetRelation('GRIDID', { { 'XXTABKEY', 'XXTABKEY' } })
	oModel:SetDescription(cTitle)
	oModel:SetPrimaryKey({ 'XXTABKEY' })

	//Ao ativar o modelo, irá alterar o campo do cabeçalho mandando o conteúdo FAKE pois é necessário alteração no cabeçalho
	oModel:SetActivate({ | oModel | FwFldPut("XXTABKEY", cKey) })
Return oModel

/*
Montagem da ViewDef
*/
Static Function ViewDef()
	Local oView    As Object
	Local oModel   As Object
	Local oStrCab  As Object
	Local oStrGrid As Object

	//Criamos agora a estrtutura falsa do cabeçalho na visualização dos dados
	oStrCab := FWFormViewStruct():New()
	oStrCab:AddField('XXTABKEY' , '01' , 'String 01' , 'Campo de texto', , 'C')

	//Agora a estrutura da Grid
	oStrGrid := FWFormViewStruct():New()

	//Adicionando campos da estrutura
	oStrGrid:AddField(;
		"ZZD_CODM",;			// [01]  C   Nome do Campo
	"02",;                      // [02]  C   Ordem
	"Codigo Montagem",;			// [03]  C   Titulo do campo
	"Codigo Montagem",;			// [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	"@!",;                      // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.F.,;                       // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo

	oStrGrid:AddField(;
		"ZZD_PALLET",;			// [01]  C   Nome do Campo
	"03",;                      // [02]  C   Ordem
	"Codigo Pallet",;			// [03]  C   Titulo do campo
	"Codigo Pallet",;			// [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	"@!",;                      // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.F.,;                       // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo

	oStrGrid:AddField(;
		"ZZD_ITEM",;			// [01]  C   Nome do Campo
	"04",;                      // [02]  C   Ordem
	"Item",;                    // [03]  C   Titulo do campo
	"Item",;                    // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	"@!",;                      // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.F.,;                       // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo

	oStrGrid:AddField(;
		"ZZD_CODPRD",;			// [01]  C   Nome do Campo
	"05",;                      // [02]  C   Ordem
	"Produto",;					// [03]  C   Titulo do campo
	"Produto",;					// [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	"@!",;                      // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.F.,;                       // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo

	oStrGrid:AddField(;
		"ZZD_DESC",;			// [01]  C   Nome do Campo
	"06",;                      // [02]  C   Ordem
	"Descrição",;				// [03]  C   Titulo do campo
	"Descrição",;				// [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	"@!",;                      // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.F.,;                       // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo

	oStrGrid:AddField(;
		"ZZD_QTDCX",;			// [01]  C   Nome do Campo
	"07",;                      // [02]  C   Ordem
	"Qtd Caixas",;				// [03]  C   Titulo do campo
	"Qtd Caixas",;				// [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"N",;                       // [06]  C   Tipo do campo
	"@E 999",;					// [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.T.,;                       // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo

	oStrGrid:AddField(;
		"D2_ETQPLT",;			// [01]  C   Nome do Campo
	"08",;                      // [02]  C   Ordem
	"Saldo Caixas",;				// [03]  C   Titulo do campo
	"Saldo Caixas",;				// [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"N",;                       // [06]  C   Tipo do campo
	"@E 999",;					// [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.F.,;                       // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo

	oStrGrid:AddField(;
		"ZZD_STATUS",;			// [01]  C   Nome do Campo
	"09",;                      // [02]  C   Ordem
	"Status",;					// [03]  C   Titulo do campo
	"Status",;					// [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	"@!",;						// [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.F.,;                       // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo

	oStrGrid:AddField(;
		"ZZD_CLIENT",;			// [01]  C   Nome do Campo
	"10",;                      // [02]  C   Ordem
	"Cliente",;					// [03]  C   Titulo do campo
	"Cliente",;					// [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	"@!",;						// [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.F.,;                       // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo

	oStrGrid:AddField(;
		"ZZD_LOJA",;			// [01]  C   Nome do Campo
	"11",;                      // [02]  C   Ordem
	"Loja",;					// [03]  C   Titulo do campo
	"Loja",;					// [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	"@!",;						// [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.F.,;                       // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo


	oStrGrid:AddField(;
		"ZZD_DOC",;			// [01]  C   Nome do Campo
	"12",;                      // [02]  C   Ordem
	"NF",;					// [03]  C   Titulo do campo
	"NF",;					// [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	"@!",;						// [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.F.,;                       // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo

	oStrGrid:AddField(;
		"ZZD_SERIE",;			// [01]  C   Nome do Campo
	"13",;                      // [02]  C   Ordem
	"Serie",;					// [03]  C   Titulo do campo
	"Serie",;					// [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	"@!",;						// [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.F.,;                       // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo

	oModel  := FWLoadModel('zGrid')

	//Agora na visualização, carrega o modelo, define o cabeçalho e a grid, e no cabeçalho coloca 0% de visualização, e na grid coloca 100%
	oView := FwFormView():New()
	oView:SetModel(oModel)
	oView:AddField('CAB', oStrCab, 'CABID')
	oView:AddGrid('GRID', oStrGrid, 'GRIDID')
	oView:CreateHorizontalBox('TOHID', 0)
	oView:CreateHorizontalBox('TOSHOW', 100)
	oView:SetOwnerView('CAB' , 'TOHID')
	oView:SetOwnerView('GRID', 'TOSHOW')
	oView:SetDescription(cTitle)
	oView:SetFieldAction( 'ZZD_QTDCX', { || AtualizaGridTEMP() } )
Return oView

/*
Função acionada no bLoad, por se tratar de uma temporária com cabeçalho fake, foi usado FWLoadByAlias 
para carregar o default e depois adicionar via ponto de entrada
*/
Static Function xGridx(oSubModel)
	Local aReg  := {}

	If ( oSubModel:GetId() == "GRIDID" )
		aReg := FWLoadByAlias(oSubModel,oTempTable:GetAlias(),oTempTable:GetRealName())
	Else
		aReg := {{cKey},0}
	EndIf
Return aReg

/*
Função bVldPos executado como ponto de entrada na confirmação da alteracao na rotina de montagem
de pallets
*/
User Function ValidCaixa()
	Local aArea := FWGetArea()
	Local lRet := .F.

	Local oModelPad			:= FWModelActive()
	Local oviewPad			:= FWViewActive()
	Local oModelGrid  		:= oModelPad:GetModel("GRIDID")
	Local nLinha			:= 0
	Local nCaixaGravada		:= 0
	Local nSaldoGravado		:= 0

	Local nQtdCaixa	:= 0
	Local cDoc		:= ""
	Local cSerie	:= ""
	Local cCliente	:= ""
	Local cLoja		:= ""
	Local cItem		:= ""
	Local cProduto	:= ""
	Local cPallet	:= ""
	Local cMensagem := ""
	Local lDel		:= .F.
	Local lAlterou	:= .F.

	Local nNovoSaldo := 0

	Begin Sequence

		For nLinha := 1 To oModelGrid:Length()

			lDel := .F.
			lRet := .F.
			lAlterou := .F.

			oModelGrid:GoLine(nLinha)

			nQtdCaixa	:= oModelPad:GetValue("GRIDID", "ZZD_QTDCX")
			cDoc		:= oModelPad:GetValue("GRIDID", "ZZD_DOC")
			cSerie		:= oModelPad:GetValue("GRIDID", "ZZD_SERIE")
			cCliente	:= oModelPad:GetValue("GRIDID", "ZZD_CLIENT")
			cLoja		:= oModelPad:GetValue("GRIDID", "ZZD_LOJA")
			cItem		:= oModelPad:GetValue("GRIDID", "ZZD_ITEM")
			cProduto	:= oModelPad:GetValue("GRIDID", "ZZD_CODPRD")
			cPallet		:= oModelPad:GetValue("GRIDID", "ZZD_PALLET")

			If oModelGrid:IsDeleted()
				DbSelectArea("ZZD")
				ZZD->(dBsetOrder(4)) //ZZD_FILIAL + ZZD_DOC + ZZD_SERIE + ZZD_ITEM
				IF ZZD->(dbSeek(FWxFilial("ZZD")+cDoc + cSerie + cItem))
					While ZZD->(!Eof()) .AND. cDoc==ZZD->ZZD_DOC .AND. cSerie== ZZD_SERIE .AND. cItem==ZZD_ITEM
						If cProduto == ZZD->ZZD_CODPRD .AND. cPallet == ZZD->ZZD_PALLET
							nCaixaGravada	:= ZZD->ZZD_QTDCX
							RecLock("ZZD", .F.)
							ZZD->(DbDelete())
							ZZD->(MsUnlock())
							lDel := .T.
						EndIf
						ZZD->(DbSkip())
					EndDo
				Endif

				If lDel
					dBselectarea("SD2")
					SD2->(dbSetOrder(3)) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
					IF SD2->(dbSeek(FWxFilial("SD2")+ cDoc + cSerie + cCliente + cLoja + cProduto + cItem ))
						nSaldoGravado := SD2->D2_ETQPLT
						RecLock("SD2", .F.)
						SD2->D2_ETQPLT  := nSaldoGravado - nCaixaGravada
						SD2->(MsUnlock())
						lRet := .T.
					Endif
				Endif
			Endif

			DbSelectArea("ZZD")
			ZZD->(dBsetOrder(4)) //ZZD_FILIAL + ZZD_DOC + ZZD_SERIE + ZZD_ITEM
			IF ZZD->(dbSeek(FWxFilial("ZZD")+cDoc + cSerie + cItem))
				While ZZD->(!Eof()) .AND. cDoc==ZZD->ZZD_DOC .AND. cSerie== ZZD_SERIE .AND. cItem==ZZD_ITEM
					iF cProduto == ZZD->ZZD_CODPRD .AND. cPallet == ZZD->ZZD_PALLET
						nCaixaGravada	:= ZZD->ZZD_QTDCX
						If nQtdCaixa <> nCaixaGravada
							lAlterou := .T.
						Endif
					Endif
					ZZD->(DbSkip())
				EndDo
			Endif

			If lAlterou .AND. !oModelGrid:IsDeleted()
				dBselectarea("SD2")
				SD2->(dbSetOrder(3)) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
				IF SD2->(dbSeek(FWxFilial("SD2")+ cDoc + cSerie + cCliente + cLoja + cProduto + cItem ))
					nSaldoDisponivel := SD2->D2_QTSEGUM - SD2->D2_ETQPLT
					nNovoSaldo := nCaixaGravada + nSaldoDisponivel - nQtdCaixa

					If  nSaldoDisponivel == 0 //.OR. (nQtdCaixa < nNovoSaldo .AND. nNovoSaldo >= 0)
						//	cMensagem := "Nao existe saldo disponivel para efetuar a manutenção deste Pallet!"
						//	Help("",1,"ValidCaixa",,cMensagem,1)
						//	Break
					Else
						If nNovoSaldo > SD2->D2_QTSEGUM .OR. nNovoSaldo < 0
							cMensagem := "A quantidade de Caixas nao pode ser superior ao Saldo de Caixas disponiveis! ("+cValToChar(nNovoSaldo)+")"
							Help("",1,"ValidCaixa",,cMensagem,1)
							Break
						Else
							DbSelectArea("ZZD")
							ZZD->(dBsetOrder(4)) //ZZD_FILIAL + ZZD_DOC + ZZD_SERIE + ZZD_ITEM
							IF ZZD->(dbSeek(FWxFilial("ZZD")+cDoc + cSerie + cItem))
								While ZZD->(!Eof()) .AND. cDoc==ZZD->ZZD_DOC .AND. cSerie== ZZD_SERIE .AND. cItem==ZZD_ITEM
									iF cProduto == ZZD->ZZD_CODPRD .AND. cPallet == ZZD->ZZD_PALLET
										RecLock("ZZD", .F.)
										ZZD->ZZD_QTDCX  := nQtdCaixa
										ZZD->(MsUnlock())
									Endif
									ZZD->(DbSkip())
								EndDo
							Endif
							
							dBselectarea("SD2")
							SD2->(dbSetOrder(3)) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
							IF SD2->(dbSeek(FWxFilial("SD2")+ cDoc + cSerie + cCliente + cLoja + cProduto + cItem ))
								RecLock("SD2", .F.)
								SD2->D2_ETQPLT  := nQtdCaixa
								SD2->(MsUnlock())
							Endif
							lRet := .T.
						Endif
					Endif
				Endif
			Endif
		Next
		//Valida CONFIRMAR quando usuario não altera nada
		If (!lAlterou .and. !lDel) .and. !lRet
			lRet := .T.
		Endif

	End Sequence

	oviewPad:Refresh()
	FWRestArea(aArea)

Return lRet


/*
Atualiza a grid da tela temporaria
*/
Static Function AtualizaGridTEMP()
	Local aArea   		:= FWGetArea()
	Local oModel        := FWModelActive()
	Local oView         := FwViewActive()
	Local oModelTMP     := Nil
	Local lRet := .F.


	Local nSaldoNovo 		:= 0
	Local nNovoSaldo 		:= 0

	Begin Sequence

		aLinhas := FWSaveRows()

		oModelTMP := oModel:GetModel(oModelTMP)

		nSaldoNovo 		:= oModel:GetValue('GRIDID','D2_ETQPLT')

		nQtdCaixa	:= oModel:GetValue("GRIDID", "ZZD_QTDCX")
		cDoc		:= oModel:GetValue("GRIDID", "ZZD_DOC")
		cSerie		:= oModel:GetValue("GRIDID", "ZZD_SERIE")
		cCliente	:= oModel:GetValue("GRIDID", "ZZD_CLIENT")
		cLoja		:= oModel:GetValue("GRIDID", "ZZD_LOJA")
		cItem		:= oModel:GetValue("GRIDID", "ZZD_ITEM")
		cProduto	:= oModel:GetValue("GRIDID", "ZZD_CODPRD")


		DbSelectArea("ZZD")
		ZZD->(dBsetOrder(4)) //ZZD_FILIAL + ZZD_DOC + ZZD_SERIE + ZZD_ITEM
		IF ZZD->(dbSeek(FWxFilial("ZZD")+cDoc + cSerie + cItem))
			nCaixaGravada	:= ZZD->ZZD_QTDCX
		Endif

		dBselectarea("SD2")
		SD2->(dbSetOrder(3)) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
		IF SD2->(dbSeek(FWxFilial("SD2")+ cDoc + cSerie + cCliente + cLoja + cProduto + cItem ))
			nSaldoDisponivel := SD2->D2_QTSEGUM - SD2->D2_ETQPLT
			nNovoSaldo := nCaixaGravada + nSaldoDisponivel - nQtdCaixa

			If  nSaldoDisponivel == 0 //.OR. (nQtdCaixa < nNovoSaldo .AND. nNovoSaldo > 0)
				cMensagem := "Nao existe saldo disponivel para efetuar a manutenção deste Pallet!"
				Help("",1,"AtualizaGridTEMP",,cMensagem,1)
				Break
			Else
				oModelTMP:SetValue('GRIDID', 'D2_ETQPLT' , nNovoSaldo )
				lRet := .T.
			Endif
		Endif

		If !lRet
			cHelp1 := "Nao houve alteracao nos dados do grid!"
			Help("",1,"AtualizaGridTEMP",,cHelp1,1)
		Endif

		FWRestRows(aLinhas)

		oview:Refresh()

	End Sequence

	FWRestArea(aArea)

Return lRet
