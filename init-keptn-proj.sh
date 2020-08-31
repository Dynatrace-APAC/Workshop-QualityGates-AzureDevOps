#!/usr/bin/env bash

# default the variables if not set
DEBUG=${DEBUG:="false"}
SOURCE=${SOURCE:="unknown"}
DYNATRACE_MONITORING=${DYNATRACE_MONITORING:="true"}

# optinal values with no defaults
# DYNATRACE_SLI_FILE
# JMETER_FILE

# Required parameters
#API_URL=${API_URL:?'API_URL ENV variable missing.'}
#KEPTN_TOKEN=${KEPTN_TOKEN:?'KEPTN_TOKEN ENV variable missing.'}
#PROJECT=${PROJECT:?'PROJECT ENV variable missing.'}
#SERVICE=${SERVICE:?'SERVICE ENV variable missing.'}
#STAGE=${STAGE:?'STAGE ENV variable missing.'}
#SHIPYARD_FILE=${SHIPYARD_FILE:?'SLO_FILE ENV variable missing'}
#SLO_FILE=${SLO_FILE:?'SLO_FILE ENV variable missing'}

echo "================================================================="
echo "Keptn Prepare Project"
echo ""
echo "API_URL              = $KeptnApiUrl"
echo "PROJECT              = $KeptnProject"
echo "SERVICE              = $KeptnService"
echo "STAGE                = $KeptnStage"
echo "SOURCE               = $SOURCE"
echo "SHIPYARD_FILE        = $SHIPYARD_FILE"
echo "SLO_FILE             = $SLO_FILE"
echo "GITUSER              = $gituser"
echo "GITURL               = $giturl"
echo "GITTOKEN             = $gittoken"
echo "DYNATRACE_CONF_FILE  = $DYNATRACE_CONF_FILE"
echo "DYNATRACE_SLI_FILE   = $DYNATRACE_SLI_FILE"
#echo "JMETER_FILE          = $JMETER_FILE"
#echo "DEBUG                = $DEBUG"
echo "================================================================="
# authorize keptn cli
#keptn auth --api-token "$KEPTN_TOKEN" --endpoint "$API_URL"
#if [ $? -ne 0 ]; then
#    echo "Aborting: Failed to authenticate Keptn CLI"
#    exit 1
#fi

# onboard project
if [ $(keptn get project $KeptnProject | wc -l) -ne 2 ]; then
  keptn create project $KeptnProject --shipyard=$SHIPYARD_FILE --git-user=$gituser --git-remote-url=$giturl --git-token=$gittoken
else
  echo "Project $PROJECT already onboarded. Skipping create project"
fi
read
# onboard service
if [ $(keptn get service $KeptnService --project $KeptnProject| wc -l) -ne 2 ]; then
  keptn create service $KeptnService --project=$KeptnProject
else
  echo "Service  $KeptnService already onboarded. Skipping create service"
fi
read
# configure Dynatrace monitoring
keptn configure monitoring dynatrace --project=$KeptnProject
read
# always add SLO resources
keptn add-resource --project=$KeptnProject --stage=$KeptnStage --service=$KeptnService --resource=$SLO_FILE --resourceUri=slo.yaml
read
# add SLI resources
keptn add-resource --project=$KeptnProject --stage=$KeptnStage --service=$KeptnService --resource=$DYNATRACE_SLI_FILE --resourceUri=dynatrace/sli.yaml
read
# add dynatrace config
keptn add-resource --project=$KeptnProject --stage=$KeptnStage --service=$KeptnService --resource=$DYNATRACE_CONF_FILE --resourceUri=dynatrace/dynatrace.conf.yaml

echo "================================================================="
echo "Completed Keptn Prepare Project"
echo "================================================================="
