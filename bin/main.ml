module D = Dream
module S = Static
module TFE = Twenty_fourty_eight
module T = Twenty_fourty_eight.Templates


let () =
    let handle_htmx ~req ~f ~no_htmx body =
        f @@
        match D.header req "HX-Request" with
        | None   -> no_htmx body
        | Some _ -> body in
    D.run ~port:8080 ~interface:"0.0.0.0"
    @@ D.logger
    @@ D.cookie_sessions
    @@ D.router [
        D.get "/static/**" 
            @@ D.static 
            ~loader:(fun _root path _req -> 
                match Static.read path with
                | None -> Dream.empty `Not_Found 
                | Some asset -> D.respond asset)
            "";

        D.get "/" (fun req ->
            handle_htmx 
                ~req
                ~f:D.html
                ~no_htmx:(fun x -> 
                    Dream_html.(
                        to_string 
                        @@ T.page ~title:"midori's devlog" 
                        @@ HTML.main [] [txt ~raw:true "%s" x])) 
            @@ Dream_html.to_string @@ T.p "");

        D.get "/game" (fun req ->
            let new_game () =
                let%lwt () = D.invalidate_session req in
                let new_game = TFE.string_of_game @@ TFE.new_game 4 in 
                let%lwt () = D.set_session_field req "game" new_game in
                Lwt.return new_game in
            let%lwt _game = 
                match D.session_field req "game" with
                | None -> new_game ()
                | Some game -> Lwt.return game in
            let rec handle_ws ws =
                match%lwt D.receive ws with
                | Some "x" -> 
                        let%lwt new_game = new_game () in 
                        let _ = D.send ws new_game in 
                        handle_ws ws
                | Some msg -> 
                        let game = TFE.handle_message msg in 
                        let _ = D.send ws game in
                        handle_ws ws
                | _ -> D.send ws "waiting"
            in
            Dream.websocket ~close:false handle_ws);

    ]
