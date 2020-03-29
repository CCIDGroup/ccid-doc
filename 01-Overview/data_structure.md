# Data Structure

Yaml的结构，用来在CI CD的过程中标记和解析数据，定义工作流等



## Pipeline

pipeline表示依次CICD活动，可以只有CI，只有CD，表示的一次特定的场景，一次特定的处理，比如：

* 前端编译
* 前端部署
* 后端编译
* 后端部署

pipeline的结构如下：

```yaml
Pipeline
  Stage A
    Job 1
    Step 1.1
    Step 1.2
    ...
    Job 2
    Step 2.1
    Step 2.2
  ...
  Stage B
  ...
```

pipeline 由stage组成，熟悉gitlab的开发同学可以理解stage，stage表示一次编译部署过程，例如上面提到的<span style="color:red;font-weight:bold">后端编译</span>可能包括如下几个步骤，每个步骤可以是上面的Stage A B C

* 获取代码
* testing
* building

job就是一系列的线性执行的步骤，比如上面的<span style="color:red">building</span> stage 的过程，可能执行很多次操作，这里以编译一次.NET Core 代码为例

* dotnet --version
* dotnet run build -- build代码
* package 代码到zip 包
* 上传代码到artifacts 目录

上面都是线性执行的步骤，所有步骤加起来叫做一个job

简单的一个pipeline

```yaml
name: string  # build numbering format
variables: # several syntaxes, see specific section
trigger: trigger
#pr: pr # not support
stages: [ stage ]
```

下面是一些内置的可以调用的变量

```yaml
resources.pipeline.<Alias>.pipelineName
resources.pipeline.<Alias>.pipelineID
resources.pipeline.<Alias>.runName
resources.pipeline.<Alias>.runID
resources.pipeline.<Alias>.runURI
resources.pipeline.<Alias>.sourceBranch
resources.pipeline.<Alias>.sourceCommit
#resources.pipeline.<Alias>.sourceProvider
#resources.pipeline.<Alias>.requestedFor
#resources.pipeline.<Alias>.requestedForID
```



## Stage

Pipeline 包含一组顺序执行的stage

```yaml
stages:
- stage: string  # name of the stage (A-Z, a-z, 0-9, and underscore)
  displayName: string  # friendly name to display in the UI
  container: [ container ]
  repositories: [ repository ]
  #dependsOn: string | [ string ] # not support
  #condition: string # not support
  variables: # several syntaxes, see specific section
  jobs: [ job ]
```



## Job

Job就是一系列具体步骤的执行，在一个node上，job也是顺序执行的

```yaml
jobs:
- job: string  # name of the job (A-Z, a-z, 0-9, and underscore)
  displayName: string  # friendly name to display in the UI
  #dependsOn: string | [ string ] # not support
  #condition: string # not support
  #strategy: #not support
    #parallel: # parallel strategy; see the following "Parallel" topic
    #matrix: # matrix strategy; see the following "Matrix" topic
    #maxParallel: number # maximum number of matrix jobs to run simultaneously
  #continueOnError: boolean  # 'true' if future jobs should run even if this job fails; defaults to 'false' # not support
  #pool: pool # see the following "Pool" schema
  #workspace: #not support
    #clean: outputs | resources | all # what to clean up before the job runs
  container: containerReference # container to run this job inside of
  timeoutInMinutes: number # how long to run the job before automatically cancelling
  cancelTimeoutInMinutes: number # how much time to give 'run always even if cancelled tasks' before killing them
  variables: # several syntaxes, see specific section
  steps: [ script ] # cmd | pwsh | powershell | checkout | task | templateReference 
  #services: { string: string | container } # container resources to run as a service container
```

### Container

```yaml
container:
  image: string  # container image name
  options: string  # arguments to pass to container at startup
  endpoint: string  # endpoint for a private container registry
  options: string  # arguments to pass to container at startup
  env: { string: string }  # list of environment variables to add
  ports: [ string ] # ports to expose on the container
  volumes: [ string ] # volumes to mount on the container
  mapDockerSocket: bool # whether to map in the Docker daemon socket; defaults to true
  #env: { string: string }  # list of environment variables to add
```

```yaml
jobs:
- job: RunsInContainer
    container:
      image: my_service:tag
      ports:
      - 8080:80 # bind container port 80 to 8080 on the host machine
      - 6379 # bind container port 6379 to a random available port on the host machine
      volumes:
      - /src/dir:/dst/dir # mount /src/dir on the host into /dst/dir in the container
      options: --hostname container-test --ip 192.168.0.1
```

## Repository

```yaml
repository:   # identifier (A-Z, a-z, 0-9, and underscore)
    type: github/gitea  # currently only support github/gitea type
    name: string  # repository name (format depends on `type`)
    ref: string  # ref name to use; defaults to 'refs/heads/master'
    endpoint: string  # name of the service connection to use (for types that aren't Azure Repos)
```

```yaml
repository: 
    type: github
    name: Contoso/CommonTools
    endpoint: MyContosoServiceConnection
```

### Trigger

目前支持两种Trigger

* Push trigger
* Pull request trigger

#### Push trigger

push trigger 是指当一个git branch被提交代码的时候自动触发CI过程的操作，必填项

```yaml
trigger: [ string ] # list of branch names
------
trigger:
- master
- develop
```

#### PR trigger

pull request trigger 是指当在某个分之上有pull request的时候执行的操作

```yaml
pr: [ string ] # list of branch names
------
pr:
- master
- develop
```

## Steps

Steps 是一组线性操作以构成一个job，每个step在container中运行自己的脚本，并且可以访问workspace

```yaml
steps: [ script ]
------
steps:
- script: echo This runs in the default shell on any machine
```

## Variables

variables使用一组键值对的形式定义变量，定义完成后可以在yaml中引用

```yaml
variables:
- name: string  # name of a variable
  value: string # value of the variable
------
variables:      # pipeline-level
  MY_VAR: 'my value'
  ANOTHER_VAR: 'another value'

stages:
- stage: Build
  variables:    # stage-level
    STAGE_VAR: 'that happened'

  jobs:
  - job: FirstJob
    variables:  # job-level
      JOB_VAR: 'a job var'
    steps:
    - script: echo $(MY_VAR) $(STAGE_VAR) $(JOB_VAR)
```

同名情况下本级的variable会覆盖上一级variable



## Script

script关键字表示在脚本执行的时候使用的terminal工具，默认使用的是bash

```yaml
steps:
- script: echo Hello world!
  displayName: Say hello
```

## Publish

其实比较纠结到底要不要将Publish加入进来，在这里Publish是要指定将编译出来的file上传到供其他task消费

```yaml
steps:
- publish: string # path to a file or folder
  artifact: string # artifact name
```

## Download

Download关键字对应Publish，上一个步骤将artifact生成后这一个步骤进行下载

```yaml
steps:
- download: [ current | pipeline resource identifier ] # disable automatic download if "none"
  artifact: string ## artifact name, optional; downloads all the available artifacts if not specified
  #patterns: string # patterns representing files to include; optional
```

