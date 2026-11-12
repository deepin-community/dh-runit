all:
check:
	./testrunner.sh
autopkgtest:
	AUTOPKGTEST=1 ./testrunner.sh
.PHONY: check
