type token =
  | CREATE
  | MOVE
  | SELECT
  | JOIN
  | GRANT
  | ACCESS_TO
  | REVOKE
  | SYSTEM
  | RESOURCE
  | RESOURCE_HANDLER
  | ATTRIBUTE
  | ATTRIBUTE_HANDLER
  | AGENT
  | IN
  | UNDER
  | TO
  | WITH
  | WITH_ENTRANCES_TO
  | GRANTED_AUTOMATICALLY_IF
  | AS
  | COMMA
  | LPAREN
  | RPAREN
  | AND
  | OR
  | ID of (string)
  | EOL
  | EOF

open Parsing;;
let _ = parse_error;;
# 1 "src/dsl/parser.mly"
 
    let file_exists = Sys.file_exists "/home/majkimge/Cambridge/DecentralisedDigitalIdentity/authentication_system/bin/parser/system_bin"
    open! Core
    open Authentication_system
    let system_table = ref (String.Map.empty)
    let () = (if file_exists then 
        system_table:= (Marshal.from_channel (In_channel.create "/home/majkimge/Cambridge/DecentralisedDigitalIdentity/authentication_system/bin/parser/system_bin") : System_new.t String.Map.t))
    let selected_system = ref ("")
    let selected_agent = ref (System_new.Node.agent "")
    let update_system system_name system = 
        system_table := Map.update (!system_table) system_name ~f:(fun _ -> system)
    let get_system name = match Map.find (!system_table) name with 
        |Some system -> system 
        |None -> raise_s [%message "No system with that name in the table" (name:string) (system_table:System_new.t String.Map.t ref)]
    let update_selected_system system = update_system (!selected_system) system
    let get_selected_system () = get_system (!selected_system);;
# 51 "src/dsl/parser.ml"
let yytransl_const = [|
  257 (* CREATE *);
  258 (* MOVE *);
  259 (* SELECT *);
  260 (* JOIN *);
  261 (* GRANT *);
  262 (* ACCESS_TO *);
  263 (* REVOKE *);
  264 (* SYSTEM *);
  265 (* RESOURCE *);
  266 (* RESOURCE_HANDLER *);
  267 (* ATTRIBUTE *);
  268 (* ATTRIBUTE_HANDLER *);
  269 (* AGENT *);
  270 (* IN *);
  271 (* UNDER *);
  272 (* TO *);
  273 (* WITH *);
  274 (* WITH_ENTRANCES_TO *);
  275 (* GRANTED_AUTOMATICALLY_IF *);
  276 (* AS *);
  277 (* COMMA *);
  278 (* LPAREN *);
  279 (* RPAREN *);
  280 (* AND *);
  281 (* OR *);
  283 (* EOL *);
    0 (* EOF *);
    0|]

let yytransl_block = [|
  282 (* ID *);
    0|]

let yylhs = "\255\255\
\001\000\004\000\004\000\002\000\002\000\002\000\005\000\005\000\
\005\000\006\000\006\000\007\000\007\000\008\000\009\000\009\000\
\009\000\009\000\010\000\010\000\011\000\011\000\012\000\013\000\
\013\000\013\000\013\000\013\000\014\000\014\000\014\000\014\000\
\014\000\014\000\015\000\015\000\015\000\015\000\015\000\015\000\
\016\000\017\000\017\000\017\000\017\000\017\000\018\000\003\000\
\003\000\000\000"

let yylen = "\002\000\
\003\000\000\000\002\000\005\000\005\000\005\000\003\000\006\000\
\006\000\008\000\008\000\001\000\003\000\003\000\001\000\003\000\
\003\000\003\000\000\000\002\000\004\000\007\000\007\000\001\000\
\001\000\001\000\001\000\001\000\005\000\005\000\004\000\004\000\
\007\000\007\000\005\000\005\000\004\000\004\000\007\000\007\000\
\004\000\001\000\001\000\001\000\001\000\001\000\002\000\000\000\
\003\000\002\000"

