# Authorizer

A simple case of study about authorizations operation in bank or credit accounts scenario

## Considerations

I follow some guidelines of clean architecture
https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html by Robert C. Martin, of course
I didn't follow all of them, however I try to take account boundaries and responsibilities in my layers to build
the exercise. I decided to use elixir for simplicity, I've been working with it for one year, and I feel comfortable
to use it in an exercise such that, I decided not use tools that I have more expertise like java and python for try do things
using 100% of functional approach.

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
