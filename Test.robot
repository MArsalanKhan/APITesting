*** Settings ***
Documentation     This test suite consists of all the SMGW-LTE testcases with its resource file.
Library           Process
Library           String
Library           DateTime
Library           Collections
Library           SSHLibrary
Library           ../Test3.py
Library           Selenium2Library
Library           OperatingSystem
Resource          Resources.robot    # The resources file for testing SMGW-LTE testcases

*** Test Cases ***
IPAddressAssignmentTest
    [Documentation]    *STEP ACTION*: The address assignment in SMGW-LTE is carried out according to the mechanisms of LTE mobile radio. The identification of the SMGW (Host) in the WAN Radius Server is done via the "IMSI" and the "APN". The PDN gateway takes only the IPv6 prefix from the Radius Access Accept response and generates a new interface ID from a random number. *EXPECTED RESULTS*: Radioman configuration with its generated log and verification of IP Address. *PRECONDITION*: The radioman should be correctly configured in SMGW.
    [Tags]    SMGW-T410
    ShowingRadiomanConfiguration
    ${message} =    Run Keyword And Return Status    RadiomanLogTest
    Run Keyword If    ${message}    TestMessageStatus

IPV6AddressAssignmentTest
    [Documentation]    *STEP ACTION*: This test explains the IPV6 address assignment in SMGW-LTE. Since IPV6 uses SLAAC protocol for configuration, we have to look for the IP assignment also. This test is done on Info-Report LTE (EON SIM 1 IPv6) SMGW because right now only EON supports IPV6 address. *EXPECTED RESULTS*: Radioman log and verification of IPV6 Address Assignment. *PRECONDITION*: The SIM has to support the IPV6 APN configuration.
    [Tags]    SMGW-T411
    ShowingRadiomanConfiguration
    ${message} =    Run Keyword And Return Status    RadiomanLogTest
    Run Keyword If    ${message}    TestMessageStatus

Fallbackto2G
    [Documentation]    *STEP ACTION*: In this testcase, we will check if the LTE connection is not established, then it should try to connect to 2G.
    ...    This testcase is linked with "Connection misfire,SMGW tries to connect automatically".
    ...    We have already set the rat mode to LTE,GSM. *EXPECTED RESULTS*: APN configuration of Deutsche Telekom SIM inserted in SMGW & radioman log. *PRECONDITIONS*: For this test, we need to have "only GSM supporting antenna" to test the connection. Since, this is not achievable, we can use the 'frequency filter(bandpass filter)' equipment which will filter out all the LTE band frequencies so that we are left behind with only GSM-900 band frequencies and hence, we can check that if SMGW tries to connect to GSM, if no LTE signals are available. Additionally, we also need a secure shielded box so that the antenna should not catch any other LTE band signal.
    ...
    ...    Bandpass filter datasheet can be found on the following link:
    ...    https://ww2.minicircuits.com/pdfs/ZX75BP-942-S+.pdf
    ...
    ...
    [Tags]    SMGW-T412
    ShowingRadiomanConfiguration
    ${message} =    Run Keyword And Return Status    LTE,GSM(Fallback)
    Run Keyword If    ${message}    TestMessageStatus

TestingPAP/CHAP Protocol
    [Documentation]    *STEP ACTION*: In this testcase, we can check which authentication protocol is currently configured in SMGW. We can see that Challenge Handshake Authentication Protocol is present by setting at+uauthreq=1,2,<username>,<password> according to "ublox AT commands manual". When <auth_type>=3 is set, +CGACT=1,<cid> may trigger at most 3 PDP context activation requests for <cid> to the protocol stack. The first request for <cid> is done with no authentication. If the PDP context activation fails, a second attempt is triggered with PAP authentication. If the second PDP context activation fails, a third attempt is triggered with CHAP authentication. The testing is done on SIM cards which are from Deutsche Telekom & A1.Digital. *EXPECTED RESULTS*: <auth chap MD5> and ppp daemon log. *PRECONDITION*: Make sure that the ppp daemon is running properly.
    [Tags]    SMGW-T413
    PPPLogTest
    ${message} =    Run Keyword And Return Status    AUTHLogTest
    Run Keyword If    ${message}    TestMessageStatus

TestingRadiomanStatus
    [Documentation]    *STEP ACTION*: In this testcase, we can observe the LTE protocol stack by first viewing radioman configurations and then checking radioman log. We have to see that AT commands are giving expected responses from "ublox AT commands manual". The LTE protocol stack layers include; Physical Layer, Medium Access Layer, Radio Link Control, Radio Resource Control, Packet Data Convergence Control and Non Access Stratum. \ *EXPECTED RESULTS*: APN details of Deutsche Telekom SIM configured in radioman, IP ADDRESS of SMGW and value of exit code in return.
    ...    *PRECONDITION*: After inserting a new SIM, its better to reboot the SMGW for the expected behaviour.
    [Tags]    SMGW-T414
    OnlyLTE(DeutscheTelekom)
    ${message} =    Run Keyword And Return Status    VerifyingLTE(IP)
    Run Keyword If    ${message}    TestMessageStatus

