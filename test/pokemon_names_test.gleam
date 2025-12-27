import gleam/string
import gleeunit
import gleeunit/should
import pokemon_names
import pokemon_names/internal/pokemon_gen.{Pokemon}

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn get_all_test() {
  case pokemon_names.get_all() {
    [first, ..] -> {
      should.be_true(first.species_id > 0)
      should.be_true(first.language_id > 0)
      should.be_true(string.length(first.name) > 0)
      should.be_true(string.length(first.genus) > 0)
    }

    [] -> should.fail()
  }
}

pub fn get_pokemon_test() {
  let pokemon = pokemon_names.get_pokemon(1, pokemon_names.English)
  assert pokemon == Ok(Pokemon(1, 9, "Bulbasaur", "Seed Pokémon"))
}

pub fn get_random_test() {
  let random = pokemon_names.get_random()
  {
    should.be_true(random.species_id > 0)
    should.be_true(random.language_id > 0)
    should.be_true(string.length(random.name) > 0)
    should.be_true(string.length(random.genus) > 0)
  }
}

pub fn get_random_with_lang_test() {
  case pokemon_names.get_random_with_lang(pokemon_names.English) {
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
  case pokemon_names.get_name(453) {
    Ok(name) -> {
      should.be_true(name == "Croagunk")
    }
    Error(_) -> {
      should.fail()
    }
  }
}

pub fn get_name_with_lang_test() {
  case pokemon_names.get_name_with_lang(453, pokemon_names.English) {
    Ok(name) -> {
      should.be_true(name == "Croagunk")
    }
    Error(_) -> {
      should.fail()
    }
  }
}
