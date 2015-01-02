#!/bin/bash

export MAVEN_OPTS="-Xmx2048m -XX:MaxPermSize=1024m -XX:+CMSClassUnloadingEnabled"
export JAVA_HOME="/usr/lib/jvm/jdk1.6.0_35" 					# Cesta k ulozenej jave
export MAVEN_HOME="$HOME/netbeans-8.0/java/maven" 				# Cesta k mavenu

PATH=$JAVA_HOME/bin:$MAVEN_HOME/bin:$PATH 					# Doplnenie PATH o horne dve cesty

SVN="/home/andreus/svn" 							# Domovsky adresar pre svn
BIN="/opt/IBM/WebSphere/AppServer/profiles/$PROFILE/bin/" 			# Cesta do aplikacneho serveru na virtualke
VIRTUAL_WAS="/opt/IBM/WebSphere/AppServer" 					# Cesta do home-u was servera
VIRTUAL_PORTAL="/opt/IBM/WebSphere/PortalServer" 				# Cesta do home-u portal servera
ISIS_DEVEL="$SVN/Isis.devel/trunk"						# SVN cesta pre ISIS
COMMON_DEVEL="$SVN/Common.devel/trunk"						# SVN cesta pre Common
EAR_REMOTE_DIR="/tmp/"								# Temporary cesta na upload EAR
DEPLOY_LOG="/home/andreus/deploy.log"						# Cesta pre ulozenie deploy Logu
BUILD_LOG="/home/andreus/build.log"						# Cesta pre ulozenie build Logu
ACTUAL_VERSION="1.20.0"								# Aktualna verzia
SCRIPT_REL_PATH="/root/scripts/"						# Adresar so skriptamy na deploy war
WPS_ADMIN_URL="http://$HOST_PORTAL:10039/wps/config"				# URL pre deploy WARka
PROFILE_BUILD="0"								# Nastavenie buildenia cez profil
SKIP_TESTS="1"									# Povolit skip testov pri buildeni
LOCAL_EJB_URL="mc-was8:9813:cell/nodes/mc-was8Node01/servers/ISIS01-01/"	# String na nahradenie pri porovnavanie EJB

#Nic dolezite
RED='\e[1;31m'
BLUE='\e[1;34m'
NC='\e[0m'

#-----------------------------------------------------------------------
#------------------------------Profiles---------------------------------
#-----------------------------------------------------------------------

NUMBER_OF_PROFILES="1"								# Pocet profilov ktore sa maju zahrnut
ACTUAL_PROFILE="DEFAULT"							# Defaultne zapnuty profil

#Prazdny profil do ktoreho si program nacita udaje.. NEMENIT HODNOTY!! (aj tak by to nic nespravilo)
#PROFILE_NUMBER_NAME="NameOfProfile"
HOST=""
HOST_PORTAL=""
HOST_USER=""
PROFILE=""
CELL=""
NODE=""
SERVER=""
USER=""
PASS=""
PORTAL_USER=""
PORTAL_PASS=""
CLUSTER=""
CELL_PORTAL=""
REMOTE_EJB_URL_PORTAL=""
REMOTE_EJB_URL_WAS=""

#Defaultny
PROFILE_1_NAME="DEFAULT"										# Meno profilu
HOSTDEFAULT="wasdevel.microcomp.sk"									# Host na was 
HOST_PORTALDEFAULT="portdevel.microcomp.sk"								# Host na port
HOST_USERDEFAULT="root"											# Uzivatel na was zelezo (ssh - nie was server)
PROFILEDEFAULT="Custom01"										# Nazov profilu na was
CELLDEFAULT="wasdevelCell01"										# Nazov Cell na was
NODEDEFAULT="wasdevelNode01"										# Nazov Node na was
SERVERDEFAULT="wasdevelServer01"									# Nazov Server na was
USERDEFAULT="was"											# User na was
PASSDEFAULT="was"											# Heslo na was
PORTAL_USERDEFAULT="was"										# User na portal
PORTAL_PASSDEFAULT="was"										# Heslo na portal
CLUSTERDEFAULT=""											# Ak je cluster tak nazov
CELL_PORTALDEFAULT="portdevel"										# Nazov Cell na portal
REMOTE_EJB_URL_PORTALDEFAULT="wasdevel:9813:cell/nodes/wasdevelNode01/servers/wasdevelServer01/"	# EJB String pre porovnanie na portal
REMOTE_EJB_URL_WASDEFAULT="wasdevel:9813:cell/nodes/wasdevelNode01/servers/wasdevelServer01/"		# EJB String pre porovnanie na was


BRANCH_BUILD="1"							# Povolit build z branchu/tagu/trunku

#Buildenie z Branchu
LAST_VERSION_NUMBER="3"							# Minoritna verzia
BRANCH_VERSION="1.17"							# Majoritna  verzia
ISIS_DEVEL_BRANCH="$SVN/Isis.devel/branches/$BRANCH_VERSION.x"		# Cesta k ISIS branch v SVN
COMMON_DEVEL_BRANCH="$SVN/Common.devel/branches/$BRANCH_VERSION.x"	# Cesta k Common branch v SVN
BRANCH_SFX=""								# neMetis branch suffix


#Buildenie z Tag
LAST_TAG_VERSION_NUMBER="1"							# Minoritna verzia
TAG_VERSION="1.14"								# Majoritna verzia
ISIS_DEVEL_TAG="$SVN/Isis.devel/tags/$TAG_VERSION.$LAST_TAG_VERSION_NUMBER"	# Cesta k ISIS branch v SVN
COMMON_DEVEL_TAG="$SVN/Common.devel/tags/$TAG_VERSION.$LAST_TAG_VERSION_NUMBER"	# Cesta k Common branch v SVN

setUpDeployParameters(){
#LOG APP
LGALE="LogApp$BRANCH_SFX/Ear/target/LogAppEar.ear"
LGAE="LogAppEar.ear"
LGA="LogAppEar"
LGAM1="LogApp Core Service"
LGAM1B="LogAppDaoImplProject-$SETUP_VERSION.jar"
LGAM2="LogApp Bussiness Service"
LGAM2B="LogAppBussinessImplProject-$SETUP_VERSION.jar"

#TASK APP
TAPLE="TaskApp$BRANCH_SFX/Ear/target/TaskApp.ear"
TAPE="TaskAppEar.ear"
TAP="TaskAppEar"
TAPM1="Task App Domain Service"
TAPM1B="TaskAppCoreDaoImpl-$SETUP_VERSION.jar"
TAPM2="Task App Bussiness Service"
TAPM2B="TaskAppBusinessServiceImpl-$SETUP_VERSION.jar"

#IAM
IAMLE="Iam$BRANCH_SFX/Ear/target/IamEar.ear"
IAME="IamEar.ear"
IAM="IamEar"
IAMM1="IamCoreDaoImplProject-$SETUP_VERSION.jar"
IAMM1B="IamCoreDaoImplProject-$SETUP_VERSION.jar"
IAMM2="IamBusinessServiceImplProject-$SETUP_VERSION.jar"
IAMM2B="IamBusinessServiceImplProject-$SETUP_VERSION.jar"

#METIS
METLE="Metis$BRANCH_SFX/Ear/target/MetisEar.ear"
METE="MetisEar.ear"
MET="MetisEar"
METM1="Metis Domain Service"
METM1B="MetisCoreDaoImplProject-$SETUP_VERSION.jar"
METM2="Metis Bussiness Service"
METM2B="MetisBusinessServiceImplProject-$SETUP_VERSION.jar"
METISWAR="MetisGuiProject-$SETUP_VERSION.war"

#ZBER
ZBELE="Zber$BRANCH_SFX/Ear/target/ZberEar.ear"
ZBEE="ZberEar.ear"
ZBE="ZberEar"
ZBEM1="Zber Domain Service"
ZBEM1B="ZberCoreDaoImplProject-$SETUP_VERSION.jar"
ZBEM2="Zber Business Service"
ZBEM2B="ZberBusinessServiceImplProject-$SETUP_VERSION.jar"

#ZBD
ZBDLE="ZBD$BRANCH_SFX/Ear/target/ZBDEar.ear"
ZBDE="ZBDEar.ear"
ZBD="ZBDEar"
ZBDM1="ZBD Domain Service"
ZBDM1B="ZBDCoreDaoImplProject-$SETUP_VERSION.jar"
ZBDM2="ZBDBusinessServiceImplProject-$SETUP_VERSION.jar"
ZBDM2B="ZBDBusinessServiceImplProject-$SETUP_VERSION.jar"

#SCRIPT LANG
SCLLE="ScriptLang$BRANCH_SFX/Ear/target/ScriptLangEar.ear"
SCLE="ScriptLangEar.ear"
SCL="ScriptLangEar"
SCLM1="ScriptLangBusinessServiceImplProject-$SETUP_VERSION.jar"
SCLM1B="ScriptLangBusinessServiceImplProject-$SETUP_VERSION.jar"

#DISEMINATION WS
DISLE="WebServices$BRANCH_SFX/DiseminationWebServices/DiseminationWebServicesEar/target/DisWsEar.ear"
DISE="DisWsEar.ear"
DIS="DiseminationWebServicesEar"
DISM1="DiseminationWebServicesImplProject-$SETUP_VERSION.war"
DISM1B="DiseminationWebServicesImplProject-$SETUP_VERSION.war"

#REGIS WS
RGSLE="WebServices$BRANCH_SFX/RegisWebServices/RegisWebServicesEar/target/RegWsEar.ear"
RGSE="RegWsEar.ear"
RGS="RegisWebServicesEar"
RGSM1="Regis Webservices"
RGSM1B="RegisWebServicesImplProject-$SETUP_VERSION.war"

#STATISTICAL WS
STSLE="WebServices$BRANCH_SFX/StatisticalWebServices/StatisticalWebServicesEar/target/StatWsEar.ear"
STSE="StatWsEar.ear"
STS="StatisticalWebServicesEar"
STSM1="Statistical Webservices"
STSM1B="StatisticalWebServicesImplProject-$SETUP_VERSION.war"

#IAM WS
IAWLE="WebServices$BRANCH_SFX/IamWebServices/Ear/target/IamWsEar.ear"
IAWE="IamWsEar.ear"
IAW="IamWebServicesEar"
IAWM2="Iam WebServices"
IAWM2B="IamWebServicesWebProject-$SETUP_VERSION.war"

#TASK WEBSERVICE
TMW="TaskManagementWebServicesEar"
TMWE="TmWsEar.ear"
TMWLE="WebServices$BRANCH_SFX/TaskManagementWebServices/TaskManagementWebServicesEar/target/TmWsEar.ear"
TMWR1="Task Management Web Services"
TMW1B="TaskManagementWebServicesImplProject-$SETUP_VERSION.war"

#KRAZ
KRAZ1="Kraz2$BRANCH_SFX/Ear/target/Kraz.ear"
KRAZ2="Kraz.ear"
KRAZ3="Kraz"
KRAZ4="KrazCoreDaoImpl-$SETUP_VERSION.jar"
KRAZ5="KrazCoreDaoImpl-$SETUP_VERSION.jar"
KRAZ6="KrazBusinessServiceImpl-$SETUP_VERSION.jar"
KRAZ7="KrazBusinessServiceImpl-$SETUP_VERSION.jar"
KRAZ8="Kraz Webservices"
KRAZ9="KrazWS-$SETUP_VERSION.war"
KRAZ10="Kraz Gui"
KRAZ11="KrazGui-$SETUP_VERSION.war"


#KRAZ_MOCK
KRAZ_MOCK_1="Kraz2$BRANCH_SFX/Ear-mock/target/Kraz.ear"
KRAZ_MOCK_2="Kraz.ear"
KRAZ_MOCK_3="Kraz"
KRAZ_MOCK_4="KrazBusinessServiceImpl-mock.jar"
KRAZ_MOCK_5="KrazBusinessServiceImpl-mock-$SETUP_VERSION.jar"
KRAZ_MOCK_6="Kraz Gui"
KRAZ_MOCK_7="KrazGui-$SETUP_VERSION.war"

#INTRASTAT
INTR1="Intrastat$BRANCH_SFX/Ear/target/Intrastat.ear"
INTR2="Intrastat.ear"
INTR3="Intrastat"
INTR4="IntrastatCoreDaoImpl-$SETUP_VERSION.jar"
INTR5="IntrastatCoreDaoImpl-$SETUP_VERSION.jar"
INTR6="IntrastatBusinessServiceImpl-$SETUP_VERSION.jar"
INTR7="IntrastatBusinessServiceImpl-$SETUP_VERSION.jar"
INTR8="Intrastat Gui"
INTR9="IntrastatGui-$SETUP_VERSION.war"

#INTRASTAT_MOCK
INTR_MOCK_1="Intrastat$BRANCH_SFX/Ear-mock/target/Intrastat.ear"
INTR_MOCK_2="Intrastat.ear"
INTR_MOCK_3="Intrastat"
INTR_MOCK_4="IntrastatBusinessServiceImpl-mock-$SETUP_VERSION.jar"
INTR_MOCK_5="IntrastatBusinessServiceImpl-mock-$SETUP_VERSION.jar"
INTR_MOCK_6="Intrastat Gui"
INTR_MOCK_7="IntrastatGui-$SETUP_VERSION.war"

#Regis
REGIS1="Regis2$BRANCH_SFX/Ear/target/Regis.ear"
REGIS2="Regis.ear"
REGIS3="Regis"
REGIS4="Regis Domain Service"
REGIS5="RegisCoreDaoImplProject-$SETUP_VERSION.jar"
REGIS6="Regis Bussiness Service"
REGIS7="RegisBusinessServiceImplProject-$SETUP_VERSION.jar"
REGIS8="Regis Webservices"
REGIS9="RegisWSProject-$SETUP_VERSION.war"
REGIS10="Regis Gui"
REGIS11="RegisGuiProject-$SETUP_VERSION.war"
}
#SELF UPDATE POINTER nemazat!!!!

