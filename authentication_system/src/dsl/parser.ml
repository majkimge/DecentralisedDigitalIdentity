type token =
  | CREATE
  | MOVE
  | SELECT
  | JOIN
  | GRANT
  | ACCESS_TO
  | SYSTEM
  | LOCATION
  | ORGANISATION
  | ATTRIBUTE
  | ATTRIBUTE_HANDLER
  | OPERATOR
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
    let selected_operator = ref (System_new.Node.operator "")
    let update_system system_name system = 
        system_table := Map.update (!system_table) system_name ~f:(fun _ -> system)
    let get_system name = match Map.find (!system_table) name with 
        |Some system -> system 
        |None -> raise_s [%message "No system with that name in the table" (name:string) (system_table:System_new.t String.Map.t ref)]
    let update_selected_system system = update_system (!selected_system) system
    let get_selected_system () = get_system (!selected_system);;
# 50 "src/dsl/parser.ml"
let yytransl_const = [|
  257 (* CREATE *);
  258 (* MOVE *);
  259 (* SELECT *);
  260 (* JOIN *);
  261 (* GRANT *);
  262 (* ACCESS_TO *);
  263 (* SYSTEM *);
  264 (* LOCATION *);
  265 (* ORGANISATION *);
  266 (* ATTRIBUTE *);
  267 (* ATTRIBUTE_HANDLER *);
  268 (* OPERATOR *);
  269 (* IN *);
  270 (* UNDER *);
  271 (* TO *);
  272 (* WITH *);
  273 (* WITH_ENTRANCES_TO *);
  274 (* GRANTED_AUTOMATICALLY_IF *);
  275 (* AS *);
  276 (* COMMA *);
  277 (* LPAREN *);
  278 (* RPAREN *);
  279 (* AND *);
  280 (* OR *);
  282 (* EOL *);
    0 (* EOF *);
    0|]

let yytransl_block = [|
  281 (* ID *);
    0|]

let yylhs = "\255\255\
\001\000\004\000\004\000\002\000\002\000\002\000\005\000\005\000\
\005\000\006\000\006\000\007\000\007\000\008\000\009\000\009\000\
\009\000\009\000\010\000\010\000\011\000\011\000\012\000\013\000\
\013\000\013\000\013\000\013\000\014\000\014\000\014\000\014\000\
\014\000\014\000\015\000\016\000\016\000\016\000\016\000\017\000\
\003\000\003\000\000\000"

let yylen = "\002\000\
\003\000\000\000\002\000\005\000\005\000\005\000\003\000\006\000\
\006\000\008\000\008\000\001\000\003\000\003\000\001\000\003\000\
\003\000\003\000\000\000\002\000\004\000\007\000\007\000\001\000\
\001\000\001\000\001\000\001\000\005\000\005\000\004\000\004\000\
\007\000\007\000\004\000\001\000\001\000\001\000\001\000\002\000\
\000\000\003\000\002\000"

let yydefred = "\000\000\
\000\000\000\000\000\000\000\000\000\000\043\000\041\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\002\000\001\000\
\000\000\000\000\000\000\000\000\042\000\004\000\005\000\006\000\
\000\000\000\000\000\000\003\000\038\000\025\000\024\000\026\000\
\027\000\028\000\036\000\037\000\039\000\040\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\014\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\021\000\035\000\
\000\000\000\000\000\000\000\000\031\000\032\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\015\000\000\000\000\000\
\000\000\030\000\029\000\000\000\000\000\009\000\008\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\023\000\022\000\016\000\017\000\018\000\034\000\033\000\000\000\
\011\000\010\000\000\000\013\000"

let yydgoto = "\002\000\
\006\000\007\000\011\000\020\000\030\000\031\000\105\000\032\000\
\079\000\063\000\033\000\034\000\035\000\036\000\037\000\038\000\
\021\000"

