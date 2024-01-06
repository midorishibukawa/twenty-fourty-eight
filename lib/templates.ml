open Batteries
open Dream_html 
open HTML 
open Types

module IntMap = Map.Make(Int)

let page ~title:title_txt html_body =
    html [ lang "en" ] 
        [ head []
            [ title [] title_txt
            ; meta  [ charset "UTF-8" ] 
            ; meta  [ http_equiv `x_ua_compatible ; content "ID=edge" ]
            ; meta  [ name "viewport" ; content "width=device-width, initial-scale=1.0" ]
            ; link  [ rel "stylesheet" ; href "static/style.css" ]
            ; script    [ src "https://unpkg.com/htmx.org@1.9.2" 
                        ; integrity "sha384-L6OqL9pRWyyFU3+/bjdSri+iIphTN/bvYyM37tICVyOJkWZLpP2vGn6VUEXgzg6h"
                        ; crossorigin `anonymous ] ""
            ; script    [ src "https://unpkg.com/htmx.org/dist/ext/ws.js" ] ""
            ; script    [ src "./static/ws.js" ] "" ]
        ; body [] 
            [ nav [] []
            ; html_body ] ] ;;

let article ctt =
    article []
        [ txt ~raw:true "%s" ctt ]

let p ctt = p [] [ txt "%s" ctt ]

let game g =
    let ids = 
        IntMap.of_list 
        @@ List.map
        (fun cell -> cell.location.x + cell.location.y * g.size, cell.value)
        g.cells
    in
    section 
        [ id "game" 
        ; int_attr "data-size" g.size ]
        (List.of_enum (0--(g.size * g.size - 1))
        |> List.map (fun i -> div [] [txt "%s" @@ string_of_int @@ IntMap.find_default 0 i ids ]))
