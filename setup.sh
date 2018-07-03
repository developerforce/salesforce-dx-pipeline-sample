#!/usr/bin/env bash

set -o errexit    # always exit on error
set -o nounset    # fail on unset variables

#################################################################
# Script to setup a fully configured pipeline for Salesforce DX #
#################################################################

### Declare values

# Name of your team (optional)
HEROKU_TEAM_NAME=""

# Descriptive name for the Heroku app
HEROKU_APP_NAME="YOUR_APP_NAME"

# Name of the Heroku apps you'll use
HEROKU_DEV_APP_NAME="$HEROKU_APP_NAME-dev"
HEROKU_STAGING_APP_NAME="$HEROKU_APP_NAME-staging"
HEROKU_PROD_APP_NAME="$HEROKU_APP_NAME-prod"

# Pipeline
HEROKU_PIPELINE_NAME="$HEROKU_APP_NAME-pipeline"

# Usernames or aliases of the orgs you're using
DEV_HUB_USERNAME="HubOrg"
DEV_USERNAME="DevOrg"
STAGING_USERNAME="TestOrg"
PROD_USERNAME="ProdOrg"

# Your package name from force:package:list
PACKAGE_NAME="YOUR_PACKAGE_NAME"

# Repository with your code (username/repo)
# (only specify a value if you have already connected your GitHub account with Heroku)
GITHUB_REPO=

### Setup script

# Support a Heroku team
HEROKU_TEAM_FLAG=""
if [ ! "$HEROKU_TEAM_NAME" == "" ]; then
  HEROKU_TEAM_FLAG="-t $HEROKU_TEAM_NAME"
fi

# Clean up script (in case something goes wrong)
echo "heroku pipelines:destroy $HEROKU_PIPELINE_NAME
heroku apps:destroy -a $HEROKU_DEV_APP_NAME -c $HEROKU_DEV_APP_NAME
heroku apps:destroy -a $HEROKU_STAGING_APP_NAME -c $HEROKU_STAGING_APP_NAME
heroku apps:destroy -a $HEROKU_PROD_APP_NAME -c $HEROKU_PROD_APP_NAME
rm -- \"destroy$HEROKU_APP_NAME.sh\"" > destroy$HEROKU_APP_NAME.sh

echo ""
echo "Run ./destroy$HEROKU_APP_NAME.sh to remove resources"
echo ""

chmod +x "destroy$HEROKU_APP_NAME.sh"

# Create three Heroku apps to map to orgs
heroku apps:create $HEROKU_DEV_APP_NAME $HEROKU_TEAM_FLAG
heroku apps:create $HEROKU_STAGING_APP_NAME $HEROKU_TEAM_FLAG
heroku apps:create $HEROKU_PROD_APP_NAME $HEROKU_TEAM_FLAG

# Set the stage (since STAGE isn't required, review apps don't get one)
heroku config:set STAGE=DEV -a $HEROKU_DEV_APP_NAME
heroku config:set STAGE=STAGING -a $HEROKU_STAGING_APP_NAME
heroku config:set STAGE=PROD -a $HEROKU_PROD_APP_NAME

# Set whether or not to use DCP packaging
heroku config:set SFDX_INSTALL_PACKAGE_VERSION=true -a $HEROKU_DEV_APP_NAME
heroku config:set SFDX_INSTALL_PACKAGE_VERSION=true -a $HEROKU_STAGING_APP_NAME
heroku config:set SFDX_INSTALL_PACKAGE_VERSION=true -a $HEROKU_PROD_APP_NAME

# Set whether to create package version
heroku config:set SFDX_CREATE_PACKAGE_VERSION=true -a $HEROKU_DEV_APP_NAME
heroku config:set SFDX_CREATE_PACKAGE_VERSION=false -a $HEROKU_STAGING_APP_NAME
heroku config:set SFDX_CREATE_PACKAGE_VERSION=false -a $HEROKU_PROD_APP_NAME

# Package name
heroku config:set SFDX_PACKAGE_NAME="$PACKAGE_NAME" -a $HEROKU_DEV_APP_NAME
heroku config:set SFDX_PACKAGE_NAME="$PACKAGE_NAME" -a $HEROKU_STAGING_APP_NAME
heroku config:set SFDX_PACKAGE_NAME="$PACKAGE_NAME" -a $HEROKU_PROD_APP_NAME

# Turn on debug logging
heroku config:set SFDX_BUILDPACK_DEBUG=true -a $HEROKU_DEV_APP_NAME
heroku config:set SFDX_BUILDPACK_DEBUG=true -a $HEROKU_STAGING_APP_NAME
heroku config:set SFDX_BUILDPACK_DEBUG=true -a $HEROKU_PROD_APP_NAME

