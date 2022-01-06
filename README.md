# BitBucket Branch Management Resource Type

A resource type to do some branch management in a repo via concourse.

Please look in the [examples](examples/README.md) to understand how you could use this.

This resource type has three commands:

- [Make a new branch](#make-a-new-branch)
- [Pull, Make a change via script, Push](#pull-make-a-change-via-script-push)
- [Pull Requests](#pull-requests)

---

## Notes and Usage

- A token for a BitBucket user is required: Service accounts are recommended. (see Service Account section below)
- You may use a repo in a project OR a repo that belongs to a user. The BitBucket user mentioned above MUST have access to it.
- Other recommendations I would give you would be to use the [built-in Concourse Git Resource Type](https://github.com/concourse/git-resource). Read up on that. You can use the `put` to push local commits to the repo.
- Anytime I mention `projectname` -- I am meaning the PROJECT KEY.  So if your project is named `Cool Team` but the key is just `COOL`...then please provide `COOL`.
  - If you don't know what the key is, check the URL and provide that.

---

> This was created and tested using Atlassian Bitbucket Server v6.7.2.

> It takes advantage of `rest/api/1.0` calls.

> If you are not using the same version that I am, or if your BitBucket admin has certain features limited/turned off -- **please note that your mileage may vary.**

---

### Additional notes on a Service Account User

- I recommend that you set up a Service Account user in BitBucket for these actions. Once created, set up a token. That will be the token you will use as a var in the pipeline.
- Additional setup for granting the service user access to your project/repo is REQUIRED. Please do that: otherwise, you will not be able to use this pipeline resource tool successfully.
  -In the example below, you will see that I choose to store my secrets in vault, and I employ the use of [spruce](https://github.com/geofffranks/spruce) to implement my secrets. Please do not expose your secrets!
- If you do not know how to do the above steps, please consult someone on your team... I will not be able to assist you with those steps.

---

# Usage

---

```yml
resource_types:
  - name: bitbucket-branch-mgmt-resource
    type: registry-image
    source:
      repository: thehandsomezebra/bitbucket-branch-mgmt-resource
      tag: latest
```

---

```yml
resources:
  - name: bitbucket
    icon: cog
    type: bitbucket-branch-mgmt-resource
    source:
      bitbucket_url: "https://bitbucket.company.com/"
      access_token: (( vault "secret/concourse/devops_account:token" ))
```

| Variable      | Req/Opt  | Description                         |
| ------------- | -------- | ----------------------------------- |
| bitbucket_url | Required | This is the URL for your BitBucket. |
| access_token  | Required | The token for the service user.     |

---

## Make a new branch

```yml
jobs:
  - name: bitbucket_actions
    plan:
      - put: lets-make-a-new-branch
        resource: bitbucket
        params:
          command: makebranch
          new_branch: "the_new_branch"
          from_branch: "main"
          reponame: "cool-repo"
          repoproject: "PROJECT"
```

| Variable    | Req/Opt  | Description                                                                                                                                 |
| ----------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| command     | Required | For a PR, please choose `makebranch`.                                                                                                       |
| new_branch  | Required | The name of the branch that Concourse will create for you.                                                                                  |
| from_branch | Required | Concourse will create the new branch from this branch.                                                                                      |
| reponame    | Required | The name of the repo.                                                                                                                       |
| repoproject | Required | The name of the project that the repo resides in. If you are using this for a USER account, please note it as `~USERNAME` (keep the tilde). |

---

## Pull, Make a change via script, Push

- Retrive a script via `- get: <resource>`
  - The `<resource>` has been tested to work using the [built-in Concourse Git Resource Type](https://github.com/concourse/git-resource).
- The script you run here should...
  - be provided in your own repo as an input.
  - be written from the perspective of entering your repo's root.
  - be written for Ubuntu Linux via `*.sh` file... The base image provided is small, but not extensive.
    - If you need additional packages, you may need to apt-get install it yourself in your script.
- It does not support Git LFS. (And there are currently zero plans to support it. Sorry.)


```yml
jobs:
  - name: bitbucket_actions
    plan:
      - get: script
      - put: lets-make-a-change
        resource: bitbucket
        params:
          command: pullchangepush
          branch: "the_branch"
          reponame: "cool-repo"
          repoproject: "PROJECT"
          script_file: "script/run_this_script.sh"
          commit_message: "Script made changes" #optional
          committer_email: "user@company.com" #optional
          committer_name: "User Name" #optional
```

| Variable        | Req/Opt  | Description                                                                                                                                 |
| --------------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| command         | Required | For a PR, please choose `pullchangepush`.                                                                                                   |
| branch          | Required | The name of the branch that Concourse will pull, edit via script, and push for you.                                                         |
| script_file     | Required | The `*.sh` script that concourse will run for you.                                                                                          |
| reponame        | Required | The name of the repo.                                                                                                                       |
| repoproject     | Required | The name of the project that the repo resides in. If you are using this for a USER account, please note it as `~USERNAME` (keep the tilde). |
| commit_message  | Optional | If you would like a custom commit message, you can enter it here. Defaults to `Changes created via Concourse`.                              |
| committer_email | Optional | If you would like to customize the committing user's email. Defaults to `pipeline@concourse.com`.                                           |
| committer_name  | Optional | If you would like to customize the committing user's name. Defaults to `Concourse Pipeline`.                                                |

---

## Pull Requests

- To do a PR, both the `to` and `from` PR branches must already exist! (You may want to leverage the `makebranch` command before this one, if your workflow requires you to accept the PRs and delete the branch.)
- Also, if you aren't keeping your branches in step - you are VERY likely to run into conflicts. Just be aware that this is a high possibility.

```yml
jobs:
  - name: bitbucket_actions
    plan:
      - put: lets-make-a-pullrequest
        resource: bitbucket
        params:
          command: pullrequest
          from_branch: "branch_with_changes"
          to_branch: "main"
          reponame: "cool-repo"
          repoproject: "PROJECT"
          pr_title: "Pull request of the day" #optional
          pr_description: "This pull request was generated by concourse." #optional
          reviewers: #optional
            - "user1"
            - "user2"
            - "user3"
          #delete_if_no_changes: true #Optional. Default is `false`. USE AT YOUR OWN RISK!
```

| Variable             | Req/Opt  | Description                                                                                                                                                                                                             |
| -------------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| command              | Required | For a PR, please choose `pullrequest`.                                                                                                                                                                                  |
| from_branch          | Required | The name of the branch that Concourse will be making the PR from. This branch MUST already exist.                                                                                                                       |
| to_branch            | Required | The name of the branch that Concourse will be making the PR into. This branch MUST already exist.                                                                                                                       |
| reponame             | Required | The name of the repo.                                                                                                                                                                                                   |
| repoproject          | Required | The name of the project that the repo resides in. If you are using this for a USER account, please note it as `~USERNAME` (keep the tilde).                                                                             |
| pr_title             | Optional | You may populate a custom title for your PR. _Default: "PR via Concourse"_                                                                                                                                              |
| pr_description       | Optional | You may populate a custom title for your PR. _Default: "PR submitted --timestamp-- ."_                                                                                                                                  |
| reviewers            | Optional | If you would like to automatically add reviewers, you may add them here as an array. The reviewers MUST exist, MUST have permissions for that project, and MUST have permissions for that repo. If that is not possible |
| delete_if_no_changes | Optional | If concourse detects that the `to` and `from` branch has ZERO differences.. delete the branch. This defaults to `false`. **USE THIS FLAG AT YOUR OWN RISK!**                                                            |

---

### Planned later improvements:

- none yet.
