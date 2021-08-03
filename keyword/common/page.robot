*** Settings ***
Library           yaml
Library           OperatingSystem
Library           Selenium2Library
Library           Collections
Library           String
Resource          ../../variable/common_variable.txt
Library           ../../customlib/common/type_judgment.py

*** Keywords ***
YamlLoad
    [Arguments]    ${filepath}
    [Documentation]    读取yaml文件
    ...    ${filepath}：文件路径
    ${yaml}=  Get File  ${filepath}
    ${loaded}=  yaml.Safe Load  ${yaml}
    [Return]    ${loaded}

CreateOrEditPage
    [Arguments]    ${elementList}    ${dataList}    ${openCreateOrEditPage}    ${okOrCance}
    [Documentation]    完整的打开创建或者修改数据页面，并进行操作（创建数据、修改数据）
    ...    ${elementList}：模板的PageData数据，格式：[{id=responsepages_profileName1,value=testname}]
    ...    ${dataList}：数据文件中的数据，格式[[id=responsepages_profileName1,value=testname]]
    ...    ${openCreateOrEditPage}:模板文件中openCreateOrEditPage数据
    ...    ${okOrCance}：模板文件中okOrCancel的数据
    #判断是否出现弹出框
    ${operatingType}    Set Variable    ${1}
    FOR    ${data}    IN    @{dataList}
        ${operatingType}    Get From Dictionary    ${data}    operatingType
        Run keyword if    "${operatingType}" == "create" or "${operatingType}" == "edit" or "${operatingType}" == "createGroup"    run keywords    log    执行用例
        ...    AND    OperatPage    ${elementList}    ${data}    ${openCreateOrEditPage}
        ...    AND    OkOrCancel    ${okOrCance}    ${data}
    END
    ${deletePosition}    Get From Dictionary    ${okOrCance}    delete
    Run keyword if    "${operatingType}" == "create" or "${operatingType}" == "edit" or "${operatingType}" == "createGroup"    run keywords    log    执行用例
    ...    AND    DeleteData    ${deletePosition}

OperatPage
    [Arguments]    ${elementList}    ${pData}    ${openCreateOrEditPage}=1
    [Documentation]    打开创建或者修改数据页面，输入数据
    ...    ${elementList}：模板的PageData数据，格式：[{id=responsepages_profileName1,value=testname}]
    ...    ${pData}：数据文件中的数据，格式[id=responsepages_profileName1,value=testname]
    ...    ${openCreateOrEditPage}:模板文件中openCreateOrEditPage数据
    ${dataType}    Evaluate    type(${openCreateOrEditPage})
    ${openType}    Run keyword if    "${dataType}" == "<class 'dict'>"    Get From Dictionary    ${pData}    operatingType
    Run keyword if    "${dataType}" == "<class 'dict'>"    run keywords    log    打开创建页面
    ...    AND    OpenCreateOREdit    ${openCreateOrEditPage}[${openType}]
    FOR    ${element}    IN    @{elementList}
        ${type}    Get From Dictionary    ${element}    type
        ${return}    ${elementId}    Run Keyword And Ignore Error    Get From Dictionary    ${element}    position
        ${elementId}    Run Keyword If    "${return}"=="FAIL"    set variable    null
        ...    ELSE    set variable    ${elementId}
        ${value}    Get From Dictionary    ${element}    value
        ${return}    ${elementValue}    Run Keyword And Ignore Error    Get From Dictionary    ${pData}    ${value}
        ${elementValue}    Run Keyword If    "${return}"=="FAIL"    set variable    null
        ...    ELSE    set variable    ${elementValue}
        ${return}    ${elementData}    Run Keyword And Ignore Error    Get From Dictionary    ${element}    data
        ${elementData}    Run Keyword If    "${return}"=="FAIL"    set variable    null
        ...    ELSE    set variable    ${elementData}
        ${return}    ${default}    Run Keyword And Ignore Error    Get From Dictionary    ${element}    default
        ${default}    Run Keyword If    "${return}"=="FAIL" or "${default}"=="${EMPTY}"    set variable    null
        ...    ELSE    set variable    ${default}
        Run Keyword IF    "${elementValue}" != "null"    run keywords    log    执行操作
        ...    AND    Operation    ${type}    ${elementId}    ${elementValue}    ${elementData}    ${default}
    END   
     
