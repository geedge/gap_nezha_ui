# coding: utf-8

import os,sys
import time
from config import BASE_PATH,Config
from global_model.log import logger
from global_model.format_change import formatChange
from email_model.run_sendEmail import sendEailMock


def batch_Call(basePath, product_item, testCase_tag):
    '''
    首次执行测试：
    param robot_testSuite: robot testSuite路径；
    param product_item: 执行的待测产品项目；
    param testCase_tag: 执行的测试用例标签；
    param testCaseReportPath: 测试报告路径；
    '''
    try:
        logger.info(u'=======================首次测试执行开始！正在初始化数据库！=============================')
        pybot_result_list = []        
        output_dir = "-d " + basePath + "/Report/primo_report"          
        output_xml = "-o output.xml"
        output_log = "-l log.html"
        output_report = "-r report.html"
        productItem = "-s " + product_item
        caseTag = "-i " + testCase_tag
        pybot_cmd = "pybot " + output_dir + " " + output_xml + " " + output_log + " " + output_report + " " + productItem + " " + caseTag + " " + basePath
        pybot_result=os.system(pybot_cmd)  
        return pybot_result

    except Exception as e:
        logger.exception(u'首次执行测试失败. %s', e)

    finally:
        logger.info(u'测试项目根目录为：{0}'.format(basePath))
        logger.debug(u'首次执行测试报告输出目录：{0}'.format(output_dir))
        logger.info(u'首次执行测试的pybot命令：{0}'.format(pybot_cmd))
        logger.info(u'======================首次执行测试已完成！用例失败数为：{0} 个！========================'.format(pybot_result))  	


def mergeReport(basePath, report_title, match_report, copy_source_match, copy_target_match, merge_report_output):
    '''
    合并报告：
    param testCaseReportPath: 测试报告路径；
    param report_title: 合并报告的标题；
    return:
    '''
    try:
        logger.info(u'==========================合并测试报告开始！==================================')
        output_dir = "-d " + basePath + "/Report/{0}".format(merge_report_output)  # 输出合并报告目录
        output_xml = "-o output.xml"
        output_log = "-l log.html"
        output_report = "-r report.html"

        # 被合并的报告
        merge_report =  "--merge " + basePath + "/Report/{0}".format(match_report) + "/output.xml"
        title = "--ReportTitle " + report_title
        rebot_cmd = r"rebot " + output_dir + " " + output_xml + " " + output_log + " " + output_report + " " + title + " "  + merge_report
        mergeReport_result = os.system(rebot_cmd)  
        logger.debug(u'合并报告的结果为：{0}'.format(mergeReport_result))

        # 复制截图
        testCaseReportPath = basePath + "/Report"
        source_files = testCaseReportPath + "/{0}/*.png".format(copy_source_match)
        target_dir = testCaseReportPath + "/{0}".format(copy_target_match)
        cp_cmd = r"copy " + source_files + " " + target_dir 
        cp_cmd = cp_cmd.replace("/", "\\")
        cope_result = os.system(cp_cmd)
        logger.debug(u'复制截图的结果为：{0}'.format(cope_result))
        return mergeReport_result

    except Exception as e:
        logger.exception(u'合并报告异常. %s', e)

    finally:
        logger.debug(u'输出合并报告目录为：{0}'.format(output_dir))
        logger.info(u'合并报告rebot命令：{0}'.format(rebot_cmd))
        if mergeReport_result != 0:
            logger.info(u'======================合并报告中有失败用例！========================')
        else:
            logger.info(u'======================没有失败重试的报告需合并，或者合并报告中的用例已全通过！========================')
        logger.info(u'复制截图命令为：{0}'.format(cp_cmd))
        if cope_result == 0:
            logger.info(u'======================截图已成功复制到合并报告中！========================')
        else:
            logger.info(u'======================报告中没有需要复制的截图！========================')


def cleanLogs(basePath):
    '''
    删除硬盘中合并前的测试报告：
    param testCaseReportPath: 测试报告路径；
    return:
    '''
    try:
        logger.info(u'==========================清理磁盘报告开始！==================================')
        testCaseReportPath = basePath + "/Report"
        primo_report_files = testCaseReportPath + "/primo_report/*"
        retry_report_files = testCaseReportPath + "/retry_report/*"
        merge_files = testCaseReportPath + "/merge/*"
        zip_merges_files = testCaseReportPath + "/zip_merges/*"
        retry_times_files = testCaseReportPath + "/retry_times/*"
        del_cmd = "del " + primo_report_files + " " + retry_report_files + " " + merge_files + " " + zip_merges_files + " " + retry_times_files 
        del_cmd = del_cmd.replace("/", "\\")
        del_cmd = del_cmd + " " + "/s /q /f"
        clean_result = os.system(del_cmd)

    except Exception as e:
       logger.exception(u'清理磁盘报告异常. %s', e)

    finally:
        logger.info(u'清理磁盘报告命令为：{0}'.format(del_cmd))
        logger.debug(u'清理磁盘报告结果为：{0}'.format(clean_result))
        if clean_result == 0:
            logger.info(u'======================测试报告清理成功！========================')      
        else:
            logger.info(u'======================测试报告清理失败！========================')  