#Dodatocne nekonfigurovatelne globalne premenne
ESC_SEQ="\E["
GREEN=$ESC_SEQ"32;01m"
YELLOW=$ESC_SEQ"33;01m"
MAGENTA=$ESC_SEQ"35;01m"
CYAN=$ESC_SEQ"36;01m"
WHITE=$ESC_SEQ"37;01m"
NE="\033[0m"
BOLD="\033[1m"
BLINK="\033[5m"
REVERSE="\033[7m"
UNDERLINE="\033[4m"
ACTUAL_SCRIPT_VERSION="3.3"

setProfileVariables(){
  eval tmp='HOST'$ACTUAL_PROFILE
  eval tmp2=\$${tmp}
  eval HOST=$tmp2
  
  eval tmp='HOST_PORTAL'$ACTUAL_PROFILE
  eval tmp2=\$${tmp}
  eval HOST_PORTAL=$tmp2
  
  eval tmp='HOST_USER'$ACTUAL_PROFILE
  eval tmp2=\$${tmp}
  eval HOST_USER=$tmp2
  
  eval tmp='PROFILE'$ACTUAL_PROFILE
  eval tmp2=\$${tmp}
  eval PROFILE=$tmp2
  
  eval tmp='CELL'$ACTUAL_PROFILE
  eval tmp2=\$${tmp}
  eval CELL=$tmp2
  
  eval tmp='NODE'$ACTUAL_PROFILE
  eval tmp2=\$${tmp}
  eval NODE=$tmp2
  
  eval tmp='SERVER'$ACTUAL_PROFILE
  eval tmp2=\$${tmp}
  eval SERVER=$tmp2
  
  eval tmp='USER'$ACTUAL_PROFILE
  eval tmp2=\$${tmp}
  eval USER=$tmp2
  
  eval tmp='PASS'$ACTUAL_PROFILE
  eval tmp2=\$${tmp}
  eval PASS=$tmp2
  
  eval tmp='PORTAL_USER'$ACTUAL_PROFILE
  eval tmp2=\$${tmp}
  eval PORTAL_USER=$tmp2
  
  eval tmp='PORTAL_PASS'$ACTUAL_PROFILE
  eval tmp2=\$${tmp}
  eval PORTAL_PASS=$tmp2
  
  
  eval tmp='CLUSTER'$ACTUAL_PROFILE
  eval tmp2=\$${tmp}
  eval CLUSTER=$tmp2
  
  eval tmp='CELL_PORTAL'$ACTUAL_PROFILE
  eval tmp2=\$${tmp}
  eval CELL_PORTAL=$tmp2
    
  eval tmp='REMOTE_EJB_URL_PORTAL'$ACTUAL_PROFILE
  eval tmp2=\$${tmp}
  eval REMOTE_EJB_URL_PORTAL=$tmp2
  
  eval tmp='REMOTE_EJB_URL_WAS'$ACTUAL_PROFILE
  eval tmp2=\$${tmp}
  eval REMOTE_EJB_URL_WAS=$tmp2
  
  eval BIN="/opt/IBM/WebSphere/AppServer/profiles/$PROFILE/bin/"
  eval WPS_ADMIN_URL="http://$HOST_PORTAL:10039/wps/config"
}

printout(){
  echo -e "$BLUE Aktualne hodnoty profilu: $NC"
  echo "HOST: $HOST"
  echo "HOST_PORTAL: $HOST_PORTAL"
  echo "HOST_USER: $HOST_USER"
  echo "PROFILE: $PROFILE"
  echo "CELL: $CELL"
  echo "NODE: $NODE"
  echo "SERVER: $SERVER"
  echo "USER: $USER"
  echo "PASS: $PASS"
  echo "PORTAL_USER: $PORTAL_USER"
  echo "PORTAL_PASS: $PORTAL_PASS"
  echo "CLUSTER: $CLUSTER"
  echo "CELL_PORTAL: $CELL_PORTAL"
  echo "REMOTE_EJB_URL_PORTAL: $REMOTE_EJB_URL_PORTAL"
  echo "REMOTE_EJB_URL_WAS: $REMOTE_EJB_URL_WAS"
}

chooseProfile(){
  cd $LOCAL_DIR
  printout
  echo ""
  echo ""
  for i in $(eval echo {1..$NUMBER_OF_PROFILES})
  do
   eval tmp='PROFILE_'$i'_NAME'
   eval tmp2=\$${tmp}
   echo "$i: $tmp2"
  done
  
  echo "Vyberte profil ktory chcete pouzivat: "
  read chosenProfile;
  eval tmp='PROFILE_'$chosenProfile'_NAME'
  eval tmp2=\$${tmp}
  if [ ! $chosenProfile = "" ]
  then
    sed -i '0,/ACTUAL_PROFILE=".*"/{s,ACTUAL_PROFILE=".*",ACTUAL_PROFILE="'${tmp2}'",}' $0
  fi
  cd $LOCAL_DIR
  bash $(basename $0)
  
  exit
}

chooseBuildPath(){
  cd $LOCAL_DIR
  clear
  echo "WasControl zacne pouzivat: "
  echo "1. Trunk"
  echo "2. Branch"
  echo "3. Tag"
  echo
  echo "default: $BRANCH_BUILD"
  echo
  echo -n "vasa hodnota (nechaj prazdne pre default): "
  read userInput
  if [ ! $userInput = "" ]
  then
    sed -i '0,/BRANCH_BUILD=".*"/{s,BRANCH_BUILD=".*",BRANCH_BUILD="'${userInput}'",}' $0
  fi
  
  clear
  case "$userInput" in
  2)
    echo "Nastavenie pozadovanej verzie aplikacii v branch (nie Metis)"
    echo "default: $BRANCH_VERSION"
    echo
    echo "VYNECHAJ POSLEDNU CISLICU VERZIE!!"
    echo -n "vasa hodnota (nechaj prazdne pre default): "
    read userActualVersion
    echo $userActualVersion
    if [ ! $userActualVersion = "" ]
    then
      sed -i '0,/BRANCH_VERSION=".*"/{s,BRANCH_VERSION=".*",BRANCH_VERSION="'$userActualVersion'",}' $0
    fi
    clear
    echo "Nastavenie minoritnej verzie CELEHO branchu"
    echo "default: $LAST_VERSION_NUMBER"
    echo
    echo -n "vasa hodnota (nechaj prazdne pre default): "
    read userActualLastVersionNumber
    echo $userActualLastVersionNumber
    if [ ! $userActualLastVersionNumber = "" ]
    then
      sed -i '0,/LAST_VERSION_NUMBER=".*"/{s,LAST_VERSION_NUMBER=".*",LAST_VERSION_NUMBER="'$userActualLastVersionNumber'",}' $0
    fi
     
    clear;
    echo "Verzie su nastavene na :" 
    echo "$(cat $(basename $0) | grep -x BRANCH_VERSION=".*")"
    echo "$(cat $(basename $0) | grep -x LAST_VERSION_NUMBER=".*")"
    echo
    echo -e "$BLUE Stlac enter pre pokracovanie $NC"
    read
    ;;
  1)
    sed -i '0,/BRANCH_SFX=".*"/{s,BRANCH_SFX=".*",BRANCH_SFX="''",}' $0
    ;;
  3)
    echo "Nastavenie pozadovanej verzie aplikacii v tag (nie Metis)"
    echo "default: $TAG_VERSION"
    echo
    echo "VYNECHAJ POSLEDNU CISLICU VERZIE!!"
    echo -n "vasa hodnota (nechaj prazdne pre default): "
    read userActualTagVersion
    echo $userActualTagVersion
    if [ ! $userActualTagVersion = "" ]
    then
      sed -i '0,/TAG_VERSION=".*"/{s,TAG_VERSION=".*",TAG_VERSION="'$userActualTagVersion'",}' $0
    fi
    clear
    echo "Nastavenie minoritnej verzie CELEHO tagu"
    echo "default: $LAST_TAG_VERSION_NUMBER"
    echo
    echo -n "vasa hodnota (nechaj prazdne pre default): "
    read userActualLastTagVersionNumber
    echo $userActualLastTagVersionNumber
    if [ ! $userActualLastTagVersionNumber = "" ]
    then
      sed -i '0,/LAST_TAG_VERSION_NUMBER=".*"/{s,LAST_TAG_VERSION_NUMBER=".*",LAST_TAG_VERSION_NUMBER="'$userActualLastTagVersionNumber'",}' $0
    fi
     
    clear;
    echo "Verzie su nastavene na :" 
    echo "$(cat $(basename $0) | grep -x TAG_VERSION=".*")"
    echo "$(cat $(basename $0) | grep -x LAST_TAG_VERSION_NUMBER=".*")"
    echo
    echo -e "$BLUE Stlac enter pre pokracovanie $NC"
    read
    ;;
  esac
  
  cd $LOCAL_DIR
  bash $(basename $0)
  
  exit
}

upload() {
 scp $1 $HOST_USER@$HOST:$2
}


touchMeGently(){
  find $1 -name '*.jsp' -exec touch '{}' \;
}

nyanCat(){
telnet miku.acm.uiuc.edu
}

checkForFiles(){
clear
  
  if [ -d $ISIS_DEVEL ]
  then
    echo -e  "$ISIS_DEVEL $BLUE uspesne najdene$NC"
  else
    echo -e "$ISIS_DEVEL ${RED}NENAJDENE$NC"
  fi
   if [ -d $COMMON_DEVEL ]
  then
    echo -e  "$COMMON_DEVEL $BLUE uspesne najdene$NC"
  else
    echo -e "$COMMON_DEVEL ${RED}NENAJDENE$NC"
  fi
  if [ -d $LOCAL_DIR ]
  then
    echo  -e "$LOCAL_DIR $BLUE uspesne najdene$NC"
  else
    echo -e "$LOCAL_DIR ${RED}NENAJDENE$NC"
  fi
  if [ "$( ping -q -c1 $HOST)" ]
  then 
    echo -e "$HOST $BLUE uspesne naviazany$NC"
  else
    echo -e "$HOST ${RED} NEUSPESNE NAVIAZANY$NC"
  fi
  echo
  echo -e "$BLUE Stlac enter pre pokracovanie $NC"
read tmp
}

