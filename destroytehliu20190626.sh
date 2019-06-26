heroku pipelines:destroy tehliu20190626-pipeline
heroku apps:destroy -a tehliu20190626-dev -c tehliu20190626-dev
heroku apps:destroy -a tehliu20190626-staging -c tehliu20190626-staging
heroku apps:destroy -a tehliu20190626-prod -c tehliu20190626-prod
rm -- "destroytehliu20190626.sh"
