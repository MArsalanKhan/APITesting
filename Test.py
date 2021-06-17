import xmltodict
import collections
import uuid
import tkinter as tk
from tkinter import filedialog
from math import nan as NaN
import argparse
import argparse_parent_with_group
import requests
import datetime
import json
import logging
from requests.auth import HTTPBasicAuth
import urllib.parse
import urllib3
import copy
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)


# (IMPORTANT): Refer JIRA(API)Testing.py for the functional code about authenticating and creating testrun in JIRA.
# Opening XML file and reading data from the file
# output13.xml file contains '13' executed testcases
# output2.xml file contains '2' executed testcases

parser = argparse.ArgumentParser()
parser.add_argument('-f', required=True, help='ROBOT output.xml file')
parser.add_argument('-u', '--username', metavar='', required=True, help='Username of JIRA')
parser.add_argument('-p', '--password', metavar='', required=True, help='Password of JIRA')
parser.add_argument("--verbosity", help="increase output verbosity")
args = parser.parse_args()
logging.info('This is an info message')

with open(args.f) as file:
    file = open(args.f, errors='ignore')
    xml_data = file.read()

# 'o' contains the parsed XML data
o = xmltodict.parse(xml_data)

# print(xml_data)


with open('testrun.json') as file:
    json_data = file.read()

# Creating DATA DICTIONARIES For "JIRA" in JSON format

index_dict = {
          "index": "0",
          "status": "",
          "comment": ""
        }


step_dict = {
      "testCaseKey": "",
      "status": "",
      "comment": "",
      "scriptResults": [

        index_dict
     ]
}

report_dict = {
  "projectKey": "",
  "testPlanKey": "SMGW-P3",
  "name": "",
  "items": [

      step_dict

  ]
}


fSet = frozenset(step_dict)

# After parsing an XML file, assigning the attribute values to the JSON dictionary object

# Getting TestSuite name which will be the name of 'projectKey' in JIRA.
# 'A' contains the hierarchy of the parsed XML data

A = o['robot']["suite"]["suite"]["suite"]
report_dict["projectKey"] = A[r"@name"]

# print(A[r"@name"])

##############################################################################
# Getting the number of tests executed in a test suite

TestCases = o['robot']["suite"]["suite"]["suite"]["test"]

# To get the length of xml list and further use it in for loops to get the extracted data.
# my_list_len = len(A)

# Assigning the 'name' of the 'TestCycle' in JIRA.

report_dict["name"] = 'SMGW-LTE: {}'.format(datetime.datetime.now())

# Assigning the 'status' and converting this according to JIRA format.

def CorrectStatus(StatusOfTC):
    if StatusOfTC == 'PASS':
        status = 'Pass'
        return status
    else:
        status = 'Fail'
        return status


reports = []

for case in TestCases:

    # report_dict_tmp = copy.deepcopy(report_dict)

    # report_dict["name"] = case[r"@name"]

    # Getting TestCase Tag which will be the 'testCaseKey' in JIRA.

    step_dict["testCaseKey"] = case[r"tags"]["tag"]

    # Getting TestCase Status which will be the 'status' of TestCase(items) in JIRA.

    step_dict["status"] = CorrectStatus(case[r"status"][r"@status"])

    # Getting TestCase Status which will be the 'status' of TestCase(items) in JIRA.

    index_dict["status"] = CorrectStatus(case[r"status"][r"@status"])

    # Getting TestCase Message which will be the 'comment' of TestCase(items) in JIRA.

    step_dict["comment"]=case["kw"][2]["kw"]["kw"]["arguments"]["arg"]

    index_dict["comment"] = case["kw"][2]["kw"]["kw"]["arguments"]["arg"]

    step_dict['scriptResults'].append(copy.deepcopy(index_dict))

    # step_dict['scriptResults'].append(index_dict.copy())

    report_dict['items'].append(copy.deepcopy(step_dict))


JSONdata = json.dumps(report_dict)

# print(JSONdata)

# Converting into JSON (Last step)

# a = json.dumps(o) # '{"e": {"a": ["text", "text"]}}'
#
# print(a)

#######################################################################################################################
# Code for JIRA API Testing starts from here
#
jira_server = "https://jira-sg-dev.devolo.intern"

jira_password = args.password
jira_username = args.username

#######################

adaptavist_api_url = jira_server + "/rest/atm/1.0"

authentication = HTTPBasicAuth(jira_username, jira_password)

headers = {"Accept": "application/json", "Content-type": "application/json"}

# 'AUTHENTICATION' procedure performed for JIRA

response = requests.get(jira_server, auth=(jira_username, jira_password),verify=False)
print(response.status_code)
# print(response.json)

if response.status_code == 200:
    print('Success!, the authentication request was successful and the server responded with the expected data.')
elif response.status_code == 401:
    print('Not Found.')

# 'POSTING' TestRuns in JIRA

request_url = adaptavist_api_url + "/testrun"

test_cases_list_of_dicts = []
# for report_dict in reports:
JSONdata = json.dumps(report_dict)
response = requests.post(request_url,auth=authentication,headers=headers,data=JSONdata, verify=False)


# response = request.json()

print(response.status_code)
print(response.text)
# print(response.json)


class APIError(Exception):
    """An API Error Exception"""

    def __init__(self, status):
        self.status = status

    def __str__(self):
        return "APIError: status={}".format(self.status)


headerInfo = {'content-type': 'application/json'}

response = requests.post(jira_server, headers=headerInfo, data=JSONdata, verify=False)
if response.status_code != 200:
    raise APIError('POST /tasks/ {}'.format(response.status_code))

# print(response.text)
# print(response.status_code)





