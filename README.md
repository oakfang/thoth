# Thoth

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add thoth to your list of dependencies in `mix.exs`:

        def deps do
          [{:thoth, "~> 0.0.1"}]
        end

  2. Ensure thoth is started before your application:

        def application do
          [applications: [:thoth]]
        end

### Notes

Use `Thoth.Query.find` for graphs with fewer than 550 vertices, otherwise use Thoth.Async.find :)
