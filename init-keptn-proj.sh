#!/usr/bin/env bash

# default the variables if not set
DEBUG=${DEBUG:="false"}
SOURCE=${SOURCE:="unknown"}
DYNATRACE_MONITORING=${DYNATRACE_MONITORING:="true"}

# optinal values with no defaults
# DYNATRACE_SLI_FILE  
# JMETER_FILE

# Required parameters
API_URL=${API_URL:?'API_URL ENV variable missing.'}
KEPTN_TOKEN=${KEPTN_TOKEN:?'KEPTN_TOKEN ENV variable missing.'}
PROJECT=${PROJECT:?'PROJECT ENV variable missing.'}
SERVICE=${SERVICE:?'SERVICE ENV variable missing.'}
STAGE=${STAGE:?'STAGE ENV variable missing.'}
SHIPYARD_FILE=${SHIPYARD_FILE:?'SLO_FILE ENV variable missing'}
SLO_FILE=${SLO_FILE:?'SLO_FILE ENV variable missing'}

echo "================================================================="
echo "Keptn Prepare Project"
echo ""
echo "API_URL              = $API_URL"
echo "PROJECT              = $PROJECT"
echo "SERVICE              = $SERVICE"
echo "STAGE                = $STAGE"
echo "SOURCE               = $SOURCE"
echo "SHIPYARD_FILE        = $SHIPYARD_FILE"
echo "SLO_FILE             = $SLO_FILE"
echo "DYNATRACE_MONITORING = $DYNATRACE_MONITORING"
echo "DYNATRACE_CONF_FILE  = $DYNATRACE_CONF_FILE"
echo "DYNATRACE_SLI_FILE   = $DYNATRACE_SLI_FILE"
echo "JMETER_FILE          = $JMETER_FILE"
echo "DEBUG                = $DEBUG"
echo "================================================================="

# authorize keptn cli
keptn auth --api-token "$KEPTN_TOKEN" --endpoint "$API_URL"
if [ $? -ne 0 ]; then
    echo "Aborting: Failed to authenticate Keptn CLI"
    exit 1
fi

# onboard project
if [ $(keptn get project $PROJECT | wc -l) -ne 2 ]; then
  keptn create project $PROJECT --shipyard=$SHIPYARD_FILE
else
  echo "Project $PROJECT already onboarded. Skipping create project"
fi

# onboard service
if [ $(keptn get service $SERVICE --project $PROJECT | wc -l) -ne 2 ]; then
  keptn create service $SERVICE --project=$PROJECT
else
  echo "Service $SERVICE already onboarded. Skipping create service"
fi

# configure Dynatrace monitoring

# always add SLO resources
keptn add-resource --project=$PROJECT --stage=$STAGE --service=$SERVICE --resource=$SLO_FILE --resourceUri=slo.yaml

echo "================================================================="
echo "Completed Keptn Prepare Project"
echo "================================================================="
