****** Settings ***
Library           yaml
Library           OperatingSystem
Library           Selenium2Library
Resource          ../../variable/common_variable.txt
Resource          ../../keyword/common/page.robot

*** Variables ***

*** Test Cases ***
# user正向用例
user
    log    ${TEST NAME}
    # 读取模板文件内容
    ${yamltemplate}    YamlLoad    ${path}/data/template/page_template.yaml
	${objtemplate}    Get From Dictionary    ${yamltemplate}    ${TEST NAME}_page
    # 读取数据文件内容
    ${yamlData}    YamlLoad    ${path}/data/administration/user_data.yaml
	${objDataList}    Get From Dictionary    ${yamlData}    ${TEST NAME}_data
	# 读取模板文件中OpenCreateOrEditPageIds中的数据（打开页面）
	${openCreateOrEditPageIds}    Get From Dictionary    ${objtemplate}    openCreateOrEditPage
	# 读取模板文件中PageData中的数据（打开页面）       
    ${tempData}    Get From Dictionary    ${objtemplate}    templateData
    ${OkOrCance}    Get From Dictionary    ${objtemplate}    okOrCancel
    FOR    ${objData}    IN    @{objDataList}
    	${pageData}    CreateOrEditPage    ${tempData}      ${objData}    ${openCreateOrEditPageIds}    ${OkOrCance}

    END
    
#验证列设置功能  
user_column_setup
    log    ${TEST NAME}
    # 读取模板文件内容
    ${yamltemplate}    YamlLoad    ${path}/data/template/page_template.yaml
	${objtemplate}    Get From Dictionary    ${yamltemplate}    user_page
    # 读取数据文件内容
    ${yamlData}    YamlLoad    ${path}/data/administration/user_data.yaml
	${objDataList}    Get From Dictionary    ${yamlData}    ${TEST NAME}_data
	# 读取模板文件中OpenCreateOrEditPageIds中的数据（打开页面）
	${tempData}    Get From Dictionary    ${objtemplate}    templateData
	${openCreateOrEditPageIds}    Get From Dictionary    ${objtemplate}    openCreateOrEditPage
    FOR    ${objData}    IN    @{objDataList}
    	ColumnSetup    ${openCreateOrEditPageIds}    ${objData}    ${tempData}
    END
    
# 翻页功能验证
user_turn_page
    log    ${TEST NAME}
    # 读取模板文件内容
    ${yamltemplate}    YamlLoad    ${path}/data/template/page_template.yaml
	${objtemplate}    Get From Dictionary    ${yamltemplate}    user_page

	${openCreateOrEditPageIds}    Get From Dictionary    ${objtemplate}    openCreateOrEditPage
    ${okOrCancel}    Get From Dictionary    ${objtemplate}    okOrCancel
    TurnPage    ${openCreateOrEditPageIds}    ${okOrCancel}
  
# 验证user页面账号日志功能  
user_operation_log
    log    ${TEST NAME}
    # 读取模板文件内容
    ${yamltemplate}    YamlLoad    ${path}/data/template/page_template.yaml
	${objtemplate}    Get From Dictionary    ${yamltemplate}    user_page
	${openCreateOrEditPageIds}    Get From Dictionary    ${objtemplate}    openCreateOrEditPage
    UserOperationLog    ${openCreateOrEditPageIds}