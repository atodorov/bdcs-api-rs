cargo_update:
#	gem install hub
#	cargo update && cargo test && git pull-request -b atodorov/bdcs-api-rs:master -m "Update cargo dependencies"
	cargo update && git commit -a -m "Auto-update crates" && git push