let yydefred = "\000\000\
\000\000\000\000\000\000\000\000\000\000\050\000\048\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\002\000\001\000\
\000\000\000\000\000\000\000\000\049\000\004\000\005\000\006\000\
\000\000\000\000\000\000\000\000\003\000\045\000\025\000\024\000\
\026\000\027\000\028\000\042\000\043\000\044\000\046\000\047\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\014\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\021\000\
\041\000\000\000\000\000\000\000\000\000\031\000\032\000\000\000\
\000\000\000\000\000\000\037\000\038\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\015\000\000\000\000\000\000\000\
\030\000\029\000\000\000\000\000\036\000\035\000\000\000\000\000\
\009\000\008\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\023\000\022\000\016\000\
\017\000\018\000\034\000\033\000\040\000\039\000\000\000\011\000\
\010\000\000\000\013\000"

let yydgoto = "\002\000\
\006\000\007\000\011\000\020\000\031\000\032\000\128\000\033\000\
\094\000\072\000\034\000\035\000\036\000\037\000\038\000\039\000\
\040\000\021\000"

let yysindex = "\016\000\
\042\255\000\000\020\255\023\255\054\255\000\000\000\000\037\255\
\038\255\039\255\001\000\046\255\048\255\049\255\000\000\000\000\
\044\255\050\255\051\255\005\255\000\000\000\000\000\000\000\000\
\026\255\052\255\250\254\007\255\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\053\255\055\255\056\255\057\255\058\255\059\255\016\255\010\255\
\032\255\012\255\060\255\066\255\070\255\000\255\000\000\061\255\
\062\255\063\255\041\255\064\255\065\255\067\255\068\255\043\255\
\069\255\071\255\045\255\047\255\074\255\080\255\018\255\000\000\
\000\000\079\255\081\255\073\255\075\255\000\000\000\000\083\255\
\085\255\077\255\078\255\000\000\000\000\082\255\084\255\086\255\
\087\255\088\255\089\255\018\255\000\000\034\255\094\255\095\255\
\000\000\000\000\096\255\098\255\000\000\000\000\093\255\099\255\
\000\000\000\000\097\255\097\255\024\255\018\255\018\255\092\255\
\100\255\101\255\102\255\103\255\103\255\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\104\255\000\000\
\000\000\103\255\000\000"

let yyrindex = "\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\002\000\000\000\003\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\004\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\003\000\003\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\005\000\000\000\
\000\000\000\000\000\000"

let yygindex = "\000\000\
\000\000\047\000\000\000\000\000\000\000\000\000\153\255\000\000\
\175\255\209\255\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000"

let yytablesize = 288
let yytable = "\047\000\
\016\000\007\000\019\000\020\000\012\000\025\000\026\000\004\000\
\005\000\027\000\109\000\028\000\049\000\129\000\070\000\059\000\
\001\000\064\000\071\000\048\000\060\000\061\000\065\000\066\000\
\057\000\058\000\131\000\008\000\121\000\122\000\009\000\029\000\
\050\000\008\000\041\000\042\000\043\000\044\000\045\000\092\000\
\062\000\063\000\003\000\093\000\004\000\005\000\120\000\110\000\
\111\000\076\000\077\000\082\000\083\000\086\000\087\000\088\000\
\089\000\110\000\111\000\118\000\119\000\010\000\012\000\013\000\
\014\000\017\000\030\000\018\000\019\000\022\000\000\000\000\000\
\000\000\067\000\056\000\023\000\024\000\046\000\051\000\068\000\
\052\000\053\000\054\000\055\000\069\000\090\000\073\000\074\000\
\075\000\078\000\079\000\091\000\080\000\081\000\084\000\095\000\
\085\000\096\000\097\000\099\000\098\000\100\000\101\000\102\000\
\112\000\113\000\114\000\103\000\115\000\104\000\116\000\105\000\
\106\000\107\000\108\000\071\000\117\000\123\000\000\000\000\000\
\000\000\000\000\000\000\000\000\130\000\124\000\125\000\126\000\
\127\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\015\000\007\000\019\000\020\000\012\000"

