*** Settings ***
Library           Selenium2Library
Resource          ../../variable/common_variable.txt

*** Keywords ***

Login
    Open Browser    http://${host}/#/login    ${browserType}
    Maximize Browser Window
    ClearCache
    input text    id=usernameInput    ${username}
    input text    name=password    ${password}
    Click button    id=login
    PasswordPrompt    #判断是否有密码过期的提示
    
ClearCache
    ${status}    Run Keyword And Return Status    Page Should Contain    After update the version, you need to clear the cache and log in again, otherwise some functions will not be available.    #判断页面是否包含该文本
    run keyword if    "${status}"=="True"    click element    xpath=/html/body/div[2]/div/div[3]/button[2]
    run keyword if    "${status}"=="False"    log    不用进行清除缓存

PasswordPrompt
    [Arguments]    ${passwd}=null   ${day}=100    ${editpasswd}=no
    sleep    ${sleep}
    Page Should Contain     Dashboard

PasswordPromptTrue
    [Arguments]    ${passwd}    ${day}    ${editpasswd}
    run keyword if    "${editpasswd}"=="yes"    run keywords    sleep    1
    ...    AND    click element   xpath=/html/body/div[2]/div/div[3]/button[2]
    ...    AND    sleep    1
    ...    AND    ChangePassword    ${passwd}    ${day}
    ...    ELSE IF    "${editpasswd}"=="no"    run keywords    sleep    1
    ...    AND    click element    xpath=/html/body/div[2]/div/div[3]/button[1]
    ...    AND    sleep    1

ChangePassword
    [Arguments]    ${passwd}    ${day}    ${Required-Password-Change}=close    
    #判断是否修改密码
    run keyword if    "${passwd}"!="null"    Run Keywords    sleep    1
    ...    AND    input text    xpath=//*[@id="app"]/div/div[3]/div[1]/div/div/div[1]/div/div/div[1]/div/div/div[1]/div[2]/form/div[3]/div/div/input    ${passwd}
    ...    AND    sleep    1
    ...    AND    input text    xpath=//*[@id="app"]/div/div[3]/div[1]/div/div/div[1]/div/div/div[1]/div/div/div[1]/div[2]/form/div[4]/div/div/input    ${passwd}
    ...    AND    sleep    1
    ${class}=    Get Element Attribute    xpath=//*[@id="app"]/div/div[3]/div[1]/div/div/div[1]/div/div/div[1]/div/div/div[1]/div[2]/form/div[5]/div/div    class    #获取Required-Password-Change按钮的class元素的值
    #通过元素的值判断按钮是开启状态还是关闭状态
    run keyword if    "${Required-Password-Change}"=="open" and "${class}"=="el-switch is-checked"    Run Keywords    log    按钮为开启状态，不进行操作
    ...    AND    sleep    1
    ...    AND    input text    xpath=//*[@id="app"]/div/div[3]/div[1]/div/div/div[1]/div/div/div[1]/div/div/div[1]/div[2]/form/div[6]/div/div/input    ${day}
    ...    AND    sleep    1
    run keyword if    "${Required-Password-Change}"=="open" and "${class}"=="el-switch"    Run Keywords    log    按钮为关闭状态，需要点击开启
    ...    AND    sleep    1
    ...    AND    input text    xpath=//*[@id="app"]/div/div[3]/div[1]/div/div/div[1]/div/div/div[1]/div/div/div[1]/div[2]/form/div[6]/div/div/input    ${day}
    ...    AND    sleep    1
    run keyword if    "${Required-Password-Change}"=="close" and "${class}"=="el-switch is-checked"    Run Keywords    log    按钮为开启状态，需要点击关闭
    ...    AND    sleep    1
    ...    AND    click element    xpath=xpath=//*[@id="app"]/div/div[3]/div[1]/div/div/div[1]/div/div/div[1]/div/div/div[1]/div[2]/form/div[5]/div/div
    run keyword if    "${Required-Password-Change}"=="close" and "${class}"=="el-switch"    log    按钮为关闭状态，不进行操作
    sleep    1
    click element    xpath=//*[@id="app"]/div/div[3]/div[1]/div/div/div[1]/div/div/div[1]/div/div/div[2]/button[1] 

Logout
    #Mouse Hover    xpath=//*[@id="app"]/div/div[1]/div[2]/div/span/div/span
    #/html/body/div[1]/div/div[1]/div[2]/div/span[2]/div/span
    Mouse Over    xpath=//*[@id="app"]/div/div[2]/div[1]/div[4]/div[2]/div
    sleep    0.5
    click element    id=header-to-logout
    sleep    2
    Close All Browsers

UiLoginAndAddLocalIP
    log    UiLoginAndAddLocalIP
    Login
    # Run Keyword If    ${addTestClentIPFlag}==1    AddLocalIp
    log    UiLoginAndAddLocalIP:${LocahIPName}
    

UiLogoutAndDelLocalIP    
    log    UiLogoutAndDelLocalIP
    # Run Keyword If    ${addTestClentIPFlag}==1    DeletePage    ${LocahIPName}
    Logout