setPaths(){
  cd $LOCAL_DIR
  clear
  echo "Nastavenie cesty 'BIN'"
  echo "default: $BIN"
  echo
  echo -n "vasa hodnota (nechaj prazdne pre default): "
  read userInput
  if [ ! $userInput = "" ]
  then
    sed -i '0,/BIN=".*"/{s,BIN=".*",BIN="'${userInput}'",}' $0
  fi
  clear
  echo "Nastavenie cesty 'SVN'"
  echo "default: $SVN"
  echo
  echo -n "vasa hodnota (nechaj prazdne pre default): "
  read userInputSVN
  echo $userInputSVN
  if [ ! $userInputSVN = "" ]
  then
    sed -i '0,/SVN=".*"/{s,SVN=".*",SVN="'${userInputSVN}'",}' $0
  fi
  clear
  echo "Nastavenie cesty 'build.log'"
  echo "default: $BUILD_LOG"
  echo
  echo -n "vasa hodnota (nechaj prazdne pre default): "
  read userInputBuildLog
  echo $userInputBuildLog
  if [ ! $userInputBuildLog = "" ]
  then
    sed -i '0,/BUILD_LOG=".*"/{s,BUILD_LOG=".*",BUILD_LOG="'$userInputBuildLog'",}' $0
  fi
  clear
  echo "Nastavenie cesty 'deploy.log'"
  echo "default: $DEPLOY_LOG"
  echo
  echo -n "vasa hodnota (nechaj prazdne pre default): "
  read userInputDeployLog
  echo $userInputDeployLog
  if [ ! $userInputDeployLog = "" ]
  then
    sed -i '0,/DEPLOY_LOG=".*"/{s,DEPLOY_LOG=".*",DEPLOY_LOG="'$userInputDeployLog'",}' $0
  fi
  
  clear;
  echo "Cesty su nastavene na :" 
  echo "$(cat $(basename $0) | grep -x BIN=".*")"
  echo "$(cat $(basename $0) | grep -x SVN=".*")"
  echo "$(cat $(basename $0) | grep -x BUILD_LOG=".*")"
  echo "$(cat $(basename $0) | grep -x DEPLOY_LOG=".*")"
  echo
  echo -e "$BLUE Stlac enter pre pokracovanie $NC"
  read
  cd $LOCAL_DIR
  bash $(basename $0)
  
  exit
}

setVersions(){
  cd $LOCAL_DIR
  clear
  echo "Nastavenie aktualnej verzie aplikacii (nie Metis)"
  echo "default: $ACTUAL_VERSION"
  echo
  echo -n "vasa hodnota (nechaj prazdne pre default): "
  read userActualVersion
  echo $userActualVersion
  if [ ! $userActualVersion = "" ]
  then
    sed -i '0,/ACTUAL_VERSION=".*"/{s,ACTUAL_VERSION=".*",ACTUAL_VERSION="'$userActualVersion'",}' $0
  fi
  clear;
  echo "Verzie su nastavene na :" 
  echo "$(cat $(basename $0) | grep -x ACTUAL_VERSION=".*")"
  echo
  echo -e "$BLUE Stlac enter pre pokracovanie $NC"
  read
  cd $LOCAL_DIR
  bash $(basename $0)
  
  exit
}


configureMenu(){
  echo "1. Otestuj default hodnoty 		2. Nastav cesty 	"
  echo "3. Premaz build.log			4. Premaz deploy.log	"
  echo "5. Nastav aktualne verzie		6. Nastav deploy skripty"
  echo "7. Automaticky update scriptu		8. Nastav build nastavenia"
  echo "9. Konfiguracia EJB"
  echo ""
  echo "w. What's new				a. About"
  echo "								0. back"
  echo "							       00. exit"
  echo -n "Vyber moznost: "
  read configureOption;

  case $configureOption in 
    1)  checkForFiles ;;
    2)  setPaths ;;
    3)  echo "" > $BUILD_LOG;;
    4)  echo "" > $DEPLOY_LOG;;
    5)  setVersions;;
    6) 	setDeployScript ;;
    7)  selfUpdate ;;
    8) setBuildOptions ;;
    9) ejbMenu ;;
    w) whatIsNew ;;
    a) about ;;
    0) clear; welcome ;;
    00) clear; exit ;;
    *) clear; echo "Chybne zadany vstup"; sleep 1; configureMenu ;;
  esac
}

genericDeploy(){  
  ssh $HOST_USER@$HOST "$BIN/wsadmin.sh -lang jython -user $USER -password $PASS -c \"AdminApp.update('$1', 'app', '[ -operation update -contents $2 -nopreCompileJSPs -installed.ear.destination \\\$(APP_INSTALL_ROOT)/$CELL -distributeApp -nouseMetaDataFromBinary -nodeployejb -createMBeansForResources -noreloadEnabled -nodeployws -validateinstall warn -noprocessEmbeddedConfig -filepermission .*\.dll=755#.*\.so=755#.*\.a=755#.*\.sl=755 -noallowDispatchRemoteInclude -noallowServiceRemoteInclude -asyncRequestDispatchType DISABLED -nouseAutoLink -noenableClientModule -clientMode isolated -novalidateSchema $3]' ) \"" 
}

