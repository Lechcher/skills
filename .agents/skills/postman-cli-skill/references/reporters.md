# Postman CLI Reporters

Reporters determine how the output of a `collection run` is formatted and saved.

## Supported Reporters
- `cli`: Standard console output (default).
- `json`: Structured JSON output.
- `junit`: Standard JUnit XML format, perfect for CI/CD tools like Jenkins, GitLab CI, and GitHub Actions.

## Syntax
To specify reporters, use the `--reporters` flag. To export the file, use `--reporter-<name>-export`.

`postman collection run <collection-id> --reporters cli,junit --reporter-junit-export test-results.xml`

## Reporting to Postman Cloud
If authenticated, results are pushed to Postman automatically. You can disable this with:
`--disable-upload`
