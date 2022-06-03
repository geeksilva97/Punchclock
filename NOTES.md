# The flow

The rake excutes
  - Github Create
    - Gitub collect
    - docker compose run --rm runner bundle exec rake github:import_contributions

1. company = Company.find(ENV['COMPANY_ID'])
2. client = Github.new(headers: {"Authorization" => "token #{ENV['GITHUB_OAUTH_TOKEN']}"})

## Executar o rake
```console
docker compose run --rm runner bundle exec rake github:import_contributions
```
