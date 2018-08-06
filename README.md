# salesforce-dx-pipeline-sample

This sample uses unlocked second generation packages (2GPs) to deploy project updates. If you're looking to perform metadata deploys instead, please use [https://github.com/wadewegner/salesforce-dx-pipeline-mdapi-sample](https://github.com/wadewegner/salesforce-dx-pipeline-mdapi-sample).

Originally developed by [Wade Wegner](https://github.com/wadewegner/salesforce-dx-pipeline-sample), adapted for Trailhead instruction by [Doug Ayers](https://github.com/douglascayers).

![image](https://user-images.githubusercontent.com/746259/36068129-5c8a19b2-0e82-11e8-96b5-a9fed295a33d.png)

To use Heroku Pipelines with any Salesforce DX project, you only need to do two things:

1. Create a `app.json` file.

2. Create a `sfdx.yml` file.

That's it. Along with the `setup.sh` script you find in this repo, the buildpacks do the rest.

## Setup

1. Install the [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli).

2. Install the [Salesforce CLI](https://developer.salesforce.com/tools/sfdxcli).

3. Log into to the four orgs you'll use with the Salesforce CLI, using `force:auth:web:login` command, and give them aliases:

    - **Dev Hub (e.g.. "HubOrg")**: this will create scratch orgs for your Review Apps
    - **Development Org (e.g. "DevOrg")**: this is the first environment you'll update using a package deploy
    - **Staging Org (e.g. "TestOrg")**: this is the first environment from which you'll promote your code via release phase
    - **Prod Org : "ProdOrg"**: this is your production org

    Note: You could cheat and, simply for demo purposes, use the same org for the DevOrg, TestOrg, and ProdOrg.

    Note: Do not use `force:auth:jwt:grant` command as it does not provide a refresh token nor a `sfdxAuthUrl` from `force:org:display --verbose` command used by the `setup.sh`.

4. Ensure you see all four orgs when you run `sfdx force:org:list`.

5. Fork this repository.

6. Clone the repository locally.

7. Update the values in `setup.sh` accordingly (e.g. `HEROKU_TEAM_NAME`, `HEROKU_APP_NAME`, `DEV_HUB_USERNAME`, `DEV_USERNAME`, `STAGING_USERNAME`, `PROD_USERNAME`, `GITHUB_REPO`, and `PACKAGE_NAME`).

8. Create an unlocked package in your hub org:

```
sfdx force:package:create -n <PACKAGE_NAME> -d <PACKAGE_DESCRIPTION> -t Unlocked -e -v <DEV_HUB_USERNAME>
```

9. Run `./setup.sh`.

10. Open your pipeline: `heroku pipelines:open <PIPELINE_NAME>`

11. For the development stage, click the expansion button and then click **Configure automatic deploys..**. Then click **Enable Automatic Deploys**. Do not check "Wait for CI to pass before deploy" unless you have CI setup.

Now you're all set.

## Usage

To demo, simply submit a pull request. It's easiest to do through the GitHub UI. Simply edit a page, then instead of committing directly to the branch, create a pull request. Once created, the review app is ready to go. When the pull request is accepted, the review app is deleted and the application is deployed to your staging org.

If you want to work against the latest buildpacks, update the version # (or remove entirely) in `app.json`.

## Clean up

At any time you can run `./destroy.sh` to delete your pipeline and apps.
