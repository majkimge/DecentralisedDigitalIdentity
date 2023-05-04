type token =
  | CREATE
  | MOVE
  | SELECT
  | JOIN
  | GRANT
  | ACCESS_TO
  | REVOKE
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

val main :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Authentication_system.System_new.t
