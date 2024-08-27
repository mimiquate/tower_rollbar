# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.1] - 2024-08-27

### Added

- New included values in every Rollbar Item report
  - language=elixir
  - elixir and Erlang/OTP version numbers
  - notifier information, i.e.
    - name=tower_rollbar
    - verison=<tower_rollbar_version>
  - Rollbar recommended uuid value set to `Tower.Event.id`.

## [0.4.0] - 2024-08-20

### Added

- Bandit support via `tower` update
- Oban support via `tower` update

### Changed

- Updates dependency to `{:tower, "~> 0.5.0"}`.

## [0.3.0] - 2024-08-16

### Changed

- Updates dependency to `{:tower, "~> 0.4.0"}`.

[0.4.1]: https://github.com/mimiquate/tower_rollbar/compare/v0.4.0...v0.4.1/
[0.4.0]: https://github.com/mimiquate/tower_rollbar/compare/v0.3.0...v0.4.0/
[0.3.0]: https://github.com/mimiquate/tower_rollbar/compare/v0.2.0...v0.3.0/
