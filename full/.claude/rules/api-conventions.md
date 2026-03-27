---
description: REST API design conventions
paths:
  - "src/api/**"
  - "src/routes/**"
  - "src/controllers/**"
---

# API Conventions

- Follow RESTful design: GET=retrieve, POST=create, PUT=update, DELETE=delete
- Responses are always JSON
- Error response format: `{ "error": { "code": "...", "message": "..." } }`
- Pagination: `?page=1&per_page=20`
- Authentication via Bearer token in Authorization header
- HTTP status codes: 422 (validation error), 401 (auth error), 403 (permission error)
