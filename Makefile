default: docker

docker:
	docker build -t thehandsomezebra/bitbucket-branch-mgmt-resource .
	docker push thehandsomezebra/bitbucket-branch-mgmt-resource

git:
	git add . && git commit -m 'quickly updating repo during initial build and testing' && git push