RATmodeTesting
    [Documentation]    *STEP ACTION*: In this testcase, we can verify the LTE IP address of SMGW from AT commands responses. It will also verify with ppp0 IPV4 address to check that if the connection is stable. The RAT mode can also be seen from the AT commands responses.
    ...    The testing is done on SIM cards which are from Deutsche Telekom & A1.Digital. *EXPECTED RESULTS*: URAT value, IP ADDRESS configuration of SMGW and value of exit code in return. *PRECONDITION*: After inserting a new SIM, its better to reboot the SMGW for the expected behaviour.
    [Tags]    SMGW-T415
    LTE,GSM(LogTest)
    ${message} =    Run Keyword And Return Status    VerifyingLTE(IP)
    Run Keyword If    ${message}    TestMessageStatus

TestingAPNconfiguration
    [Documentation]    *STEP ACTION*: This testcase is specifically for A1.digital network. It doesn't support IPV6.
    ...    *EXPECTED RESULTS*: APN configuration of A1 digital SIM inserted in SMGW & radioman log with the verification of IP address. *PRECONDITION*: After inserting a new SIM, its better to reboot the SMGW for the expected behaviour.
    ...    https://www.a1.digital/
    [Tags]    SMGW-T416
    LTE,GSM(A1.digital)
    ${message} =    Run Keyword And Return Status    VerifyingRadioman
    Run Keyword If    ${message}    TestMessageStatus

TestingRoamingNetwork
    [Documentation]    *STEP ACTION*: This testcase is specifically for *A1 Telekom Austria Group* network. It doesn't support IPV6 and its a roaming SIM.
    ...    The SIM connects to its network within the following countries:
    ...    *Austria, Bulgaria, Belarus, Croatia, Slovenia, Serbia, Macedonia, Liechtenstein.*
    ...    *EXPECTED RESULTS*: The response from LTE LED is "long-time OFF, short-time ON". It means that it is trying to connect to the roaming network. If we get the roaming signals, then it will be verified with the IP address and APN activation with their respective AT command responses. \ *PRECONDITIONS*: After inserting a new SIM, its recommended to reboot the SMGW for the expected behaviour. Since it is a roaming SIM, it will hardly catch the signals of the nearby base station matching with its configuration. https://www.a1.group/
    [Tags]    SMGW-T417
    RoamingTest
    ${message} =    Run Keyword And Return Status    VerifyingRadioman
    Run Keyword If    ${message}    TestMessageStatus

TestingATCommandsResponses
    [Documentation]    *STEP ACTION*: In this testcase, we are getting AT commands responses from the serial ports /dev/tty in SMGW. We are referring AT commands from ublox manual.
    ...    This all testing is done via scripts. The radioman is running in (0,1 and 2) devices.
    ...    In this AT script file, we are issuing commands for manufacturer identification, model number identification and firmware version identification of the modem so that we can easily identify ublox device.
    ...    Also the IMEI number helps us to get the equipment specification of SMGW-LTE.
    ...    "In this test, we are doing the following processes: 1) Sending AT command request to one of the dev/tty device present in SMGW. In other words we are executing a local script file on the remote server with the help of RunRemoteSSH script file. 2) The AT commands have the following requests such as Getting IMSI of the SIM card and Cell environment description giving details of MCC,MNC and TAC. 3) We can extract the particular information with the help of Regular expression such as IMSI.
    ...    *EXPECTED RESULTS*: Manufacturer name, Model number, Firmware version, IMSI, Cell environment description for GSM or LTE and IMEI value. \ *PRECONDITIONS*:
    ...    (1) Before sending AT commands and getting expected response, make sure to stop radioman by the following command: "stop radioman". We can start radioman by using "start radioman" command and wait for 30s. (2) While sending AT commands, make sure that the dev/tty device in which you are sending AT commands is present.
    [Tags]    SMGW-T418
    CheckingSMGW-LTEParameters
    ${message1} =    Run Keyword And Return Status    ATcommandstest
    Run Keyword If    ${message1}    TestMessageStatus

