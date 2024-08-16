# TowerRollbar

[![ci](https://github.com/mimiquate/tower_rollbar/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/mimiquate/tower_rollbar/actions?query=branch%3Amain)
[![Hex.pm](https://img.shields.io/hexpm/v/tower_rollbar.svg)](https://hex.pm/packages/tower_rollbar)
[![Docs](https://img.shields.io/badge/docs-gray.svg)](https://hexdocs.pm/tower_rollbar)

A [Rollbar](https://rollbar.com) reporter for [Tower](https://github.com/mimiquate/tower) error handler.

## Installation

The package can be installed by adding `tower_rollbar` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:tower_rollbar, "~> 0.2.0"}
  ]
end
```

## License

Copyright 2024 Mimiquate

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
