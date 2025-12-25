# pokemon

Based off a previous [Rust package](https://github.com/emzinnia/pokemon) I wrote, which itself is based off an [npm package](https://github.com/sindresorhus/pokemon) by Sindre Sorhous. 

[![Package Version](https://img.shields.io/hexpm/v/pokemon)](https://hex.pm/packages/pokemon)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/pokemon/)

### Installation

```sh
gleam add pokemon@1
```

### API

Pokémon contain the following properties

```gleam
pub type Pokemon {
  Pokemon(species_id: Int, language_id: Int, name: String, genus: String)
}
```

#### `get_all() -> Result(List(Pokemon), PokemonError)`

Returns all Pokémon from the dataset across all languages.

```gleam
case pokemon.get_all() {
  Ok(all) -> io.println("Loaded " <> int.to_string(list.length(all)) <> " Pokémon")
  Error(_) -> io.println("Failed to load data")
}
```

#### `get_pokemon(id: Int, lang: Language) -> Result(Pokemon, PokemonError)`

Get a specific Pokémon by species ID and language.

```gleam
pokemon.get_pokemon(25, pokemon.English)
// -> Ok(Pokemon(25, 9, "Pikachu", "Mouse Pokémon"))
```

#### `get_random() -> Result(Pokemon, PokemonError)`

Get a random Pokémon from the entire dataset (any language).

#### `get_random_with_lang(lang: Language) -> Result(Pokemon, PokemonError)`

Get a random Pokémon in a specific language.

```gleam
pokemon.get_random_with_lang(pokemon.Japanese)
// -> Ok(Pokemon(143, 1, "カビゴン", "いねむりポケモン"))
```

#### `get_name(id: Int) -> Result(String, PokemonError)`

Get the English name of a Pokémon by species ID.

```gleam
pokemon.get_name(6)
// -> Ok("Charizard")
```

#### `get_name_with_lang(id: Int, lang: Language) -> Result(String, PokemonError)`

Get the name of a Pokémon by species ID in a specific language.

```gleam
pokemon.get_name_with_lang(6, pokemon.English)
// -> Ok("Charizard")
```

### Types

#### Language

Supported languages for Pokémon names and genus text:

```gleam
pub type Language {
  Japanese          // language_id: 1
  JapaneseRomanized // language_id: 2
  Korean            // language_id: 3
  Chinese           // language_id: 4
  French            // language_id: 5
  German            // language_id: 6
  Spanish           // language_id: 7
  Italian           // language_id: 8
  English           // language_id: 9
}
```

#### Errors

Possible errors returned by the API:

```gleam
pub type PokemonError {
  ReadError   // Failed to read the CSV file
  ParseError  // Failed to parse CSV format
  InvalidRow  // Row has unexpected structure
  InvalidInt  // Failed to parse species/language ID
  NotFound    // Pokémon not found
}
```
