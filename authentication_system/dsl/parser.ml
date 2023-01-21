type token =
  | CREATE
  | MOVE
  | SELECT
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
# 1 "dsl/parser.mly"
 
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
# 49 "dsl/parser.ml"
let yytransl_const = [|
  257 (* CREATE *);
  258 (* MOVE *);
  259 (* SELECT *);
  260 (* GRANT *);
  261 (* ACCESS_TO *);
  262 (* SYSTEM *);
  263 (* LOCATION *);
  264 (* ORGANISATION *);
  265 (* ATTRIBUTE *);
  266 (* ATTRIBUTE_HANDLER *);
  267 (* OPERATOR *);
  268 (* IN *);
  269 (* UNDER *);
  270 (* TO *);
  271 (* WITH *);
  272 (* WITH_ENTRANCES_TO *);
  273 (* GRANTED_AUTOMATICALLY_IF *);
  274 (* AS *);
  275 (* COMMA *);
  276 (* LPAREN *);
  277 (* RPAREN *);
  278 (* AND *);
  279 (* OR *);
  281 (* EOL *);
    0 (* EOF *);
    0|]

let yytransl_block = [|
  280 (* ID *);
    0|]

let yylhs = "\255\255\
\001\000\004\000\004\000\002\000\002\000\005\000\005\000\005\000\
\006\000\006\000\007\000\007\000\008\000\009\000\009\000\009\000\
\009\000\010\000\010\000\011\000\011\000\012\000\013\000\013\000\
\013\000\013\000\013\000\014\000\014\000\014\000\014\000\014\000\
\014\000\015\000\016\000\016\000\016\000\016\000\017\000\003\000\
\003\000\000\000"

let yylen = "\002\000\
\003\000\000\000\002\000\005\000\005\000\003\000\006\000\006\000\
\008\000\008\000\001\000\003\000\003\000\001\000\003\000\003\000\
\003\000\000\000\002\000\004\000\007\000\007\000\001\000\001\000\
\001\000\001\000\001\000\005\000\005\000\004\000\004\000\007\000\
\007\000\004\000\001\000\001\000\001\000\001\000\002\000\000\000\
\003\000\002\000"

let yydefred = "\000\000\
\000\000\000\000\000\000\000\000\042\000\040\000\000\000\000\000\
\000\000\000\000\000\000\002\000\001\000\000\000\000\000\000\000\
\041\000\004\000\005\000\000\000\000\000\000\000\003\000\035\000\
\024\000\023\000\025\000\026\000\027\000\036\000\037\000\038\000\
\039\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\013\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\020\000\034\000\000\000\000\000\000\000\000\000\030\000\
\031\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\014\000\000\000\000\000\000\000\029\000\028\000\000\000\000\000\
\008\000\007\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\022\000\021\000\015\000\016\000\017\000\
\033\000\032\000\000\000\010\000\009\000\000\000\012\000"

let yydgoto = "\002\000\
\005\000\006\000\009\000\016\000\025\000\026\000\100\000\027\000\
\074\000\058\000\028\000\029\000\030\000\031\000\032\000\033\000\
\017\000"

let yysindex = "\020\000\
\017\255\000\000\020\255\026\255\000\000\000\000\010\255\027\255\
\001\000\035\255\037\255\000\000\000\000\028\255\030\255\005\255\
\000\000\000\000\000\000\006\255\033\255\251\254\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\039\255\040\255\041\255\042\255\043\255\044\255\032\255\
\018\255\047\255\048\255\049\255\016\255\000\000\045\255\046\255\
\050\255\034\255\051\255\052\255\036\255\038\255\058\255\061\255\
\011\255\000\000\000\000\057\255\062\255\054\255\055\255\000\000\
\000\000\056\255\059\255\060\255\063\255\064\255\065\255\011\255\
\000\000\025\255\072\255\073\255\000\000\000\000\069\255\070\255\
\000\000\000\000\074\255\074\255\015\255\011\255\011\255\066\255\
\068\255\071\255\071\255\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\075\255\000\000\000\000\071\255\000\000"