OpenCreateOREdit
    [Arguments]    ${menuIdList}
    [Documentation]    点击新增或修改按钮
    ...   ${menuIdList}:打开目标界面需要点击的所有按钮，顺序输入
    
    FOR    ${menuId}    IN    @{menuIdList}
        sleep    ${sleep}
        #Wait Until Element Is Enabled    id=${menuId}    ${sleep_Wait}
        click element    ${menuId}
    END
    sleep    ${sleep}
    
Operation
    [Arguments]    ${type}    ${positioning}    ${dataValue}=null    ${elementData}=null    ${default}=null
    [Documentation]  根据type进行操作
    ...    ${type}：操作类型
    ...    ${positioning}：操作的元素定位信息
    ...    ${dataValue}：输入、或者上传的数据信息
    ...    ${elementData} :  模板中的PageData中的data数据，当数据为嵌套数据时有该字段
    
    Run Keyword If    "${type}" == "input"    input text	${positioning}    ${dataValue}
    ...    ELSE IF    "${type}" == "upload"    Choose File    ${positioning}    ${path}data/scriptfile/${dataValue} 
    ...    ELSE IF    "${type}" == "combination"    run keywords    log    嵌套操作
    ...    AND    OperatCombinationData    ${dataValue}    ${elementData}    ${positioning}
    ...    ELSE IF    "${type}" == "combinationAfter"    run keywords    log    嵌套操作第二种
    ...    AND    OperatCombinationData2    ${dataValue}    ${elementData}    ${positioning}
    ...    ELSE IF    "${type}" == "click"    run keywords    log    点击按钮
    ...    AND    click element    ${positioning}
    ...    AND    sleep    ${sleep}
    ...    ELSE IF    "${type}" == "clickTexts"    run keywords    log    点击多个文本
    ...    AND    ClickTexts    ${dataValue}
    ...    ELSE IF    "${type}" == "clickText"    run keywords    log    点击单个文本
    ...    AND    ClickText    ${dataValue}
    ...    ELSE IF    "${type}" == "columnSetup"    run keywords    log    点击列设置中取消列选中
    ...    AND    CancelColumnSetup    ${dataValue}
    ...    ELSE IF    "${type}" == "switch"    run keywords    log    开关按钮
    ...    AND    SwitchButton    ${positioning}    ${dataValue}    ${default}
    ...    ELSE IF    "${type}" == "switchCombination"    run keywords    log    开关按钮，关闭或打开时进行操作
    ...    AND    SwitchCombination    ${positioning}    ${dataValue}    ${default}    ${elementData}
    ...    ELSE IF    "${type}" == "radioButton"    run keywords    log    单选按钮
    ...    AND    RadioButton    ${dataValue}    ${elementData}
    ...    ELSE IF    "${type}" == "search"    run keywords    log    单条查询点击定位位置
    ...    AND    SearchOperation    ${positioning}    ${dataValue}
    ...    ELSE IF    "${type}" == "searchClickText"    run keywords    log    单条查询点击文本
    ...    AND    SearchOperationClickText    ${positioning}    ${dataValue}
    ...    ELSE IF    "${type}" == "searchs"    run keywords    log    查询多数据后点击文本
    ...    AND    SearchOperations    ${positioning}    ${dataValue}
    ...    ELSE IF    "${type}" == "assert"    run keywords    log    断言
    ...    AND    PageAssert    ${positioning}    ${dataValue} 
    ...    ELSE    log    无法识别的类型 
    sleep    ${sleep}
 
OperatCombinationData
    [Arguments]    ${elementValue}    ${templateData}    ${positioning}
    [Documentation]    多步骤嵌套动作方法，循环取出数据
    ...    ${elementValue}：数据文件中嵌套操作数据
    ...    ${templateData}：模板文件中嵌套数据data数据

    FOR    ${element}    IN    @{elementValue}
        sleep    ${sleep}
        click element    ${positioning}
        sleep    ${sleep}
        ${elementList}    create list    ${element}
        OperatCombination    ${elementList}    ${templateData}
    END
    