TestingSignalQuality
    [Documentation]    *STEP ACTION*: This testcase will check the signal quality of mobile network. According to ublox manual, AT+CSQ is the command for getting the signal quality.
    ...    This contains received link quality e.g. LQI for IEEE 802.15.4 (range 0...255), RSSI for GSM (range 0...7, refer to [3GPP 44.018] for more details on Network Measurement Report encoding), RSRP for LTE, (refer to [3GPP 36.214]), NRSRQ for NB-IoT (refer to [3GPP 36.214]). _Reference Signals Received Power (RSRP)_ and _Reference Signal Received Quality (RSRQ)_ are key measures of signal level and quality for modern LTE networks. In cellular networks, when a mobile device moves from cell to cell and performs cell selection/reselection and handover, it has to measure the signal strength/quality of the neighbor cells. In the procedure of handover, the LTE specification provides the flexibility of using RSRP, RSRQ, or both.
    ...    "RSRP – Reference Signal Received Power": is an RSSI type of measurement. It is the power of the LTE Reference Signals spread over the full bandwidth and narrowband. A minimum of -20 dB SINR (of the S-Synch channel) is needed to detect RSRP/RSRQ.
    ...    "RSRQ – Reference Signal Received Quality": Quality considering also RSSI and the number of used Resource Blocks (N) RSRQ = (N * RSRP) / RSSI measured over the same bandwidth. RSRQ is a C/I type of measurement and it indicates the quality of the received reference signal. The RSRQ measurement provides additional information when RSRP is not sufficient to make a reliable handover or cell reselection decision.
    ...    https://wiki.teltonika.lt/view/RSRP_and_RSRQ
    ...    *EXPECTED RESULT*: CSQ value, for example CSQ: 15,99.
    ...    *PRECONDITIONS*
    ...    Before sending AT commands and getting expected response, make sure to stop radioman by the following command: "stop radioman". We can start radioman by using "start radioman" command and wait for 30s.
    ...    _Refer 7.2.2 & 7.2.3 of ublox manual for the range of values of signal strength and its significance._
    [Tags]    SMGW-T419
    CheckingSMGW-LTEParameters
    ${message} =    Run Keyword And Return Status    GettingSignalQuality
    Run Keyword If    ${message}    TestMessageStatus

TestingIMSI
    [Documentation]    *STEP ACTION*: This testcase will check that if the required SIM is inserted in the SMGW by the identification of IMSI. This test is verified by both D-Telekom and A1.digital.
    ...    An IMSI is usually presented as a 15-digit number.
    ...    The first 3 digits represent the mobile country code (MCC), which is followed by the mobile network code (MNC), either 2-digit (European standard) or 3-digit (North American standard).
    ...    The length of the MNC depends on the value of the MCC, and it is recommended that the length is uniform within a MCC area. The remaining digits are the mobile subscription identification number (MSIN) within the network's customer base, usually 9 to 10 digits long, depending on the length of the MNC length.
    ...    https://en.wikipedia.org/wiki/International_mobile_subscriber_identity
    ...    For checking and verifying the SIM with IMSI, we can use this link:
    ...    https://www.numberingplans.com/?page=analysis&sub=imsinr
    ...    *EXPECTED RESULTS*: For example: If Deutsche Telekom SIM, IMSI = 262017740271986. If A1 digital SIM, IMSI = 232010850301936.
    ...    *PRECONDITIONS*:
    ...    1) Before sending AT commands and getting expected response, make sure to stop radioman by the following command: "stop radioman".
    ...    We can start radioman by using "start radioman" command and wait for 30s.
    ...    2) If the SIM is changed, make sure to reboot the SMGW and wait atleast 2 mins so that we can get the desired expected response from the device.
    ...    _Refer 4.11. of ublox manual._
    [Tags]    SMGW-T420
    CheckingSMGW-LTEParameters
    ${message} =    Run Keyword And Return Status    GettingIMSI
    Run Keyword If    ${message}    TestMessageStatus

