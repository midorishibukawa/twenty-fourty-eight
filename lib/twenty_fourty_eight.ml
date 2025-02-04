open Batteries

module IntSet = Set.Make(Int)

module type Game = sig
    type direction = Up | Down | Left | Right
    type state = Won | Over | Playing
    type cell = { value : int ; position : int } 
    type t = cell list
    val new_game : unit -> t
    val move : direction -> t -> t * state * int
end

module type GameParams = sig
    val size : int
    val seed : int option
end

module Game(Params : GameParams) : Game = struct
    type direction = Up | Down | Left | Right
    type axis = Horizontal | Vertical
    type state = Won | Over | Playing
    type cell = { value : int ; position : int } 
    type t = cell list

    (** Initializes the game RNG.  *)
    let () = 
        Option.map Random.init Params.seed
        |? Random.self_init ()

    let cell_qty = Params.size * Params.size

    (** Empty game structure. Alias of an empty `List`. *)
    let empty_game = []

    (** Set of all possible positions a cell can have. *)
    let all_pos_set = 0 --^ cell_qty |> IntSet.of_enum
    
    (** Receives a cell and returns its position. *)
    let get_pos { position ; _ } = position

    (** Receives a cell and returns its value. *)
    let rec xy_of_idx ?(y=0) x =
        if x < Params.size
        then x, y
        else xy_of_idx ~y:(y + 1) (x - Params.size)
   
    (** Receives a tuple of coordinates 
        and returns its corresponding index. *)
    let idx_of_xy (x, y) = y * Params.size + x

    (** Array where all possible positions a cell can have are the indexes,
        while their cartesian coordinates are the values. *)
    let all_pos_arr =
        let i_to_xy acc i = acc.(i) <- xy_of_idx i; acc in
        let placeholder_arr = Array.make cell_qty (-1, -1) in
        all_pos_set
        |> IntSet.elements
        |> List.fold i_to_xy placeholder_arr 

    (** Generates a new cell with a value between 0 and 1 
        on any random empty spaces. *)
    let generate_cell game =
        let empty_pos =
            game
            |> List.map get_pos
            |> List.fold (flip IntSet.remove) all_pos_set
            |> IntSet.to_array in
        if Array.length empty_pos = 0
        then game
        else
        let position =
            empty_pos
            |> Array.length
            |> Random.int
            |> Array.get empty_pos in 
        let value = if Random.int 16 = 0 then 1 else 0 in
        { value ; position }::game

    (** Receives a game structure and returns its current state. *)
    let get_state_score game =
        let check_cells game (max, score, over) cell =
            let { value ; position } = cell in
            let x, y = xy_of_idx position in
            let are_coordinates_valid (x, y) (dx, dy) = 
                let is_coordinate_valid coordinate = 
                    coordinate >= 0 && coordinate < Params.size in
                let x', y' = x + dx, y + dy in
                if is_coordinate_valid x' && is_coordinate_valid y'
                then Some (x', y')
                else None in
            let cant_move_in_dir opt = 
                Option.map ((!=) value) opt |? false in
            let no_moves = 
                [ -1,  0 ;  1,  0
                ;  0, -1 ;  0,  1
                ]
                |> List.filter_map @@ are_coordinates_valid (x, y)
                |> List.map @@ Array.get game % idx_of_xy
                |> List.for_all cant_move_in_dir in
            Int.max max value, score + (Int.pow 2 (value + 1)), no_moves && over in
        let game_arr =
            let opt_arr = Array.make cell_qty None in
            let update_pos acc { value ; position } =
                acc.(position) <- Some value;
                acc in
            List.fold update_pos opt_arr game in
        let max, score, over = 
            List.fold_left (check_cells game_arr) (0, 0, true) game in
        let state = 
            if over
            then Over
            else if max >= 10
            then Won
            else Playing in 
        state, score

    (** Creates a new game with a single random cell. *)
    let new_game () = generate_cell empty_game

    (** Moves all cells into the given direction,generates a new cell,
        and returns a tuple of the new cells and the game state. *)
    let move dir game =
        let axis =
            match dir with
            | Left | Right -> Horizontal
            | Up   | Down  -> Vertical in
        let line_arr = Array.make Params.size [] in
        let update_arr arr { value ; position } = 
            let select_i (x, y) = if axis = Vertical then x else y in
            let i = select_i all_pos_arr.(position) in
            arr.(i) <- value::arr.(i);
            arr in
        let is_rev = dir = Down || dir = Right in
        let rec arr_to_cells ?(acc=[]) ?(j=0) i values =
            let j' = 
                match dir with
                | Down | Right -> Params.size - j - 1
                | Up   | Left  -> j in
            let x, y = if axis = Vertical then i, j' else j', i in
            let position = y * Params.size + x in
            match values with
            | [] -> (if is_rev then List.rev else Fun.id) acc 
            | value_a::value_b::values' ->
                    let accd, values'' =
                        if value_a = value_b
                        then 1, values'
                        else 0, value_b::values' in
                    let acc = { value = value_a + accd ; position }::acc in
                    let j = j + 1 in
                    arr_to_cells ~acc ~j i values''
            | value::values' -> 
                    let acc = { value ; position }::acc in
                    let j = j + 1 in
                    arr_to_cells ~acc ~j i values'
            in
        let set_of_game = IntSet.of_list % List.map get_pos  in
        let game_set = set_of_game game in
        let generate_cell_if_moved game' =
            if IntSet.equal game_set (set_of_game game')
            then game'
            else generate_cell game' in
        let game' =
            game
            |> List.fold update_arr line_arr
            |> Array.map (if is_rev then Fun.id else List.rev)
            |> Array.mapi arr_to_cells
            |> Array.to_list
            |> List.flatten
            |> generate_cell_if_moved
            |> List.sort (fun a b -> a.position - b.position) in
        let state, score = get_state_score game' in
        game', state, score
end
