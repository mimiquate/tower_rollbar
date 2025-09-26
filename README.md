# TowerRollbar

[![ci](https://github.com/mimiquate/tower_rollbar/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/mimiquate/tower_rollbar/actions?query=branch%3Amain)
[![Hex.pm](https://img.shields.io/hexpm/v/tower_rollbar.svg)](https://hex.pm/packages/tower_rollbar)
[![Documentation](https://img.shields.io/badge/Documentation-purple.svg)](https://hexdocs.pm/tower_rollbar)

Error tracking and reporting to Rollbar.

A [Rollbar](https://rollbar.com) reporter for [Tower](https://github.com/mimiquate/tower) error handler.

## Installation

The package can be installed by adding `tower_rollbar` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:tower_rollbar, "~> 0.6.5"}
  ]
end
```

## Usage

Ask `Tower` to use the `TowerRollbar` reporter.

```elixir
# config/config.exs

config(
  :tower,
  :reporters,
  [
    # along any other possible reporters
    TowerRollbar
  ]
)
```

And configure `:tower_rollbar`.

```elixir
# config/runtime.exs

if config_env() == :prod do
  config :tower_rollbar,
    access_token: System.get_env("ROLLBAR_SERVER_ACCESS_TOKEN"),
    environment: System.get_env("DEPLOYMENT_ENV", to_string(config_env()))
end
```

That's it.

It will try report any error, throw or abnormal exit within your application. That includes errors in
any plug call (including Phoenix), Oban job, async task or any other process.

Some HTTP request data will be included in the report if a `Plug.Conn` is available when handling the error.

### Manual reporting

You can manually report errors just by informing `Tower` about any manually handled errors, throws or abnormal exits.


```elixir
try do
  # possibly crashing code
rescue
  exception ->
    Tower.report_exception(exception, __STACKTRACE__)
end
```

More details on https://hexdocs.pm/tower/Tower.html#module-manual-reporting.

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