TestingBehaviourOfLTE-LED
    [Documentation]    *STEP ACTION:* In this testcase, we have to check the behavior of LTE-LED in SMGW. Also, we can analyze if the GWA is able to visualize the results with the proper established connection between SMGW and GWA. Refer confluence page “WAN connection state LED”.
    ...    The necessary steps are that SMGW with SIM is configured within radioman and the antenna is supporting all band frequencies.
    ...    *EXPECTED RESULTS:* If LTE-LED is off → no mobile network available;
    ...    If LTE-LED flashes, Mobile network detected;
    ...    If LTE-LED lights up continuously, Connection established.
    ...    If its color is ‘green’: signal strength quality is very good which is nearly 14,99 or 15,99. (>= -84 dBm).
    ...    If its color is ‘orange’: signal strength quality is acceptable and lies within range of (-85dBm to -94dBm).
    ...    If its color is ‘red’: signal strength quality is bad. (<= -95 dBm).
    ...    The signal strength can also be determined with the help of “signal quality AT command”.
    ...    The resulted value for example CSQ: 15,99, means -81dBm. (Refer ublox manual Chap 7.2.4, Table:5 for the complete list of values). \ \ *PRECONDITIONS:*
    ...    1) Make sure that SMGW and radioman is properly configured. If radioman is stopped, try to start with ‘start radioman’ command and wait for 30s.
    ...    2) Sometimes it will take time to establish connection. If it’s taking long try to adjust antennas properly or check if the SIM is properly inserted in SMGW.
    ...    3) We can use radioman-vvv command to see the debug log radioman.
    ...    4) Before using the above command, make sure to kill radioman process.
    ...    5) If you stopped radioman and reboot, radioman will start automatically.
    [Tags]    SMGW-T421
    CheckingSMGW-LTEParameters
    ${message} =    Run Keyword And Return Status    GettingSignalQuality
    Run Keyword If    ${message}    TestMessageStatus

AutomaticReconnectionAfterNetworkFailure
    [Documentation]    *STEP ACTION:* In this testcase, we will test the automatic reconnection procedure for SMGW-LTE. First, we will disconnect antenna and after few seconds we can connect it again to see if it is reconnecting with the same network. Refer confluence page “LTE Reconnection Attempts”.
    ...    The necessary steps are that SMGW with SIM is configured within radioman and the antenna is supporting all band frequencies. If the SMGW-LTE parameters are not configured, it can be done easily with setprop command. The parameters are: \ lteReconnectInterval -> persist.wan.lte.reconn.intvl \ Value is 15s. \ lteReconnectMaxTries -> persist.wan.lte.reconn.max Value is 0. (Maximum number of reconnect tries between two pauses. If 0, then unlimited). \ lteReconnectPause -> persist.wan.lte.reconn.pause Value is 3600s. (Pause between two reconnect activities).
    ...    *EXPECTED RESULTS:*
    ...    After disconnecting the antenna and connecting it again, it will try to reconnect with the network by unlimited number of tries. We can verify the successful reconnection with the help of “APN configuration in radioman log”.
    ...    *PRECONDITIONS:*
    ...    1)Make sure that SMGW and radioman is properly configured. If radioman is stopped, try to start with ‘start radioman’ command and wait for 30s.
    ...    2)Sometimes it will take time to establish connection. If it’s taking long try to adjust antennas properly or check if the SIM is properly inserted in SMGW.
    ...
    ...    radioman-config v1.0.2
    [Tags]    SMGW-T422
    ShowingRadiomanConfiguration
    ${message} =    Run Keyword And Return Status    RadiomanLogTest
    Run Keyword If    ${message}    TestMessageStatus

TestingSIMwithPIN
    [Documentation]    *STEP ACTION:* In this testcase, we will test the SIM with its specified PIN value.
    ...    The necessary steps are that the SMGW with SIM details are properly configured within radioman. If the SMGW-LTE parameters are not configured, it can be done easily with setprop command. The parameter to set for SIM pin is:
    ...    persist.wan.lte.pin.
    ...    *EXPECTED RESULTS:*
    ...    The logcat output will show that the set pin output is positive means that it has accepted the PIN details and it will try to connect to its desired network. The AT command response will be +CPIN: READY in radioman log.
    ...    *PRECONDITIONS:*
    ...    1)Make sure that SMGW and radioman is properly configured. If radioman is stopped, try to start with ‘start radioman’ command and wait for 30s.
    ...    2)Sometimes it will take time to establish connection. If it’s taking long try to adjust antennas properly or check if the SIM is properly inserted in SMGW.
    ...    3)Check the PIN number mentioned in the SIM card details.
    ...    radioman-config v1.0.2
    ...    radioman v2.0.2
    [Tags]    SMGW-T1064
    CheckingSMGW-LTEParameters
    ${message} =    Run Keyword And Return Status    RadiomanLogTest
    Run Keyword If    ${message}    TestMessageStatus

*** Keywords ***
CheckingSMGW-LTEParameters
    [Documentation]    *STEP ACTION*: This keyword is used to check the android properties of SMGW-LTE. *EXPECTED RESULT*: Android properties of SMGW-LTE.
    ${result}    Run Process    /usr/bin/ssh    root@${IPAddress}    getprop | grep persist
    ${output}    Set Variable    ${result.stdout}
    Log    ${output}

