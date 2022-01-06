# Examples


## Example 1

Please view the [example1/pipeline](example1/pipeline.yml) and the [example1/run_this_script.sh](example1/run_this_script.sh) example.

In this case, the workflow of this pipeline works as follows:

1. Create a branch called `testing` from the `main` branch in `my-cool-repo`.
2. Clone down the `my-cool-repo` at the `testing` branch and run a script.
3. `run_this_script.sh` will create a new txt document in the root of my repo with some random numbers in it, and name it with some random numbers.
4. Add, commit, and push the changes up to the branch `testing`.
5. Submit a Pull Request from `testing` back to `main`, adding `username1` and `username2` as reviewers.



# Example 2

Please view the [example2/pipeline](example2/pipeline.yml) and the [example2/tf_docs.sh](example2/tf_docs.sh) example.


The steps for the workflow above are mostly the same, except in this case, we are updating a Terraform Module repo and creating automated TF Docs using [https://terraform-docs.io/](https://terraform-docs.io/).

The workflow works like this:

1. Create a branch called `feature/update-tf-docs` from the `master` branch in `my-tf-module`.
2. Clone down the `my-tf-module` at the `feature/update-tf-docs` branch and run a script.
3. `tf_docs.sh` will do the following..
  - Download the latest terraform-docs into a `tmp/` folder.
  - Grant it `+x` to give it the ability to run.
  - Run thru the paths in your repo to update `README.md` with the automated Terraform Docs.
  - Clean up `tmp/`
4. Add, commit, and push the changes up to the branch `feature/update-tf-docs`.
5. Submit a Pull Request from `feature/update-tf-docs` back to `master`, adding `myusername`, `thatusername`, and `yourusername` as reviewers.



---


You can use the above examples to your needs, customizing your own script, commit messages, adding reviewers to your pull request, and more.


I highly recommend returning to the [README](../README.md) at the root of this repo to learn more.

Thanks!