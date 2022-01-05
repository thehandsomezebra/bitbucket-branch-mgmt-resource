# Examples

Please view the [pipeline](pipeline.yml) and the [run_this_script.sh](run_this_script.sh) example.

In this case, the workflow of this pipeline works as follows:

1. Create a branch called `testing` from the `main` branch in `my-cool-repo`.
2. Clone down the `my-cool-repo` at the `testing` branch and run a script.
3. `run_this_script.sh` will create a new txt document in the root of my repo with some random numbers in it, and name it with some random numbers.
4. Add, commit, and push the changes up to the branch `testing`.
5. Submit a Pull Request from `testing` back to `main`, adding `username1` and `username2` as reviewers.


You can use the example to your needs, customizing your own script, commit messages, adding reviewers to your pull request, and more.


I highly recommend returning to the [README](../README.md) at the root of this repo to learn more.

Thanks!