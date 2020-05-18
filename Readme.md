# Notes on concourse

## Local Setup

### Ran tutorial to set up locally
* https://concoursetutorial.com/
* Used Git Bash
* Altered docker-compose.yml to use port `8090` as I had other service running on Port 8080

```
ports: ["8090:8080"]
...
CONCOURSE_EXTERNAL_URL: http://localhost:8090
```

### start  local Concourse service
* started local Concourse service running in detached mode (`-d`)
  * `docker-compose up -d`

* Concourse will be running at localhost:8090. You can log in with the username/password as test/test

### Install fly (concourse CLI)
* Install fly CLI (local concourse cli) by downloading it from the web UI and target your local Concourse as the test user:
  * _(You may need to manually copy fly.exe onto your PATH)_
  * `fly -t my_concourse_server login -c http://localhost:8090 -u test -p test`
* 1% of tasks that Concourse runs are via `fly execute`. 99% of tasks that Concourse runs are within "pipelines".

### stop  local Concourse service
* `docker-compose down`

## Concourse building blocks
* You configure `jobs` (_containing `tasks`_) and `resources` together into a yaml file to make a `pipeline`
### Overview
* **_pipeline_**
  * `pipelines` are top level block
  * **A pipeline is the result of configuring Jobs and Resources together**

* **_jobs_**
  * A `job` has a single `job.plan`
    * This determines the sequence of steps to execute in the job
    * https://concourse-ci.org/jobs.html
  * `jobs` contain `steps` - https://concourse-ci.org/jobs.html#steps
    * EG run a `task`, fetch/update a git `resource`
  * Although a `pipeline` object will control running a predefined set of `jobs`, you can also run any `jobs` without triggerening the entire `pipeline`
    * EG `fly -t example trigger-job --job my-pipeline/my-job`
    * This will queue a new build of the my-job job in the my-pipeline pipeline.
  * Jobs are independent of each other (eg you cannot pass artifacts between jobs) however jobs can be chained together - see https://concourse-ci.org/manual-trigger-example.html

### Tasks
* The smallest configurable unit in a Concourse pipeline is a single `task`. A task can be thought of as a function from `task.inputs` to `task.outputs` that can either succeed or fail.
* Ideally tasks are pure functions: given the same set of inputs, it should either always succeed with the same outputs or always fail
* `task` configuration
  * provide docker image to be used and steps to run (eg run a shell script)
  * Can provide inputs in the form of files that get mounted into the docker container so are available for the the task to use
  * Example of a task that runs on the busybox docker image, mounts a folder called `task-scripts` into the image (this folder is available before job starts) and then runs a shell script contained in that folder
    ```
    ---
    platform: linux

    image_resource:
      type: docker-image
      source: {repository: busybox}

    inputs:
      - name: task-scripts

    run:
      path: /bin/sh
      args: ["./task-scripts/task_show_uname.sh"]
    ```
* Once you've created your `task`, you can reuse it for a `job` in your `pipeline`.
* You can use the `fly` CLI to run tasks locally on your system, or (more common) you can use the `fly` CLI to push the task to your remote Concourse Server for execution. This is probably best practice as it avoids any issues relating to docker configuration on developers local systems.


* **task outputs**
  * You can specify the name of a task's outputs location - eg
  ```
  outputs:
  - name: some-output
  ...
  ...
  run:
    path: touch
    args: [some-output/my-built-artifact]
  ```
  ...and propagate `my-built-artifact` to any later `task` steps or `put` steps that reference the `some-output` artifact, in the same way that this task had `some-input` as an input.
  * Note that folder names (eg `some-output` in this example) are automatically created by concourse when it runs the task.

### Resources
* Eg local files, Git repo, S3 bucket etc
* You configure `jobs` (containing `tasks`) and `resources` together into a yml file to make a `pipeline`
* https://concourse-ci.org/resources.html

## Triggering jobs
4 ways a job can be triggered
* Clicking the + button on the web UI of a job
* Input resource triggering a job (see below)
* `fly trigger-job -j pipeline/jobname` command
* Sending POST HTTP request to Concourse API

### Triggering jobs with resources
* **Triggered by change to resource**
  You set `trigger: true` to enable a job to be triggered by changes to the resource (remember branch is hardcoded - it's not multibranch!)
  ```
  ---
  resources:
    - name: resource-tutorial
      type: git
      source:
        uri: https://github.com/starkandwayne/concourse-tutorial.git
        branch: develop

  jobs:
    - name: job-hello-world
      public: true
      plan:
        - get: resource-tutorial
          trigger: true
        - task: hello-world
          file: resource-tutorial/tutorials/basic/task-hello-world/task_hello_world.yml
  ```
* **Triggered on time interval**
If you want a job to trigger every few minutes then there is the time resource.
```
resources:
- name: my-timer
  type: time
  source:
    interval: 2m
```

## Secrets
Looks like you need to use vault here (other options are available). Info in tutorial doesn't give example for vault - https://concoursetutorial.com/basics/secret-parameters/

### Areas to consider
* Currently it looks like there is no default support for multibranch pipelines (although this is a work in progress to support this). Therefore you have to ensure you architect your CI/CD model to take this into consideration before any implementation.
* You must use a secrets provider, as secrets passed as variables could be read by a user who can download the yaml files from the Concourse Server
* Some of the resource types look very useful - https://resource-types.concourse-ci.org/
  * Eg Terraform, Artifactory, S3, Git, Github, Slack, K8s
  * Notably there is not an MS Teams resource type shown here