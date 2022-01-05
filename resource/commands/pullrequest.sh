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
##############################

# assemble the url... adjust it if it's user vs project...
if [[ $repoproject == *"~"* ]]; then
  user_url=$(echo "$repoproject" | awk '{print tolower($0)}' | sed 's/^\~//')
  url_part="users/$user_url/repos/$reponame"
else
  url_part="projects/$repoproject/repos/$reponame"
fi
api_url=$(echo ${bitbucket_url}"rest/api/1.0/"${url_part}"/pull-requests")

if [ ! -z "$reviewers" ]; then
  # echo "Adding reviewers: $reviewers"
  tempDir=$(mktemp -dt "$(basename $0)-XXXXXXXXXX")

  reviewers_ready=' "reviewers": ['
  echo $reviewers | jq -r '.[] ' |
    while IFS=$'\n' read -r user; do
      userblock="{\"user\": {\"name\": \"$user\"}}"
      echo "$userblock, " >>$tempDir/userblock.txt
    done
  #grab all users set
  reviewers_set=$(cat $tempDir/userblock.txt)
  #remove the last comma and space
  reviewers_set=$(echo "${reviewers_set%??}")
  reviewers_ready="$reviewers_ready $reviewers_set ],"

else
  reviewers_ready=""
fi

if [ -z "$pr_description" ]; then
  pr_description="PR submitted $(echo $(date))"
fi

if [ -z "$pr_title" ]; then
  pr_title="PR via Concourse"
fi

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
    "id": "refs/heads/${to_branch}",
    "displayId": "$to_branch",
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
# echo "Sending the above request to this url: $api_url "

## make a pull request
curl --silent -H "Authorization: Bearer ${access_token}" \
  $api_url \
  --request POST --header 'Content-Type: application/json' \
  --data "$(generate_post_data)" | jq '.' >response.json

if cat response.json | grep -q '"message":'; then
  #If `"message":` is populated.. it's an error.
  message=$(cat response.json | jq '.[][].message')
  color::boldblue "=========================================================================="
  echo $message
  case $message in
  *"already up-to-date"*)
    color::boldyellow "No changes!"
    echo $delete_if_no_changes
    if [[ $delete_if_no_changes == "true" ]]; then
      echo "delete_if_no_changes flag is set to true via the pipeline."
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
      #     #assemble the post deletion data

      generate_post_data_for_delete() {
        cat <<EOF
{  "name": "$from_branch" }
EOF
      }
      # echo $(generate_post_data_for_delete)
      curl --silent -H "Authorization: Bearer ${access_token}" \
        $delete_url \
        --request DELETE --header 'Content-Type: application/json' \
        --data "$(generate_post_data_for_delete)"
      color::boldyellow "Concourse has removed the branch."
    fi
    color::boldblue "=========================================================================="
    ;;

  *"Only one pull request may be open for a given source and target branch"*)
    echo "--------------------------------------------------------------------------"
    color::boldyellow "Please view the pull request that already exists at ${bitbucket_url}${url_part}/pull-requests/"
    color::boldblue "=========================================================================="
    ;;
  *)
    echo "--------------------------------------------------------------------------"
    color::boldred "Something went wrong, please review the above message."
    color::boldblue "=========================================================================="
    ;;
  esac

else
  pr_id=$(cat response.json | jq '.id')
  color::boldgreen "=========================================================================="
  color::boldgreen "New pull request at ${bitbucket_url}${url_part}/pull-requests/${pr_id}/overview"
  color::boldgreen "=========================================================================="
fi
