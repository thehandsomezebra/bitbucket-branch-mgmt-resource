# BitBucket Branch Management Resource Type

A resource type to do some branch management in a repo via concourse.

Currently, it will do a PR for two existing branches.

---

## Notes and Usage

- Both the `to` and `from` PR branches must already exist!
- A token for a BitBucket user is required: Service accounts are recommended. (see Service Account section below)
- You may use a repo in a project OR a repo that belongs to a user. The BitBucket user mentioned above MUST have access to it.
- Other recommendations I would give you would be to use the [built-in Concourse Git Resource Type](https://github.com/concourse/git-resource).  Read up on that.  You can use the `put` to push local commits to the repo.
- Be mindful when you accept the PRs... you may want to put delete protection on it.. because if the branch doesn't exist anymore, your pipeline won't function.
- Also, if you aren't keeping your branches in step - you are VERY likely to run into conflicts. (A later update to this resource type may help).


---

## Service Account

- I recommend that you set up a Service Account user in BitBucket for these actions. Once created, set up a token. That will be the token you will use as a var in the pipeline.
- Additional setup for granting the service user access to your project/repo is REQUIRED. Please do that: otherwise, you will not be able to use this pipeline resource tool successfully.
- If you do not know how to do the above steps, please consult someone on your team... I will not be able to assist you with those steps.

---

# Variables

| Variable         | Req/Opt  | Location            | Description                                                                                                                                                                                                             |
| ---------------- | -------- | ------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| from_branch | Required | Jobs block (in put) | The name of the branch that Concourse will be making the PR from. This branch MUST already exist.                                                                                                                        |
| to_branch    | Required | Jobs block (in put) | The name of the branch that Concourse will be making the PR into. This branch MUST already exist.                                                                                                                       |
| reponame         | Required | Jobs block (in put) | The name of the repo that both branches reside in.                                                                                                                                                                      |
| title            | Optional | Jobs block (in put) | You may populate a custom title for your PR. _Default will say "PR via Concourse"_                                                                                                                                      |
| description      | Optional | Jobs block (in put) | You may populate a custom title for your PR. _Default will say "PR submitted --timestamp-- ."_                                                                                                                            |
| repoproject      | Required | Jobs block (in put) | The name of the project that the repo resides in. If you are using this for a USER account, please note it as `~USERNAME` (keep the tilde).                                                                             |
| reviewers        | Optional | Jobs block (in put) | If you would like to automatically add reviewers, you may add them here as an array. The reviewers MUST exist, MUST have permissions for that project, and MUST have permissions for that repo. If that is not possible |
| bitbucket_url    | Required | Resource block      | This is the URL for your BitBucket.                                                                                                                                                                                     |
| token            | Required | Resource block      | The token for the service user.                                                                                                                                                                                         |

---

# Usage

## PUT command will make a PR.

```yml
jobs:
  - name: bitbucket_actions
    plan:
      - put: pullrequest
        resource: bitbucket
        params:
          from_branch: "concourse/branch_with_changes"
          to_branch: "main"
          reponame: "cool-repo"
          repoproject: "PROJECT"
          reviewers:
            - "user1"
            - "user2"
            - "user3"
```

---

```yml
resources:
  - name: bitbucket
    icon: cloud
    type: bitbucket-pr-resource
    source:
      bitbucket_url: "https://bitbucket.company.com/"
      token: (( vault "secret/concourse/devops_account:token" ))
```

> note, that I choose to store my secrets in vault, and I employ the use of [spruce](https://github.com/geofffranks/spruce) to implement my secrets. Please do not expose your secrets!

---

```yml
resource_types:
  - name: bitbucket-pr-resource
    type: registry-image
    source:
      repository: thehandsomezebra/bitbucket-pr-resource
      tag: latest
```

---

### Planned later improvements:

- Another resource type to CREATE the branch.
