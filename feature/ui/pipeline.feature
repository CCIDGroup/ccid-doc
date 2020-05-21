Feature: Pipelines

    Create and manage all pipelines

    Scenario: Show pipelines
        Given Open Pipelines within the project
        When Click the tabpage recent
        Then Show recenttly run pipelines

    Scenario: Show all pipelines
        Given Click the tabpage All
        Then Show all pipelines folders
        And Show all pipelines

    Scenario: Show pipeline run history list
        Given Click the tabpage run
        Then Show all pipeline running history list
        And Include build, stage and running time information

    Scenario: Pipeline detail result
        Given CLick one of the run history item
        Then Show pipeline running summary
        And Include basic information and publish artifact