ReadingRadiomanJsonFile
    [Documentation]    *STEP ACTION*: The usual configuration file takes place in /data/etc/radioman/radioman.json.In case this is missing there is also a default configuration file in /etc/radioman.json which would be then used. *EXPECTED RESULT*: Radioman APN configuration of SIM inserted in SMGW. {
    ...    \ \ "apn_connection_profile": [
    ...    \ \ \ \ \ {
    ...    \ \ \ \ \ \ \ \ "apn": "devolo.ic.m2mportal.de",
    ...    \ \ \ \ \ \ \ "authentication_type": 1,
    ...    \ \ \ \ \ \ "enable_status": true,
    ...    \ \ \ \ \ "pdn_type": 1,
    ...    \ \ \ \ "profile_name": "smgw-default",
    ...    \ \ \ "secret": "sim",
    ...    \ \ "user_name": "m2m"
    ...    }
    ...    ],
    ...    "bearer_selection": {
    ...    "preferred_communications_bearer": [
    ...    4,
    ...    2
    ...    ]
    ...    },
    ...    "pppd_options": {
    ...    "ipv4_options_path": "/etc/ppp/ipv4-options",
    ...    "ipv6_options_path": "/etc/ppp/ipv6-options"
    ...    },
    ...    "reconnection_properties": {
    ...    "reconnect_interval": 15,
    ...    "reconnect_max_tries": 0,
    ...    "reconnect_pause": 3600
    ...    },
    ...    "serial_port": {
    ...    "baud_rate": 115200,
    ...    "modem_tty_path": "/dev/ttyACM1",
    ...    "monitor_tty_path": "/dev/ttyACM2"
    ...    }
    ...    }
    ${result}    Run Process    /usr/bin/ssh    root@${IPAddress}    cat /data/etc/radioman.json
    ${output}    Set Variable    ${result.stdout}
    Log    ${output}

ShowingRadiomanConfiguration
    [Documentation]    *STEP ACTION*: This keyword is used to see the current radioman configuration configured in SMGW. *EXPECTED RESULT*: Radioman APN configuration of SIM inserted in SMGW. *PRECONDITION*: (1) SMGW is running and make sure that you have configured radioman & SIM properly.
    ${result}    Run Process    /usr/bin/ssh    root@${IPAddress}    radioman-config --show
    ${output}    Set Variable    ${result.stdout}
    Log    ${output}

ReadingSSHKeyInSMGW
    [Documentation]    This keyword can be used to view the SSH keys in SMGW.
    ${result}    Run Process    /usr/bin/ssh    root@${IPAddress}    cat /data/ssh/robotkey.pub
    ${output}    Set Variable    ${result.stdout}
    Log    ${output}

ExecuteTesterWithDependencies
    Run Process    java    -jar    /home/mkhan/Desktop/SMGW-Tester/smgw-tester-1.0-SNAPSHOT-jar-with-dependencies.jar    cwd=/home/mkhan/Desktop/SMGW-Tester

ExecuteTester
    Run Process    java    -jar    /home/mkhan/Desktop/SMGW-Tester/smgw-tester-1.0-SNAPSHOT.jar    cwd=/home/mkhan/Desktop/SMGW-Tester

KeywordInPython
    [Documentation]    Including test3.py python library in Robot framework and executing a function written in Python. With this, it is also possible to make testcases in python and run as a user keyword in Robot framework.
    arsalan

RadiomanLogTest
    [Documentation]    *STEP ACTION*: This will display only the radioman log of SMGW. *EXPECTED RESULT*: Radioman log from the logcat command. *PRECONDITIONS*: (1) SMGW is running and make sure that you have configured radioman & SIM properly. (2) RAT mode is selected as LTE,GSM.
    Set Test Message    Connection to SMGW opened
    ${result}    Run Process    /usr/bin/ssh    root@${IPAddress}    logcat -d | grep radioman
    ${output}    Set Variable    ${result.stdout}
    Log    ${output}
    Set Test Message    Connection to SMGW closed

IPV6AddressAssignment
    [Documentation]    *STEP ACTION*: In this keyword, the IPV6 testing is done on the EON SMGW and verifying that the IPV6 address is accurately configured. *EXPECTED RESULT*: Radioman log and verification of IPV6 Address Assignment. *PRECONDITIONS*: (1) SMGW is running and make sure that you have configured radioman & SIM properly. (2) RAT mode is selected as LTE,GSM. (3) The SIM has to support IPV6, in order to run this keyword in a test.
    Set Test Message    Connection to SMGW opened
    ${result1}    Run Process    /usr/bin/ssh    root@${IPV6Address}    logcat -d | grep radioman
    ${result2}    Run Process    /usr/bin/ssh    root@${IPV6Address}    ifconfig
    ${output1}    Set Variable    ${result1.stdout}
    ${output2}    Set Variable    ${result2.stdout}
    Log    ${output1}
    Log    ${output2}
    Set Test Message    Connection to SMGW closed