genericPreDeploy(){

  echo "- UPLOADING ${1}"
  upload "$ISIS_DEVEL/${1}" "$EAR_REMOTE_DIR/${2}"

  local modulesToServersName=("${!4}")
  local modulesToServersValues=("${!5}")
  
  local finalMapForIBM="-MapModulesToServers [";
  local hostingMap="";
  for (( t=0; t<${#modulesToServersName[@]}; t++ ))
  do
    finalMapForIBM+="[ "    
    finalMapForIBM+="\\\"${modulesToServersName[$t]}\\\" ${modulesToServersValues[$t]}"
    if [[ "${modulesToServersValues[$t]}" == *war ]]; 
    then 
      finalMapForIBM+=",WEB-INF/web.xml " 
      hostingMap+="[\\\"${modulesToServersName[$t]}\\\" ${modulesToServersValues[$t]},WEB-INF/web.xml default_host ]"
    else 
      finalMapForIBM+=",META-INF/ejb-jar.xml " 
    fi
    
    if [ "$CLUSTER" == "" ]
    then
      finalMapForIBM+="WebSphere:cell=$CELL,node=$NODE,server=$SERVER ]"
    else
      finalMapForIBM+="WebSphere:cell=$CELL,cluster=$CLUSTER ]"
    fi
  done
  finalMapForIBM+="]"
  if [ "$hostingMap" != "" ]; 
  then 
    finalMapForIBM+=" -MapWebModToVH ["
    finalMapForIBM+="$hostingMap"
    finalMapForIBM+="]"
  fi
    
  genericDeploy $3 "$EAR_REMOTE_DIR/${2}" "$finalMapForIBM"
}

deployKraz(){
  echo -e "Deploy from $RED $SETUP_TYPE $NC"
  echo -e "Pouzivam Ear:$GREEN  $ISIS_DEVEL/$KRAZ1 $NC"
  
  local  modulesToServersName=("$KRAZ4" "$KRAZ6" "$KRAZ8" "$KRAZ10")
  local  modulesToServersValues=("$KRAZ5" "$KRAZ7"  "$KRAZ9" "$KRAZ11")
  genericPreDeploy "$KRAZ1" "$KRAZ2" "$KRAZ3" modulesToServersName[@] modulesToServersValues[@]
}

deployKrazMock(){
  echo -e "Deploy from $RED $SETUP_TYPE $NC"
  echo -e "Pouzivam Ear:$GREEN  $ISIS_DEVEL/$KRAZ_MOCK_1 $NC"
  
  local  modulesToServersName=("$KRAZ_MOCK_4" "$KRAZ_MOCK_6")
  local  modulesToServersValues=("$KRAZ_MOCK_5" "$KRAZ_MOCK_7")
  genericPreDeploy "$KRAZ_MOCK_1" "$KRAZ_MOCK_2" "$KRAZ_MOCK_3" modulesToServersName[@] modulesToServersValues[@]
}

deployIntrastat(){  
  echo -e "Deploy from $RED $SETUP_TYPE $NC"
  echo -e "Pouzivam Ear:$GREEN  $ISIS_DEVEL/$INTR1 $NC"
   
  local  modulesToServersName=("$INTR4" "$INTR6"  "$INTR8")
  local  modulesToServersValues=("$INTR5" "$INTR7"  "$INTR9")
   
  genericPreDeploy "$INTR1" "$INTR2" "$INTR3" modulesToServersName[@] modulesToServersValues[@]
}

deployIntrastatMock(){  
  echo -e "Deploy from $RED $SETUP_TYPE $NC"
  echo -e "Pouzivam Ear:$GREEN  $ISIS_DEVEL/$INTR_MOCK_1 $NC"
  
  local  modulesToServersName=("$INTR_MOCK_4" "$INTR_MOCK_6")
  local  modulesToServersValues=("$INTR_MOCK_5" "$INTR_MOCK_7")
  genericPreDeploy "$INTR_MOCK_1" "$INTR_MOCK_2" "$INTR_MOCK_3" modulesToServersName[@] modulesToServersValues[@]
}

deployRegis(){
  echo -e "Deploy from $RED $SETUP_TYPE $NC"
  echo -e "Pouzivam Ear:$GREEN  $ISIS_DEVEL/$REGIS1 $NC"
   
  local  modulesToServersName=("$REGIS4" "$REGIS6" "$REGIS8" "$REGIS10")
  local  modulesToServersValues=("$REGIS5" "$REGIS7" "$REGIS9" "$REGIS11")
  genericPreDeploy "$REGIS1" "$REGIS2" "$REGIS3" modulesToServersName[@] modulesToServersValues[@]
}

deployZber(){
  echo -e "Deploy from $RED $SETUP_TYPE $NC"
  echo -e "Pouzivam Ear:$GREEN  $ISIS_DEVEL/$ZBELE $NC"
   
  local  modulesToServersName=("$ZBEM1" "$ZBEM2")
  local  modulesToServersValues=("$ZBEM1B" "$ZBEM2B")
  genericPreDeploy "$ZBELE" "$ZBEE" "$ZBE" modulesToServersName[@] modulesToServersValues[@]
}

deployZbd(){
  echo -e "Deploy from $RED $SETUP_TYPE $NC"
  echo -e "Pouzivam Ear:$GREEN  $ISIS_DEVEL/$ZBDLE $NC"
      
  local  modulesToServersName=("$ZBDM1" "$ZBDM2")
  local  modulesToServersValues=("$ZBDM1B" "$ZBDM2B")
  genericPreDeploy "$ZBDLE" "$ZBDE" "$ZBD" modulesToServersName[@] modulesToServersValues[@]
}

deployMetis(){
  echo -e "Deploy from $RED $SETUP_TYPE $NC"
  echo -e "Pouzivam Ear:$GREEN  $ISIS_DEVEL/$METLE $NC"
         
  local  modulesToServersName=("$METM1" "$METM2")
  local  modulesToServersValues=("$METM1B" "$METM2B")
  genericPreDeploy "$METLE" "$METE" "$MET" modulesToServersName[@] modulesToServersValues[@]
}

deployIAM(){
  echo -e "Deploy from $RED $SETUP_TYPE $NC"
  echo -e "Pouzivam Ear:$GREEN  $ISIS_DEVEL/$IAMLE $NC"
         
  local  modulesToServersName=("$IAMM1" "$IAMM2")
  local  modulesToServersValues=("$IAMM1B" "$IAMM2B")
  genericPreDeploy "$IAMLE" "$IAME" "$IAM" modulesToServersName[@] modulesToServersValues[@]
}

deployWS(){
  echo -e "Deploy from $RED $SETUP_TYPE $NC"   
  echo -e "Pouzivam Ear:$GREEN  $ISIS_DEVEL/$DISLE $NC"
            
  local  modulesToServersName=("$DISM1")
  local  modulesToServersValues=("$DISM1B")
  genericPreDeploy "$DISLE" "$DISE" "$DIS" modulesToServersName[@] modulesToServersValues[@]
  
  echo -e "Pouzivam Ear:$GREEN  $ISIS_DEVEL/$RGSLE $NC"
  local  modulesToServersName=("$RGSM1")
  local  modulesToServersValues=("$RGSM1B")
  genericPreDeploy "$RGSLE" "$RGSE" "$RGS" modulesToServersName[@] modulesToServersValues[@]
  
  echo -e "Pouzivam Ear:$GREEN  $ISIS_DEVEL/$STSLE $NC"
  local  modulesToServersName=("$STSM1")
  local  modulesToServersValues=("$STSM1B")
  genericPreDeploy "$STSLE" "$STSE" "$STS" modulesToServersName[@] modulesToServersValues[@]
  
  echo -e "Pouzivam Ear:$GREEN  $ISIS_DEVEL/$IAWLE $NC"
  local  modulesToServersName=("$IAWM2")
  local  modulesToServersValues=("$IAWM2B")
  genericPreDeploy "$IAWLE" "$IAWE" "$IAW" modulesToServersName[@] modulesToServersValues[@]
  
  echo -e "Pouzivam Ear:$GREEN  $ISIS_DEVEL/$TMWLE $NC"
  local  modulesToServersName=("$TMWR1")
  local  modulesToServersValues=("$TMW1B")
  genericPreDeploy "$TMWLE" "$TMWE" "$TMW" modulesToServersName[@] modulesToServersValues[@]
}

deployLogapp(){
  echo -e "Deploy from $RED $SETUP_TYPE $NC"
  echo -e "Pouzivam Ear:$GREEN  $ISIS_DEVEL $LGALE $NC"
            
  local  modulesToServersName=("$LGAM1" "$LGAM2")
  local  modulesToServersValues=("$LGAM1B" "$LGAM2B")
  genericPreDeploy "$LGALE" "$LGAE" "$LGA" modulesToServersName[@] modulesToServersValues[@]
}

deployTaskapp(){
  echo -e "Deploy from $RED $SETUP_TYPE $NC"
  echo -e "Pouzivam Ear:$GREEN  $ISIS_DEVEL/$TAPLE $NC"
            
  local  modulesToServersName=("$TAPM1" "$TAPM2")
  local  modulesToServersValues=("$TAPM1B" "$TAPM2B")
  genericPreDeploy "$TAPLE" "$TAPE" "$TAP" modulesToServersName[@] modulesToServersValues[@]
}

deployScriptLang(){
  echo -e "Deploy from $RED $SETUP_TYPE $NC"
  echo -e "Pouzivam Ear:$GREEN  $ISIS_DEVEL/$SCLLE $NC"
            
  local  modulesToServersName=("$SCLM1")
  local  modulesToServersValues=("$SCLM1B")
  genericPreDeploy "$SCLLE" "$SCLE" "$SCL" modulesToServersName[@] modulesToServersValues[@]
}

postDeploy(){
  # ulozenie konfiguracie
  echo "- SAVE CONFIG"
  ssh $HOST_USER@$HOST "$BIN/wsadmin.sh -lang jython -user $USER -password $PASS -c \"AdminConfig.save()\""
  # vymaz ear z tempu
  echo "- REMOVING OLD FILES"
  ssh $HOST_USER@$HOST "rm -fvr $EAR_REMOTE_DIR/*.ear"
}

deployWAR(){

  echo "- UPLOADING"
  echo -e "Deploy from $RED $SETUP_TYPE $NC"
  echo -e "Pouzivam war:$GREEN $1 $NC"
  scp $1 $HOST_USER@$HOST_PORTAL:$VIRTUAL_PORTAL/installableApps/ 
  
  echo -e "<request xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:noNamespaceSchemaLocation=\"PortalConfig_1.4.xsd\" type=\"update\" create-oids=\"true\">
	  <portal action=\"locate\">
	    <web-app action=\"update\" active=\"true\" uid=\"$2.webmod\">
	      <url>file:///\$server_root\$/installableApps/$3</url>
	      <portlet-app action=\"update\" active=\"true\" uid=\"$2\"></portlet-app>
	    </web-app>	
	  </portal>
	</request>" > tmpUpdate.xmlaccess
	
  scp tmpUpdate.xmlaccess $HOST_USER@$HOST_PORTAL:$VIRTUAL_PORTAL/installableApps/ 
  
  
  echo "- DEPLOY START"  
  ssh $HOST_USER@$HOST_PORTAL "$VIRTUAL_PORTAL/bin/xmlaccess.sh" -in "$VIRTUAL_PORTAL/installableApps/tmpUpdate.xmlaccess" -user $PORTAL_USER -pwd $PORTAL_PASS -url $WPS_ADMIN_URL -out "$VIRTUAL_PORTAL/installableApps/deploymentresults.xmlaccess"

  echo "- DEPLOY FINISHED"
  rm tmpUpdate.xmlaccess
}

deployMetisWAR(){

  WAR_PATH="$ISIS_DEVEL/Metis$BRANCH_SFX/Gui/target/MetisGuiProject-$SETUP_VERSION.war"
  APP_NAME="MetisGuiProject-$SETUP_VERSION.war"
  APP_MODULE="MetisApp"
  
  deployWAR $WAR_PATH $APP_MODULE $APP_NAME
}

deployZberWar(){

  WAR_PATH="$ISIS_DEVEL/Zber$BRANCH_SFX/Gui/target/ZberGuiProject-$SETUP_VERSION.war"
  APP_NAME="ZberGuiProject-$SETUP_VERSION.war"
  APP_MODULE="ZberApp"
  
  deployWAR $WAR_PATH $APP_MODULE $APP_NAME
}
deployZbdWar(){

  WAR_PATH="$ISIS_DEVEL/ZBD$BRANCH_SFX/Gui/target/ZBDGuiProject-$SETUP_VERSION.war"
  APP_NAME="ZBDGuiProject-$SETUP_VERSION.war"
  APP_MODULE="ZBDApp"
  
  deployWAR $WAR_PATH $APP_MODULE $APP_NAME

}
deployIamWar(){

  WAR_PATH="$ISIS_DEVEL/Iam$BRANCH_SFX/Gui/target/IamGuiProject-$SETUP_VERSION.war"
  APP_NAME="IamGuiProject-$SETUP_VERSION.war"
  APP_MODULE="IamApp"
  
  deployWAR $WAR_PATH $APP_MODULE $APP_NAME

}
deployLogAppWar(){

  WAR_PATH="$ISIS_DEVEL/LogApp$BRANCH_SFX/Gui/target/LogAppGuiProject-$SETUP_VERSION.war"
  APP_NAME="LogAppGuiProject-$SETUP_VERSION.war"
  APP_MODULE="LogApp"
  
  deployWAR $WAR_PATH $APP_MODULE $APP_NAME
}
deployIsisWar(){

  WAR_PATH="$ISIS_DEVEL/IsisCommon$BRANCH_SFX/IsisMenu/target/IsisMenuProject-$SETUP_VERSION.war"
  APP_NAME="IsisMenuGuiProject-$SETUP_VERSION.war"
  APP_MODULE="IsisMenuApp"
  
  deployWAR $WAR_PATH $APP_MODULE $APP_NAME
}

showDeployLog(){
  cat $DEPLOY_LOG | less
}
  
partialDeploy() {
  case $1 in
    a* ) deployMetis; 		partialDeploy $(echo $1|tr -d 'a') ;;
    b* ) deployZber; 		partialDeploy $(echo $1|tr -d 'b') ;;
    c* ) deployIAM; 		partialDeploy $(echo $1|tr -d 'c') ;;    
    d* ) deployTaskapp; 	partialDeploy $(echo $1|tr -d 'd') ;;
    e* ) deployLogapp; 		partialDeploy $(echo $1|tr -d 'e') ;;
    f* ) deployScriptLang; 	partialDeploy $(echo $1|tr -d 'f') ;;
    g* ) deployWS; 		partialDeploy $(echo $1|tr -d 'g') ;;
    h* ) deployZbd; 		partialDeploy $(echo $1|tr -d 'h') ;;
    i* ) deployRegis; 		partialDeploy $(echo $1|tr -d 'i') ;;
    jj* ) deployKrazMock; 	partialDeploy $(echo $1|tr -d 'jj') ;;
    j* ) deployKraz; 		partialDeploy $(echo $1|tr -d 'j') ;;
    kk* ) deployIntrastatMock; 	partialDeploy $(echo $1|tr -d 'kk') ;;
    k* ) deployIntrastat; 	partialDeploy $(echo $1|tr -d 'k') ;;    
    
    u* ) deployMetisWAR; 		partialDeploy $(echo $1|tr -d 'u') ;;    
    v* ) deployZberWar; 	partialDeploy $(echo $1|tr -d 'v') ;;
    w* ) deployZbdWar; 		partialDeploy $(echo $1|tr -d 'w') ;;
    x* ) deployIamWar; 		partialDeploy $(echo $1|tr -d 'x') ;;
    y* ) deployLogAppWar; 	partialDeploy $(echo $1|tr -d 'y') ;;
    z* ) deployIsisWar; 	partialDeploy $(echo $1|tr -d 'z') ;;

    0) clear; welcome ;;
    00) clear; exit ;;
    "")  ;;
    *) clear; echo "Chybne zadany vstup"; sleep 1; chooseDeploy ;;
  esac
}

deploy() {

  if [ $1 = "ALL" ]
  then
    deployMetisWAR
    deployZberWar
    deployIsisWar
    deployIamWar
    deployZbdWar
    deployLogAppWar
    deployIAM
    deployLogapp
    deployTaskapp
    deployWS
    deployZber
    deployZbd
    deployMetis
    deployScriptLang    
    deployKraz
    deployRegis
    postDeploy
  else
    partialDeploy $1
    postDeploy
  fi
  
  echo -e "$BLUE Stlac enter pre pokracovanie $NC"
  read
}

chooseDeploy() {
  echo "a. METIS 		b. ZBER	"
  echo "c. IAM			d. TASKAPP	"
  echo "e. LOGAPP		f. ScriptLang"
  echo "g. WebServices 	 	h. ZBD "
  echo "i. Regis		j. Kraz - jj.Mock "
  echo "k. Intrastat - kk. Mock "
  echo ""
  echo "u. METIS GUI		v. ZBER GUI"
  echo "w. ZBD GUI		x. IAM GUI"
  echo "y. LogApp GUI		z. ISIS Menu"
  echo "								0. back"
  echo "							       00. exit"
  echo -n "Vyber moznost(i): "
  read deployOption;

  deploy $deployOption "1" | tee $DEPLOY_LOG;
}


showBuildLog(){
  cat $BUILD_LOG | less
}

setBuildOptions(){
  cd $LOCAL_DIR
  clear
  echo "Nastavenie BuildProfile"
  echo "default: $PROFILE_BUILD"
  echo
  echo -n "vasa hodnota (nechaj prazdne pre default): "
  read userProfileBuild
  echo $userProfileBuild
  if [ ! $userProfileBuild = "" ]
  then
    sed -i '0,/PROFILE_BUILD=".*"/{s,PROFILE_BUILD=".*",PROFILE_BUILD="'$userProfileBuild'",}' $0
  fi
  clear
  echo "Nastavenie preskocenia Testov"
  echo "default: $SKIP_TESTS"
  echo
  echo -n "vasa hodnota (nechaj prazdne pre default): "
  read userSkipTests
  echo $userSkipTests
  if [ ! $userSkipTests = "" ]
  then
    sed -i '0,/SKIP_TESTS=".*"/{s,SKIP_TESTS=".*",SKIP_TESTS="'$userSkipTests'",}' $0
  fi
  
  clear;
  echo "Verzie su nastavene na :" 
  echo "$(cat $(basename $0) | grep -x PROFILE_BUILD=".*")"
  echo "$(cat $(basename $0) | grep -x SKIP_TESTS=".*")"
  echo
  echo -e "$BLUE Stlac enter pre pokracovanie $NC"
  read
  cd $LOCAL_DIR
  bash $(basename $0)
  
  exit
}

pomBuild(){
  cd  $ISIS_DEVEL
  
  if [ "$PROFILE_BUILD" == "1" ]
  then
    PR_BUILD="-Pbuild"
  else
    PR_BUILD=""
  fi
  
  if [ "$SKIP_TESTS" == "1" ]
  then
    TST_BUILD="-DskipTests=true"
  else
    TST_BUILD=""
  fi
  mvn clean install $PR_BUILD $TST_BUILD | tee $BUILD_LOG
  cd $LOCAL_DIR
}

buildISISCommons(){
  cd $ISIS_DEVEL/IsisCommon$BRANCH_SFX
  touchMeGently './'
  mvn clean install $1 $2
}

buildMETIS(){
  cd $ISIS_DEVEL/Metis$BRANCH_SFX
  touchMeGently './'
  mvn clean install $1 $2
}

buildCommons(){
  cd $COMMON_DEVEL
  touchMeGently './'
  mvn clean install  $1 $2
}

buildIAM(){
  cd $ISIS_DEVEL/Iam$BRANCH_SFX
  touchMeGently './'
  mvn clean install  $1 $2
}

buildLogapp(){
  cd $ISIS_DEVEL/LogApp$BRANCH_SFX
  touchMeGently './'
  mvn clean install  $1 $2
}

buildTaskapp(){
  cd $ISIS_DEVEL/TaskApp$BRANCH_SFX
  touchMeGently './'
  mvn clean install $1 $2
}

