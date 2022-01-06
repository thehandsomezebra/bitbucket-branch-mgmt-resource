## install tf docs
mkdir tmp
curl -Lo tmp/terraform-docs.tar.gz https://github.com/terraform-docs/terraform-docs/releases/download/v0.16.0/terraform-docs-v0.16.0-$(uname)-amd64.tar.gz
tar -xzf tmp/terraform-docs.tar.gz -C tmp/
chmod +x tmp/terraform-docs

## Run tf docs
repo=`pwd`
paths=$(tree ${repo} -fdi --noreport)

while IFS= read -r path
do
  list=$(ls -1 ${path})
  terraform=0
  while IFS= read -r file
  do
    if [[ "${file}" == *".tf" ]]; then
      terraform=1
    fi
  done <<< ${list}
  if [[ "${terraform}" -eq 1 ]]; then
    ./tmp/terraform-docs markdown table ${path} --output-file README.md
  fi
done <<< "${paths}"

#### clean up the tf docs files we unzipped and used.
rm -rf tmp/

#done.  The rest of the pipeline will commit the changes.
############################################################