# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.6.2] - 2024-11-19

### Fixed

- Properly format reported throw value

### Changed

- Updates `tower` dependency from `{:tower, "~> 0.6.0"}` to `{:tower, "~> 0.7.1"}`.

## [0.6.1] - 2024-10-24

### Fixed

- Properly report common `:gen_server` abnormal exits

## [0.6.0] - 2024-10-07

### Added

- Can include less verbose `TowerRollbar` as reporter instead of `TowerRollbar.Reporter`.

### Changed

- No longer necessary to call `Tower.attach()` in your application `start`. It is done
automatically.

- Updates `tower` dependency from `{:tower, "~> 0.5.0"}` to `{:tower, "~> 0.6.0"}`.

## [0.5.0] - 2024-09-03

### Added

- New included values in every Rollbar Item report
  - server os type and version
  - Elixir node name, i.e. the result of `Node.self()`.

### Removed

- `:enabled` configuration option.

### Changed

- Reporting is enabled if `:access_token` configuration option is set and is a binary. Otherwise
  TowerRollbar is disabled. This logic replaces now removed `:enabled` configuration option.

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

[0.6.2]: https://github.com/mimiquate/tower_rollbar/compare/v0.6.1...v0.6.2/
[0.6.1]: https://github.com/mimiquate/tower_rollbar/compare/v0.6.0...v0.6.1/
[0.6.0]: https://github.com/mimiquate/tower_rollbar/compare/v0.5.0...v0.6.0/
[0.5.0]: https://github.com/mimiquate/tower_rollbar/compare/v0.4.1...v0.5.0/
[0.4.1]: https://github.com/mimiquate/tower_rollbar/compare/v0.4.0...v0.4.1/
[0.4.0]: https://github.com/mimiquate/tower_rollbar/compare/v0.3.0...v0.4.0/
[0.3.0]: https://github.com/mimiquate/tower_rollbar/compare/v0.2.0...v0.3.0/
