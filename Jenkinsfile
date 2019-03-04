#!/usr/bin/env groovy

@Library('Carbon-CI') _

carbon.withNode("py-docker") {
    def containerName = "carbon-ts-protoc-gen"
    def containerTag = "${env.BRANCH_NAME}"

    carbon.withStage("Build") {
        py "build.py --name ${containerName} --tag ${containerTag} --build ./"
    }
}

if (env.BRANCH_NAME == 'master') {
    carbon.withNode("py-docker && npm-deploy") {
        carbon.withDeploymentStage("Client") {
            py "build.py --build ./ --vars-file envs/client/deployment.vars --deploy-npm"
        }
    }
}
