# BitBucket Branch Management Resource Type

A resource type to do some branch management in a repo via concourse.

Currently, it will do a PR for two existing branches.

---

## Notes and Usage

- To do a PR, both the `to` and `from` PR branches must already exist!
- A token for a BitBucket user is required: Service accounts are recommended. (see Service Account section below)
- You may use a repo in a project OR a repo that belongs to a user. The BitBucket user mentioned above MUST have access to it.
- Other recommendations I would give you would be to use the [built-in Concourse Git Resource Type](https://github.com/concourse/git-resource). Read up on that. You can use the `put` to push local commits to the repo.
- Be mindful when you accept the PRs... you may want to put delete protection on it.. because if the branch doesn't exist anymore, your pipeline won't function.
- Also, if you aren't keeping your branches in step - you are VERY likely to run into conflicts. (A later update to this resource type may help).

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

# Variables

                                                           |

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
    icon: cloud
    type: bitbucket-branch-mgmt-resource
    source:
      bitbucket_url: "https://bitbucket.company.com/"
      access_token: (( vault "secret/concourse/devops_account:token" ))
```

| Variable      | Req/Opt  | Location       | Description                         |
| ------------- | -------- | -------------- | ----------------------------------- |
| bitbucket_url | Required | Resource block | This is the URL for your BitBucket. |
| access_token  | Required | Resource block | The token for the service user.     |

---

## This PUT command will make a PR.

```yml
jobs:
  - name: bitbucket_actions
    plan:
      - put: lets-make-a-pullrequest
        resource: bitbucket
        params:
          command: pullrequest
          from_branch: "concourse/branch_with_changes"
          to_branch: "main"
          reponame: "cool-repo"
          repoproject: "PROJECT"
          reviewers:
            - "user1"
            - "user2"
            - "user3"
```

| Variable             | Req/Opt  | Location            | Description                                                                                                                                                                                                             |
| -------------------- | -------- | ------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| command              | Required | Jobs block (in put) | Current actions availalable: `pullrequest`. Please see the section of the readme for what you need.                                                                                                                     |
| from_branch          | Required | Jobs block (in put) | The name of the branch that Concourse will be making the PR from. This branch MUST already exist.                                                                                                                       |
| to_branch            | Required | Jobs block (in put) | The name of the branch that Concourse will be making the PR into. This branch MUST already exist.                                                                                                                       |
| reponame             | Required | Jobs block (in put) | The name of the repo that both branches reside in.                                                                                                                                                                      |
| pr_title             | Optional | Jobs block (in put) | You may populate a custom title for your PR. _Default will say "PR via Concourse"_                                                                                                                                      |
| pr_description       | Optional | Jobs block (in put) | You may populate a custom title for your PR. _Default will say "PR submitted --timestamp-- ."_                                                                                                                          |
| repoproject          | Required | Jobs block (in put) | The name of the project that the repo resides in. If you are using this for a USER account, please note it as `~USERNAME` (keep the tilde).                                                                             |
| reviewers            | Optional | Jobs block (in put) | If you would like to automatically add reviewers, you may add them here as an array. The reviewers MUST exist, MUST have permissions for that project, and MUST have permissions for that repo. If that is not possible |
| delete_if_no_changes | Optional | Jobs block (in put) | If concourse detects that the `to` and `from` branch has ZERO differences.. delete the branch. This defaults to `false`. **USE THIS FLAG AT YOUR OWN RISK!**                                                            |

---

### Planned later improvements:

- An additional command to CREATE a branch.
