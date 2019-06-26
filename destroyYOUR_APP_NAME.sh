heroku pipelines:destroy YOUR_APP_NAME-pipeline
heroku apps:destroy -a YOUR_APP_NAME-dev -c YOUR_APP_NAME-dev
heroku apps:destroy -a YOUR_APP_NAME-staging -c YOUR_APP_NAME-staging
heroku apps:destroy -a YOUR_APP_NAME-prod -c YOUR_APP_NAME-prod
rm -- "destroyYOUR_APP_NAME.sh"
