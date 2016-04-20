# Thoth

`Thoth` is a simple GDB meant for local usage that can withstand a high number of vertices.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add thoth to your list of dependencies in `mix.exs`:

        def deps do
          [{:thoth, "~> 0.0.5"}]
        end

  2. Ensure thoth is started before your application:

        def application do
          [applications: [:thoth]]
        end

## Usage

### Creating the Models

```elixir
defmodule Person do
    defstruct name: nil, age: nil, type: :person
end

# A Model struct has to implement Thoth.Model's id/1 that creates a uniquq id per instance
defimpl Thoth.Model, for: Person do
    def id (%Person{name: name}) do
        name |> String.downcase |> String.replace(" ", "_") |> String.to_atom
    end
end

defmodule Place do
    defstruct type: :place, name: nil
end

defimpl Thoth.Model, for: Place do
    def id (%Place{name: name}) do
        String.to_atom String.downcase name
    end
end

# It can also derive it for the default "UUIDv4" implementation
defmodule Post do
    @derive Thoth.Model
    defstruct type: :post, text: nil, is_comment: false
end
```

### Creating the Graph

```elixir
defmodule FB.Scenario do
    require Person
    require Place
    require Post
    require Thoth.Persistence
    require Thoth.Entities

    def run path do
        # Create new graph
        dag = Thoth.Persistence.load
        il = Thoth.Entities.add!(dag, %Place{name: "Israel"})
        fr = Thoth.Entities.add!(dag, %Place{name: "France"})
        au = Thoth.Entities.add!(dag, %Place{name: "Australia"})
        ca = Thoth.Entities.add!(dag, %Place{name: "Canada"})
        sp = Thoth.Entities.add!(dag, %Place{name: "Spain"})

        jaubourg = Thoth.Entities.add!(dag, %Person{name: "Julian Auborg", age: 20})

        # connecting 2 entities:
        # connect!(graph, source, target, connection_type) -- create a single directed conncetion
        # connect!(graph, source, target, connection_type, true) -- create a mutual directed conncetion of the same type
        # connect!(graph, source, target, connection_type, reverse_connection_type) -- create a two directed connections,
        # one from source to target, the other from target to source
        Thoth.Entities.connect!(dag, jaubourg, il, :from, :natives)
        Thoth.Entities.connect!(dag, jaubourg, ca, :lives_in, :dwellers)

        phiggins = Thoth.Entities.add!(dag, %Person{name: "Peter Higgins", age: 21})
        Thoth.Entities.connect!(dag, phiggins, il, :from, :natives)
        Thoth.Entities.connect!(dag, phiggins, ca, :lives_in, :dwellers)

        blowery = Thoth.Entities.add!(dag, %Person{name: "Ben Lowery", age: 21})
        Thoth.Entities.connect!(dag, blowery, ca, :from, :natives)
        Thoth.Entities.connect!(dag, blowery, fr, :lives_in, :dwellers)

        jeresig = Thoth.Entities.add!(dag, %Person{name: "John Resig", age: 22})
        Thoth.Entities.connect!(dag, jeresig, ca, :from, :natives)
        Thoth.Entities.connect!(dag, jeresig, fr, :lives_in, :dwellers)

        slightlylate = Thoth.Entities.add!(dag, %Person{name: "Alex Russell", age: 20})
        Thoth.Entities.connect!(dag, slightlylate, au, :from, :natives)
        Thoth.Entities.connect!(dag, slightlylate, sp, :lives_in, :dwellers)

        ajpiano = Thoth.Entities.add!(dag, %Person{name: "Adam Sontag", age: 24})
        Thoth.Entities.connect!(dag, ajpiano, au, :from, :natives)
        Thoth.Entities.connect!(dag, ajpiano, sp, :lives_in, :dwellers)

        Thoth.Entities.connect!(dag, ajpiano, phiggins, :friends, true)        
        Thoth.Entities.connect!(dag, jaubourg, phiggins, :friends, true)        
        Thoth.Entities.connect!(dag, ajpiano, slightlylate, :friends, true)        
        Thoth.Entities.connect!(dag, jeresig, slightlylate, :friends, true)        
        Thoth.Entities.connect!(dag, ajpiano, jaubourg, :friends, true)        
        Thoth.Entities.connect!(dag, ajpiano, blowery, :friends, true)        

        post = Thoth.Entities.add!(dag, %Post{text: "Hell of a day!"})
        Thoth.Entities.connect!(dag, ajpiano, post, :posted, :author)
        Thoth.Entities.connect!(dag, phiggins, post, :likes, :likers)
        Thoth.Entities.connect!(dag, blowery, post, :likes, :likers)
        
        comment = Thoth.Entities.add!(dag, %Post{text: "Awesome!", is_comment: true})
        Thoth.Entities.connect!(dag, phiggins, comment, :posted, :author)
        Thoth.Entities.connect!(dag, post, comment, :comments)
        Thoth.Entities.connect!(dag, ajpiano, comment, :likes, :likers)

        comment = Thoth.Entities.add!(dag, %Post{text: "Fuck you, mate", is_comment: true})
        Thoth.Entities.connect!(dag, slightlylate, comment, :posted, :author)
        Thoth.Entities.connect!(dag, post, comment, :comments)
        subcomment = Thoth.Entities.add!(dag, %Post{text: "Huh?", is_comment: true})
        Thoth.Entities.connect!(dag, phiggins, subcomment, :posted, :author)
        Thoth.Entities.connect!(dag, comment, subcomment, :comments)

        # Save graph to path
        Thoth.Persistence.save(dag, path)
    end
end
```

### Using the Graph

```elixir
dag = Thoth.Persistence.load('./test') # load the graph
friends_of_friends = Thoth.Query.query(
  dag, 
  :alex_russell,
  [:friends, :friends]
)
assert length(friends_of_friends) === 4
```