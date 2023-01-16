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

val main :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Authentication_system.System_new.t
