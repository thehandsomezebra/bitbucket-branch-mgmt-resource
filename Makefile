default: docker

docker:
	docker build -t thehandsomezebra/bitbucket-branch-mgmt-resource .
	docker push thehandsomezebra/bitbucket-branch-mgmt-resource
