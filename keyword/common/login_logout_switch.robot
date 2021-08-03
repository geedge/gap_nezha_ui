*** Settings ***
Resource          ../../variable/common_variable.txt
Library           Collections
Resource          login_logout.robot
#Resource          logout.robot
#Resource          login.robot


*** Keywords ***    
LoginAndAddLocalIP
    [Tags]    tsg_adc    tsg_bf_api    tsg_device    tsg_adc_wp    adc_api    adc_verify    adc_log
    #[Tags]    分步骤之外的全流程    毕方接口    设备相关    分步骤全部    分步骤策略    分步骤功能端验证    分步骤日志验证
    # 获取主机IP
    #${ip}    Get Host IP
    #Run Keyword If    '${ip}' != '${EMPTY}'    Set Global Variable    ${testClentIP}    ${ip}    
    
    Run Keyword If    '${loginType}' == 'ui'        UiLoginAndAddLocalIP
 

LogoutAndDelLocalIP    
    [Tags]    tsg_adc    tsg_bf_api    tsg_device    tsg_adc_wp    adc_api    adc_verify    adc_log  
    Run Keyword If    '${loginType}' == 'ui'        UiLogoutAndDelLocalIP