buildPDB(){
  cd $ISIS_DEVEL/PBD$BRANCH_SFX
  touchMeGently './'
  mvn clean install $1 $2
}

buildZBD(){
  cd $ISIS_DEVEL/ZBD$BRANCH_SFX
  touchMeGently './'
  mvn clean install  $1 $2
}

buildScriptLang(){
  cd  $ISIS_DEVEL/ScriptLang$BRANCH_SFX
  touchMeGently './'
  mvn clean install $1 $2
}

buildWebServices(){  
  cd $ISIS_DEVEL/WebServices$BRANCH_SFX
  touchMeGently './'
  mvn clean install $1 $2
}

buildZber(){ 
  cd $ISIS_DEVEL/Zber$BRANCH_SFX
  touchMeGently './'
  mvn clean install $1 $2
}

buildKRAZ(){
  cd $ISIS_DEVEL/Kraz2$BRANCH_SFX
  touchMeGently './'
  mvn clean install $1 $2  
}

buildIntrastat(){
  cd $ISIS_DEVEL/Intrastat$BRANCH_SFX
  touchMeGently './'
  mvn clean install $1 $2
}

buildRegis(){
  cd $ISIS_DEVEL/Regis2$BRANCH_SFX
  touchMeGently './'
  mvn clean install $1 $2
}


cleanPartialBuildLog(){
  if [ -f partialBuildLog.log ]
  then
    ERROR_POINTER="$( cat partialBuildLog.log | grep 'ERROR' -m1 -n| cut -d':' -f1 )"
    FIRST_POINTER="$( cat partialBuildLog.log | grep 'Reactor Summary:' -m1 -n| cut -d':' -f1 )"
    LAST_POINTER="$( cat partialBuildLog.log | grep 'Final Memory:' -m1 -n| cut -d':' -f1 )"
    if [ "$ERROR_POINTER" != "" ]
    then
      sed "$FIRST_POINTER,$LAST_POINTER!d" partialBuildLog.log >> $BUILD_LOG
      echo "" >> $BUILD_LOG
      echo "-------------------------ERROR-------------------------" >> $BUILD_LOG
      echo "" >> $BUILD_LOG
      cat partialBuildLog.log |  grep 'ERROR' >> $BUILD_LOG
    else
      sed "$FIRST_POINTER,$LAST_POINTER!d" partialBuildLog.log >> $BUILD_LOG
    fi
    rm partialBuildLog.log
  fi
}

partialBuild(){  
  cleanPartialBuildLog
  
  case $1 in
    a* ) buildMETIS $PR_BUILD $TST_BUILD | tee partialBuildLog.log; 
	  partialBuild $(echo $1|tr -d 'a') ;;
    b* ) buildZber $PR_BUILD $TST_BUILD | tee partialBuildLog.log; 
	  partialBuild $(echo $1|tr -d 'b') ;;
    c* ) buildIAM  $PR_BUILD $TST_BUILD| tee partialBuildLog.log; 
	  partialBuild $(echo $1|tr -d 'c') ;;
    d* ) buildTaskapp $PR_BUILD $TST_BUILD | tee partialBuildLog.log; 
	  partialBuild $(echo $1|tr -d 'd') ;;
    e* ) buildLogapp $PR_BUILD $TST_BUILD | tee partialBuildLog.log; 
	  partialBuild $(echo $1|tr -d 'e') ;;
    f* ) buildScriptLang $PR_BUILD $TST_BUILD | tee partialBuildLog.log; 
	  partialBuild $(echo $1|tr -d 'f') ;;
    g* ) buildWebServices $PR_BUILD $TST_BUILD | tee partialBuildLog.log; 
	  partialBuild $(echo $1|tr -d 'g') ;;
    h* ) buildZBD $PR_BUILD $TST_BUILD | tee partialBuildLog.log; 
	  partialBuild $(echo $1|tr -d 'h') ;;
    i* ) buildRegis $PR_BUILD $TST_BUILD | tee partialBuildLog.log; 
	  partialBuild $(echo $1|tr -d 'i') ;;
    j* ) buildKRAZ $PR_BUILD $TST_BUILD | tee partialBuildLog.log; 
	  partialBuild $(echo $1|tr -d 'j') ;;
    k* ) buildIntrastat $PR_BUILD $TST_BUILD | tee partialBuildLog.log; 
	  partialBuild $(echo $1|tr -d 'k') ;;
    y* ) buildISISCommons $PR_BUILD $TST_BUILD | tee partialBuildLog.log; 
	  partialBuild $(echo $1|tr -d 'y') ;;
    z* ) buildCommons $PR_BUILD $TST_BUILD | tee partialBuildLog.logs; 
	  partialBuild $(echo $1|tr -d 'z') ;;
    0) clear; welcome ;;
    00) clear; exit ;;
    "")  ;;
    *) clear; echo "Chybne zadany vstup"; sleep 1; chooseBuild ;;
  esac
}

build(){
  if [ "$PROFILE_BUILD" == "1" ]
  then
    PR_BUILD="-Pbuild"
  else
    PR_BUILD=""
  fi
  
  if [ "$SKIP_TESTS" == "1" ]
  then
    TST_BUILD="-DskipTests=true"
  else
    TST_BUILD=""
  fi
  
  if [ $1 = "ALL" ]
  then
    buildIntrastat  $PR_BUILD $TST_BUILD | tee partialBuildLog.log; 
    cleanPartialBuildLog;
    buildCommons  $PR_BUILD $TST_BUILD | tee partialBuildLog.log; 
    cleanPartialBuildLog;
    buildISISCommons $PR_BUILD $TST_BUILD | tee partialBuildLog.log; 
    cleanPartialBuildLog;
    buildLogapp $PR_BUILD $TST_BUILD | tee partialBuildLog.log; 
    cleanPartialBuildLog;
    buildTaskapp $PR_BUILD $TST_BUILD | tee partialBuildLog.log; 
    cleanPartialBuildLog;
    buildIAM $PR_BUILD $TST_BUILD | tee partialBuildLog.log; 
    cleanPartialBuildLog;
    buildPDB $PR_BUILD $TST_BUILD | tee partialBuildLog.log; 
    cleanPartialBuildLog;
    buildMETIS $PR_BUILD $TST_BUILD | tee partialBuildLog.log; 
    cleanPartialBuildLog;
    buildZBD $PR_BUILD $TST_BUILD | tee partialBuildLog.log; 
    cleanPartialBuildLog;
    buildScriptLang $PR_BUILD $TST_BUILD | tee partialBuildLog.log; 
    cleanPartialBuildLog;
    buildZber $PR_BUILD $TST_BUILD | tee partialBuildLog.log; 
    cleanPartialBuildLog;
    buildWebServices $PR_BUILD $TST_BUILD | tee partialBuildLog.log; 
    cleanPartialBuildLog;
    buildKRAZ $PR_BUILD $TST_BUILD | tee partialBuildLog.log; 
    cleanPartialBuildLog;
    buildRegis $PR_BUILD $TST_BUILD | tee partialBuildLog.log; 
    cleanPartialBuildLog;
  else
    partialBuild $1 $PR_BUILD $TST_BUILD 
  fi
  
  cd $LOCAL_DIR
}

chooseBuild() {
  echo "a. Metis 	 	b. ZBER 	"
  echo "c. IAM 			d. TASKAPP	"
  echo "e. LogApp 		f. ScriptLang "
  echo "g. WebServices  	h. ZBD"
  echo "i. Regis 		j. KRAZ "
  echo "k. Intrastat		"
  
  echo "y. ISISCommon		z. COMMONS"
  echo "								0. back"
  echo "							       00. exit"
  echo -n "Vyber moznost(i): "
  read buildOption;

  build $buildOption ;
  if grep -q FAILURE "$BUILD_LOG" 
  then
       echo -e "$RED Build zlyhal!! $NC"
  fi
  echo -e "$BLUE Stlac enter pre pokracovanie $NC"
  read 
}
buildAndDeploy(){
  rm $BUILD_LOG

  echo "a. METIS 		b. ZBER	"
  echo "c. IAM			d. TASKAPP	"
  echo "e. LOGAPP		f. ScriptLang"
  echo "g. WebServices 	 	h. ZBD "
  echo "i. Regis		j. Kraz - jj.Mock "
  echo "k. Intrastat - kk. Mock "
  echo ""
  echo "u. METIS GUI		v. ZBER GUI"
  echo "w. ZBD GUI		x. IAM GUI"
  echo "y. LogApp GUI		z. ISIS Menu"
  echo "								0. back"
  echo "							       00. exit"
  echo -n "Vyber moznost(i): "
  read deployOption;
  
  buildOption=$(echo $deployOption | sed 's/u/a/g' | sed 's/v/b/g' | sed 's/w/h/g' | sed 's/x/c/g' | sed 's/y/e/g' | sed 's/z/y/g' );
  
  build $buildOption ;
  if grep -q FAILURE "$BUILD_LOG" 
  then
    echo -e "$RED Build zlyhal!! $NC"
    read 
  else
    echo -e "$GREEN Build prebehol v poriadku $NC"
    echo -e "$BLUE Pokracuje Deploy $NC"
  
  rm $DEPLOY_LOG
    deploy $deployOption | tee $DEPLOY_LOG;
  fi  
}
whatIsNew(){
clear  
  echo -e $UNDERLINE"Verzia:3.3 $NE"
  echo ""
  echo ""
  echo -e "$RED 07.10.2014: $NC"
  
  echo "----------------------------------------------------------------------------
  * Version 3.0
  * Kompletna zmena skriptu
  * Poriesene .jar a WS z IAM
  "
  echo ""  
  echo -e "$RED 28.10.2014: $NC"
  
  echo "----------------------------------------------------------------------------
  * Version 3.1
  * Zmena ciest k EJB suborom
  "
  
  echo ""  
  echo -e "$RED 01.12.2014: $NC"
  echo "----------------------------------------------------------------------------
  * Version 3.3
  * Poriesene .jar zmeny
  "
  read
}

checkIfNewVersionAvailable(){
  local targetVersionOfScript=$(wget -qO- http://andreus.valec.net/wasControlNews | cat | grep "Verzia" | cut -d ":" -f2 | sed 's/ //g')
  if [ "$targetVersionOfScript" == "$ACTUAL_SCRIPT_VERSION" ]
  then
    echo "0"
  else
    echo "1"
  fi
}

whatsInNewVersion(){
  wget -qO- http://andreus.valec.net/wasControlNews | cat 
  echo
  echo -e "$BLUE Stlac enter pre pokracovanie $NC"
  read
}

about(){
clear
echo "				(c) Andreus 2014"
echo "	 		      peter.andreus@gmail.com"
echo ""
echo "" 
echo "			             .888888:."
echo "			             88888.888."
echo "			            .8888888888"
echo "			            8' \`88' \`888"
echo "			            8 8 88 8 888"
echo "			            8:.,::,.:888"
echo "			           .8\`::::::'888"
echo "			           88  \`::'  888"
echo "			          .88        \`888."
echo "			        .88'   .::.  .:8888."
echo "			        888.'   :'    \`'88:88."
echo "			      .8888'    '        88:88."
echo "			     .8888'     .        88:888"
echo "			     \`88888     :        8:888'"
echo "			      \`.:.88    .       .::888'"
echo "			     .:::::88   \`      .:::::::."
echo "			    .::::::.8         .:::::::::"
echo "			    :::::::::..     .:::::::::'"
echo "			     \`:::::::::88888:::::::'"
echo "			        rs\`:::'       \`:'"
read
}

ejbMenu(){
  clear
  
  EJB_CONFIG_WAS_SVN="$ISIS_DEVEL/Deploy/ejbConfigWas.txt"
  EJB_CONFIG_PORTAL_SVN="$ISIS_DEVEL/Deploy/ejbConfigPortal.txt"
  
  echo "1. Skontrolovat EJB config WAS		"
  echo "2. Skontrolovat EJB config PORTAL	"
  echo "								0. back"
  echo "							       00. exit"
  echo -n "Vyber moznost: "
  read ejbMenuOption;
  case $ejbMenuOption in
    1 ) controlEJBCustomProperties "was"; ejbMenu  ;;
    2 ) controlEJBCustomProperties "portal"; ejbMenu  ;;
    3 ) createEjbCustomPropFile; ejbMenu  ;;
    4 ) createEjbCustomPropFilePortal; ejbMenu ;;
    0) clear; welcome ;;
    00) clear; exit ;;
    "")  ;;
    *) clear; echo "Chybne zadany vstup"; sleep 1; ejbMenu ;;
  esac
}

