import erlang/binary
import erlang/file
import gleam/io

pub type CsvError {
  ReadError
  ParseError
}

pub fn main() -> Nil {
  io.println("Hello from pokemon!")
}
