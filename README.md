# CCAccountRule

A simple case of study about authorizations operation in bank or credit accounts scenario

## Execution

```shell script
make run FILE_NAME=<OPTIONAL>
```
Or with the example provided
```shell script
make run 
```

If no file being passed to application it will execute the default input is given in exercise statement

## Tests
```shell script
make test
```
As a design decision all test are at same time integration tests and unit tests
I decided use just function composition to apply operations at initial state
then I just change de entry to validate de output, I did that at all layers, no mock was used, I mean
the only mock was IO.read to provide an entry for tests.