controlEJBCustomProperties(){
  if [ "$1" == "portal" ] 
  then
    local ejbResourceXmlStart=$(ssh $HOST_USER@$HOST_PORTAL "cat $VIRTUAL_WAS/../wp_profile/config/cells/$CELL_PORTAL/resources.xml | grep 'RemoteEJBLocatorReference' -n | cut -d ':' -f1")
    local tmpFile="$EJB_CONFIG_PORTAL_SVN"
    local resourceFileSize=$(ssh $HOST_USER@$HOST_PORTAL "cat $VIRTUAL_WAS/../wp_profile/config/cells/$CELL_PORTAL/resources.xml | wc -l")
    local ejbResourceXmlEnd=$(ssh $HOST_USER@$HOST_PORTAL "cat $VIRTUAL_WAS/../wp_profile/config/cells/$CELL_PORTAL/resources.xml | sed \"$ejbResourceXmlStart,$resourceFileSize!d\" | grep '</propertySet>' -n | cut -d ':' -f1 | head -n 1")
    let "ejbResourceXmlEnd=$(echo $ejbResourceXmlEnd) + $(echo $ejbResourceXmlStart)"
    local EJB_CONGIF_FULL_FROM_RESOURCE_XML=$(ssh $HOST_USER@$HOST_PORTAL "cat $VIRTUAL_WAS/../wp_profile/config/cells/$CELL_PORTAL/resources.xml | sed \"$ejbResourceXmlStart,$ejbResourceXmlEnd!d\" | sed 's/ //g'")
  else
    local ejbResourceXmlStart=$(ssh $HOST_USER@$HOST "cat $VIRTUAL_WAS/profiles/$PROFILE/config/cells/$CELL/resources.xml | grep 'RemoteEJBLocatorReference' -n | cut -d ':' -f1")
    local tmpFile="$EJB_CONFIG_WAS_SVN"
    local resourceFileSize=$(ssh $HOST_USER@$HOST "cat $VIRTUAL_WAS/profiles/$PROFILE/config/cells/$CELL/resources.xml | wc -l")
    local ejbResourceXmlEnd=$(ssh $HOST_USER@$HOST "cat $VIRTUAL_WAS/profiles/$PROFILE/config/cells/$CELL/resources.xml | sed \"$ejbResourceXmlStart,$resourceFileSize!d\" | grep '</propertySet>' -n | cut -d ':' -f1 | head -n 1")
    let "ejbResourceXmlEnd=$(echo $ejbResourceXmlEnd) + $(echo $ejbResourceXmlStart)"
    local EJB_CONGIF_FULL_FROM_RESOURCE_XML=$(ssh $HOST_USER@$HOST "cat $VIRTUAL_WAS/profiles/$PROFILE/config/cells/$CELL/resources.xml | sed \"$ejbResourceXmlStart,$ejbResourceXmlEnd!d\" | sed 's/ //g' ")
  fi
  
  local err_values=0;
  local ok_values=0;
  local addEJBCustomPropertyValues=();
  local removeEJBCustomPropertyValues=();
  local editEJBCustomPorpertyValues=();
  
  for i in $(echo "$EJB_CONGIF_FULL_FROM_RESOURCE_XML" | grep 'resourceProperties')
  do 
    local remoteValue=$( echo "$i"  | sed 's/value="/#/'| cut -d"#" -f2 | cut -d"\"" -f1)
    local remoteName=$(echo "$i"  | sed 's/name="/#/'| cut -d"#" -f2 | cut -d"\"" -f1)
    #local localName=$( cat $tmpFile | grep $remoteValue | cut -d"|" -f3)
    local localValue=$( cat $tmpFile | grep $remoteName | cut -d"|" -f4)
     
    if [ "$1" == "portal" ] 
    then
      local correctedLocalValue=$(echo "$localValue"| sed "s#$LOCAL_EJB_URL#$REMOTE_EJB_URL_PORTAL#g")
    else
      local correctedLocalValue=$(echo "$localValue"| sed "s#$LOCAL_EJB_URL#$REMOTE_EJB_URL_WAS#g")
    fi
     #echo "-$correctedRemoteValue-"
     if [[ "$remoteValue" == "$correctedLocalValue" ]]
     then
	#echo -e "$BLUE Hodnoty sa zhoduju $NC"
	let "ok_values=$ok_values + 1"
     else
	
	echo "Name: $remoteName"
	echo "Value Local: -$correctedLocalValue-"
	echo "Value Remote: -$remoteValue-"
	if [ "$localValue" == "" ]
	then
	    removeEJBCustomPropertyValues=("${removeEJBCustomPropertyValues[@]}" "$remoteName")
	    echo -e "$RED Hodnota je nepotrebna $NC"
	else
	    editEJBCustomPorpertyValues=("${editEJBCustomPorpertyValues[@]}" "$remoteName")
	    echo -e "$RED Hodnoty sa nezhoduju $NC"
	fi
	let "err_values=$err_values + 1"
     fi
  done
  
  for i in $(cat $tmpFile |sed 's/ //g')
  do 
    local localName=$( echo $i | cut -d"|" -f3)
    local localValue=$( echo $i | cut -d"|" -f4)
    local remoteValue=$( echo "$EJB_CONGIF_FULL_FROM_RESOURCE_XML" | grep "$localName"  | sed 's/value="/#/'| cut -d"#" -f2 | cut -d"\"" -f1)
    if [ "$1" == "portal" ] 
    then
      local correctedRemoteValue=$(echo "$remoteValue"| sed "s#$REMOTE_EJB_URL_PORTAL#$LOCAL_EJB_URL#g")
    else
      local correctedRemoteValue=$(echo "$remoteValue"| sed "s#$REMOTE_EJB_URL_WAS#$LOCAL_EJB_URL#g")
    fi
     #echo "-$correctedRemoteValue-"
     if [[ "$localValue" != "$correctedRemoteValue" ]]
     then
	if [ "$correctedRemoteValue" == "" ]
	then
	  echo "Name Local: $localName"
	  echo "Value Local: $localValue"
	  echo "Value Remote: $remoteValue"
	  addEJBCustomPropertyValues=("${addEJBCustomPropertyValues[@]}" "$localName")
	  echo -e "$RED Hodnota je nevyplnena $NC"
	  let "err_values=$err_values + 1"
	fi
     fi
  done
  echo
  echo
  echo "Statistics WAS EJB: "
  echo -e "EJB v poriadku:$BLUE $ok_values $NC"
  echo -e "Nekompatibilne EJB:$RED $err_values $NC"
  echo
  echo
  
  echo "1. Pridanie EJBconfigov 		2. Odstranenie EJBconfigov"
  echo "3. Uprava zmien v EJBconfigoch	"
  echo "								0. back"
  echo "							       00. exit"
  echo -n "Vyber moznost: "
  read ejbSubMenuOption
  case $ejbSubMenuOption in
    1 ) addEJBCustomProperty addEJBCustomPropertyValues[@] $1;  ;;
    2 ) removeEJBCustomProperty removeEJBCustomPropertyValues[@] $1 ;;
    3 ) updateEJBCustomProperty editEJBCustomPorpertyValues[@] $1; ;;   
    0) clear; ejbMenu ;;
    00) clear; exit ;;
    "")  ;;
    *) clear; echo "Chybne zadany vstup"; sleep 1; ejbMenu ;;
  esac
}

findJ2EEResourcePorpertyWAS(){
  let LINE_NUM=$(ssh $HOST_USER@$HOST "cat $VIRTUAL_WAS/profiles/$PROFILE/config/cells/$CELL/resources.xml | grep 'RemoteEJBLocatorReference' -n | cut -d ':' -f1")
  let "LINE_NUM_1=$(echo $LINE_NUM) +1"
  J2EE_ENV_ENTRY=$(ssh $HOST_USER@$HOST "cat $VIRTUAL_WAS/profiles/$PROFILE/config/cells/$CELL/resources.xml | sed -n "$(echo $LINE_NUM_1)p" | cut -d'\"' -f2 ")
}

findJ2EEResourcePorpertyPortal(){
  let LINE_NUM=$(ssh $HOST_USER@$HOST_PORTAL "cat $VIRTUAL_WAS/../wp_profile/config/cells/$CELL_PORTAL/resources.xml | grep 'RemoteEJBLocatorReference' -n | cut -d ':' -f1")
  let "LINE_NUM_1=$(echo $LINE_NUM) +1"
  J2EE_ENV_ENTRY=$(ssh $HOST_USER@$HOST_PORTAL "cat $VIRTUAL_WAS/../wp_profile/config/cells/$CELL_PORTAL/resources.xml | sed -n "$(echo $LINE_NUM_1)p" | cut -d'\"' -f2 ")
}

createEjbCustomPropFile(){
  vi $EJB_CONFIG_WAS_SVN
}

createEjbCustomPropFilePortal(){
  vi $EJB_CONFIG_PORTAL_SVN
}

addEJBCustomPropertyWAS(){
  findJ2EEResourcePorpertyWAS
  declare -a argAry1=("${!1}")
  local datum=$(date '+%d-%m-%Y')
  
  for property in "${argAry1[@]}"
  do
    echo
    local actualValue=$(cat $EJB_CONFIG_WAS_SVN |sed 's/ //g' | grep $property | cut -d"|" -f4 | sed "s#$LOCAL_EJB_URL#$REMOTE_EJB_URL_WAS#g")
    echo "Pridavam customProperty: $property s value: $actualValue"
    echo "Je to v poriadku?(y/N)"
    read adder
    if [[ $adder == [yY][eE][sS] ]]  || [[ $adder == [yY] ]]
    then
      ssh $HOST_USER@$HOST "$BIN/wsadmin.sh -lang jython -user $USER -password $PASS -c \"AdminConfig.create('J2EEResourceProperty', '(cells/$CELL|resources.xml#$J2EE_ENV_ENTRY)', '[[name \\\"$property\\\"] [type \\\"java.lang.String\\\"] [description \\\"Added $datum\\\"] [value \\\"$actualValue\\\"] [required \\\"false\\\"]]')\""
    fi
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
  done
  echo -e "$BLUE EJBconfigy boli pridane $NC"
  read
}

addEJBCustomPropertyPortal(){
  findJ2EEResourcePorpertyPortal
  declare -a argAry1=("${!1}")
  local datum=$(date '+%d-%m-%Y')
  echo "" > tmpJython.py
  
  for property in "${argAry1[@]}"
  do
    echo
    local actualValue=$(cat $EJB_CONFIG_PORTAL_SVN |sed 's/ //g' | grep $property | cut -d"|" -f4 | sed "s#$LOCAL_EJB_URL#$REMOTE_EJB_URL_PORTAL#g")
    echo "Pridavam customProperty: $property s value: $actualValue"
    echo "Je to v poriadku?(y/N)"
    read adder
    if [[ $adder == [yY][eE][sS] ]]  || [[ $adder == [yY] ]]
    then
      echo "AdminConfig.create('J2EEResourceProperty', '(cells/$CELL_PORTAL|resources.xml#$J2EE_ENV_ENTRY)', '[[name \"$property\"] [type \"java.lang.String\"] [description \"Added $datum\"] [value \"$actualValue\"] [required \"false\"]]')" >> tmpJython.py
    fi
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
  done
  echo "AdminConfig.save()" >> tmpJython.py
  scp tmpJython.py $HOST_USER@$HOST_PORTAL:./
  ssh $HOST_USER@$HOST_PORTAL "/opt/IBM/WebSphere/PortalServer/bin/wpscript.sh -lang jython -user $PORTAL_USER -password $PORTAL_PASS -f tmpJython.py "
  
  ssh $HOST_USER@$HOST_PORTAL "rm tmpJython.py"
  rm tmpJython.py
  echo -e "$BLUE EJBconfigy boli pridane $NC"
  read
}