let yysindex = "\026\000\
\034\255\000\000\026\255\044\255\045\255\000\000\000\000\028\255\
\029\255\030\255\001\000\038\255\039\255\040\255\000\000\000\000\
\036\255\041\255\042\255\005\255\000\000\000\000\000\000\000\000\
\006\255\043\255\250\254\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\046\255\047\255\
\048\255\049\255\050\255\054\255\031\255\018\255\051\255\052\255\
\056\255\016\255\000\000\053\255\055\255\057\255\033\255\058\255\
\059\255\035\255\037\255\065\255\066\255\011\255\000\000\000\000\
\063\255\069\255\061\255\062\255\000\000\000\000\064\255\067\255\
\068\255\070\255\071\255\072\255\011\255\000\000\024\255\078\255\
\080\255\000\000\000\000\074\255\077\255\000\000\000\000\081\255\
\081\255\254\254\011\255\011\255\073\255\075\255\076\255\076\255\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\082\255\
\000\000\000\000\076\255\000\000"

let yyrindex = "\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\002\000\
\000\000\003\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\004\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\003\000\
\003\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\005\000\
\000\000\000\000\000\000\000\000"

let yygindex = "\000\000\
\000\000\036\000\000\000\000\000\000\000\000\000\172\255\000\000\
\190\255\217\255\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000"

let yytablesize = 287
let yytable = "\045\000\
\016\000\007\000\019\000\020\000\012\000\025\000\026\000\004\000\
\005\000\027\000\090\000\106\000\008\000\039\000\040\000\041\000\
\042\000\043\000\046\000\099\000\091\000\092\000\108\000\055\000\
\100\000\101\000\001\000\056\000\057\000\061\000\028\000\077\000\
\008\000\062\000\003\000\078\000\004\000\005\000\053\000\054\000\
\067\000\068\000\071\000\072\000\073\000\074\000\091\000\092\000\
\097\000\098\000\009\000\010\000\012\000\013\000\014\000\029\000\
\017\000\018\000\019\000\000\000\022\000\000\000\000\000\058\000\
\059\000\023\000\024\000\044\000\052\000\060\000\047\000\048\000\
\049\000\050\000\051\000\075\000\076\000\064\000\080\000\065\000\
\000\000\066\000\069\000\070\000\081\000\082\000\083\000\093\000\
\084\000\094\000\095\000\085\000\086\000\096\000\087\000\088\000\
\089\000\102\000\062\000\103\000\104\000\107\000\000\000\000\000\
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
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\015\000\007\000\019\000\020\000\012\000"

let yycheck = "\006\001\
\000\000\000\000\000\000\000\000\000\000\001\001\002\001\003\001\
\004\001\005\001\077\000\096\000\007\001\008\001\009\001\010\001\
\011\001\012\001\025\001\022\001\023\001\024\001\107\000\006\001\
\091\000\092\000\001\000\010\001\011\001\014\001\026\001\021\001\
\007\001\018\001\001\001\025\001\003\001\004\001\008\001\009\001\
\008\001\009\001\008\001\009\001\008\001\009\001\023\001\024\001\
\088\000\089\000\007\001\007\001\025\001\025\001\025\001\020\000\
\019\001\019\001\019\001\255\255\025\001\255\255\255\255\013\001\
\013\001\025\001\025\001\025\001\015\001\014\001\025\001\025\001\
\025\001\025\001\025\001\011\001\011\001\025\001\016\001\025\001\
\255\255\025\001\025\001\025\001\016\001\025\001\025\001\010\001\
\025\001\010\001\017\001\025\001\025\001\017\001\025\001\025\001\
\025\001\025\001\018\001\025\001\025\001\020\001\255\255\255\255\
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
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\026\001\026\001\026\001\026\001\026\001"

let yynames_const = "\
  CREATE\000\
  MOVE\000\
  SELECT\000\
  JOIN\000\
  GRANT\000\
  ACCESS_TO\000\
  SYSTEM\000\
  LOCATION\000\
  ORGANISATION\000\
  ATTRIBUTE\000\
  ATTRIBUTE_HANDLER\000\
  OPERATOR\000\
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
# 278 "src/dsl/parser.ml"
               : Authentication_system.System_new.t))
