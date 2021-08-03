*** Settings ***
Library           String
Library           json
Library           OperatingSystem
Library           RequestsLibrary
Library           Selenium2Library
Library           Collections
Library           FileLibrary
Resource          ../common.robot
Resource          ../../../variable/common_variable.txt

*** Keywords ***
insert_policyId_to_file
    [Arguments]    ${key}    ${policyId}    ${objectids}
    ${dict}    Create Dictionary    policyId=${policyId}    objectId=${objectids}
    ${json}    json.Dumps    ${dict}
    Alter Dict    ${path}/variable/AllFlowCaseVariable.txt    ${key}    ${json}

insert_time_to_file
    [Arguments]    ${key}    ${starttime}    ${endtime}
    ${value}    json.Loads    ${${key}}
    ${dict}    Create Dictionary    policyId=${value}[policyId]    objectId=${value}[objectId]    starttime=${starttime}    endtime=${endtime}
    ${json}    json.Dumps    ${dict}
    Alter Dict    ${path}/variable/AllFlowCaseVariable.txt    ${key}    ${json}

insert_policyId_to_file1
    [Arguments]    ${key}    ${objectids}
    Alter Dict    ${path}/all_flow_case_variable.txt    ${key}    ${objectids}

insert_time_to_file1
    [Arguments]    ${key}    ${starttime}
    Alter Dict    ${path}/AllFlowCaseVariable1.txt    ${key}    ${starttime}
    
insert_Report_to_file1
    [Arguments]    ${key}    ${objectids}
    Alter Dict    ${path}/ReportCaseVariable.txt    ${key}    ${objectids}