updateEJBCustomPropertyWAS(){
  local EJB_CONGIF_FULL_FROM_RESOURCE_XML=$(ssh $HOST_USER@$HOST "cat $VIRTUAL_WAS/profiles/$PROFILE/config/cells/$CELL/resources.xml")
  local datum=$(date '+%d-%m-%Y')
  
  declare -a argAry1=("${!1}")
  for property in "${argAry1[@]}"
  do
    local remoteValue=$( echo "$EJB_CONGIF_FULL_FROM_RESOURCE_XML" | grep "$property"  | sed 's/value="/#/'| cut -d"#" -f2 | cut -d"\"" -f1)
    local remoteJ2EEResourceProperty=$( echo "$EJB_CONGIF_FULL_FROM_RESOURCE_XML" | grep "$property"  | sed 's/xmi:id="/#/'| cut -d"#" -f2 | cut -d"\"" -f1)
    echo
    local actualValue=$(cat $EJB_CONFIG_WAS_SVN |sed 's/ //g' | grep $property | cut -d"|" -f4 | sed "s#$LOCAL_EJB_URL#$REMOTE_EJB_URL_WAS#g")
    echo "Menim customProperty: $property"
    echo "Stara hodnota: -$remoteValue-"
    echo "Nova hodnota: -$actualValue-"
    echo "Je to v poriadku?(y/N)"
    read updater
    if [[ $updater == [yY][eE][sS] ]]  || [[ $updater == [yY] ]]
    then
      ssh $HOST_USER@$HOST "$BIN/wsadmin.sh -lang jython -user $USER -password $PASS -c \"AdminConfig.modify('(cells/$CELL|resources.xml#$remoteJ2EEResourceProperty)', '[[name \\\"$property\\\"] [type \\\"java.lang.String\\\"] [description \\\"Updated $datum\\\"] [value \\\"$actualValue\\\"] [required \\\"false\\\"]]')\""
    fi
  done
  echo -e "$BLUE EJBconfigy boli Upravene $NC"
  read
}

updateEJBCustomPropertyPortal(){
  local EJB_CONGIF_FULL_FROM_RESOURCE_XML=$(ssh $HOST_USER@$HOST_PORTAL "cat $VIRTUAL_WAS/../wp_profile/config/cells/$CELL_PORTAL/resources.xml")
  local datum=$(date '+%d-%m-%Y')
  declare -a argAry1=("${!1}")
  echo "" > tmpJython.py
  for property in "${argAry1[@]}"
  do
    local remoteValue=$( echo "$EJB_CONGIF_FULL_FROM_RESOURCE_XML" | grep "$property"  | sed 's/value="/#/'| cut -d"#" -f2 | cut -d"\"" -f1)
    local remoteJ2EEResourceProperty=$( echo "$EJB_CONGIF_FULL_FROM_RESOURCE_XML" | grep "$property"  | sed 's/xmi:id="/#/'| cut -d"#" -f2 | cut -d"\"" -f1)
    echo
    local actualValue=$(cat $EJB_CONFIG_PORTAL_SVN |sed 's/ //g' | grep $property | cut -d"|" -f4 | sed "s#$LOCAL_EJB_URL#$REMOTE_EJB_URL_PORTAL#g")
    echo "Menim customProperty: $property"
    echo "Stara hodnota: -$remoteValue-"
    echo "Nova hodnota: -$actualValue-"
    echo "Je to v poriadku?(y/N)"
    read updater
    if [[ $updater == [yY][eE][sS] ]]  || [[ $updater == [yY] ]]
    then
	echo "AdminConfig.modify('(cells/$CELL_PORTAL|resources.xml#$remoteJ2EEResourceProperty)', '[[name \"$property\"] [type \"java.lang.String\"] [description \"Updated $datum\"] [value \"$actualValue\"] [required \"false\"]]')" >> tmpJython.py
    fi
  done
  echo "AdminConfig.save()" >> tmpJython.py
  scp tmpJython.py $HOST_USER@$HOST_PORTAL:./
  ssh $HOST_USER@$HOST_PORTAL "/opt/IBM/WebSphere/PortalServer/bin/wpscript.sh -lang jython -user $PORTAL_USER -password $PORTAL_PASS -f tmpJython.py "
  
  ssh $HOST_USER@$HOST_PORTAL "rm tmpJython.py"
  rm tmpJython.py
  echo -e "$BLUE EJBconfigy boli upravene $NC"
  read
}

removeEJBCustomPropertyWAS(){
  local EJB_CONGIF_FULL_FROM_RESOURCE_XML=$(ssh $HOST_USER@$HOST "cat $VIRTUAL_WAS/profiles/$PROFILE/config/cells/$CELL/resources.xml")
  
  declare -a argAry1=("${!1}")
  for property in "${argAry1[@]}"
  do
    local remoteValue=$( echo "$EJB_CONGIF_FULL_FROM_RESOURCE_XML" | grep "$property"  | sed 's/value="/#/'| cut -d"#" -f2 | cut -d"\"" -f1)
    local remoteJ2EEResourceProperty=$( echo "$EJB_CONGIF_FULL_FROM_RESOURCE_XML" | grep "$property"  | sed 's/xmi:id="/#/'| cut -d"#" -f2 | cut -d"\"" -f1)
    echo
    echo "Mazem customProperty: $property"
    echo "Stara hodnota: -$remoteValue-"
    echo "Je to v poriadku?(y/N)"
    read deleter
    if [[ $deleter == [yY][eE][sS] ]]  || [[ $deleter == [yY] ]]
    then
      ssh $HOST_USER@$HOST "$BIN/wsadmin.sh -lang jython -user $USER -password $PASS -c \"AdminConfig.remove('(cells/$CELL|resources.xml#$remoteJ2EEResourceProperty)')\""
    fi
  done
  echo -e "$BLUE EJBconfigy boli Zmazane $NC"
  read
}

removeEJBCustomPropertyPortal(){
  local EJB_CONGIF_FULL_FROM_RESOURCE_XML=$(ssh $HOST_USER@$HOST_PORTAL "cat $VIRTUAL_WAS/../wp_profile/config/cells/$CELL_PORTAL/resources.xml")
  declare -a argAry1=("${!1}")
  echo "" > tmpJython.py
  for property in "${argAry1[@]}"
  do
    local remoteValue=$( echo "$EJB_CONGIF_FULL_FROM_RESOURCE_XML" | grep "$property"  | sed 's/value="/#/'| cut -d"#" -f2 | cut -d"\"" -f1)
    local remoteJ2EEResourceProperty=$( echo "$EJB_CONGIF_FULL_FROM_RESOURCE_XML" | grep "$property"  | sed 's/xmi:id="/#/'| cut -d"#" -f2 | cut -d"\"" -f1)
    echo
    echo "Mazem customProperty: $property"
    echo "Stara hodnota: -$remoteValue-"
    echo "Je to v poriadku?(y/N)"
    read deleter
    if [[ $deleter == [yY][eE][sS] ]]  || [[ $deleter == [yY] ]]
    then
	echo "AdminConfig.remove('(cells/$CELL_PORTAL|resources.xml#$remoteJ2EEResourceProperty)')" >> tmpJython.py
    fi
  done
  echo "AdminConfig.save()" >> tmpJython.py
  scp tmpJython.py $HOST_USER@$HOST_PORTAL:./
  ssh $HOST_USER@$HOST_PORTAL "/opt/IBM/WebSphere/PortalServer/bin/wpscript.sh -lang jython -user $PORTAL_USER -password $PORTAL_PASS -f tmpJython.py "
  
  ssh $HOST_USER@$HOST_PORTAL "rm tmpJython.py"
  rm tmpJython.py
  echo -e "$BLUE EJBconfigy boli zmazane $NC"
  read
}

addEJBCustomProperty(){
  clear
  if [ "$2" == "portal" ] 
  then
    addEJBCustomPropertyPortal $1
  else
    addEJBCustomPropertyWAS $1
  fi
  
}

updateEJBCustomProperty(){
  clear
  if [ "$2" == "portal" ] 
  then
    updateEJBCustomPropertyPortal $1
  else
    updateEJBCustomPropertyWAS $1
  fi
}

removeEJBCustomProperty(){
  clear
  if [ "$2" == "portal" ] 
  then
    removeEJBCustomPropertyPortal $1
  else
    removeEJBCustomPropertyWAS $1
  fi
}
restartMachine(){
  ssh $HOST_USER@$1 "/root/bin/was-control.sh restart" 
}
startMachine(){
  ssh $HOST_USER@$1 "/root/bin/was-control.sh start"
}
stopMachine(){
  ssh $HOST_USER@$1 "/root/bin/was-control.sh stop"
}
machineControl(){
  case $1 in
    *1* ) startMachine $HOST; machineControl $(echo $1|tr -d '1') ;;
    *2* ) startMachine $HOST_PORTAL; machineControl $(echo $1|tr -d '2') ;;
    *3* ) stopMachine $HOST; machineControl $(echo $1|tr -d '3') ;;
    *4* ) stopMachine $HOST_PORTAL; machineControl $(echo $1|tr -d '4') ;;
    *5* ) restartMachine $HOST; machineControl $(echo $1|tr -d '5') ;;
    *6* ) restartMachine $HOST_PORTAL; machineControl $(echo $1|tr -d '6') ;;
    *7* ) startMachine $HOST;
	  startMachine $HOST_PORTAL; machineControl $(echo $1|tr -d '7') ;;
    *8* ) stopMachine $HOST;
	  stopMachine $HOST_PORTAL; machineControl $(echo $1|tr -d '8') ;;
    *9* ) restartMachine $HOST;
	  restartMachine $HOST_PORTAL; machineControl $(echo $1|tr -d '9') ;;
    0) clear; welcome ;;
    00) clear; exit ;;
    "")  ;;
    *) clear; echo "Chybne zadany vstup"; sleep 1; chooseControl ;;
  esac
}


chooseControl() {
  echo "1. Start Devel server(was) 		2. Start Portal server	"
  echo "3. Vypnut Devel server			4. Vypnut Portal server	"
  echo "5. Restart Devel server			6. Restart Portal server"
  echo ""
  echo "7. Start oboch serverov			8. Vypnut oba servery"
  echo "9. Restart oboch serverov"
  echo "								0. back"
  echo "							       00. exit"
  echo -n "Vyber moznost(i): "
  read controlOption;

  machineControl $controlOption 
  
  echo
  echo -e "$BLUE Stlac enter pre pokracovanie $NC"
  read
}
svnUpdate(){
  
  cd $COMMON_DEVEL 
  svn update
  
  cd $ISIS_DEVEL
  svn update
  
  cd $LOCAL_DIR
  echo
  echo -e "$BLUE Stlac enter pre pokracovanie $NC"
  read
}
svnBranchUpdate(){
  cd $COMMON_DEVEL_BRANCH 
  svn update
  
  cd $ISIS_DEVEL_BRANCH
  svn update
  
  cd $LOCAL_DIR
  echo
  echo -e "$BLUE Stlac enter pre pokracovanie $NC"
  read
}
selfUpdate(){
  cd $LOCAL_DIR
  wget -c http://andreus.valec.net/wasControlUpdate.sh

  SCRIPT_NAME=$(basename $0)
  POINTER="$( cat $SCRIPT_NAME | grep 'SELF UPDATE POINTER' -m1 -n| cut -d':' -f1 )"
  POINTER_NEW="$( cat wasControlUpdate.sh | grep 'SELF UPDATE POINTER' -m1 -n| cut -d':' -f1 )"
  SCRIPT_SIZE_NEW="$( cat wasControlUpdate.sh | wc -l)"
  let "POINTERPLUS_NEW= $POINTER_NEW + 1"

  sed "1,$POINTER!d" $SCRIPT_NAME > HEAD.TILE
  sed "$POINTERPLUS_NEW,$SCRIPT_SIZE_NEW!d" wasControlUpdate.sh > TAIL.TILE

  cat HEAD.TILE TAIL.TILE > newWasControl.sh

  rm wasControlUpdate.sh HEAD.TILE TAIL.TILE
  mv newWasControl.sh $SCRIPT_NAME
  chmod +x $SCRIPT_NAME
  cd $LOCAL_DIR
  bash $(basename $0)
  exit
}

