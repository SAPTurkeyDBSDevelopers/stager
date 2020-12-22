#!/usr/bin/env bash
export ENV=dev
source ./parse_yaml.sh
#set -x


######################################################
# Check parameters
######################################################
CONFIG_FILE=$1
if [ -f "${CONFIG_FILE}" ]; then
    echo "Found config file ${CONFIG_FILE}";
else
    echo "Please call $0 <vars-file> [-build] [-deploy-si] [-deploy-db] [-deploy-ar] [-deploy-ui] [-deploy-srv] [-deploy-cs]";
    exit 1
fi

while (( "$#" )); do
   case $1 in
      -build)
         echo "Build"
         export BUILD=1
         ;;
      -deploy-db)
         echo "Deploy HDI container"
         export DEPLOY_DB=1
         ;;
      -deploy-si)
         echo "Create service instances"
         export CREATE_INSTANCES=1
         ;;
      -deploy-ar)
         echo "Deploy approuter container"
         export DEPLOY_AR=1
         ;;
      -deploy-srv)
         echo "Deploy OData service"
         export DEPLOY_SRV=1
         ;;
      -deploy-ui)
         echo "Deploy static web content"
         export DEPLOY_UI=1
         ;;
      -deploy-cs)
         echo "Deploy content server"
         export DEPLOY_CS=1
         ;;
       -clean)
         echo "Clean up"
         export CLEAN_UP=1
         ;;
   esac
shift
done

eval $(parse_yaml $CONFIG_FILE "config_")
echo "########################"
echo "Deploying as $config_env"
#eval $(parse_yaml $CONFIG_FILE "config_")
echo "########################"

export WD=`pwd` 
echo "b $BUILD"

if [ "$BUILD" ]
then
    cd ..
    rm -rf gen
    rm -rf app/node_modules
    #CDS
    npm i
    CDS_ENV=production cds build/all
    #UI
    npm run ui5:build
 
else
      echo "no build"
fi


cf t -o $config_org -s $config_space

if [ "$CREATE_INSTANCES" ]
then
    preprod_str="preprod"
    cd "$WD/.."
 

    if [ "${config_env}" == "$preprod_str" ]
    then
         cf cs hanatrial hdi-shared stageroids-db-hdi-container
    else
         cf cs hanatrial hdi-shared stageroids-db-hdi-container
    fi

 
   # cf cs objectstore s3-standard astager-objectstore
else
      echo "no service instance creation"
fi


if [ "$DEPLOY_DB" ]
then
    #cds deploy --to hana
    cd "$WD/../db/src/gen"
    npm install
    cf push -f manifest.yaml
    cd "$WD"
else
      echo "no DB deployment"
fi

if [ "$DEPLOY_SRV" ]
then
    cd "$WD/.."
    cf push -f deploy/manifest.yaml stager-srv-green -p gen/srv --no-route --vars-file deploy/${CONFIG_FILE}
    cf map-route stager-srv-green ${config_srv_domain}  -n ${config_srv_host}
    cf stop stager-srv-${config_env} || echo "assuming stager-srv does not exist"
    cf delete -f stager-srv-${config_env}
    cf rename stager-srv-green stager-srv-${config_env}
else
      echo "no srv deployment";
fi

if [ "$DEPLOY_AR" ]
then
    prod_str="prod"
    cd "$WD/.."
    cd approuter
    npm install
    cd ..
    cf push -f deploy/manifest.yaml stagerapp-green -p approuter --no-route --vars-file deploy/${CONFIG_FILE}

    if [ "${config_env}" == "$prod_str" ]
    then
        cf map-route stagerapp-green ${config_ar_domain} -n ${config_ar_host}
        cf map-route stagerapp-green ${config_ar_domain}  # -n ${config_ar_host}
    else
        cf map-route stagerapp-green ${config_ar_domain} -n ${config_ar_host}
    fi

    cf stop stagerapp-${config_env} || echo "assuming stager-srv does not exist"
    cf delete -f stagerapp-${config_env}
    cf rename stagerapp-green stagerapp-${config_env};
else
      echo "no approuter deployment";
fi

if [ "$DEPLOY_UI" ]
then
    cd "$WD/.."
    cf push -f deploy/manifest.yaml static-web-green -p app --no-route --vars-file deploy/${CONFIG_FILE}
    cf map-route static-web-green ${config_static_web_domain}  -n ${config_static_web_host}
    cf stop static-web-${config_env} || echo "assuming static-web does not exist"
    cf delete -f static-web-${config_env}
    cf rename static-web-green static-web-${config_env};
else
      echo "no static web content deployment";
fi

if [ "$DEPLOY_CS" ]
then
    cd "$WD/.."
    cd content-srv
    npm install
    cd ..
    cf push -f deploy/manifest.yaml stager-contentsrv-green -p content-srv --no-route --vars-file deploy/${CONFIG_FILE}
    cf map-route stager-contentsrv-green ${config_content_server_domain}  -n ${config_content_server_host}
    cf stop stager-contentsrv-${config_env} || echo "assuming content server does not exist"
    cf delete -f stager-contentsrv-${config_env}
    cf rename stager-contentsrv-green stager-contentsrv-${config_env};
else
      echo "no content server deployment";
fi

if [ "$CLEAN_UP" ]
then
    cf delete -f static-web-${config_env}
    cf delete -f static-web
    cf delete -f static-web-green

    cf delete -f stagerapp-${config_env}
    cf delete -f stagerapp
    cf delete -f stagerapp-green

    cf delete -f stager-srv-${config_env}
    cf delete -f stager-srv
    cf delete -f stager-srv-green

    cf delete -f stager-contentsrv-${config_env}
    cf delete -f stager-contentsrv
    cf delete -f stager-contentsrv-green

else
      echo "no static web content deployment";
fi

