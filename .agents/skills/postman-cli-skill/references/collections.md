# Postman CLI Collection Commands

The fundamental use-case for the Postman CLI is running collections.

## Running By ID
You can run a Postman collection by passing its ID:
`postman collection run <collection-id>`

## Using Environments
To pass variables or an environment file (either local JSON or cloud ID):
`postman collection run <collection-id> --environment <environment-id-or-path>`

## Passing Data Files
When testing with iterations, pass a CSV or JSON file:
`postman collection run <collection-id> --iteration-data data.csv`

## Error Handling
By default, the CLI will output detailed error traces. You can suppress these with `--suppress-error-trace` or halt on errors using `--bail`.
