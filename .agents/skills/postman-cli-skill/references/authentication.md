# Authentication with Postman CLI

To interact with Postman servers (to download collections via ID or upload reports), users must authenticate.

## Login Command
`postman login --with-api-key <api-key>`

**Best Practice:**
Never hardcode API keys. Tell users to set up an environment variable like `POSTMAN_API_KEY`.
Using environment variables directly in workflows:
`postman login --with-api-key $POSTMAN_API_KEY`

## Logging Out
To clear the session:
`postman logout`
