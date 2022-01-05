# xxx=$(get_option '.xxxx')
new_branch=$(get_option '.new_branch')
from_branch=$(get_option '.from_branch')
reponame=$(get_option '.reponame')
repoproject=$(get_option '.repoproject')

# These two vars were set from the resource via `out`
# bitbucket_url
# access_token
##############################


#assemble the url... adjust it if it's user vs project...
if [[ $repoproject == *"~"* ]]; then
  user_url=$(echo "$repoproject" | awk '{print tolower($0)}' | sed 's/^\~//')
  url_part="users/$user_url/repos/$reponame"
else
  url_part="projects/$repoproject/repos/$reponame"
fi
api_url=$(echo ${bitbucket_url}"rest/api/1.0/"${url_part}"/branches")

##########KEEPTHISBLOCK##################
branchFrom="refs/heads/$from_branch"
branchQuery=$(curl --silent --header 'Content-Type: application/json' -H "Authorization: Bearer ${access_token}" $api_url)
branchCheck=$(echo $branchQuery | jq -r --arg new_branch "$new_branch" '.values[] | select(.displayId==$new_branch)')
###########KEEPTHISBLOCK#################

##check if branch exists
if [ -z "$branchCheck" ]; then
  # echo "Branch does not exist. Creating new branch named $new_branch"
  #assemble the post data
  generate_post_data() {
    cat <<EOF
{
  "name": "$new_branch",
  "startPoint": "$branchFrom"
}
EOF
  }

  ## make the branch
  curl --silent -H "Authorization: Bearer ${access_token}" \
    $api_url \
    --request POST --header 'Content-Type: application/json' \
    --data "$(generate_post_data)" | jq '.' >response.json

  outputCheck=$(cat response.json | jq -r '.displayId')

  if [ "$outputCheck" = "$new_branch" ]; then
    color::boldgreen "=========================================================================="
    color::boldgreen "Branch $new_branch successfully created."
    color::boldgreen "=========================================================================="
  else
    color::boldred "=========================================================================="
    color::boldred "Branch did not exist; Concourse encountered an error creating new branch $new_branch."
    color::boldred "=========================================================================="
    exit 1
  fi

else
  color::boldblue "=========================================================================="
  color::boldyellow "Branch already exists."
  color::boldblue "=========================================================================="
fi