OperatCombinationData2
    [Arguments]    ${elementValue}    ${templateData}    ${positioning}
    [Documentation]    多步骤嵌套动作方法，循环取出数据。
    ...    ${elementValue}：数据文件中嵌套操作数据
    ...    ${templateData}：模板文件中嵌套数据data数据
    ${sum}    Set Variable    ${0}
    FOR    ${element}    IN    @{elementValue}
        run keyword if    "${sum}" != "0"    run keywords    log    第二次循环开始执行
        ...    AND    click element    ${positioning}
        ...    AND    sleep    ${sleep}
        ${elementList}    create list    ${element}
        OperatCombination    ${elementList}    ${templateData}
        ${sum}    Evaluate    ${sum}+${1}
    END

OperatCombination
    [Arguments]    ${elementValue}    ${templateData}
    [Documentation]    多步骤嵌套动作方法，递归执行该方法
    ...    ${elementValue}：数据文件中嵌套操作数据
    ...    ${templateData}：模板文件中嵌套数据data数据
    ${dataValue}    Set variable
    ${dataValueKey}    Set variable
    FOR    ${element}    IN    @{elementValue}
        log    ${element}
        ${dataType}    dataType    ${element}
        ${dataValue}    Run keyword if    "${dataType}" == "<class 'dict'>"    get dictionary keys    ${element}
        log    ${dataValue}
        ${dataValueKey}    Run keyword if    "${dataType}" == "<class 'dict'>"    Set variable    ${dataValue}[0]
        ...    ELSE    Set Variable    ${element}
        log    ${dataValueKey}
        ${re}    CombinationLate    ${templateData}    ${dataValueKey}
        ${type}    Get From Dictionary    ${re}    type
        ${return}    ${elementId}    Run Keyword And Ignore Error    Get From Dictionary    ${re}    position
        ${elementId}    Run Keyword If    "${return}"=="FAIL"    set variable    null
        ...    ELSE    set variable    ${elementId}
        ${data}    Get From Dictionary    ${re}    data
        log    ${dataType}
        ${value}    Run keyword if    "${dataType}" == "<class 'dict'>"    Get From Dictionary    ${element}    ${dataValueKey} 
        ...    ELSE IF    "${dataType}" == "<class 'str'>"    Set Variable    null
        ...    ELSE    log    非类型
        log    ${value}
        # ${value}    Get From Dictionary    ${element}    ${dataValueKey}
        ${return}    ${default}    Run Keyword And Ignore Error    Get From Dictionary    ${re}    default
        ${default}    Run Keyword If    "${return}"=="FAIL" or "${default}"=="${EMPTY}"    set variable    null
        ...    ELSE    set variable    ${default}
        Run keyword if    "${value}" == "None"    log    无数据不操作
        ...    ELSE    Operation    ${type}    ${elementId}    ${value}    ${data}    default=${default}
        ${listType}    dataType    ${value}
        log    ${listType}
        Run keyword if    "${listType}" != "<class 'str'>" and "${type}" != "combination" and "${type}" != "combinationAfter" and "${listType}" != "<class 'NoneType'>"    OperatCombination    ${value}    ${data} 
    END

CombinationLate
    [Arguments]    ${elementData}    ${dataValue}
    [Documentation]     多步骤嵌套动作对比循环取出模板文件的value同数据文件中的值进行对比，并返回对比成功的key值
    log    ${dataValue}
    ${re}    Set variable
    FOR    ${i}    IN    @{elementData}
        log    ${i}[value]
        ${re}    Run keyword if    "${i}[value]" == "${dataValue}"    Set variable    ${i}
        ...    ELSE    Set variable    ${re}
    END
    log    ${re}
    [Return]    ${re}
    
SwitchButton
    [Arguments]    ${positioning}    ${dataStatus}    ${default}
    [Documentation]    单选按钮操作
    ...    ${positioning}：单选按钮定位信息
    ...    ${dataStatus}：数据中按钮的状态
    ...    ${default}：模板中按钮的默认状态
    Run Keyword If    "${dataStatus}" == "${default}"    log    状态相同不进行操作
    ...    ELSE    click element    ${positioning}

