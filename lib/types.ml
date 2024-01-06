type direction = Up | Down | Left | Right
type axis = Horizontal | Vertical
type location = { x: int; y: int }
type cell = { value: int; location: location }
type game = { size: int; cells: cell list }

