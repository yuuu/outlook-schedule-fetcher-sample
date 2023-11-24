# Outlook Schedule Fetcher Sample

This sample uses the Microsoft Graph API to retrieve a calendar.

## Tools

- Ruby 3.2.2
- SAM CLI 1.97.0

## Deploy

```bash
sam build
sam deploy --guided

# sync code
sam sync --watch
```

## Log

```bash
sam logs -t
```

## クリーンアップ

```bash
sam delete --stack-name {your stack name}
```