SwitchCombination
    [Arguments]    ${positioning}    ${pageData}    ${default}    ${elementData}
    [Documentation]    开关按钮组合操作，关闭或打开时进行下一步操作
    ...    ${positioning}： 开关按钮定位信息
    ...    ${pageData}：数据中按钮的状态
    ...    ${default}：模板中按钮的默认状态
    ...    ${elementData}：模板中的PageData中的data数据，按钮状态改变进行下一步操作
    log    ${positioning}
    log    ${pageData}
    log    ${default}
    log    ${elementData}
    ${dataType}    dataType    ${pageData}
    ${dataValue}    Run keyword if    "${dataType}" == "<class 'dict'>"    get dictionary keys    ${pageData}
    log    ${dataValue}
    ${dataValueKey}    Set Variable if    "${dataType}" == "<class 'dict'>"    ${dataValue}[0]
    ...    ${pageData} 
    ${data}    Run keyword if    "${dataType}" == "<class 'dict'>"    Set variable    ${pageData}[${dataValueKey}]
    Run Keyword If    "${dataValueKey}" == "${default}"    log    状态相同不进行操作
    ...    ELSE    SwitchCombinationOperation    ${positioning}    ${elementData}    ${data}

SwitchCombinationOperation
    [Arguments]    ${positioning}    ${elementData}    ${datas}
    [Documentation]    根据开关状态进行下一步操作
    ...    ${positioning}：开关按钮定位信息
    ...    ${elementData}：模板中的PageData中的data数据，按钮状态改变进行下一步操作
    ...    ${datas} ：数据文件中的操作数据
    click element    ${positioning}
    sleep    ${sleep}
    FOR    ${data}    IN    @{datas}
        ${dataKey}    get dictionary keys    ${data}
        log    ${dataKey}
        ${template}    CombinationLate    ${elementData}    ${dataKey}[0]
        ${type}    Get From Dictionary    ${template}    type
        ${elementId}    Get From Dictionary    ${template}    position
        ${templateData}    Get From Dictionary    ${template}    data
        ${value}    Get From Dictionary    ${template}    value
        ${dataValue}    Get From Dictionary    ${data}    ${value}
        Operation    ${type}    ${elementId}    ${dataValue}    ${templateData}
    END

RadioButton
    [Arguments]    ${dataValue}    ${elementData}
    [Documentation]    单选按钮操作
    ...    ${dataValue}：数据文件中单选按钮的名称
    ...    ${elementData}：模板中所有单选按钮的数据
    FOR    ${button}    IN    @{elementData}
        ${type}    Get From Dictionary    ${button}    type
        ${position}    Get From Dictionary    ${button}    position
        ${value}    Get From Dictionary    ${button}    value
        Run Keyword If    "${dataValue}" == "${value}"    run keywords    log    点击${value}按钮
        ...    AND    Operation    ${type}    ${position}
    END
    
ClickTexts
    [Arguments]    ${positioning}
    [Documentation]    根据文本定位，点击页面中多个文本
    ...    ${positioning}：文本列表
    FOR    ${i}    IN    @{positioning}
        click element    //span[contains(text(),'${i}')]
        sleep    ${sleep}
    END

ClickText
    [Arguments]    ${positioning}
    [Documentation]    根据文本定位，点击页面中多个文本
    ...    ${positioning}：文本列表
    click element    //span[contains(text(),'${positioning}')]
    sleep    ${sleep}
    
SearchOperation
    [Arguments]    ${positioning}    ${searchData}
    [Documentation]    页面查询操作
    ...    ${positioning}：查询输入框定位
    ...    ${searchData}：查询内容
    sleep    ${sleep}
    input text    ${positioning}[0]    ${searchData}
    sleep    ${sleep}
    press keys    ${positioning}[0]    ENTER
    sleep    ${sleep}
    click element    ${positioning}[1]
    sleep    ${sleep}
    
SearchOperationClickText
    [Arguments]    ${positioning}    ${searchData}
    [Documentation]    页面查询操作
    ...    ${positioning}：查询输入框定位
    ...    ${searchData}：查询内容
    sleep    ${sleep}
    input text    ${positioning}    ${searchData}
    sleep    ${sleep}
    press keys    ${positioning}    ENTER
    sleep    ${sleep}
    click element    //span[contains(text(),'${searchData}')]
    sleep    ${sleep}
    
SearchOperations
    [Arguments]    ${positioning}    ${searchData}
    [Documentation]    页面查询多数据操作
    ...    ${positioning}：查询输入框定位
    ...    ${searchData}：查询内容
    sleep    ${sleep}
    FOR    ${i}    IN    @{searchData}
        input text    ${positioning}[0]    ${i}
        sleep    ${sleep_min}
        press keys    ${positioning}[0]    ENTER
        sleep    ${sleep}
        click element    //span[contains(text(),'${i}')]
        sleep    ${sleep}
    END

