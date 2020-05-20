## Overview
* A simple concourse-ci pipeline example.
* This pipeline has 3 jobs, 2 of which run in parallel, and one which is only triggered if these 2 parallel jobs pass

### Start local concourse
See concourse quick start guide for detailed notes on setting up a concourse server
* `docker-compose up -d`

### Use fly CLI to connect and set the target name
Target name set as `my_concourse_server`:
* `fly -t my_concourse_server login -c http://localhost:8090 -u test -p test`

### Create the pipeline on the Concourse server
It would be nicer if you could just configure the Concourse server to the location in the Github repo, however you have to manually set the pipeline on the Concourse server (and rerun this command if the pipeline yaml is changed)
`fly --target my_concourse_server set-pipeline --config "examples/pipeline_basic_2/pipeline/pipeline.yml" -p "my-example2-pipeline"`


### Run the pipeline
* You can now run the pipeline through the concourse server UI.
* Additionally, the pipeline.yml file has `trigger: true` set for the git repo used by the job, therefore any changes to the master branch of the git repo will also trigger the job to execute.


### Close
* logout of fly
  * `fly logout --target my_concourse_server`
  * (or `fly logout --all`)
* stop local Concourse service
  * `docker-compose down`