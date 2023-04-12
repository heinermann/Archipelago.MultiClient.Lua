# Archipelago.MultiClient.Lua
A client library written in Lua for use with Archipelago.

Assumes very minimal features available, i.e. `table`, `string`, `math`. Assumes that `require` is unavailable.

Must register a table containing callbacks.

## Lua Versions In Video Games
*Not a list of games that use this.*

| Game               | Lua Version |
| ------------------ | ----------- |
| Binding of Isaac   | 5.1         |
| Civilization V     | 5.1         |
| Don't Starve       | 5.1         |
| Garry's Mod        | 5.1         |
| Noita              | 5.1         |
| Factorio           | 5.2         |
| Project Zomboid    | 5.2         |
| Tabletop Simulator | 5.2         |
| Starbound          | 5.3         |


## Additional Notes
### Bitwise Operations
Noita uses `bit`, Lua 5.2 uses `bit32`, and Lua 5.3 has built-in operators. Other Lua 5.1 games will need a custom
implementation using math.
