import gleam/string
import gleeunit
import gleeunit/should
import pokemon

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn get_all_test() {
  case pokemon.get_all() {
    Ok([first, ..]) -> {
      should.be_true(first.species_id > 0)
      should.be_true(first.language_id > 0)
      should.be_true(string.length(first.name) > 0)
      should.be_true(string.length(first.genus) > 0)
    }
    Ok([]) -> {
      should.be_error(Ok(pokemon.NotFound))
    }
    Error(e) -> {
      should.fail()
    }
  }
}

pub fn get_pokemon_test() {
  let pokemon = pokemon.get_pokemon(1, pokemon.English)
  assert pokemon == Ok(pokemon.Pokemon(1, 9, "Bulbasaur", "Seed Pokémon"))
}

pub fn get_random_test() {
  case pokemon.get_random() {
    Ok(pokemon) -> {
      should.be_true(pokemon.species_id > 0)
      should.be_true(pokemon.language_id > 0)
      should.be_true(string.length(pokemon.name) > 0)
      should.be_true(string.length(pokemon.genus) > 0)
    }
    Error(e) -> {
      should.fail()
    }
  }
}