PageAssert
    [Arguments]    ${positioning}    ${assertText}
    [Documentation]    页面查询多数据操作
    ...    ${positioning}: 断言定位
    ...    ${assertText}: 断言文本
    ${text}    Get Text    ${positioning}
    Should Be Equal As Strings    ${text}    ${assertText}

OkOrCancel
    [Arguments]    ${templateData}    ${data}
    [Documentation]    提交数据后校验
    ...    ${templateData}： 模板文件中okOrCancel数据，用于点击ok按钮及创建成功校验
    ...    ${data}：数据文件内容
    ${okBUutton}    Get From Dictionary    ${templateData}    position
    ${assertPosition}    Get From Dictionary    ${templateData}    ${data}[searchCriteria]
    ${searchCriteria}    Get From Dictionary    ${data}    searchCriteria
    click element    ${okBUutton}    #点击OK缇交
    sleep    ${sleep}
    SearchData    ${data}[${searchCriteria}]    ${templateData}    ${searchCriteria}        #搜索框的关键字
    click element    ${templateData}[Selected]
    ${text1}    Get Text    ${assertPosition}        #获取点击后页面文本信息
    Should Be Equal As Strings    ${text1}    ${data}[${searchCriteria}]
    
SearchData
    [Arguments]    ${value}    ${templateData}    ${searchCriteria}
    [Documentation]
    ...    ${value}:传入查询的数据
    ...    ${templateData}：模板中okOrCancel得数据
    ...    ${searchCriteria}:搜索条件
    ${searchType}    Get From Dictionary    ${templateData}    search
    Run Keyword If    "${searchType}" == "type1"    run keywords    log    第一种搜索
    ...    AND    SearchType1    ${value}    ${searchCriteria}

CancelColumnSetup
    [Arguments]    ${columns}
    FOR    ${i}    IN    @{columns}
        click element    xpath=/html/body/div[1]/div/div[2]/div[2]/div/div/div/div[3]/div[2]/div/div/span[contains(text(),'${i}')]
        sleep    ${sleep}
    END

SearchType1
    [Arguments]    ${searchvalue}    ${searchCriteria}
    [Documentation]    本方法搜索查询适用于User
    ...    ${searchvalue}:搜索条件的值
    ...    ${search}：搜索条件
    ...    ${templateData}:模板中okOrCancel得数据
    sleep    ${sleep}
    click element    id=one-input   #点击搜索框
    sleep    ${sleep_min}
    click element    xpath=//*[@id="input_list"]/ul/li/span[contains(text(), "${searchCriteria}")] 
    input text    id=sreach_input    ${searchValue}
    sleep    ${sleep}
    click element    id=search-input-search    #点击搜索按钮
    sleep    ${sleep}
    click element    xpath=//*[@id="app"]/div/div[2]/div[2]/div/div/div/div[2]/div[1]/div[2]/div[1]/div/div/div[3]/i
    sleep    ${sleep}
    
DeleteData
     [Arguments]    ${position}
     [Documentation]    删除测试数据
     ...    ${position}：删除按钮元素定位
     sleep    ${sleep}
     click element    ${position}
     sleep    ${sleep}
     click element    xpath=/html/body/div/div/div[3]/button[2]
     sleep    ${sleep}

CreateOrEditPageNegtive
    [Arguments]    ${elementList}    ${dataList}    ${OpenCreateOrEditPage}    ${OkOrCance}
    [Documentation]    完整的打开创建页面反向用例关键字
    ...    ${elementList}：模板的PageData数据，格式：[{id=responsepages_profileName1,value=testname}]
    ...    ${dataList}：数据文件中的数据，格式[[id=responsepages_profileName1,value=testname]]
    ...    ${OpenCreateOrEditPage}:模板文件中OpenCreateOrEditPage数据
    ...    ${OkOrCance}：模板文件中OkOrCancel的数据
    
    FOR    ${data}    IN    @{dataList}
        #打开页面输入数据
        OperatPageNegtive    ${elementList}    ${data}    ${OpenCreateOrEditPage}
        # 点击OK按钮
        OkButton   ${OkOrCance}
        # 页面断言
        AssertPage    ${data}[assertText]
    END

