.PHONY: test

FILE_NAME="input"

run: build
	@docker run -i authorizer:latest authorizer -t < $(FILE_NAME)

test: build
	@docker run -e MIX_ENV=test authorizer mix test

build:
	@docker build -t authorizer:latest .