; (fun __caml_parser_env ->
    Obj.repr(
# 40 "src/dsl/parser.mly"
                ()
# 284 "src/dsl/parser.ml"
               : 'empty_lines))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'empty_lines) in
    Obj.repr(
# 41 "src/dsl/parser.mly"
                     ()
# 291 "src/dsl/parser.ml"
               : 'empty_lines))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 44 "src/dsl/parser.mly"
                            (
                                let admin = System_new.Node.operator _5 in
                                let system = System_new.create admin _3 in 
                                let () = selected_system := _3 in 
                                let () = update_system _3 system in 
                                let () = selected_operator := admin in
                                system
                            )
# 306 "src/dsl/parser.ml"
               : 'init_line))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 52 "src/dsl/parser.mly"
                                  (
                                let () = selected_system := _3 in 
                                let () = selected_operator := System_new.Node.operator _5 in
                                get_system _3
                            )
# 318 "src/dsl/parser.ml"
               : 'init_line))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 57 "src/dsl/parser.mly"
                                (
                                let () = selected_system := _3 in 
                                let operator = System_new.Node.operator _5 in
                                let system = get_system _3 in
                                let system = System_new.add_operator system ~operator in
                                let () = selected_operator := operator in
                                let () = update_system _3 system in 
                                system
                            )
# 334 "src/dsl/parser.ml"
               : 'init_line))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 71 "src/dsl/parser.mly"
                               (
                                let organisation = System_new.Node.organisation _3 in
                                let system = get_selected_system () in
                                System_new.add_organisation system ~maintainer:(!selected_operator) ~organisation
                                    ~parent:System_new.root_node
                            )
# 346 "src/dsl/parser.ml"
               : 'add_organisation_line))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _6 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 77 "src/dsl/parser.mly"
                                                 (
                                let organisation = System_new.Node.organisation _3 in
                                let system = get_selected_system () in
                                let parent = System_new.Node.organisation _6 in
                                System_new.add_organisation system ~maintainer:(!selected_operator) ~organisation
                                    ~parent
                            )
# 360 "src/dsl/parser.ml"
               : 'add_organisation_line))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _6 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 84 "src/dsl/parser.mly"
                                             (
                                let organisation = System_new.Node.organisation _3 in
                                let system = get_selected_system () in
                                let parent = System_new.Node.location _6 in
                                System_new.add_organisation system ~maintainer:(!selected_operator) ~organisation
                                    ~parent
                            )
# 374 "src/dsl/parser.ml"
               : 'add_organisation_line))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 5 : string) in
    let _6 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _8 = (Parsing.peek_val __caml_parser_env 0 : 'location_list) in
    Obj.repr(
# 92 "src/dsl/parser.mly"
                                                                             (
                                let location = System_new.Node.location _3 in
                                let system = get_selected_system () in
                                let parent = System_new.Node.organisation _6 in
                                System_new.add_location system location ~parent
                                    ~entrances:_8
                            )
# 389 "src/dsl/parser.ml"
               : 'add_location_line))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 5 : string) in
    let _6 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _8 = (Parsing.peek_val __caml_parser_env 0 : 'location_list) in
    Obj.repr(
# 99 "src/dsl/parser.mly"
                                                                          (
                                let location = System_new.Node.location _3 in
                                let system = get_selected_system () in
                                let parent = System_new.Node.location _6 in
                                System_new.add_location system location ~parent
                                    ~entrances:_8
                            )
# 404 "src/dsl/parser.ml"
               : 'add_location_line))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 107 "src/dsl/parser.mly"
             ([System_new.Node.location _1])
# 411 "src/dsl/parser.ml"
               : 'location_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'location_list) in
    Obj.repr(
# 108 "src/dsl/parser.mly"
                             ((System_new.Node.location _1) :: _3)
# 419 "src/dsl/parser.ml"
               : 'location_list))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 111 "src/dsl/parser.mly"
                           (
                                let operator = System_new.Node.operator _3 in
                                let system = get_selected_system () in
                                System_new.add_operator system ~operator
                            )
# 430 "src/dsl/parser.ml"
               : 'add_operator_line))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 119 "src/dsl/parser.mly"
                (let system = get_selected_system () in
                let attribute_id = System_new.Node.attribute_id _1 in
                System_new.Node.Attribute_required (System_new.get_attribute_by_id system attribute_id))
# 439 "src/dsl/parser.ml"
               : 'attribute_condition))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'attribute_condition) in
    Obj.repr(
# 122 "src/dsl/parser.mly"
                                       (_2)
# 446 "src/dsl/parser.ml"
               : 'attribute_condition))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'attribute_condition) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'attribute_condition) in
    Obj.repr(
# 123 "src/dsl/parser.mly"
                                                 (System_new.Node.And (_1, _3))
# 454 "src/dsl/parser.ml"
               : 'attribute_condition))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'attribute_condition) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'attribute_condition) in
    Obj.repr(
# 124 "src/dsl/parser.mly"
                                                (System_new.Node.Or (_1, _3))
# 462 "src/dsl/parser.ml"
               : 'attribute_condition))
; (fun __caml_parser_env ->
    Obj.repr(
# 127 "src/dsl/parser.mly"
                    (System_new.Node.Never)
# 468 "src/dsl/parser.ml"
               : 'with_attribute_condition))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'attribute_condition) in
    Obj.repr(
# 128 "src/dsl/parser.mly"
                                                      (_2)
# 475 "src/dsl/parser.ml"
               : 'with_attribute_condition))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 1 : string) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : 'with_attribute_condition) in
    Obj.repr(
# 131 "src/dsl/parser.mly"
                                                           (
                                let attribute_maintainer = System_new.Node.attribute_maintainer _3 _4 in
                                let system = get_selected_system () in
                                System_new.add_attribute_maintainer_under_operator system ~attribute_maintainer ~operator:(!selected_operator)
                            )
# 487 "src/dsl/parser.ml"
               : 'add_attribute_handler_line))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 4 : string) in
    let _6 = (Parsing.peek_val __caml_parser_env 1 : string) in
    let _7 = (Parsing.peek_val __caml_parser_env 0 : 'with_attribute_condition) in
    Obj.repr(
# 136 "src/dsl/parser.mly"
                                                                                     (
                                let attribute_maintainer = System_new.Node.attribute_maintainer _3 _7 in
                                let system = get_selected_system () in
                                let attribute_id = System_new.Node.attribute_id _6 in

                                let parent_maintainer = System_new.get_attribute_maintainer_by_id system attribute_id in
                                System_new.add_attribute_maintainer_under_maintainer system 
                                ~attribute_maintainer ~attribute_maintainer_maintainer:(System_new.Node.attribute_maintainer_node_of_attribute_maintainer parent_maintainer)
                            )
# 504 "src/dsl/parser.ml"
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
                                let attribute_maintainer = System_new.get_attribute_maintainer_by_id system attribute_id in
                                System_new.add_attribute system ~attribute ~attribute_maintainer:(System_new.Node.attribute_maintainer_node_of_attribute_maintainer attribute_maintainer)

                            )
# 520 "src/dsl/parser.ml"
               : 'add_attribute_line))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'add_location_line) in
    Obj.repr(
# 156 "src/dsl/parser.mly"
                      (_1)
# 527 "src/dsl/parser.ml"
               : 'add_line))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'add_organisation_line) in
    Obj.repr(
# 157 "src/dsl/parser.mly"
                           (_1)
# 534 "src/dsl/parser.ml"
               : 'add_line))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'add_operator_line) in
    Obj.repr(
# 158 "src/dsl/parser.mly"
                       (_1)
# 541 "src/dsl/parser.ml"
               : 'add_line))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'add_attribute_handler_line) in
    Obj.repr(
# 159 "src/dsl/parser.mly"
                                (_1)
# 548 "src/dsl/parser.ml"
               : 'add_line))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'add_attribute_line) in
    Obj.repr(
# 160 "src/dsl/parser.mly"
                        (_1)
# 555 "src/dsl/parser.ml"
               : 'add_line))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 163 "src/dsl/parser.mly"
                                       (let to_ =  System_new.Node.organisation _5 in 
                                        let from = System_new.Node.operator _2 in
                                        let system = get_selected_system () in 
                                        System_new.add_permission_edge system ~operator:(!selected_operator) ~from ~to_
                                        
                                        )
# 568 "src/dsl/parser.ml"
               : 'grant_line))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 169 "src/dsl/parser.mly"
                                    (let to_ =  System_new.Node.location _5 in 
                                        let from = System_new.Node.operator _2 in
                                        let system = get_selected_system () in 
                                        System_new.add_permission_edge system ~operator:(!selected_operator) ~from ~to_
                                        
                                        )
# 581 "src/dsl/parser.ml"
               : 'grant_line))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 175 "src/dsl/parser.mly"
                           (
                                        let from = System_new.Node.operator _2 in
                                        let system = get_selected_system () in 
                                        let attribute_id = System_new.Node.attribute_id _4 in
                                        let to_ = System_new.get_attribute_by_id system attribute_id |> System_new.Node.attribute_node_of_attribute in
                                        System_new.add_permission_edge system ~operator:(!selected_operator) ~from ~to_
                                        
                                        )
# 596 "src/dsl/parser.ml"
               : 'grant_line))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 183 "src/dsl/parser.mly"
                                   (
                                        let from = System_new.Node.operator _2 in
                                        let system = get_selected_system () in 
                                        let attribute_maintainer_id = System_new.Node.attribute_id _4 in
                                        let to_ = System_new.get_attribute_maintainer_by_id system attribute_maintainer_id |>
                                        System_new.Node.attribute_maintainer_node_of_attribute_maintainer in
                                        System_new.add_permission_edge system ~operator:(!selected_operator) ~from ~to_
                                        
                                        )
# 612 "src/dsl/parser.ml"
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
                                        let to_ = System_new.Node.organisation _4 in
                                        System_new.add_permission_edge system ~operator:(!selected_operator) ~from ~to_
                                        
                                        )
# 627 "src/dsl/parser.ml"
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
                                        let to_ = System_new.Node.location _4 in
                                        System_new.add_permission_edge system ~operator:(!selected_operator) ~from ~to_
                                        )
# 641 "src/dsl/parser.ml"
               : 'grant_line))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 209 "src/dsl/parser.mly"
                                    (
                                        let operator = System_new.Node.operator _2 in 
                                        let system = get_selected_system () in 
                                        let to_ = System_new.Node.location _4 in 
                                        System_new.move_operator system ~operator ~to_

                                    )
# 655 "src/dsl/parser.ml"
               : 'move_line))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'add_line) in
    Obj.repr(
# 218 "src/dsl/parser.mly"
               (let () = update_selected_system _1 in _1)
# 662 "src/dsl/parser.ml"
               : 'content_line))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'grant_line) in
    Obj.repr(
# 219 "src/dsl/parser.mly"
                 (let () = update_selected_system _1 in _1)
# 669 "src/dsl/parser.ml"
               : 'content_line))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'init_line) in
    Obj.repr(
# 220 "src/dsl/parser.mly"
                 (_1)
# 676 "src/dsl/parser.ml"
               : 'content_line))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'move_line) in
    Obj.repr(
# 221 "src/dsl/parser.mly"
                (let () = update_selected_system _1 in _1)
# 683 "src/dsl/parser.ml"
               : 'content_line))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'empty_lines) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'content_line) in
    Obj.repr(
# 224 "src/dsl/parser.mly"
                             (
      Yojson.to_file "system_rep"
        (Authentication_system.System_new.to_json _2);
      _2)
# 694 "src/dsl/parser.ml"
               : 'line))
; (fun __caml_parser_env ->
    Obj.repr(
# 229 "src/dsl/parser.mly"
              (get_selected_system ())
# 700 "src/dsl/parser.ml"
               : 'lines))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'lines) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'line) in
    Obj.repr(
# 230 "src/dsl/parser.mly"
                    (_3)
# 708 "src/dsl/parser.ml"
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
