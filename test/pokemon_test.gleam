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

    Ok([]) -> should.fail()

    Error(_) -> should.fail()
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
    Error(_) -> {
      should.fail()
    }
  }
}

pub fn get_random_with_lang_test() {
  case pokemon.get_random_with_lang(pokemon.English) {
    Ok(poke) -> {
      should.be_true(poke.species_id > 0)
      should.be_true(poke.language_id == 9)
      should.be_true(string.length(poke.name) > 0)
      should.be_true(string.length(poke.genus) > 0)
    }
    Error(_) -> {
      should.fail()
    }
  }
}

pub fn get_name_test() {
  case pokemon.get_name(453) {
    Ok(name) -> {
      should.be_true(name == "Croagunk")
    }
    Error(_) -> {
      should.fail()
    }
  }
}

pub fn get_name_with_lang_test() {
  case pokemon.get_name_with_lang(453, pokemon.English) {
    Ok(name) -> {
      should.be_true(name == "Croagunk")
    }
    Error(_) -> {
      should.fail()
    }
  }
}
