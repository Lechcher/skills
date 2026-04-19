# Postman CLI GitHub Actions

You can easily automate API testing using the official Postman GitHub action or bare shell commands.

## Setup via Action
Name: `postman-cli-action`

Example `.github/workflows/postman.yml`:

```yaml
name: Automated API tests using Postman CLI

on: push

jobs:
  automated-api-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install Postman CLI
        run: |
          curl -o- "https://dl-cli.pstmn.io/install/linux64.sh" | sh
      - name: Login to Postman CLI
        run: postman login --with-api-key ${{ secrets.POSTMAN_API_KEY }}
      - name: Run API tests
        run: |
          postman collection run "${{ secrets.POSTMAN_COLLECTION_ID }}" -e "${{ secrets.POSTMAN_ENVIRONMENT_ID }}"
```
