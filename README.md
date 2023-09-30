Monte-Carlo.ai
====

Monte-Carlo.ai is a Stable Diffusion AIGC service based on a fully decentralized computing powers network.

- Demo site (may offline in the future): https://demo.monte-carlo.ai
- Decentralized worker source code: https://github.com/cybros-network/cybros-network/tree/main/protocol_impl/examples/monte_carlo

## Requirements

- Ruby 3.2

## Prepare

- `git clone`
- `bundle`
- `cp config/database.yml.sqlite.example config/database.yml`
- `cp config/mailer.yml.example config/mailer.yml`
- `cp config/settings.yml config/settings.local.yml`
- `EDITOR="vim" bin/rails credentials:edit` and save