OperatPageNegtive
    [Arguments]    ${elementList}    ${pData}    ${OpenCreateOrEditPage}
    [Documentation]    打开创建或者修改数据页面，输入数据
    ...    ${elementList}：模板的PageData数据，格式：[{id=responsepages_profileName1,value=testname}]
    ...    ${pData}：数据文件中的数据，格式[id=responsepages_profileName1,value=testname]
    ...    ${OpenCreateOrEditPage}:模板文件中OpenCreateOrEditPage数据
   
    ${openType}    Get From Dictionary    ${pData}    operatingType
    OpenCreateOREdit    ${OpenCreateOrEditPage}[${openType}]
    ${dataType}    Run keyword if    "${openType}" == "create" or "${openType}" == "edit"    Set Variable    createAndEdit
    ...    ELSE IF        "${openType}" == "createGroup" or "${openType}" == "editGroup"    Set Variable    createAndEditGroup
    ${elementList}    Set Variable    ${elementList}[${dataType}]
    FOR    ${element}    IN    @{elementList}
        ${type}    Get From Dictionary    ${element}    type
        ${return}    ${elementId}    Run Keyword And Ignore Error    Get From Dictionary    ${element}    position
        ${elementId}    Run Keyword If    "${return}"=="FAIL"    set variable    null
        ...    ELSE    set variable    ${elementId}
        ${value}    Get From Dictionary    ${element}    value
        ${return}    ${elementValue}    Run Keyword And Ignore Error    Get From Dictionary    ${pData}    ${value}
        ${elementValue}    Run Keyword If    "${return}"=="FAIL"    set variable    null
        ...    ELSE    set variable    ${elementValue}
        ${return}    ${elementData}    Run Keyword And Ignore Error    Get From Dictionary    ${element}    data
        ${elementData}    Run Keyword If    "${return}"=="FAIL"    set variable    null
        ...    ELSE    set variable    ${elementData}
        ${return}    ${default}    Run Keyword And Ignore Error    Get From Dictionary    ${element}    default
        ${default}    Run Keyword If    "${return}"=="FAIL" or "${default}"=="${EMPTY}"    set variable    null
        ...    ELSE    set variable    ${default}
        Run Keyword If    "${elementValue}" != "null"    run keywords    log    进行操作
        ...    AND    Operation    ${type}    ${elementId}    ${elementValue}    ${elementData}    ${default}
    END 

OkButton
    [Arguments]    ${OkOrCance}
    [Documentation]    点击Ok按钮
    ...    ${OkOrCance}：模板文件中OkOrCancel的数据
    ${okPosition}    Get From Dictionary    ${OkOrCance}    position
    sleep    ${sleep}
    click element    ${okPosition}
    sleep    ${sleep_min}

AssertPage
    [Arguments]    ${assertText}
    [Documentation]    反向用例断言
    ...    ${assertText}： 断言数据列表形式["assertText1","assertText2"]
    FOR    ${text}    IN    @{assertText}
        Page Should Contain    ${text} 
    END

TextContain
    [Arguments]    ${columnList}    ${text}
    [Documentation]    验证页面不存在文本关键字
    FOR    ${column}    IN    @{columnList}
        should not be equal    ${column}    ${text}
    END

CreatePageTextAssert
    [Arguments]    ${elementList}    ${dataList}    ${OpenCreateOrEditPage}
    [Documentation]    用于创建页面内文本断言
    ...    ${elementList}：模板的PageData数据，格式：[{id=responsepages_profileName1,value=testname}]
    ...    ${dataList}：数据文件中的数据，格式[id=responsepages_profileName1,value=testname]
    ...    ${OpenCreateOrEditPage}:模板文件中OpenCreateOrEditPage数据
    #打开页面输入数据
    OperatPageNegtive    ${elementList}    ${dataList}    ${OpenCreateOrEditPage}
    #数据文件中断言列表
    ${texts}    Get From Dictionary    ${dataList}    AssertText
    # 页面文本断言
    FOR    ${text}    IN    @{texts}
        Page Should Contain    ${text}
    END
    
