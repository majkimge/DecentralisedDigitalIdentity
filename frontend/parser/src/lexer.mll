{
open Parser        (* The type token is defined in parser.mli *)
exception Eof
}
(*
%token CREATE MOVE SELECT GRANT ACCESS_TO
%token SYSTEM
%token RESOURCE RESOURCE_HANDLER ATTRIBUTE ATTRIBUTE_HANDLER AGENT
%token IN UNDER 
%token WITH_ENTRANCES_TO  
%token GRANTED_AUTOMATICALLY_IF
%token AS
%token COMMA LPAREN RPAREN
%token AND OR
%token <string> ID
%token EOL
*)


rule token = parse
    [' ' '\t']     { token lexbuf }     (* skip blanks *)
    | ['\n' ]        { EOL }
    | "create"           { CREATE }
    | "move"                      { MOVE }
    | "select"                    { SELECT }
    | "join"                    { JOIN }
    | "grant"                     { GRANT }
    | "revoke"                  {REVOKE}
    | "access to"                 { ACCESS_TO }
    | "system"                  { SYSTEM }
    | "resource"                 { RESOURCE }
    | "resource handler"            { RESOURCE_HANDLER }
    | "attribute"              { ATTRIBUTE }
    | "attribute handler"        { ATTRIBUTE_HANDLER }
    | "agent"                 { AGENT }
    | "in"                  { IN }
    | "under"                   { UNDER }
    | "with entrances to"          { WITH_ENTRANCES_TO }
    | "granted automatically if"         { GRANTED_AUTOMATICALLY_IF }
    | "as"         { AS }
    | "and"         { AND }
    | "or"           { OR }
    | "to"           { TO }
    | "with"           { WITH }
    | ','            { COMMA }
    | '('            { LPAREN }
    | ')'            { RPAREN }
    | (['a'-'z' 'A'-'Z' '0'-'9' '_' '-'])+ as id       {ID (id)}
    | _ {token lexbuf}
    | eof            { EOF }