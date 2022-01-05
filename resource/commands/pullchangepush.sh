# xxx=$(get_option '.xxxx')
branch=$(get_option '.branch')
script_file=$(get_option '.script_file')
reponame=$(get_option '.reponame')
repoproject=$(get_option '.repoproject')
commit_message=$(get_option '.commit_message')
committer_email=$(get_option '.committer_email')
committer_name=$(get_option '.committer_name')

# These two vars were set from the resource via `out`
# bitbucket_url
# access_token
##############################

if [[ $repoproject == *"~"* ]]; then
  user_url=$(echo "$repoproject" | awk '{print tolower($0)}')
  url_part="scm/$user_url/$reponame"
else
  url_part="scm/$repoproject/$reponame"
fi
https_clone_url=$(echo ${bitbucket_url}${url_part}".git")

git clone -b "$branch" -c http.extraHeader="Authorization: Bearer ${access_token}" $https_clone_url
cd $reponame

echo "Now running: $script_file."

source ../$script_file
#

if [ -z "$committer_email" ]; then
  committer_email="pipeline@concourse.com"
fi
git config --global user.email "$committer_email"

if [ -z "$committer_name" ]; then
  committer_name="Concourse Pipeline"
fi
git config --global user.name "$committer_name"

if [ -z "$commit_message" ]; then
  commit_message="Changes created via Concourse"
fi

git config --global user.email "$committer_email"
git config --global user.name "$committer_name"
git add .
git commit -m "$commit_message"
git push
