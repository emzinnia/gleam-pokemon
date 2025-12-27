import gleam/list
import gleam/string
import simplifile

pub fn main() {
  let assert Ok(data) = simplifile.read("priv/pokemon.csv")
  let elements =
    string.split(data, "\n")
    |> list.drop(1)
    |> list.filter(fn(line) { line != "" })
    |> list.map(fn(line) {
      let assert [species_id, language_id, name, genus] =
        string.split(line, ",")
      "Pokemon(species_id: "
      <> species_id
      <> ", language_id: "
      <> language_id
      <> ", name: \""
      <> name
      <> "\", genus: \""
      <> genus
      <> "\")"
    })
    |> string.join(",\n  ")
  let code = "pub type Pokemon {
  Pokemon(species_id: Int, language_id: Int, name: String, genus: String)
}

pub const pokemon: List(Pokemon) = [
  " <> elements <> ",
]"
  let assert Ok(_) = simplifile.write("src/internal/pokemon_gen.gleam", code)
}
