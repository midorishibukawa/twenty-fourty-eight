open Dream_html
open Types

val page : title : (node, unit, string, node) format4 -> node -> node

val article : string -> node

val p : string -> node

val game : game -> node
