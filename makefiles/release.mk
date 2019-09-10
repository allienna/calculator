CHANGELOG=./CHANGELOG.md
COMMIT_ID=`git rev-parse --short HEAD`
GIT_BRANCH := $(or ${GIT_BRANCH},$(shell git rev-parse --abbrev-ref HEAD))

.PHONY: release
release: ## release a version or bump dev version
	@echo "+ $@"
ifeq ($(GIT_BRANCH),master)
	$(MAKE) .release
else
	@$(MAKE) .bump-version
endif

.PHONY: .release
.release: .pre-release
	@echo "+ $@"
ifeq (,$(wildcard $(CHANGELOG)))
	@$(MAKE) .first-release
else
	@$(MAKE) .generate-release
endif

.PHONY: .pre-release
.pre-release:
	@echo "+ $@"
	@npm init --force --silent > /dev/null

.PHONY: .first-release
.first-release:
	@echo "+ $@"
	@standard-version --first-release;
	@echo '1.0.0' > VERSION;

.PHONY: .generate-release
.generate-release:
	@echo "+ $@"
	@sed -ri '/version/s/(")[[:digit:].]*"/'"\1`cat VERSION`\1/g" package.json
	@standard-version
	@grep '"version":' package.json | cut -d\" -f4 > VERSION

.PHONY: .bump-version
.bump-version: ## bump-version description
	@echo "+ $@"
	@sed -i "s#\$$#-$(GIT_BRANCH)-$(COMMIT_ID)#; s#/#-#" VERSION
	@cat VERSION

.PHONY: commit-and-push-release
commit-and-push-release: ## commit CHANGELOG and commit/push current version
	@echo "+ $@"
ifeq ($(GIT_BRANCH),master)
	@git add CHANGELOG.md VERSION
	@git commit -m "chore(release): `cat VERSION`"
	@git push --follow-tags origin $(GIT_BRANCH)
endif

.PHONY: check-last-commit
check-last-commit: ## validate that the last commit is not a release
	@echo "+ $@"
	@git log -1 --pretty=%s | grep -qv "chore(release): "