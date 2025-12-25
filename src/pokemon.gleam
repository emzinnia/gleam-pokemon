import gleam/erlang/atom
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import gsv
import simplifile

@external(erlang, "rand", "seed")
fn rand_seed(alg: atom.Atom) -> Nil

@external(erlang, "rand", "uniform")
fn rand_uniform(max: Int) -> Int

pub type CsvError {
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
) -> Result(Pokemon, CsvError) {
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

fn parse_header(header: List(String)) -> Result(List(String), CsvError) {
  case header {
    ["pokemon_species_id", "local_language_id", "name", "genus"] -> Ok([])
    [name, ..rest] -> Ok([name, ..rest])
    _ -> Error(ParseError)
  }
}

fn data_rows_to_pokemon(
  data_rows: List(List(String)),
  langs: List(String),
) -> Result(List(Pokemon), CsvError) {
  data_rows
  |> list.map(fn(row) { row_to_pokemon(row, langs) })
  |> sequence_results
}

fn rows_to_pokemon(rows: List(List(String))) -> Result(List(Pokemon), CsvError) {
  case rows {
    [] -> Ok([])
    [header, ..data_rows] -> {
      case parse_header(header) {
        Error(e) -> Error(e)
        Ok(langs) -> data_rows_to_pokemon(data_rows, langs)
      }
    }
  }
}

fn parse_csv(contents: String) -> Result(List(Pokemon), CsvError) {
  gsv.to_lists(contents, ",")
  |> result.map_error(fn(_) { ParseError })
  |> result.try(rows_to_pokemon)
}

pub fn get_all() -> Result(List(Pokemon), CsvError) {
  case simplifile.read("data/pokemon.csv") {
    Ok(contents) -> parse_csv(contents)
    Error(_) -> Error(ReadError)
  }
}

pub fn get_pokemon(id: Int, lang: Language) -> Result(Pokemon, CsvError) {
  let lang_id = language_id(lang)
  get_all()
  |> result.try(fn(all) {
    all
    |> list.find(fn(pokemon) {
      pokemon.species_id == id && pokemon.language_id == lang_id
    })
    |> result.replace_error(NotFound)
  })
}

pub fn get_random() -> Result(Pokemon, CsvError) {
  get_all()
  |> result.try(fn(all) {
    case all {
      [] -> Error(NotFound)
      _ -> {
        rand_seed(atom.create("exsplus"))
        let idx = rand_uniform(list.length(all)) - 1

        case list.drop(all, idx) {
          [pokemon, ..] -> Ok(pokemon)
          _ -> Error(NotFound)
        }
      }
    }
  })
}

pub fn get_random_with_lang(lang: Language) -> Result(Pokemon, CsvError) {
  get_all()
  |> result.try(fn(all) {
    let filtered =
      list.filter(all, fn(pokemon) { pokemon.language_id == language_id(lang) })
    case filtered {
      [] -> Error(NotFound)
      _ -> {
        rand_seed(atom.create("exsplus"))
        let idx = rand_uniform(list.length(filtered)) - 1
        case list.drop(filtered, idx) {
          [pokemon, ..] -> Ok(pokemon)
          _ -> Error(NotFound)
        }
      }
    }
  })
}

pub fn get_name(id: Int) -> Result(String, CsvError) {
  get_all()
  |> result.try(fn(all) {
    case all {
      [] -> Error(NotFound)
      _ -> {
        all
        |> list.find(fn(pokemon) { pokemon.species_id == id })
        |> result.replace_error(NotFound)
        |> result.map(fn(pokemon) { pokemon.name })
      }
    }
  })
}

pub fn get_name_with_lang(id: Int, lang: Language) -> Result(String, CsvError) {
  get_all()
  |> result.try(fn(all) {
    case all {
      [] -> Error(NotFound)
      _ -> {
        all
        |> list.filter(fn(pokemon) { pokemon.language_id == language_id(lang) })
        |> list.find(fn(pokemon) { pokemon.species_id == id })
        |> result.replace_error(NotFound)
        |> result.map(fn(pokemon) { pokemon.name })
      }
    }
  })
}

pub fn main() -> Nil {
  case get_all() {
    Ok(pokemon) -> io.println(string.inspect(pokemon))
    Error(_) -> io.println("Failed to read data.csv")
  }
}