LTE,GSM(Fallback)
    [Documentation]    *STEP ACTION*: This will configure the Deutsche Telekom APN configuration in radioman-config tool and checking the log. If there are no LTE signals , it will try to connect to GSM. \ *EXPECTED RESULT*: APN configuration of the SIM inserted in SMGW & its radioman log. *PRECONDITIONS*: (1) SMGW is running and make sure that you have configured radioman & SIM properly. (2) RAT mode is selected as LTE,GSM.
    Set Test Message    Connection to SMGW opened
    ${result1}    Run Process    /usr/bin/ssh    root@${IPAddress}    radioman-config --apn &{A1.digitalSIM}[APN] --user &{A1.digitalSIM}[User] --password &{A1.digitalSIM}[Password] --rat LTE,GSM --show
    ${result2}    Run Process    /usr/bin/ssh    root@${IPAddress}    logcat -d | grep radioman
    ${output1}    Set Variable    ${result1.stdout}
    ${output2}    Set Variable    ${result2.stdout}
    Log    ${output1}
    Log    ${output2}
    Set Test Message    Connection to SMGW closed

LTE,GSM(A1.digital)
    [Documentation]    *STEP ACTION* : Firstly, we have to configure the radioman with A1 digital SIM configuration. Then we can see the AT commands responses from logcat command. \ *EXPECTED RESULT*: APN configuration of A1 digital SIM inserted in SMGW & radioman log with the verification of IP address. *PRECONDITIONS*: (1) SMGW is running and make sure that you have configured radioman & SIM properly. (2) RAT mode is selected as LTE,GSM.
    Set Test Message    Connection to SMGW opened
    ${result1}    Run Process    /usr/bin/ssh    root@${IPAddress}    radioman-config --apn &{A1.digitalSIM}[APN] --user &{A1.digitalSIM}[User] --password &{A1.digitalSIM}[Password] --show
    ${result2}    Run Process    /usr/bin/ssh    root@${IPAddress}    logcat -d | grep radioman
    ${result3}    Run Process    /usr/bin/ssh    root@${IPAddress}    ifconfig ppp0
    ${output1}    Set Variable    ${result1.stdout}
    ${output2}    Set Variable    ${result2.stdout}
    ${output3}    Set Variable    ${result3.stdout}
    Log    ${output1}
    Log    ${output2}
    Log    ${output3}
    Set Test Message    Connection to SMGW closed

OnlyLTE(DeutscheTelekom)
    [Documentation]    *STEP ACTION* : This will configure the Deutsche Telekom APN configuration in radioman-config tool and checking the log. *EXPECTED RESULT*: APN configuration of Deutsche Telekom SIM inserted in SMGW & radioman log. *PRECONDITIONS*: (1) SMGW is running and make sure that you have configured radioman & SIM properly. \ (2) RAT mode is selected as LTE.
    Set Test Message    Connection to SMGW opened
    ${result1}    Run Process    /usr/bin/ssh    root@${IPAddress}    radioman-config --apn &{DeutscheTelekomSIM}[APN] --user &{DeutscheTelekomSIM}[User] --password &{DeutscheTelekomSIM}[Password] --rat LTE --show
    ${result2}    Run Process    /usr/bin/ssh    root@${IPAddress}    logcat -d | grep radioman
    ${output1}    Set Variable    ${result1.stdout}
    ${output2}    Set Variable    ${result2.stdout}
    Log    ${output1}
    Log    ${output2}
    Set Test Message    Connection to SMGW closed

OnlyGSM
    Set Test Message    Connection to SMGW opened
    ${result1}    Run Process    /usr/bin/ssh    root@${IPAddress}    radioman-config --apn &{A1.digitalSIM}[APN] --user &{A1.digitalSIM}[User] --password &{A1.digitalSIM}[Password] --rat GSM --show
    ${result2}    Run Process    /usr/bin/ssh    root@${IPAddress}    logcat -d | grep radioman
    ${output1}    Set Variable    ${result1.stdout}
    ${output2}    Set Variable    ${result2.stdout}
    Log    ${output1}
    Log    ${output2}
    Set Test Message    Connection to SMGW closed

RoamingTest
    [Documentation]    *STEP ACTION* : Configuring APN & getting log of radioman. *EXPECTED RESULT*: APN configuration of roaming SIM inserted in SMGW & radioman log. *PRECONDITIONS*: (1) SMGW is running and make sure that you have configured radioman & SIM properly. \ (2) RAT mode is selected as LTE,GSM.
    Set Test Message    Connection to SMGW opened
    ${result1}    Run Process    /usr/bin/ssh    root@${IPAddress}    radioman-config --apn &{RoamingSIM}[APN] --user &{RoamingSIM}[User] --password &{RoamingSIM}[Password] --show
    ${result2}    Run Process    /usr/bin/ssh    root@${IPAddress}    logcat -d | grep radioman
    ${output1}    Set Variable    ${result1.stdout}
    ${output2}    Set Variable    ${result2.stdout}
    Log    ${output1}
    Log    ${output2}
    Set Test Message    Connection to SMGW closed

