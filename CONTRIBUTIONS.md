# Contribution processes

Let's take a look to the contribution process.

Generally this solution is contributed in ADO organization by adding changes and repacking of the bootstrap artifact.
But here some possibilities to provide changes from GitHub.

## Repositories changes

Any changes to terraform code, yml pipelines and etc. Could be done in appropriated folders.
In **_bootstrap-artifact_** folder are projects under which is located repositories with `repo_` prefix. 
Here you can find repositories code base which could be updated.

With `wiki_` prefix is documentation repository.

## Changes in projects set up

Any changes to projects importing process (updating/adding variables groups, pipelines, envinroments, repositories).
This changes could be done in `snapshot.json` files under each project.

## Task entity properties

Any task entity shall be described in details as separate issue. If the task has its subtasks - they can be described in the "parent" issue or as separate issues but linked with their "parent".

General task entity properties:

1. _Type_. Defines the "background" of the task. There are two main task types:
    - **`enhancement`** - for description of new features that shall be added to the Cloud Pipeline functionality
    - **`bug`** - for description bugs/errors found during the Cloud Pipeline usage
2. _Description_. Contains the task description, requirements to implement, technical details, additional data
3. _Assignee(s)_. Defines member(s) of the development team who should implement the functionality described in the task
4. _Label(s)_. Optional properties that can define additional different task attributes - priority/project/state etc. These labels are optional, but could be convenient - e.g., for searching or sorting the tasks

### Task formulation

This process is fundamental, from which the task development begins.  
It includes the preparation and writing of the task description and setting of task properties.

_Enhancement_ issue description shall contain, at least:

- title
- clear and detailed description of the task/problem/feature that shall be implemented
- (_if necessary_) technical details of the implementation approach for the development team
- (_if necessary_) images or other documents to clearify the task

_Bug_ issue description shall contain, at least:

- title
- clear and detailed description of what works incorrect and should be fixed
- (_if necessary_) images or other documents to clearify the problem

For any task, should be set the _assignee(s)_ - to define specific member(s) of the development team who will perform the development of that task.

Additionally for the task, labels can be set - for specifying the general version of the **`Cloud Pipeline`**, priority of the task, area of the Platform to which the task belongs, etc.

### Development

Before pushing any new changes it is need to be sure that all pipelines and processes still work as expected.
Don't forget that after bootstrap.ps1 was run at once it already replaced content in all file, so don't push artifact to Github after its running. For testing propose make a copy of prepaired bootstrap folder.