setDeployScript(){
  clear
  
  REL_PATH_SCRIPT=$(cat $ISIS_DEVEL/Metis/Gui/src/main/scripts/portaldevel_deploy_war.sh | grep 'SCRIPT_REL_PATH=')
  REL_PATH=$(echo $REL_PATH_SCRIPT | cut -d '"' -f2)
  
  sed -i -r s/'[0-9]+.[0-9]+\.[0-9]+'/$SETUP_ERSION/g $ISIS_DEVEL/Metis/Gui/src/main/scripts/deployScript.sh
  sed -i -r s/'[0-9]+.[0-9]+\.[0-9]+'/$SETUP_VERSION/g $ISIS_DEVEL/Metis/Gui/src/main/scripts/deployMetisGuiWar.sh
  sed -i -r s/'[0-9]+.[0-9]+\.[0-9]+'/$SETUP_VERSION/g $ISIS_DEVEL/Metis/Gui/src/main/scripts/portaldevel_deploy_war.sh
  sed -i -r s/'[0-9]+.[0-9]+\.[0-9]+'/$SETUP_VERSION/g $ISIS_DEVEL/Metis/Gui/src/main/scripts/update.xmlaccess
  sed -i -r s/'[0-9]+.[0-9]+\.[0-9]+'/$SETUP_VERSION/g $ISIS_DEVEL/Zber/Gui/src/main/scripts/portaldevel_deploy_war.sh
  ssh $HOST_USER@$HOST_PORTAL "sed -i -r s/'[0-9]+.[0-9]+\.[0-9]+'/$SETUP_VERSION/g $SCRIPT_REL_PATH/update.xmlaccess"
  ssh $HOST_USER@$HOST_PORTAL "sed -i -r s/'[0-9]+.[0-9]+\.[0-9]+'/$SETUP_VERSION/g $SCRIPT_REL_PATH/ZBER/update.xmlaccess"
  ssh $HOST_USER@$HOST_PORTAL "sed -i -r s/'[0-9]+.[0-9]+\.[0-9]+'/$SETUP_VERSION/g $SCRIPT_REL_PATH/ZBD/update.xmlaccess"
  ssh $HOST_USER@$HOST_PORTAL "sed -i -r s/'[0-9]+.[0-9]+\.[0-9]+'/$SETUP_VERSION/g $SCRIPT_REL_PATH/IAM/update.xmlaccess"
  ssh $HOST_USER@$HOST_PORTAL "sed -i -r s/'[0-9]+.[0-9]+\.[0-9]+'/$SETUP_VERSION/g $SCRIPT_REL_PATH/LogApp/update.xmlaccess"
  ssh $HOST_USER@$HOST_PORTAL "sed -i -r s/'[0-9]+.[0-9]+\.[0-9]+'/$SETUP_VERSION/g $SCRIPT_REL_PATH/ISIS_GUI/update.xmlaccess"
  
  
  sed -i -r s/'[0-9]+.[0-9]+\.[0-9]+'/$ACTUAL_VERSION/g $ISIS_DEVEL/Metis/Ear/deploy_ear.sh
  sed -i -r s/'[0-9]+.[0-9]+\.[0-9]+'/$ACTUAL_VERSION/g $ISIS_DEVEL/Metis/Ear/wasdevel_deploy_ear.sh
  
  echo "Update scriptov prebehol"
  echo -e "$BLUE Stlac enter pre pokracovanie $NC"
  read
}



removeOldJars(){

  let "OLD_VERSION = $(echo $SETUP_VERSION | cut -d"." -f2 ) -1"
  RMIAMSECURITY="$VIRTUAL_PORTAL/shared/ext/IsisSecurityProject-*.jar"
  RMIAMLOGINFACADE="$VIRTUAL_PORTAL/shared/ext/IamBusinessServiceFacadeForCustomLoginProject-*.jar"
  RMIAMLOGIN_OLD="$VIRTUAL_PORTAL/shared/app/IamAuthCustomLoginModuleProject-*.jar"
  RMIAMLOGIN="$VIRTUAL_PORTAL/shared/ext/IamAuthCustomLoginModuleProject-*.jar"
  RMCOMMONUTILS="$VIRTUAL_WAS/lib/ext/CommonUtilsProject-*.jar"
  RMEJBPORTAL="$VIRTUAL_WAS/lib/ext/EjbConfigProject-*.jar"
  RMEJBWAS="$VIRTUAL_WAS/lib/ext/EjbConfigProject-*.jar"
  RMCOMMONUTILSWAS="$VIRTUAL_WAS/lib/ext/CommonUtilsProject-*.jar"
  RMIPFILTER="$VIRTUAL_PORTAL/shared/app/IamAuthIpFilterProject-*.jar"
  echo "Navrhujem mazat veci:"
  echo $RMIAMSECURITY;
  echo $RMIAMLOGINFACADE;
  echo $RMIAMLOGIN;
  echo $RMCOMMONUTILS;
  echo $RMEJBPORTAL;
  echo $RMEJBWAS;
  echo $RMCOMMONUTILSWAS;
  echo $RMIPFILTER;
  echo
  echo "Je to v poriadku?(y/N)"
  read remover
  if [[ $remover == [yY][eE][sS] ]]  || [[ $remover == [yY] ]]
  then
    echo "Mazem"
    ssh $HOST_USER@$HOST_PORTAL "rm -fvr $RMIAMSECURITY"
    ssh $HOST_USER@$HOST_PORTAL "rm -fvr $RMIAMLOGINFACADE"
    ssh $HOST_USER@$HOST_PORTAL "rm -fvr $RMIAMLOGIN"
    ssh $HOST_USER@$HOST_PORTAL "rm -fvr $RMIAMLOGIN_OLD"
    ssh $HOST_USER@$HOST_PORTAL "rm -fvr $RMCOMMONUTILS"
    ssh $HOST_USER@$HOST_PORTAL "rm -fvr $RMEJBPORTAL"
    ssh $HOST_USER@$HOST_PORTAL "rm -fvr $RMIPFILTER"
    ssh $HOST_USER@$HOST "rm -fvr $RMCOMMONUTILSWASL"
    ssh $HOST_USER@$HOST "rm -fvr $RMEJBWAS"
    ssh $HOST_USER@$HOST "rm -fvr $RMCOMMONUTILSWAS"
    #for toRM in $(ls *.$OLD_VERSION.0.jar) 
    #do 
    #  rm -fv $toRM
    #done
  else
    echo "ok :("
  fi
}

sendJars(){

  removeOldJars
  echo  
  echo 'Sending ...'
  scp $ISIS_DEVEL/IsisCommon/IsisSecurity/target/IsisSecurityProject-$SETUP_VERSION.jar $HOST_USER@$HOST_PORTAL:$VIRTUAL_PORTAL/shared/ext/
  echo '...'
  scp $ISIS_DEVEL/Iam/Business/ServiceFacadeForCustomLogin/target/IamBusinessServiceFacadeForCustomLoginProject-$SETUP_VERSION.jar $HOST_USER@$HOST_PORTAL:$VIRTUAL_PORTAL/shared/ext/
  echo '...'
  scp $ISIS_DEVEL/Iam$BRANCH_SFX/Auth/CustomLoginModule/target/IamAuthCustomLoginModuleProject-$SETUP_VERSION.jar $HOST_USER@$HOST_PORTAL:$VIRTUAL_PORTAL/shared/ext/
  echo '...'
  scp $ISIS_DEVEL/Iam$BRANCH_SFX/Auth/IpFilter/target/IamAuthIpFilterProject-$SETUP_VERSION.jar $HOST_USER@$HOST_PORTAL:$VIRTUAL_PORTAL/shared/app/
  echo '...'
  scp $COMMON_DEVEL/CommonUtils/target/CommonUtilsProject-$SETUP_VERSION.jar $HOST_USER@$HOST_PORTAL:$VIRTUAL_WAS/lib/ext/
  echo '...'
  scp $COMMON_DEVEL/CommonUtils/target/CommonUtilsProject-$SETUP_VERSION.jar $HOST_USER@$HOST:$VIRTUAL_WAS/lib/ext/
  echo '...'
  scp $COMMON_DEVEL/EjbConfig/target/EjbConfigProject-$SETUP_VERSION.jar $HOST_USER@$HOST_PORTAL:$VIRTUAL_WAS/lib/ext/
  echo '...'  
  scp $COMMON_DEVEL/EjbConfig/target/EjbConfigProject-$SETUP_VERSION.jar $HOST_USER@$HOST:$VIRTUAL_WAS/lib/ext/
  echo '...'
  echo
  echo -e "$BLUE Stlac enter pre pokracovanie $NC"
  read
}

function welcome {
  clear;
  case "$BRANCH_BUILD" in
    1) echo -e "Build (b):$RED Trunk$NC" ;;
    2) echo -e "Build (b):$RED Branch$NC" ;;
    3) echo -e "Build (b):$RED Tag$NC" ;;
  esac
  
  echo -e "Aktualny profil (p):$RED $ACTUAL_PROFILE $NC"
  echo -e "Nastavena verzia na :$RED $SETUP_VERSION $NC"
  if [ "$(checkIfNewVersionAvailable)" == "1" ]
  then
    echo -e "$BLINK Nova verzia k dispozicii (n) $NE"
  fi
  echo ""
  echo ""
  echo "    ________  __  ___   _       __     __   _____       __                 "
  echo "   /  _/ __ )/  |/  /  | |     / /__  / /_ / ___/____  / /_  ___  ________ "
  echo '   / // __  / /|_/ /   | | /| / / _ \/ __ \\__ \/ __ \/ __ \/ _ \/ ___/ _ \'
  echo " _/ // /_/ / /  / /    | |/ |/ /  __/ /_/ /__/ / /_/ / / / /  __/ /  /  __/"
  echo "/___/_____/_/  /_/     |__/|__/\___/_.___/____/ .___/_/ /_/\___/_/   \___/ "
  echo "                                             /_/                           "
  echo ""
  
  echo
  echo
  echo "1. Deploy vsetkeho 				2. Build vsetkeho -- 22. Build pom"
  echo "3. Ciastocny deploy -- 33. Build->Deploy	4. Ciastocny build	"
  echo "5. SVN Update -- 55. Branch			6. Odoslanie novych verzii JAR"
  echo "7. Konfiguracia					8. Ovladanie masin"
  echo ""
  echo "9. Build.log 		       			10. Deploy.log"
  echo "								00. exit"
  echo -n "Vyber moznost: "
  read option;
  clear;
  case "$option" in 
    1) deploy "ALL" | tee $DEPLOY_LOG ;;
    2) rm $BUILD_LOG
       build "ALL" 
       if grep -q FAILURE "$BUILD_LOG" 
       then
       echo -e "$RED Build zlyhal!! $NC"
       echo
       fi
       echo -e "$BLUE Stlac enter pre pokracovanie $NC"
       read
       ;;
    3) chooseDeploy | tee $DEPLOY_LOG ;;
    4) rm $BUILD_LOG
       chooseBuild ;;
    5) svnUpdate;;
    6) sendJars;;
    7) configureMenu ;;
    8) chooseControl ;;
    9) showBuildLog ;;
    10)showDeployLog;;
    22)	rm $BUILD_LOG
	pomBuild
	if grep -q FAILURE "$BUILD_LOG" 
       then
       echo -e "$RED Build zlyhal!! $NC"
       echo
       fi
       echo -e "$BLUE Stlac enter pre pokracovanie $NC"
       read
       ;;
    55) svnBranchUpdate ;;
    33) buildAndDeploy ;;
    p) chooseProfile;;
    b) chooseBuildPath ;;
    w) w
       echo -e "$BLUE Stlac enter pre pokracovanie $NC"
       read
       ;;
    n) whatsInNewVersion ;;
    #EASTER_EGGS
    nyan) nyanCat;;
    0) clear; exit ;;
    00) clear; exit ;;
    *) clear; echo "Chybne zadany vstup"; sleep 1; welcome ;;
  esac
  welcome
}

mainFunction(){
  
  LOCAL_DIR=$( dirname $(readlink -f "$0"))
  cd $LOCAL_DIR
  clear;
  
  setProfileVariables
  
  case "$BRANCH_BUILD" in
  1) SETUP_VERSION="$ACTUAL_VERSION"
     SETUP_TYPE="Trunk"
     ;;
  2) ISIS_DEVEL="$ISIS_DEVEL_BRANCH"
     COMMON_DEVEL="$COMMON_DEVEL_BRANCH"
     SETUP_VERSION="$BRANCH_VERSION.$LAST_VERSION_NUMBER"
     SETUP_TYPE="Branch"
     ;;
  3) ISIS_DEVEL="$ISIS_DEVEL_TAG"
     COMMON_DEVEL="$COMMON_DEVEL_TAG"
     SETUP_VERSION="$TAG_VERSION.$LAST_TAG_VERSION_NUMBER"
     SETUP_TYPE="Tag"
     ;;
  esac
  
  setUpDeployParameters
  welcome
}
mainFunction