PPPLogTest
    [Documentation]    *STEP ACTION*: The pppd daemon running in SMGW is useful \ as it can be configured to run in all modes: as a client, as a server, over dial-up connections, and over dedicated connections. Here, in this case it is configured over dial-up connections for getting at-commands responses. *EXPECTED RESULT*: ppp daemon log. *PRECONDITION*: (1) SMGW is running and configured properly.
    Set Test Message    Connection to SMGW opened
    ${result}    Run Process    /usr/bin/ssh    root@${IPAddress}    logcat -d |grep ppp
    ${output}    Set Variable    ${result.stdout}
    Log    ${output}
    Set Test Message    Connection to SMGW closed

AUTHLogTest
    [Documentation]    *STEP ACTION*: In this keyword we will observe which authentication protocol is currently configured in SMGW. *EXPECTED RESULT*: <auth chap MD5>. *PRECONDITION*: (1) Make sure that the ppp daemon is running properly.
    Set Test Message    Connection to SMGW opened
    ${result}    Run Process    /usr/bin/ssh    root@${IPAddress}    logcat -d | grep pppd | grep auth
    ${string}    Set Variable    ${result.stdout}
    ${AUTHmethod}=    Get Regexp Matches    ${string}    <.*? .*? .*?>
    Log Many    ${AUTHmethod}
    Set Test Message    Connection to SMGW closed

LTE,GSM(LogTest)
    [Documentation]    *STEP ACTION*: In this keyword we will verify the RAT mode from the expected AT response according to ublox manual. *EXPECTED RESULT*: URAT value 5,3. *PRECONDITIONS*: (1) When inserting any new SIM, it is recommended to reboot the SMGW and wait for atleast 2 mins so that radioman configures the APN information properly and we get the expected response. (2) Make sure that the radioman is running properly.
    Set Test Message    Connection to SMGW opened
    ${result}    Run Process    /usr/bin/ssh    root@${IPAddress}    logcat -d | grep radioman | grep +URAT
    ${string}    Set Variable    ${result.stdout}
    ${RATvalue}=    Get Regexp Matches    ${string}    "URAT"
    Log    ${RATvalue}
    Set Test Message    Connection to SMGW closed

VerifyingLTE(IP)
    [Documentation]    *STEP ACTION*: In this keyword, we will check and verfiy the SMGW-LTE IP address with the radioman log's IP address. It will also display the exit code value in return. *EXPECTED RESULT*: IP ADDRESS configuration of SMGW and value of exit code. *PRECONDITIONS*: (1) When inserting any new SIM, it is recommended to reboot the SMGW and wait for atleast 2 mins so that radioman configures the APN information properly and we get the expected response. (2) Make sure that the radioman is running properly.
    Set Test Message    Connection to SMGW opened
    ${result1}    Run Process    /usr/bin/ssh    root@${IPAddress}    ifconfig
    ${result2}    Run Process    /usr/bin/ssh    root@${IPAddress}    echo $?
    ${IPConfiguration}    Set Variable    ${result1.stdout}
    ${ExitCode}    Set Variable    ${result2.stdout}
    Log    ${IPConfiguration}
    Log    ${ExitCode}
    Set Test Message    Connection to SMGW closed

VerifyingRadioman
    [Documentation]    "This will verify the configuration of radioman with the help of regular expressions. *STEP ACTION*: In this keyword, we are showing radioman configuration for verification purposes. *EXPECTED RESULT*: APN configuration for the SIM currently inserted in SMGW. *PRECONDITIONS*: (1) When inserting any new SIM, it is recommended to reboot the SMGW and wait for atleast 2 mins so that radioman configures the APN information properly and we get the expected response. (2) Make sure that the radioman is running properly." \
    Set Test Message    Connection to SMGW opened
    ${result1}    Run Process    /usr/bin/ssh    root@${IPAddress}    radioman-config --show
    ${APN}=    Get Regexp Matches    ${result1.stdout}    apn: (.*)    1
    ${User}=    Get Regexp Matches    ${result1.stdout}    user: (.*)    1
    ${PDN}=    Get Regexp Matches    ${result1.stdout}    pdn_type: (.*)    1
    ${Network Bearer}=    Get Regexp Matches    ${result1.stdout}    bearer: (.*)    1
    Set Test Message    Connection to SMGW closed