let yycheck = "\006\001\
\000\000\000\000\000\000\000\000\000\000\001\001\002\001\003\001\
\004\001\005\001\092\000\007\001\006\001\117\000\015\001\006\001\
\001\000\006\001\019\001\026\001\011\001\012\001\011\001\012\001\
\009\001\010\001\130\000\008\001\110\000\111\000\008\001\027\001\
\026\001\008\001\009\001\010\001\011\001\012\001\013\001\022\001\
\009\001\010\001\001\001\026\001\003\001\004\001\023\001\024\001\
\025\001\009\001\010\001\009\001\010\001\009\001\010\001\009\001\
\010\001\024\001\025\001\107\000\108\000\008\001\026\001\026\001\
\026\001\020\001\020\000\020\001\020\001\026\001\255\255\255\255\
\255\255\014\001\016\001\026\001\026\001\026\001\026\001\014\001\
\026\001\026\001\026\001\026\001\015\001\012\001\026\001\026\001\
\026\001\026\001\026\001\012\001\026\001\026\001\026\001\017\001\
\026\001\017\001\026\001\017\001\026\001\017\001\026\001\026\001\
\011\001\011\001\011\001\026\001\011\001\026\001\018\001\026\001\
\026\001\026\001\026\001\019\001\018\001\026\001\255\255\255\255\
\255\255\255\255\255\255\255\255\021\001\026\001\026\001\026\001\
\026\001\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\027\001\027\001\027\001\027\001\027\001"

let yynames_const = "\
  CREATE\000\
  MOVE\000\
  SELECT\000\
  JOIN\000\
  GRANT\000\
  ACCESS_TO\000\
  REVOKE\000\
  SYSTEM\000\
  RESOURCE\000\
  RESOURCE_HANDLER\000\
  ATTRIBUTE\000\
  ATTRIBUTE_HANDLER\000\
  AGENT\000\
  IN\000\
  UNDER\000\
  TO\000\
  WITH\000\
  WITH_ENTRANCES_TO\000\
  GRANTED_AUTOMATICALLY_IF\000\
  AS\000\
  COMMA\000\
  LPAREN\000\
  RPAREN\000\
  AND\000\
  OR\000\
  EOL\000\
  EOF\000\
  "

let yynames_block = "\
  ID\000\
  "

let yyact = [|
  (fun _ -> failwith "parser")
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'init_line) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'lines) in
    Obj.repr(
# 35 "src/dsl/parser.mly"
                            ( Marshal.to_channel (Out_channel.create "/home/majkimge/Cambridge/DecentralisedDigitalIdentity/authentication_system/bin/parser/system_bin") (!system_table) [Closures]; 
                                              _2
                                             )
# 292 "src/dsl/parser.ml"
               : Authentication_system.System_new.t))
