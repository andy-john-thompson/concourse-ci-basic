## Overview
* A simple concourse-ci pipeline example.
* This pipeline has 1 job, and the job contains 2 tasks.
* Output from task 1 is passed into task 2
* This code is reliant on access to pull this Git Repo being present (see the uri coded in the `git_scm_resource` block in the `pipeline.yml` file)

### Start local concourse
See concourse quick start guide for detailed notes on setting up a concourse server
* `docker-compose up -d`

### Use fly CLI to connect and set the target name
Target name set as `my_concourse_server`:
* `fly -t my_concourse_server login -c http://localhost:8090 -u test -p test`

### Create the pipeline on the Concourse server
It would be nicer if you could just configure the Concourse server to the location in the Github repo, however you have to manually set the pipeline on the Concourse server (and rerun this command if the pipeline yaml is changed)
`fly --target my_concourse_server set-pipeline --config "examples/pipeline_basic_1/pipeline/pipeline.yml" -p "my-test-pipeline"`


### Run the pipeline
* You can now run the pipeline through the concourse server UI.
* Additionally, the pipeline.yml file has `trigger: true` set for the git repo used by the job, therefore any changes to the master branch of the git repo will also trigger the job to execute.


### Manually trigger jobs
You can manually trigger a job to run using the following syntax
* `fly --target <your_target> trigger-job -j <your-pipeline-name>/<job_name>`
* EG `fly --target my_concourse_server trigger-job -j my-test-pipeline/job-compile-code`

### Manually trigger tasks
You can manually trigger the tasks to run individually by specifying the input required in the command line arguments. For example, to triggr a run of task 1, you need to specify the `git_scm_resource` location (i.e. the git folder)
* `fly --target my_concourse_server execute --config examples/pipeline_basic_1/tasks/task_1.yml -i git_scm_resource="."`

### Close
* logout of fly
  * `fly logout --target my_concourse_server`
  * (or `fly logout --all`)
* stop local Concourse service
  * `docker-compose down`