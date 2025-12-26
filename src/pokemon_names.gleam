import gleam/dynamic
import gleam/erlang/atom
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import gsv
import simplifile

@external(erlang, "ets", "info")
fn ets_info(table: atom.Atom, item: atom.Atom) -> dynamic.Dynamic

@external(erlang, "erlang", "is_integer")
fn is_integer(x: dynamic.Dynamic) -> Bool

@external(erlang, "ets", "new")
fn ets_new(name: atom.Atom, options: List(atom.Atom)) -> atom.Atom

@external(erlang, "ets", "insert")
fn ets_insert(table: atom.Atom, object: a) -> Bool

@external(erlang, "ets", "lookup")
fn ets_lookup(table: atom.Atom, key: k) -> List(a)

@external(erlang, "rand", "seed")
fn rand_seed(alg: atom.Atom) -> Nil

@external(erlang, "rand", "uniform")
fn rand_uniform(max: Int) -> Int

const table_by_key = "pokemon_by_key"

const table_all = "pokemon_all"

const table_by_lang = "pokemon_by_lang"

fn table_atom(name: String) -> atom.Atom {
  atom.create(name)
}

fn ets_exists(name: atom.Atom) -> Bool {
  ets_info(name, atom.create("size"))
  |> is_integer
}

fn ensure_loaded() -> Result(Nil, PokemonError) {
  let by_key = table_atom(table_by_key)

  case ets_exists(by_key) {
    True -> Ok(Nil)
    False -> {
      let _ =
        ets_new(by_key, [
          atom.create("named_table"),
          atom.create("set"),
          atom.create("public"),
        ])

      let _ =
        ets_new(table_atom(table_all), [
          atom.create("named_table"),
          atom.create("set"),
          atom.create("public"),
        ])

      let _ =
        ets_new(table_atom(table_by_lang), [
          atom.create("named_table"),
          atom.create("set"),
          atom.create("public"),
        ])

      rand_seed(atom.create("exsplus"))

      get_all_from_csv()
      |> result.map(fn(all) {
        populate_tables(all)
        Nil
      })
    }
  }
}

fn populate_tables(all: List(Pokemon)) -> Nil {
  let by_key = table_atom(table_by_key)
  all
  |> list.each(fn(p) {
    let key = #(p.species_id, p.language_id)
    let _ = ets_insert(by_key, #(key, p))
    Nil
  })

  let _ = ets_insert(table_atom(table_all), #(atom.create("all"), all))

  let langs = [1, 2, 3, 4, 5, 6, 7, 8, 9]
  langs
  |> list.each(fn(lang_id) {
    let filtered =
      all
      |> list.filter(fn(p) { p.language_id == lang_id })
    let _ =
      ets_insert(table_atom(table_by_lang), #(
        atom.create(int.to_string(lang_id)),
        filtered,
      ))
    Nil
  })
}

fn get_all_from_csv() -> Result(List(Pokemon), PokemonError) {
  case simplifile.read("data/pokemon.csv") {
    Ok(contents) -> parse_csv(contents)
    Error(_) -> Error(ReadError)
  }
}

fn get_all_from_ets() -> Result(List(Pokemon), PokemonError) {
  case ets_lookup(table_atom(table_all), atom.create("all")) {
    [#(_, all)] -> Ok(all)
    _ -> Error(NotFound)
  }
}

pub type PokemonError {
  ReadError
  ParseError
  InvalidRow
  InvalidInt
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

pub type Pokemon {
  Pokemon(species_id: Int, language_id: Int, name: String, genus: String)
}

fn row_to_pokemon(
  row: List(String),
  _langs: List(String),
) -> Result(Pokemon, PokemonError) {
  case row {
    [species_id_str, lang_id_str, name, genus] -> {
      case int.parse(species_id_str), int.parse(lang_id_str) {
        Ok(species_id), Ok(local_language_id) ->
          Ok(Pokemon(species_id, local_language_id, name, genus))

        _, _ -> Error(InvalidInt)
      }
    }
    _ -> Error(InvalidRow)
  }
}

fn sequence_results(results: List(Result(a, e))) -> Result(List(a), e) {
  list.fold(results, Ok([]), fn(acc, next) {
    case acc, next {
      Ok(xs), Ok(x) -> Ok([x, ..xs])
      Error(e), _ -> Error(e)
      _, Error(e) -> Error(e)
    }
  })
  |> result.map(list.reverse)
}

fn parse_header(header: List(String)) -> Result(Nil, PokemonError) {
  case header {
    ["pokemon_species_id", "local_language_id", "name", "genus"] -> Ok(Nil)
    _ -> Error(ParseError)
  }
}

fn data_rows_to_pokemon(
  data_rows: List(List(String)),
  langs: List(String),
) -> Result(List(Pokemon), PokemonError) {
  data_rows
  |> list.map(fn(row) { row_to_pokemon(row, langs) })
  |> sequence_results
}

fn rows_to_pokemon(
  rows: List(List(String)),
) -> Result(List(Pokemon), PokemonError) {
  case rows {
    [] -> Ok([])
    [header, ..data_rows] -> {
      case parse_header(header) {
        Error(e) -> Error(e)
        Ok(_) -> data_rows_to_pokemon(data_rows, [])
      }
    }
  }
}

fn parse_csv(contents: String) -> Result(List(Pokemon), PokemonError) {
  gsv.to_lists(contents, ",")
  |> result.map_error(fn(_) { ParseError })
  |> result.try(rows_to_pokemon)
}

pub fn get_all() -> Result(List(Pokemon), PokemonError) {
  ensure_loaded()
  |> result.try(fn(_) { get_all_from_ets() })
}

pub fn get_pokemon(id: Int, lang: Language) -> Result(Pokemon, PokemonError) {
  ensure_loaded()
  |> result.try(fn(_) {
    let lang_id = language_id(lang)
    let key = #(id, lang_id)

    case ets_lookup(table_atom(table_by_key), key) {
      [#(_, pokemon)] -> Ok(pokemon)
      _ -> Error(NotFound)
    }
  })
}

pub fn get_random() -> Result(Pokemon, PokemonError) {
  ensure_loaded()
  |> result.try(fn(_) {
    get_all_from_ets()
    |> result.try(fn(all) {
      case all {
        [] -> Error(NotFound)
        _ -> {
          let idx = rand_uniform(list.length(all)) - 1
          case list.drop(all, idx) {
            [pokemon, ..] -> Ok(pokemon)
            _ -> Error(NotFound)
          }
        }
      }
    })
  })
}

pub fn get_random_with_lang(lang: Language) -> Result(Pokemon, PokemonError) {
  ensure_loaded()
  |> result.try(fn(_) {
    let lang_id = language_id(lang)

    case
      ets_lookup(table_atom(table_by_lang), atom.create(int.to_string(lang_id)))
    {
      [#(_, filtered)] -> {
        case filtered {
          [] -> Error(NotFound)
          _ -> {
            let idx = rand_uniform(list.length(filtered)) - 1
            case list.drop(filtered, idx) {
              [pokemon, ..] -> Ok(pokemon)
              _ -> Error(NotFound)
            }
          }
        }
      }
      _ -> Error(NotFound)
    }
  })
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
  case get_all() {
    Ok(pokemon) -> io.println(string.inspect(pokemon))
    Error(_) -> io.println("Failed to read data.csv")
  }
}