; (fun __caml_parser_env ->
    Obj.repr(
# 40 "src/dsl/parser.mly"
                ()
# 298 "src/dsl/parser.ml"
               : 'empty_lines))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'empty_lines) in
    Obj.repr(
# 41 "src/dsl/parser.mly"
                     ()
# 305 "src/dsl/parser.ml"
               : 'empty_lines))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 44 "src/dsl/parser.mly"
                            (
                                let admin = System_new.Node.agent _5 in
                                let system = System_new.create admin _3 in 
                                let () = selected_system := _3 in 
                                let () = update_system _3 system in 
                                let () = selected_agent := admin in
                                system
                            )
# 320 "src/dsl/parser.ml"
               : 'init_line))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 52 "src/dsl/parser.mly"
                                  (
                                let () = selected_system := _3 in 
                                let () = selected_agent := System_new.Node.agent _5 in
                                get_system _3
                            )
# 332 "src/dsl/parser.ml"
               : 'init_line))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 57 "src/dsl/parser.mly"
                                (
                                let () = selected_system := _3 in 
                                let agent = System_new.Node.agent _5 in
                                let system = get_system _3 in
                                let system = System_new.add_agent system ~agent in
                                let () = selected_agent := agent in
                                let () = update_system _3 system in 
                                system
                            )
# 348 "src/dsl/parser.ml"
               : 'init_line))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 71 "src/dsl/parser.mly"
                                   (
                                let resource_handler = System_new.Node.resource_handler _3 in
                                let system = get_selected_system () in
                                System_new.add_resource_handler system ~maintainer:(!selected_agent) ~resource_handler
                                    ~parent:System_new.root_node
                            )
# 360 "src/dsl/parser.ml"
               : 'add_resource_handler_line))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _6 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 77 "src/dsl/parser.mly"
                                                         (
                                let resource_handler = System_new.Node.resource_handler _3 in
                                let system = get_selected_system () in
                                let parent = System_new.Node.resource_handler _6 in
                                System_new.add_resource_handler system ~maintainer:(!selected_agent) ~resource_handler
                                    ~parent
                            )
# 374 "src/dsl/parser.ml"
               : 'add_resource_handler_line))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _6 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 84 "src/dsl/parser.mly"
                                                 (
                                let resource_handler = System_new.Node.resource_handler _3 in
                                let system = get_selected_system () in
                                let parent = System_new.Node.resource _6 in
                                System_new.add_resource_handler system ~maintainer:(!selected_agent) ~resource_handler
                                    ~parent
                            )
# 388 "src/dsl/parser.ml"
               : 'add_resource_handler_line))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 5 : string) in
    let _6 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _8 = (Parsing.peek_val __caml_parser_env 0 : 'resource_list) in
    Obj.repr(
# 92 "src/dsl/parser.mly"
                                                                                 (
                                let resource = System_new.Node.resource _3 in
                                let system = get_selected_system () in
                                let parent = System_new.Node.resource_handler _6 in
                                System_new.add_resource system resource ~parent
                                    ~entrances:_8
                            )
# 403 "src/dsl/parser.ml"
               : 'add_resource_line))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 5 : string) in
    let _6 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _8 = (Parsing.peek_val __caml_parser_env 0 : 'resource_list) in
    Obj.repr(
# 99 "src/dsl/parser.mly"
                                                                          (
                                let resource = System_new.Node.resource _3 in
                                let system = get_selected_system () in
                                let parent = System_new.Node.resource _6 in
                                System_new.add_resource system resource ~parent
                                    ~entrances:_8
                            )
# 418 "src/dsl/parser.ml"
               : 'add_resource_line))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 107 "src/dsl/parser.mly"
             ([System_new.Node.resource _1])
# 425 "src/dsl/parser.ml"
               : 'resource_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'resource_list) in
    Obj.repr(
# 108 "src/dsl/parser.mly"
                             ((System_new.Node.resource _1) :: _3)
# 433 "src/dsl/parser.ml"
               : 'resource_list))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 111 "src/dsl/parser.mly"
                        (
                                let agent = System_new.Node.agent _3 in
                                let system = get_selected_system () in
                                System_new.add_agent system ~agent
                            )
# 444 "src/dsl/parser.ml"
               : 'add_agent_line))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 119 "src/dsl/parser.mly"
                (let system = get_selected_system () in
                let attribute_id = System_new.Node.attribute_id _1 in
                System_new.Node.Attribute_required (System_new.get_attribute_by_id system attribute_id))
# 453 "src/dsl/parser.ml"
               : 'attribute_condition))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'attribute_condition) in
    Obj.repr(
# 122 "src/dsl/parser.mly"
                                       (_2)
# 460 "src/dsl/parser.ml"
               : 'attribute_condition))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'attribute_condition) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'attribute_condition) in
    Obj.repr(
# 123 "src/dsl/parser.mly"
                                                 (System_new.Node.And (_1, _3))
# 468 "src/dsl/parser.ml"
               : 'attribute_condition))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'attribute_condition) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'attribute_condition) in
    Obj.repr(
# 124 "src/dsl/parser.mly"
                                                (System_new.Node.Or (_1, _3))
# 476 "src/dsl/parser.ml"
               : 'attribute_condition))
; (fun __caml_parser_env ->
    Obj.repr(
# 127 "src/dsl/parser.mly"
                    (System_new.Node.Never)
# 482 "src/dsl/parser.ml"
               : 'with_attribute_condition))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'attribute_condition) in
    Obj.repr(
# 128 "src/dsl/parser.mly"
                                                      (_2)
# 489 "src/dsl/parser.ml"
               : 'with_attribute_condition))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 1 : string) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : 'with_attribute_condition) in
    Obj.repr(
# 131 "src/dsl/parser.mly"
                                                           (
                                let attribute_handler = System_new.Node.attribute_handler _3 _4 in
                                let system = get_selected_system () in
                                System_new.add_attribute_handler_under_agent system ~attribute_handler ~agent:(!selected_agent)
                            )
# 501 "src/dsl/parser.ml"
               : 'add_attribute_handler_line))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 4 : string) in
    let _6 = (Parsing.peek_val __caml_parser_env 1 : string) in
    let _7 = (Parsing.peek_val __caml_parser_env 0 : 'with_attribute_condition) in
    Obj.repr(
# 136 "src/dsl/parser.mly"
                                                                                     (
                                let attribute_handler = System_new.Node.attribute_handler _3 _7 in
                                let system = get_selected_system () in
                                let attribute_id = System_new.Node.attribute_id _6 in

                                let parent_maintainer = System_new.get_attribute_handler_by_id system attribute_id in
                                System_new.add_attribute_handler_under_maintainer system 
                                ~attribute_handler ~attribute_handler_maintainer:(System_new.Node.attribute_handler_node_of_attribute_handler parent_maintainer)
                            )
# 518 "src/dsl/parser.ml"
               : 'add_attribute_handler_line))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 4 : string) in
    let _6 = (Parsing.peek_val __caml_parser_env 1 : string) in
    let _7 = (Parsing.peek_val __caml_parser_env 0 : 'with_attribute_condition) in
    Obj.repr(
# 147 "src/dsl/parser.mly"
                                                                            (
                                let attribute = System_new.Node.attribute _3 _7 in
                                let system = get_selected_system () in
                                let attribute_id = System_new.Node.attribute_id _6 in
                                let attribute_handler = System_new.get_attribute_handler_by_id system attribute_id in
                                System_new.add_attribute system ~attribute ~attribute_handler:(System_new.Node.attribute_handler_node_of_attribute_handler attribute_handler)

                            )
# 534 "src/dsl/parser.ml"
               : 'add_attribute_line))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'add_resource_line) in
    Obj.repr(
# 156 "src/dsl/parser.mly"
                      (_1)
# 541 "src/dsl/parser.ml"
               : 'add_line))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'add_resource_handler_line) in
    Obj.repr(
# 157 "src/dsl/parser.mly"
                               (_1)
# 548 "src/dsl/parser.ml"
               : 'add_line))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'add_agent_line) in
    Obj.repr(
# 158 "src/dsl/parser.mly"
                    (_1)
# 555 "src/dsl/parser.ml"
               : 'add_line))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'add_attribute_handler_line) in
    Obj.repr(
# 159 "src/dsl/parser.mly"
                                (_1)
# 562 "src/dsl/parser.ml"
               : 'add_line))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'add_attribute_line) in
    Obj.repr(
# 160 "src/dsl/parser.mly"
                        (_1)
# 569 "src/dsl/parser.ml"
               : 'add_line))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 163 "src/dsl/parser.mly"
                                           (let to_ =  System_new.Node.resource_handler _5 in 
                                        let from = System_new.Node.agent _2 in
                                        let system = get_selected_system () in 
                                        System_new.grant_access system ~agent:(!selected_agent) ~from ~to_
                                        
                                        )
# 582 "src/dsl/parser.ml"
               : 'grant_line))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 169 "src/dsl/parser.mly"
                                    (let to_ =  System_new.Node.resource _5 in 
                                        let from = System_new.Node.agent _2 in
                                        let system = get_selected_system () in 
                                        System_new.grant_access system ~agent:(!selected_agent) ~from ~to_
                                        
                                        )
# 595 "src/dsl/parser.ml"
               : 'grant_line))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 175 "src/dsl/parser.mly"
                           (
                                        let from = System_new.Node.agent _2 in
                                        let system = get_selected_system () in 
                                        let attribute_id = System_new.Node.attribute_id _4 in
                                        let to_ = System_new.get_attribute_by_id system attribute_id |> System_new.Node.attribute_node_of_attribute in
                                        System_new.grant_attribute system ~agent:(!selected_agent) ~from ~to_
                                        
                                        )
# 610 "src/dsl/parser.ml"
               : 'grant_line))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 183 "src/dsl/parser.mly"
                                   (
                                        let from = System_new.Node.agent _2 in
                                        let system = get_selected_system () in 
                                        let attribute_handler_id = System_new.Node.attribute_id _4 in
                                        let to_ = System_new.get_attribute_handler_by_id system attribute_handler_id |>
                                        System_new.Node.attribute_handler_node_of_attribute_handler in
                                        System_new.grant_attribute system ~agent:(!selected_agent) ~from ~to_
                                        
                                        )
# 626 "src/dsl/parser.ml"
               : 'grant_line))
; (fun __caml_parser_env ->
    let _4 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _7 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 192 "src/dsl/parser.mly"
                                                           (
                                        let system = get_selected_system () in 
                                        let attribute_id = System_new.Node.attribute_id _7 in
                                        let from = System_new.get_attribute_by_id system attribute_id |> System_new.Node.attribute_node_of_attribute in
                                        let to_ = System_new.Node.resource_handler _4 in
                                        System_new.automatic_permission system ~agent:(!selected_agent) ~from ~to_
                                        
                                        )
# 641 "src/dsl/parser.ml"
               : 'grant_line))
; (fun __caml_parser_env ->
    let _4 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _7 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 200 "src/dsl/parser.mly"
                                                   (
                                        let system = get_selected_system () in 
                                        let attribute_id = System_new.Node.attribute_id _7 in
                                        let from = System_new.get_attribute_by_id system attribute_id |> System_new.Node.attribute_node_of_attribute in
                                        let to_ = System_new.Node.resource _4 in
                                        System_new.automatic_permission system ~agent:(!selected_agent) ~from ~to_
                                        )
# 655 "src/dsl/parser.ml"
               : 'grant_line))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 209 "src/dsl/parser.mly"
                                            (let to_ =  System_new.Node.resource_handler _5 in 
                                        let from = System_new.Node.agent _2 in
                                        let system = get_selected_system () in 
                                        System_new.revoke_access system ~agent:(!selected_agent) ~from ~to_
                                        
                                        )
# 668 "src/dsl/parser.ml"
               : 'revoke_line))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 215 "src/dsl/parser.mly"
                                     (let to_ =  System_new.Node.resource _5 in 
                                        let from = System_new.Node.agent _2 in
                                        let system = get_selected_system () in 
                                        System_new.revoke_access system ~agent:(!selected_agent) ~from ~to_
                                        
                                        )
# 681 "src/dsl/parser.ml"
               : 'revoke_line))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 221 "src/dsl/parser.mly"
                            (
                                        let from = System_new.Node.agent _2 in
                                        let system = get_selected_system () in 
                                        let attribute_id = System_new.Node.attribute_id _4 in
                                        let to_ = System_new.get_attribute_by_id system attribute_id |> System_new.Node.attribute_node_of_attribute in
                                        System_new.revoke_attribute system ~agent:(!selected_agent) ~from ~to_
                                        
                                        )
# 696 "src/dsl/parser.ml"
               : 'revoke_line))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 229 "src/dsl/parser.mly"
                                    (
                                        let from = System_new.Node.agent _2 in
                                        let system = get_selected_system () in 
                                        let attribute_handler_id = System_new.Node.attribute_id _4 in
                                        let to_ = System_new.get_attribute_handler_by_id system attribute_handler_id |>
                                        System_new.Node.attribute_handler_node_of_attribute_handler in
                                        System_new.revoke_attribute system ~agent:(!selected_agent) ~from ~to_
                                        
                                        )
# 712 "src/dsl/parser.ml"
               : 'revoke_line))
; (fun __caml_parser_env ->
    let _4 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _7 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 238 "src/dsl/parser.mly"
                                                            (
                                        let system = get_selected_system () in 
                                        let attribute_id = System_new.Node.attribute_id _7 in
                                        let from = System_new.get_attribute_by_id system attribute_id |> System_new.Node.attribute_node_of_attribute in
                                        let to_ = System_new.Node.resource_handler _4 in
                                        System_new.revoke_automatic_permission system ~agent:(!selected_agent) ~from ~to_
                                        
                                        )
# 727 "src/dsl/parser.ml"
               : 'revoke_line))
; (fun __caml_parser_env ->
    let _4 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _7 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 246 "src/dsl/parser.mly"
                                                    (
                                        let system = get_selected_system () in 
                                        let attribute_id = System_new.Node.attribute_id _7 in
                                        let from = System_new.get_attribute_by_id system attribute_id |> System_new.Node.attribute_node_of_attribute in
                                        let to_ = System_new.Node.resource _4 in
                                        System_new.revoke_automatic_permission system ~agent:(!selected_agent) ~from ~to_
                                        )
# 741 "src/dsl/parser.ml"
               : 'revoke_line))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 255 "src/dsl/parser.mly"
                                    (
                                        let agent = System_new.Node.agent _2 in 
                                        let system = get_selected_system () in 
                                        let to_ = System_new.Node.resource _4 in 
                                        System_new.move_agent system ~agent ~to_

                                    )
# 755 "src/dsl/parser.ml"
               : 'move_line))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'add_line) in
    Obj.repr(
# 264 "src/dsl/parser.mly"
               (let () = update_selected_system _1 in _1)
# 762 "src/dsl/parser.ml"
               : 'content_line))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'grant_line) in
    Obj.repr(
# 265 "src/dsl/parser.mly"
                 (let () = update_selected_system _1 in _1)
# 769 "src/dsl/parser.ml"
               : 'content_line))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'revoke_line) in
    Obj.repr(
# 266 "src/dsl/parser.mly"
                  (let () = update_selected_system _1 in _1)
# 776 "src/dsl/parser.ml"
               : 'content_line))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'init_line) in
    Obj.repr(
# 267 "src/dsl/parser.mly"
                 (_1)
# 783 "src/dsl/parser.ml"
               : 'content_line))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'move_line) in
    Obj.repr(
# 268 "src/dsl/parser.mly"
                (let () = update_selected_system _1 in _1)
# 790 "src/dsl/parser.ml"
               : 'content_line))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'empty_lines) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'content_line) in
    Obj.repr(
# 271 "src/dsl/parser.mly"
                             (
      Yojson.to_file "system_rep"
        (Authentication_system.System_new.to_json _2);
      _2)
# 801 "src/dsl/parser.ml"
               : 'line))
; (fun __caml_parser_env ->
    Obj.repr(
# 276 "src/dsl/parser.mly"
              (get_selected_system ())
# 807 "src/dsl/parser.ml"
               : 'lines))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'lines) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'line) in
    Obj.repr(
# 277 "src/dsl/parser.mly"
                    (_3)
# 815 "src/dsl/parser.ml"
               : 'lines))
(* Entry main *)
; (fun __caml_parser_env -> raise (Parsing.YYexit (Parsing.peek_val __caml_parser_env 0)))
|]
let yytables =
  { Parsing.actions=yyact;
    Parsing.transl_const=yytransl_const;
    Parsing.transl_block=yytransl_block;
    Parsing.lhs=yylhs;
    Parsing.len=yylen;
    Parsing.defred=yydefred;
    Parsing.dgoto=yydgoto;
    Parsing.sindex=yysindex;
    Parsing.rindex=yyrindex;
    Parsing.gindex=yygindex;
    Parsing.tablesize=yytablesize;
    Parsing.table=yytable;
    Parsing.check=yycheck;
    Parsing.error_function=parse_error;
    Parsing.names_const=yynames_const;
    Parsing.names_block=yynames_block }
let main (lexfun : Lexing.lexbuf -> token) (lexbuf : Lexing.lexbuf) =
   (Parsing.yyparse yytables 1 lexfun lexbuf : Authentication_system.System_new.t)
