import gleam/int
import gleam/io
import gleam/list
import gleam/result
import pokemon_names/internal/pokemon_gen

pub type Pokemon =
  pokemon_gen.Pokemon

pub type PokemonError {
  NotFound
}

pub type Language {
  Japanese
  JapaneseRomanized
  Korean
  Chinese
  French
  German
  Spanish
  Italian
  English
}

pub fn language_id(lang: Language) -> Int {
  case lang {
    Japanese -> 1
    JapaneseRomanized -> 2
    Korean -> 3
    Chinese -> 4
    French -> 5
    German -> 6
    Spanish -> 7
    Italian -> 8
    English -> 9
  }
}

pub fn get_all() -> List(Pokemon) {
  pokemon_gen.pokemon
}

pub fn get_all_with_lang(lang: Language) -> List(Pokemon) {
  let lang_id = language_id(lang)
  pokemon_gen.pokemon
  |> list.filter(fn(p) { p.language_id == lang_id })
}

pub fn get_pokemon(id: Int, lang: Language) -> Result(Pokemon, PokemonError) {
  let lang_id = language_id(lang)
  pokemon_gen.pokemon
  |> list.find(fn(p) { p.species_id == id && p.language_id == lang_id })
  |> result.replace_error(NotFound)
}

pub fn get_random() -> Result(Pokemon, PokemonError) {
  let all = pokemon_gen.pokemon
  case list.length(all) {
    0 -> Error(NotFound)
    len -> {
      let idx = int.random(len)
      list.drop(all, idx)
      |> list.first
      |> result.replace_error(NotFound)
    }
  }
}

pub fn get_random_with_lang(lang: Language) -> Result(Pokemon, PokemonError) {
  let filtered = get_all_with_lang(lang)
  case list.length(filtered) {
    0 -> Error(NotFound)
    len -> {
      let idx = int.random(len)
      list.drop(filtered, idx)
      |> list.first
      |> result.replace_error(NotFound)
    }
  }
}

pub fn get_name(id: Int) -> Result(String, PokemonError) {
  get_pokemon(id, English)
  |> result.map(fn(pokemon) { pokemon.name })
}

pub fn get_name_with_lang(
  id: Int,
  lang: Language,
) -> Result(String, PokemonError) {
  get_pokemon(id, lang)
  |> result.map(fn(pokemon) { pokemon.name })
}

pub fn main() -> Nil {
  case get_name(25) {
    Ok(name) -> io.println("Pikachu is: " <> name)
    Error(_) -> io.println("Not found")
  }
}