let yyrindex = "\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\002\000\000\000\003\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\004\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\003\000\003\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\005\000\000\000\000\000\000\000\000\000"

let yygindex = "\000\000\
\000\000\040\000\000\000\000\000\000\000\000\000\176\255\000\000\
\194\255\222\255\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000"

let yytablesize = 286
let yytable = "\040\000\
\013\000\006\000\018\000\019\000\011\000\020\000\021\000\004\000\
\022\000\085\000\101\000\007\000\034\000\035\000\036\000\037\000\
\038\000\003\000\041\000\004\000\001\000\103\000\050\000\095\000\
\096\000\007\000\051\000\052\000\056\000\023\000\072\000\008\000\
\057\000\010\000\073\000\094\000\086\000\087\000\048\000\049\000\
\062\000\063\000\066\000\067\000\068\000\069\000\086\000\087\000\
\092\000\093\000\011\000\018\000\014\000\019\000\015\000\024\000\
\039\000\047\000\053\000\054\000\000\000\055\000\042\000\043\000\
\044\000\045\000\046\000\070\000\059\000\060\000\071\000\075\000\
\000\000\061\000\064\000\065\000\076\000\077\000\078\000\079\000\
\088\000\089\000\080\000\081\000\090\000\091\000\082\000\083\000\
\084\000\097\000\057\000\098\000\000\000\102\000\099\000\000\000\
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
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\012\000\006\000\018\000\019\000\011\000"

let yycheck = "\005\001\
\000\000\000\000\000\000\000\000\000\000\001\001\002\001\003\001\
\004\001\072\000\091\000\006\001\007\001\008\001\009\001\010\001\
\011\001\001\001\024\001\003\001\001\000\102\000\005\001\086\000\
\087\000\006\001\009\001\010\001\013\001\025\001\020\001\006\001\
\017\001\024\001\024\001\021\001\022\001\023\001\007\001\008\001\
\007\001\008\001\007\001\008\001\007\001\008\001\022\001\023\001\
\083\000\084\000\024\001\024\001\018\001\024\001\018\001\016\000\
\024\001\014\001\012\001\012\001\255\255\013\001\024\001\024\001\
\024\001\024\001\024\001\010\001\024\001\024\001\010\001\015\001\
\255\255\024\001\024\001\024\001\015\001\024\001\024\001\024\001\
\009\001\009\001\024\001\024\001\016\001\016\001\024\001\024\001\
\024\001\024\001\017\001\024\001\255\255\019\001\024\001\255\255\
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
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\025\001\025\001\025\001\025\001\025\001"

let yynames_const = "\
  CREATE\000\
  MOVE\000\
  SELECT\000\
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
# 35 "dsl/parser.mly"
                             (print_string "Printing";print_string "AHKJSDHFKJSHDKJFHKDHFKHSKJFHKJHSDJFHKJSDH"; Marshal.to_channel (Out_channel.create "/home/majkimge/Cambridge/DecentralisedDigitalIdentity/authentication_system/bin/parser/system_bin") (!system_table) [Closures];
                                              _2
                                             )
# 272 "dsl/parser.ml"
               : Authentication_system.System_new.t))