PrioritySelectCaseData    
    [Arguments]    ${objDataList}
    #增加优先级筛选执行代码,当operatingtype中最后一位值为9时，只执行该数据参数
    ${templist}    create list
    log to console    获取的原始数据------${objDataList}
    FOR    ${it}    IN    @{objDataList}
        ${operatingType0}    Get From Dictionary    ${it}[0]    operatingType
        ${operatingType}    get substring    ${operatingType0}        -1
        ${operatingType1}    get substring    ${operatingType0}    0    -1
        Run keyword if    "${operatingType}" == "9"    run keywords
        ...    set to dictionary    ${it}[0]    operatingType    ${operatingType1}
        ...    AND    append to list    ${templist}    ${it}
        ...    AND    log to console    ${templist}
    END
    ${templistcount}    get length    ${templist}
    
    ${objDataList}   run keyword if    ${templistcount}>0    set variable    ${templist} 
    ...    ELSE      set variable    ${objDataList}   
    log to console    优先执行的数据------${objDataList}    
    [Return]    ${objDataList}
    #优先级筛选执行结束
OpenPage
    [Arguments]    ${openCreateOrEditPage}
    [Documentation]    打开测试页面
    ${pagePosition}    Get From Dictionary    ${openCreateOrEditPage}    create
    ${pagePosition}    get substring    ${pagePosition}    0    2
    FOR    ${i}    IN    @{pagePosition}
        click element    ${i}
        sleep    ${sleep}
    END
    
TestPageVerifyOperation
    [Arguments]    ${openCreateOrEditPage}    ${data}    ${tempData}
    [Documentation]    测试页面操作验证
    ...    ${openCreateOrEditPage}：模板文件中openCreateOrEditPage中数据，打开页面定位信息
    #登录后打开测试页面
    OpenPage    ${openCreateOrEditPage}
    OperatPage    ${tempData}    ${data}


ColumnSetup    
    [Arguments]    ${openCreateOrEditPage}    ${data}    ${tempData}
    [Documentation]    列设置验证关键字
    ...    ${openCreateOrEditPage}：模板文件中openCreateOrEditPage中数据，打开页面定位信息
    #登录后打开测试页面
    OpenPage    ${openCreateOrEditPage}
    OperatPage    ${tempData}    ${data}
    # 断言页面不存在列
    ${columnList}    Get From Dictionary    ${data}    cancel_show
    ${assertPosition}    Get From Dictionary    ${data}    assertPosition
    FOR    ${position}    IN    @{assertPosition}
        ${text}    Get text    ${position}
        TextContain    ${columnList}    ${text}
    END
    
TurnPage
    [Arguments]    ${openCreateOrEditPage}    ${okOrCancel}
    [Documentation]    翻页功能
    
    OpenPage    ${openCreateOrEditPage}
    ${number}    Get Text    xpath=//*[@id="app"]/div/div[2]/div[2]/div/div/div/div[2]/div[3]/div/div/span
    log    ${number}
    ${number}    get substring    ${number}    6
    log    ${number}
    Run keyword if    ${number} > 20    Run keywords    log    执行翻页操作
    ...    AND    TurnPageAssert    ${okOrCancel}

TurnPageAssert
    [Arguments]    ${okOrCancel}
    [Documentation]    验证翻页功能
    ${idPosition}    Get From Dictionary    ${okOrCancel}    ID
    ${id1}    Get Text    ${idPosition}
    click element    xpath=//*[@id="app"]/div/div[2]/div[2]/div/div/div/div/div[2]/div[3]/div/div/button[2]
    sleep    ${sleep}
    ${id2}    Get Text    ${idPosition}
    click element    xpath=//*[@id="app"]/div/div[2]/div[2]/div/div/div/div/div[2]/div[3]/div/div/button[1]
    sleep    ${sleep}
    ${id3}    Get Text    ${idPosition}
    click element    xpath=//*[@id="app"]/div/div[2]/div[2]/div/div/div[1]/div/div[2]/div[3]/div/div/ul/li[2]
    sleep    ${sleep}
    ${id4}    Get Text    ${idPosition}
    Should Not Be Equal    ${id1}    ${id2}
    Should Not Be Equal    ${id2}    ${id3}
    Should Not Be Equal    ${id3}    ${id4}
    



UserOperationLog
    [Arguments]    ${openCreateOrEditPage}
    [Documentation]    验证user页面账号日志功能
    
    OpenPage    ${openCreateOrEditPage}
    SearchType1    ${username}    User
    click element    xpath=//*[@id="userTable"]/div[4]/div[2]/table/tbody/tr/td[11]/div/div/button
    sleep    ${sleep}
    ${text}    Get Text    xpath=//*[@id="roleTable"]/div[3]/table/tbody/tr[1]/td[4]/div/span
    Should Be Equal As Strings    ${text}    ${testClentIP}

