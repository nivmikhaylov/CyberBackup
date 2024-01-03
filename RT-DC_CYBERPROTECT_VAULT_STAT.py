#!/usr/bin/python
 
import re
import requests
import json
import urllib3
import time
urllib3.disable_warnings()
 
comment = ''
GEOP = re.compile("(cstXX-bms|cstXX-bsn)")
GEOP = re.compile("(ctr-bms|ctr-bsn)")
CPusername = ''
CPpassword = ''
 
dateNow = time.strftime('%Y-%m-%d %H:%M:%S')
 
def getSessionCP(CPusername, CPpassword):
    user_agent_val = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/111.0.0.0 Safari/537.36'
    url = 'https://localhost:9877/idp/authorize/local'
    session = requests.Session()
 
    r = session.get(url, headers = {
        'User-Agent': user_agent_val},
        verify=False)
 
    req = r.url.split("?")[1]
    session.headers.update({'Referer':url})
    session.headers.update({'User-Agent':user_agent_val})
    _xsrf = session.cookies.get('_xsrf', domain="localhost")
    post_request = session.post(url, {
        'login': CPusername,
        'password': CPpassword,
        '_xsrf':_xsrf,
        'remember':'yes'},
        verify=False,
        params=req)
 
    if post_request.status_code == 200:
        return session
    else:
        return False
 
def getApiStatisticVaults(CPsession):
    vaults = CPsession.get('https://localhost:9877/api/vault_manager/v1/vaults',
                                headers = {'Content-Type': "text/html,application/xhtml+xml"},
                                verify=False)
    json_vaults = vaults.json()["items"]
    return json_vaults
 
def getApiStatisticAgents(CPsession):
    agents = CPsession.get('https://localhost:9877/api/agent_manager/v2/agents',
                                headers = {'Content-Type': "text/html,application/xhtml+xml"},
                                verify=False)
    json_agents = agents.json()["items"]
    return json_agents
 
def sumVaultsData(json_vaults):
    Total_Space = 0
    Free_space = 0
    for vault in json_vaults:
        if vault["name"] == "BMS_BACKUP" :
            continue
 
        Total_Space = Total_Space + vault["total_space"]
        Free_space = Free_space + vault["free_space"]
 
    Used_KB = (Total_Space - Free_space) / 1024
    jsonStatistic = {
                    "Used_KB" : Used_KB,
                    "Total_KB" : Total_Space / 1024,
                    "Free_KB" : Free_space / 1024
                    }
    return json.dumps(jsonStatistic, indent=4)
 
def sumAgentsData(json_agents):
    SumAgents = 0
    for agent in json_agents:
        if GEOP.search(agent["hostname"]) :
            continue
        SumAgents += 1
         
      
    jsonStatistic = {
                    "SumAgents" : SumAgents
                    }
    return json.dumps(jsonStatistic, indent=4)
 
sessionSP = getSessionCP(CPusername,CPpassword)
json_vaults = getApiStatisticVaults(sessionSP)
json_agents = getApiStatisticAgents(sessionSP)
print(sumAgentsData(json_agents))
print(sumVaultsData(json_vaults))