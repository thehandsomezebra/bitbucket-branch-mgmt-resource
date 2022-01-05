# xxx=$(get_option '.xxxx')

from_branch=$(get_option '.from_branch')
to_branch=$(get_option '.to_branch')
reponame=$(get_option '.reponame')
repoproject=$(get_option '.repoproject')

#the below are optional.. see how it handles not set?
reviewers=$(get_option '.reviewers')
pr_title=$(get_option '.pr_title')
pr_description=$(get_option '.pr_description')
delete_if_no_changes=$(get_option '.delete_if_no_changes')

# These two vars were set from the resource via `out`
# bitbucket_url
# access_token

echo "$to_branch"
echo "Oh look, it made it here."
##############################

# assemble the url... adjust it if it's user vs project...
if [[ $repoproject == *"~"* ]]; then
  user_url=$(echo "$repoproject" | awk '{print tolower($0)}' | sed 's/^\~//')
  url_part="users/$user_url/repos/$reponame"
else
  url_part="projects/$repoproject/repos/$reponame"
fi
api_url=$(echo ${bitbucket_url}"rest/api/1.0/"${url_part}"/pull-requests")

if [ ! -z $reviewers ]; then
  echo "Adding reviewers: $reviewers"

  tempDir=$(mktemp -dt "$(basename $0)-XXXXXXXXXX")

  reviewers_ready=' "reviewers": ['
  echo $reviewers | jq -r '.[] ' |
    while IFS=$'\n' read -r user; do
      userblock="{\"user\": {\"name\": \"$user\"}}"
      echo "$userblock, " >>$tempDir/userblock.txt
    done
  #grab all that we set
  reviewers_set=$(cat $tempDir/userblock.txt)
  #remove the last comma and space
  reviewers_set=$(echo "${reviewers_set%??}")
  reviewers_ready="$reviewers_ready $reviewers_set ],"

else
  reviewers_ready=""
fi

pr_title="PR via Concourse"
now=$(date)
pr_description="PR submitted $now"

#assemble the post data
generate_post_data() {
  cat <<EOF
{
  "title": "$pr_title",
  "description": "$pr_description",
  "state": "OPEN",
  "open": true,
  "closed": false,
  "fromRef": {
    "id": "refs/heads/$from_branch",
    "repository": {
      "slug": "$reponame",
      "name": "$reponame",
      "project": {
        "key": "$repoproject"
      }
    }
  },
  ${reviewers_ready}
  "toRef": {
    "id": "refs/heads/${pr_branch}",
    "displayId": "$pr_branch",
    "repository": {
      "slug": "$reponame",
      "name": "$reponame",
      "project": {
        "key": "$repoproject"
      }
    }
  }
}
EOF
}

# echo $(generate_post_data)

## make a pull request

curl -H "Authorization: Bearer ${access_token}" \
  $api_url \
  --request POST --header 'Content-Type: application/json' \
  --data "$(generate_post_data)" | jq '.' >response.json

cat response.json | jq '.[][].message' &>/dev/null
if [ $? -eq 0 ]; then
  #this will be an error message
  message=$(cat response.json | jq '.[][].message')
  echo $message
  if [[ $message == *"already up-to-date"* ]]; then
    echo "No changes!"

    #################### IF THE DELETE FLAG IS ON:  delete_if_no_changes #######
    echo "Cleaning up unnecessary branch..."
    #assemble the delete url
    if [[ $repoproject == *"~"* ]]; then
      user_url=$(echo "$repoproject" | awk '{print toupper($0)}')
      url_part="projects/$user_url/repos/$reponame"
    else
      url_part="projects/$repoproject/repos/$reponame"
    fi
    delete_url=$(echo ${bitbucket_url}"rest/branch-utils/latest/"${url_part}"/branches")
    echo $delete_url
    #assemble the post deletion data

    generate_post_data_for_delete() {
      cat <<EOF
 {
   "name": "$from_branch"
   }
EOF
    }

    curl -H "Authorization: Bearer ${access_token}" \
      $delete_url \
      --request DELETE --header 'Content-Type: application/json' \
      --data "$(generate_post_data_for_delete)"
    echo "Concourse branch has been removed."
    ##############################################

  elif
    [[ $message == *"Only one pull request may be open for a given source and target branch"* ]]
  then
    echo "Please view the pull request that already exists at ${bitbucket_url}${url_part}/pull-requests/"
  else
    echo "Something went wrong, please review the above message."
  fi
else
  pr_id=$(cat response.json | jq '.id')
  echo "=========================================================================="
  echo "New pull request at ${bitbucket_url}${url_part}/pull-requests/${pr_id}/overview"
  echo "=========================================================================="
fi
