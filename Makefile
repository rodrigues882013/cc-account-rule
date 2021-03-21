.PHONY: test

FILE_NAME="input"

run: build
	@docker run -i ccaccountrule:latest ccaccountrule -t < $(FILE_NAME)

test: build
	@docker run -e MIX_ENV=test ccaccountrule mix test

build:
	@docker build -t ccaccountrule:latest .