def run_test(basePath, product_item, testCase_tag, report_title, email_switch, smtp_server, server_username, server_pwd, msg_to, msg_subject, retry_switch, retry_time):
    '''
    失败自动重试：
    param robot_testSuite: robot testSuite路径；
    param testCase_tag: 执行的测试用例标签；
    param testCaseReportPath: 测试报告路径；
    param report_title: 合并报告的标题；
    '''
    #清理环境
    cleanLogs(basePath)

    #首次执行
    run_result = batch_Call(basePath, product_item, testCase_tag)
    
    #失败重试
    retryFunction = retry_switch
    if retryFunction == 1:
        try:
            if  run_result != 0:
                logger.info(u'======================失败用例重试第 1 次！========================')
                output_dir = "-d " + basePath + "/Report/retry_report"
                retry_xml = "-R " + basePath + "/Report/primo_report/output.xml"
                pybot_cmd = "pybot " + retry_xml + " " + output_dir + " " + basePath
                logger.info(u'第 1 次失败重试命令为：{0}'.format(pybot_cmd))
                retry_result=os.system(pybot_cmd)
                logger.info(u'======================失败用例重试第 1 次已完成！用例失败数为：{0} 个！========================'.format(retry_result))

                retryTimes = retry_time
                n = 2
                while (retryTimes >=2 and retry_result != 0):
                    logger.info(u'======================失败用例重试第 {0} 次！========================'.format(n))
                    output_dir = "-d " + basePath + "/Report/retry_times"
                    retry_xml = "-R " + basePath + "/Report/retry_report/output.xml"
                    pybot_cmd = "pybot " + retry_xml + " " + output_dir + " " + basePath
                    logger.info(u'第 {0} 次失败重试命令为：{1}'.format(n, pybot_cmd))
                    retry_result=os.system(pybot_cmd)
                    logger.info(u'======================失败用例重试第 {0} 次已完成！用例失败数为：{1} 个！========================'.format(n, retry_result))
                    
                    logger.info(u'======================正在合并重试报告！========================')
                    merge_report_output = 'retry_report'
                    match_report = 'retry_*'
                    copy_source_match = 'retry_times'
                    copy_target_match = 'retry_report'
                    mergeReport(basePath, report_title, match_report, copy_source_match, copy_target_match, merge_report_output)
                    logger.info(u'======================失败用例重试第 {0} 次合并报告已完成！========================'.format(n))
                    n = n + 1
                    retryTimes = retryTimes-1

        except Exception as e:
           logger.exception(u'失败重试异常. %s', e)

    else:
        logger.info(u'======================本次测试的失败重试功能已关闭！========================')

    #合并报告
    merge_report_output = 'merge'
    match_report = '*_report'
    copy_source_match = 'retry_report'
    copy_target_match = 'merge'
    report_result = mergeReport(basePath, report_title, match_report, copy_source_match, copy_target_match, merge_report_output)
    logger.debug(u'======================最终测试结果为： {0} ！========================'.format(report_result))
    if report_result == 0:
        ReportResult = u'测试通过！'
    else:
        ReportResult = u'测试不通过！失败用例数为：{0} 个'.format(report_result)

    #发送report到邮件
    emailFunction = email_switch
    if  emailFunction == 1:

        #将字符中的反斜杠转成正斜杠
        fileUrl_PATH = basePath.replace('\\','/')
        logger.debug(u'基础路径的反斜杠转成正斜杠为：{0}'.format(fileUrl_PATH))
         
        fileUrl='file:///{0}/Report/merge/report.html'.format(fileUrl_PATH)
        logger.info(u'html测试报告的url为：{0}'.format(fileUrl))
        save_fn=r'{0}\Report\zip_merges\report.png'.format(basePath)
        logger.debug(u'转成图片报告后保存的目标路径为：{0}'.format(save_fn))
        formatChange_obj = formatChange()
        formatChange_obj.html_to_image(fileUrl, save_fn)

        email_folder_dir = basePath + "/Report/merge"       #待压缩文件夹
        logger.debug(u'待压缩文件夹为：{0}'.format(email_folder_dir))
        email_target_dir = basePath + "/Report/zip_merges"  #压缩文件保存路径
        sendEailMock_obj = sendEailMock()
        sendEailMock_obj.send_email(email_folder_dir, email_target_dir, smtp_server, server_username, server_pwd, msg_to, msg_subject, ReportResult, save_fn) 
    else:
        logger.info(u'======================本次测试的邮件功能已关闭！========================')


if __name__ == '__main__':
 
    c = Config()
    ProductItem = c.get('ProductItem')
    testSuite = c.get('testSuite')
    testReportTitle = c.get('testReportTitle')

    emailSwitch = c.get('emailSwitch')
    smtp_server = c.get('smtp_server')
    server_username = c.get('server_username')
    server_pwd = c.get('server_pwd')  
    msg_to = c.get('msg_to')
    msg_subject = c.get('msg_subject')

    retrySwitch = c.get('retry_switch')
    retryTime = c.get('retryTime')

    run_test(BASE_PATH, ProductItem, testSuite, testReportTitle, emailSwitch, smtp_server, server_username, server_pwd, msg_to, msg_subject, retrySwitch, retryTime)