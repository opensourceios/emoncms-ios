bootstrap:
	carthage bootstrap --platform iOS --no-use-binaries

update:
	carthage update --platform iOS --no-use-binaries
	./scripts/ackack.py
