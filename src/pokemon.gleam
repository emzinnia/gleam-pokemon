import gleam/io
import gleam/list
import gleam/result
import gleam/string
import gsv
import simplifile

pub type CsvError {
  ReadError
  ParseError
}

pub type Pokemon {
  Pokemon(
    pokemon_species_id: Int,
    local_language_id: Int,
    name: String,
    genus: String,
  )
}

pub fn row_to_pokemon(
  row: List(String),
  langs: List(String),
) -> Result(Pokemon, CsvError) {
  // TODO: implement stub
  Ok(Pokemon(0, 0, "", ""))
}

pub fn sequence_results(results: List(Result(a, e))) -> Result(List(a), e) {
  // TODO: implement sequence_results
  Ok([])
}

fn parse_header(header: List(String)) -> Result(List(String), CsvError) {
  case header {
    [] -> Ok([])
    [name, ..rest] -> Ok([name, ..rest])
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

pub fn rows_to_pokemon(
  rows: List(List(String)),
) -> Result(List(Pokemon), CsvError) {
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

pub fn parse_csv(contents: String) -> Result(List(Pokemon), CsvError) {
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

pub fn main() -> Nil {
  case get_all() {
    Ok(pokemon) -> io.println(string.inspect(pokemon))
    Error(_) -> io.println("Failed to read data.csv")
  }
}