ATcommandstest
    [Documentation]    "This keyword is used for getting multiple responses from AT commands. *STEP ACTION*: In this keyword, we are sending AT commands to see the u-blox manufacturer & model identification. *EXPECTED RESULT*: Manufacturer name, Model number, Firmware version, IMSI and Cell environment description for GSM or LTE. *PRECONDITIONS*: (1) When inserting any new SIM, it is recommended to reboot the SMGW and wait for atleast 2 mins so that radioman configures the APN information properly and we get the expected response. (2) Make sure to temporarily stop radioman to see the actual output." \
    Set Test Message    Connection to SMGW opened
    ${result1}    Run Process    ${RunRemoteSSH}    root@${IPAddress}    ${AT_SCRIPT}    \    timeout=30s
    ${ATCommandResp}    Set Variable    ${result1.stdout}
    Log    ${ATCommandResp}
    ${result2}    Run Process    ${RunRemoteSSH}    root@${IPAddress}    ${GetIMEI}    \    timeout=30s
    ${IMEI}    Set Variable    ${result2.stdout}
    Log    ${IMEI}
    ${IMSI}=    Get Regexp Matches    ${ATCommandResp}    \\d{15}    0
    Log    ${IMSI}
    Set Test Message    Connection to SMGW closed

GettingIMEI
    [Documentation]    "This keyword is used for getting IMEI. *STEP ACTION*: In this keyword, we are sending AT command to observe the IMEI (International Mobile Equipment Identity) of the MT (device). *EXPECTED RESULT*: 15 digit IMEI of the device (equipment). It will return the product serial number. *PRECONDITIONS*: (1) When inserting any new SIM, it is recommended to reboot the SMGW and wait for atleast 2 mins so that radioman configures the APN information properly and we get the expected response. (2) Make sure to temporarily stop radioman to see the actual output." \
    Set Test Message    Connection to SMGW opened
    ${result1}    Run Process    ${RunRemoteSSH}    root@${IPAddress}    ${GetIMEI}    \    timeout=30s
    ${IMEI}    Set Variable    ${result1.stdout}
    Log    ${IMEI}
    Set Test Message    Connection to SMGW closed

GettingSignalQuality
    [Documentation]    "This keyword is used for getting signal quality." *STEP ACTION*: In this keyword, we are sending AT command to check the signal quality of mobile network. *EXPECTED RESULT*: CSQ value describing SignalQuality of LTE/GSM network. *PRECONDITIONS*: (1) When inserting any new SIM, it is recommended to reboot the SMGW and wait for atleast 2 mins so that radioman configures the APN information properly and we get the expected response. (2) Make sure to temporarily stop radioman to see the actual output."
    Set Test Message    Connection to SMGW opened
    ${result}    Run Process    ${RunRemoteSSH}    root@${IPAddress}    stop radioman
    ${result1}    Run Process    ${RunRemoteSSH}    root@${IPAddress}    ${GetSignalQuality}    \    timeout=30s
    ${SignalQuality}    Set Variable    ${result1.stdout}
    Log    ${SignalQuality}
    Set Test Message    Connection to SMGW closed

GettingIMSI
    [Documentation]    "This keyowrd is used for getting IMSI. *STEP ACTION*: In this keyword, regular expression pattern is used to identify the 15-digit IMSI from the AT script provided as a file. *EXPECTED RESULT*: 15 digit IMSI value. *PRECONDITIONS*: (1) When starting radioman, we have to check which SIM is inserted in SMGW and for that this IMSI will identify the mobile network. (2) When inserting any new SIM, it is recommended to reboot the SMGW and wait for atleast 2 mins so that radioman configures the APN information properly and we get the expected response (expected IMSI). (3) Make sure to temporarily stop radioman to see the actual output."
    Set Test Message    Connection to SMGW opened
    ${result1}    Run Process    ${RunRemoteSSH}    root@${IPAddress}    ${AT_SCRIPT}    \    timeout=30s
    ${output1}    Set Variable    ${result1.stdout}
    Log    ${output1}
    ${IMSI}=    Get Regexp Matches    ${output1}    \\d{15}    0
    Log    ${IMSI}
    Set Test Message    Connection to SMGW closed

TestMessageStatus
    Log    Expected Results achieved

EnteringPIN
    Set Test Message    Connection to SMGW opened
    ${result}    Run Process    ${RunRemoteSSH}    root@${IPAddress}    stop radioman
    ${result1}    Run Process    ${RunRemoteSSH}    root@${IPAddress}    ${EnterPIN}    \    timeout=30s
    ${Response}    Set Variable    ${result1.stdout}
    Log    ${Response}
    Set Test Message    Connection to SMGW closed