# Setup sfdxUrl's for Dev Hub auth
devHubSfdxAuthUrl=$(sfdx force:org:display --verbose -u $DEV_HUB_USERNAME | grep "Sfdx Auth Url" | awk '{ print $4 }')
if [[ "$devHubSfdxAuthUrl" =~ ^force://.*\.salesforce\.com$ ]]; then
  heroku config:set SFDX_DEV_HUB_AUTH_URL=$devHubSfdxAuthUrl -a $HEROKU_DEV_APP_NAME
  heroku config:set SFDX_DEV_HUB_AUTH_URL=$devHubSfdxAuthUrl -a $HEROKU_STAGING_APP_NAME
  heroku config:set SFDX_DEV_HUB_AUTH_URL=$devHubSfdxAuthUrl -a $HEROKU_PROD_APP_NAME
else
  echo ""
  echo "ERROR: Did not find 'Sfdx Auth Url' output from command: sfdx force:org:display --verbose -u $DEV_HUB_USERNAME"
  echo ""
  exit 1
fi

# Setup sfdxUrl for Dev Org auth
devSfdxAuthUrl=$(sfdx force:org:display --verbose -u $DEV_USERNAME | grep "Sfdx Auth Url" | awk '{ print $4 }')
if [[ "$devSfdxAuthUrl" =~ ^force://.*\.salesforce\.com$ ]]; then
  heroku config:set SFDX_AUTH_URL=$devSfdxAuthUrl -a $HEROKU_DEV_APP_NAME
else
  echo ""
  echo "ERROR: Did not find 'Sfdx Auth Url' output from command: sfdx force:org:display --verbose -u $DEV_USERNAME"
  echo ""
  exit 1
fi

# Setup sfdxUrl for Staging Org auth
stagingSfdxAuthUrl=$(sfdx force:org:display --verbose -u $STAGING_USERNAME | grep "Sfdx Auth Url" | awk '{ print $4 }')
if [[ "$stagingSfdxAuthUrl" =~ ^force://.*\.salesforce\.com$ ]]; then
  heroku config:set SFDX_AUTH_URL=$stagingSfdxAuthUrl -a $HEROKU_STAGING_APP_NAME
else
  echo ""
  echo "ERROR: Did not find 'Sfdx Auth Url' output from command: sfdx force:org:display --verbose -u $STAGING_USERNAME"
  echo ""
  exit 1
fi

# Setup sfdxUrl for Prod Org auth
prodSfdxAuthUrl=$(sfdx force:org:display --verbose -u $PROD_USERNAME | grep "Sfdx Auth Url" | awk '{ print $4 }')
if [[ "$prodSfdxAuthUrl" =~ ^force://.*\.salesforce\.com$ ]]; then
  heroku config:set SFDX_AUTH_URL=$prodSfdxAuthUrl -a $HEROKU_PROD_APP_NAME
else
  echo ""
  echo "ERROR: Did not find 'Sfdx Auth Url' output from command: sfdx force:org:display --verbose -u $PROD_USERNAME"
  echo ""
  exit 1
fi

# Add buildpacks to apps (to use latest remove version info)
heroku buildpacks:add -i 1 https://github.com/heroku/salesforce-cli-buildpack#v3 -a $HEROKU_DEV_APP_NAME
heroku buildpacks:add -i 1 https://github.com/heroku/salesforce-cli-buildpack#v3 -a $HEROKU_STAGING_APP_NAME
heroku buildpacks:add -i 1 https://github.com/heroku/salesforce-cli-buildpack#v3 -a $HEROKU_PROD_APP_NAME

heroku buildpacks:add -i 2 https://github.com/douglascayers/salesforce-buildpack -a $HEROKU_DEV_APP_NAME
heroku buildpacks:add -i 2 https://github.com/douglascayers/salesforce-buildpack -a $HEROKU_STAGING_APP_NAME
heroku buildpacks:add -i 2 https://github.com/douglascayers/salesforce-buildpack -a $HEROKU_PROD_APP_NAME

# Create Pipeline
heroku pipelines:create $HEROKU_PIPELINE_NAME -a $HEROKU_DEV_APP_NAME -s development $HEROKU_TEAM_FLAG
heroku pipelines:add $HEROKU_PIPELINE_NAME -a $HEROKU_STAGING_APP_NAME -s staging
heroku pipelines:add $HEROKU_PIPELINE_NAME -a $HEROKU_PROD_APP_NAME -s production

heroku ci:config:set -p $HEROKU_PIPELINE_NAME SFDX_DEV_HUB_AUTH_URL=$devHubSfdxAuthUrl
heroku ci:config:set -p $HEROKU_PIPELINE_NAME SFDX_AUTH_URL=$devSfdxAuthUrl
heroku ci:config:set -p $HEROKU_PIPELINE_NAME SFDX_BUILDPACK_DEBUG=true
heroku ci:config:set -p $HEROKU_PIPELINE_NAME SFDX_INSTALL_PACKAGE_VERSION=true
heroku ci:config:set -p $HEROKU_PIPELINE_NAME SFDX_CREATE_PACKAGE_VERSION=false
heroku ci:config:set -p $HEROKU_PIPELINE_NAME SFDX_PACKAGE_NAME="$PACKAGE_NAME"
heroku ci:config:set -p $HEROKU_PIPELINE_NAME HEROKU_APP_NAME="$HEROKU_APP_NAME"

# Connect Pipeline to GitHub repo
# (will only work if you've already authorized Heroku's access to your GitHub account)
if [ ! "$GITHUB_REPO" == "" ]; then
  heroku pipelines:connect $HEROKU_PIPELINE_NAME --repo $GITHUB_REPO
  heroku reviewapps:enable -p $HEROKU_PIPELINE_NAME -a $HEROKU_DEV_APP_NAME --autodeploy --autodestroy
fi

echo ""
echo "Heroku pipelines setup script completed"
echo ""
echo "If you need to undo these changes, run ./destroy$HEROKU_APP_NAME.sh"
echo ""