; (fun __caml_parser_env ->
    Obj.repr(
# 40 "dsl/parser.mly"
                ()
# 278 "dsl/parser.ml"
               : 'empty_lines))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'empty_lines) in
    Obj.repr(
# 41 "dsl/parser.mly"
                     ()
# 285 "dsl/parser.ml"
               : 'empty_lines))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 44 "dsl/parser.mly"
                            (
                                let admin = System_new.Node.operator _5 in
                                let system = System_new.create admin _3 in 
                                let () = selected_system := _3 in 
                                let () = update_system _3 system in 
                                let () = selected_operator := admin in
                                system
                            )
# 300 "dsl/parser.ml"
               : 'init_line))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 52 "dsl/parser.mly"
                                  (
                                let () = selected_system := _3 in 
                                let () = selected_operator := System_new.Node.operator _5 in
                                get_system _3
                            )
# 312 "dsl/parser.ml"
               : 'init_line))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 61 "dsl/parser.mly"
                               (
                                let organisation = System_new.Node.organisation _3 in
                                let system = get_selected_system () in
                                System_new.add_organisation system ~maintainer:(!selected_operator) ~organisation
                                    ~parent:System_new.root_node
                            )
# 324 "dsl/parser.ml"
               : 'add_organisation_line))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _6 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 67 "dsl/parser.mly"
                                                 (
                                let organisation = System_new.Node.organisation _3 in
                                let system = get_selected_system () in
                                let parent = System_new.Node.organisation _6 in
                                System_new.add_organisation system ~maintainer:(!selected_operator) ~organisation
                                    ~parent
                            )
# 338 "dsl/parser.ml"
               : 'add_organisation_line))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _6 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 74 "dsl/parser.mly"
                                             (
                                let organisation = System_new.Node.organisation _3 in
                                let system = get_selected_system () in
                                let parent = System_new.Node.location _6 in
                                System_new.add_organisation system ~maintainer:(!selected_operator) ~organisation
                                    ~parent
                            )
# 352 "dsl/parser.ml"
               : 'add_organisation_line))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 5 : string) in
    let _6 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _8 = (Parsing.peek_val __caml_parser_env 0 : 'location_list) in
    Obj.repr(
# 82 "dsl/parser.mly"
                                                                             (
                                let location = System_new.Node.location _3 in
                                let system = get_selected_system () in
                                let parent = System_new.Node.organisation _6 in
                                System_new.add_location system location ~parent
                                    ~entrances:_8
                            )
# 367 "dsl/parser.ml"
               : 'add_location_line))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 5 : string) in
    let _6 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _8 = (Parsing.peek_val __caml_parser_env 0 : 'location_list) in
    Obj.repr(
# 89 "dsl/parser.mly"
                                                                          (
                                let location = System_new.Node.location _3 in
                                let system = get_selected_system () in
                                let parent = System_new.Node.location _6 in
                                System_new.add_location system location ~parent
                                    ~entrances:_8
                            )
# 382 "dsl/parser.ml"
               : 'add_location_line))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 97 "dsl/parser.mly"
             ([System_new.Node.location _1])
# 389 "dsl/parser.ml"
               : 'location_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'location_list) in
    Obj.repr(
# 98 "dsl/parser.mly"
                             ((System_new.Node.location _1) :: _3)
# 397 "dsl/parser.ml"
               : 'location_list))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 101 "dsl/parser.mly"
                           (
                                let operator = System_new.Node.operator _3 in
                                let system = get_selected_system () in
                                System_new.add_operator system ~operator
                            )
# 408 "dsl/parser.ml"
               : 'add_operator_line))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 109 "dsl/parser.mly"
                (let system = get_selected_system () in
                let attribute_id = System_new.Node.attribute_id _1 in
                System_new.Node.Attribute_required (System_new.get_attribute_by_id system attribute_id))
# 417 "dsl/parser.ml"
               : 'attribute_condition))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'attribute_condition) in
    Obj.repr(
# 112 "dsl/parser.mly"
                                       (_2)
# 424 "dsl/parser.ml"
               : 'attribute_condition))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'attribute_condition) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'attribute_condition) in
    Obj.repr(
# 113 "dsl/parser.mly"
                                                 (System_new.Node.And (_1, _3))
# 432 "dsl/parser.ml"
               : 'attribute_condition))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'attribute_condition) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'attribute_condition) in
    Obj.repr(
# 114 "dsl/parser.mly"
                                                (System_new.Node.Or (_1, _3))
# 440 "dsl/parser.ml"
               : 'attribute_condition))
; (fun __caml_parser_env ->
    Obj.repr(
# 117 "dsl/parser.mly"
                    (System_new.Node.Never)
# 446 "dsl/parser.ml"
               : 'with_attribute_condition))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'attribute_condition) in
    Obj.repr(
# 118 "dsl/parser.mly"
                                                      (_2)
# 453 "dsl/parser.ml"
               : 'with_attribute_condition))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 1 : string) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : 'with_attribute_condition) in
    Obj.repr(
# 121 "dsl/parser.mly"
                                                           (
                                let attribute_maintainer = System_new.Node.attribute_maintainer _3 _4 in
                                let system = get_selected_system () in
                                System_new.add_attribute_maintainer_under_operator system ~attribute_maintainer ~operator:(!selected_operator)
                            )
# 465 "dsl/parser.ml"
               : 'add_attribute_handler_line))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 4 : string) in
    let _6 = (Parsing.peek_val __caml_parser_env 1 : string) in
    let _7 = (Parsing.peek_val __caml_parser_env 0 : 'with_attribute_condition) in
    Obj.repr(
# 126 "dsl/parser.mly"
                                                                                     (
                                let attribute_maintainer = System_new.Node.attribute_maintainer _3 _7 in
                                let system = get_selected_system () in
                                let attribute_id = System_new.Node.attribute_id _6 in

                                let parent_maintainer = System_new.get_attribute_maintainer_by_id system attribute_id in
                                System_new.add_attribute_maintainer_under_maintainer system 
                                ~attribute_maintainer ~attribute_maintainer_maintainer:(System_new.Node.attribute_maintainer_node_of_attribute_maintainer parent_maintainer)
                            )
# 482 "dsl/parser.ml"
               : 'add_attribute_handler_line))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 4 : string) in
    let _6 = (Parsing.peek_val __caml_parser_env 1 : string) in
    let _7 = (Parsing.peek_val __caml_parser_env 0 : 'with_attribute_condition) in
    Obj.repr(
# 137 "dsl/parser.mly"
                                                                            (
                                let attribute = System_new.Node.attribute _3 _7 in
                                let system = get_selected_system () in
                                let attribute_id = System_new.Node.attribute_id _6 in
                                let attribute_maintainer = System_new.get_attribute_maintainer_by_id system attribute_id in
                                System_new.add_attribute system ~attribute ~attribute_maintainer:(System_new.Node.attribute_maintainer_node_of_attribute_maintainer attribute_maintainer)

                            )
# 498 "dsl/parser.ml"
               : 'add_attribute_line))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'add_location_line) in
    Obj.repr(
# 146 "dsl/parser.mly"
                      (_1)
# 505 "dsl/parser.ml"
               : 'add_line))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'add_organisation_line) in
    Obj.repr(
# 147 "dsl/parser.mly"
                           (_1)
# 512 "dsl/parser.ml"
               : 'add_line))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'add_operator_line) in
    Obj.repr(
# 148 "dsl/parser.mly"
                       (_1)
# 519 "dsl/parser.ml"
               : 'add_line))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'add_attribute_handler_line) in
    Obj.repr(
# 149 "dsl/parser.mly"
                                (_1)
# 526 "dsl/parser.ml"
               : 'add_line))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'add_attribute_line) in
    Obj.repr(
# 150 "dsl/parser.mly"
                        (_1)
# 533 "dsl/parser.ml"
               : 'add_line))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 153 "dsl/parser.mly"
                                       (let to_ =  System_new.Node.organisation _5 in 
                                        let from = System_new.Node.operator _2 in
                                        let system = get_selected_system () in 
                                        System_new.add_permission_edge system ~operator:(!selected_operator) ~from ~to_
                                        
                                        )
# 546 "dsl/parser.ml"
               : 'grant_line))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 159 "dsl/parser.mly"
                                    (let to_ =  System_new.Node.location _5 in 
                                        let from = System_new.Node.operator _2 in
                                        let system = get_selected_system () in 
                                        System_new.add_permission_edge system ~operator:(!selected_operator) ~from ~to_
                                        
                                        )
# 559 "dsl/parser.ml"
               : 'grant_line))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 165 "dsl/parser.mly"
                           (
                                        let from = System_new.Node.operator _2 in
                                        let system = get_selected_system () in 
                                        let attribute_id = System_new.Node.attribute_id _4 in
                                        let to_ = System_new.get_attribute_by_id system attribute_id |> System_new.Node.attribute_node_of_attribute in
                                        System_new.add_permission_edge system ~operator:(!selected_operator) ~from ~to_
                                        
                                        )
# 574 "dsl/parser.ml"
               : 'grant_line))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 173 "dsl/parser.mly"
                                   (
                                        let from = System_new.Node.operator _2 in
                                        let system = get_selected_system () in 
                                        let attribute_maintainer_id = System_new.Node.attribute_id _4 in
                                        let to_ = System_new.get_attribute_maintainer_by_id system attribute_maintainer_id |>
                                        System_new.Node.attribute_maintainer_node_of_attribute_maintainer in
                                        System_new.add_permission_edge system ~operator:(!selected_operator) ~from ~to_
                                        
                                        )
# 590 "dsl/parser.ml"
               : 'grant_line))
; (fun __caml_parser_env ->
    let _4 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _7 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 182 "dsl/parser.mly"
                                                       (
                                        let system = get_selected_system () in 
                                        let attribute_id = System_new.Node.attribute_id _7 in
                                        let from = System_new.get_attribute_by_id system attribute_id |> System_new.Node.attribute_node_of_attribute in
                                        let to_ = System_new.Node.organisation _4 in
                                        System_new.add_permission_edge system ~operator:(!selected_operator) ~from ~to_
                                        
                                        )
# 605 "dsl/parser.ml"
               : 'grant_line))
; (fun __caml_parser_env ->
    let _4 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _7 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 190 "dsl/parser.mly"
                                                   (
                                        let system = get_selected_system () in 
                                        let attribute_id = System_new.Node.attribute_id _7 in
                                        let from = System_new.get_attribute_by_id system attribute_id |> System_new.Node.attribute_node_of_attribute in
                                        let to_ = System_new.Node.location _4 in
                                        System_new.add_permission_edge system ~operator:(!selected_operator) ~from ~to_
                                        )
# 619 "dsl/parser.ml"
               : 'grant_line))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 199 "dsl/parser.mly"
                                    (
                                        let operator = System_new.Node.operator _2 in 
                                        let system = get_selected_system () in 
                                        let to_ = System_new.Node.location _4 in 
                                        System_new.move_operator system ~operator ~to_

                                    )
# 633 "dsl/parser.ml"
               : 'move_line))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'init_line) in
    Obj.repr(
# 208 "dsl/parser.mly"
              (_1)
# 640 "dsl/parser.ml"
               : 'content_line))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'add_line) in
    Obj.repr(
# 209 "dsl/parser.mly"
               (let () = update_selected_system _1 in _1)
# 647 "dsl/parser.ml"
               : 'content_line))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'grant_line) in
    Obj.repr(
# 210 "dsl/parser.mly"
                 (let () = update_selected_system _1 in _1)
# 654 "dsl/parser.ml"
               : 'content_line))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'move_line) in
    Obj.repr(
# 211 "dsl/parser.mly"
                (let () = update_selected_system _1 in _1)
# 661 "dsl/parser.ml"
               : 'content_line))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'empty_lines) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'content_line) in
    Obj.repr(
# 214 "dsl/parser.mly"
                             (
        print_string
        (Yojson.to_string (Authentication_system.System_new.to_json _2));
      Yojson.to_file "system_rep"
        (Authentication_system.System_new.to_json _2);
      _2)
# 674 "dsl/parser.ml"
               : 'line))
; (fun __caml_parser_env ->
    Obj.repr(
# 221 "dsl/parser.mly"
              (get_selected_system ())
# 680 "dsl/parser.ml"
               : 'lines))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'lines) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'line) in
    Obj.repr(
# 222 "dsl/parser.mly"
                    (_3)
# 688 "dsl/parser.ml"
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
