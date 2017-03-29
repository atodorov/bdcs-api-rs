cargo_update:
#	gem install hub
#	cargo update && cargo test && git pull-request -b atodorov/bdcs-api-rs:master -m "Update cargo dependencies"
	git config --global user.email "atodorov@redhat.com"
	git config --global user.name "Alexander Todorov"
	git remote add authenticated https://atodorov:$(GITHUB_TOKEN)@github.com/atodorov/bdcs-api-rs.git
	cargo update && git commit -a -m "Auto-update crates" && git push authenticated && ./open-pr
