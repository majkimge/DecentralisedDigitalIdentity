
%token CREATE MOVE SELECT JOIN GRANT ACCESS_TO REVOKE
%token SYSTEM
%token RESOURCE RESOURCE_HANDLER ATTRIBUTE ATTRIBUTE_HANDLER AGENT
%token IN UNDER TO WITH
%token WITH_ENTRANCES_TO  
%token GRANTED_AUTOMATICALLY_IF
%token AS
%token COMMA LPAREN RPAREN
%token AND OR
%token <string> ID
%token EOL EOF
%left AND OR
%start main             /* the entry point */
%type <bool> main
%%
main:
        
    |init_line lines EOF    {true}
;
empty_lines:
    /* empty */ {()}
    |empty_lines EOL {()};

init_line:
    CREATE SYSTEM ID AS ID  {()}
    |SELECT SYSTEM ID AS ID       {()}
    |JOIN SYSTEM ID AS ID       {()};                        
                        ;



add_resource_handler_line:
    CREATE RESOURCE_HANDLER ID     {()}
    |CREATE RESOURCE_HANDLER ID IN RESOURCE_HANDLER ID   {()}
    |CREATE RESOURCE_HANDLER ID IN RESOURCE ID   {()};
add_resource_line:
    CREATE RESOURCE ID IN RESOURCE_HANDLER ID WITH_ENTRANCES_TO resource_list    {()}
    |CREATE RESOURCE ID IN RESOURCE ID WITH_ENTRANCES_TO resource_list    {()};
resource_list:
    ID       {()}
    |ID COMMA resource_list  {()};

add_agent_line:
    CREATE AGENT ID     {()};

attribute_condition:

    ID          {()}
    |LPAREN attribute_condition RPAREN {()}
    |attribute_condition AND attribute_condition {()}
    |attribute_condition OR attribute_condition {()};

with_attribute_condition:
        /* empty */ {()}
        |GRANTED_AUTOMATICALLY_IF attribute_condition {()};

add_attribute_handler_line:
    CREATE ATTRIBUTE_HANDLER ID with_attribute_condition   {()}
    |CREATE ATTRIBUTE_HANDLER ID UNDER ATTRIBUTE_HANDLER ID with_attribute_condition {()};

add_attribute_line:
    CREATE ATTRIBUTE ID UNDER ATTRIBUTE_HANDLER ID with_attribute_condition {()};
add_line:
    add_resource_line {()}
    |add_resource_handler_line {()}
    |add_agent_line {()}
    |add_attribute_handler_line {()}
    |add_attribute_line {()};

grant_line:
    GRANT ID ACCESS_TO RESOURCE_HANDLER ID {()}
    |GRANT ID ACCESS_TO RESOURCE ID {()}                               
    |GRANT ID ATTRIBUTE ID {()}
    |GRANT ID ATTRIBUTE_HANDLER ID {()}
    |GRANT ACCESS_TO RESOURCE_HANDLER ID WITH ATTRIBUTE ID {()}
    |GRANT ACCESS_TO RESOURCE ID WITH ATTRIBUTE ID {()};    

revoke_line:
    REVOKE ID ACCESS_TO RESOURCE_HANDLER ID {()}
    |REVOKE ID ACCESS_TO RESOURCE ID {()}                               
    |REVOKE ID ATTRIBUTE ID {()}
    |REVOKE ID ATTRIBUTE_HANDLER ID {()}
    |REVOKE ACCESS_TO RESOURCE_HANDLER ID WITH ATTRIBUTE ID {()}
    |REVOKE ACCESS_TO RESOURCE ID WITH ATTRIBUTE ID {()};              

move_line:
    MOVE ID TO ID                   {()}

content_line:
    |add_line  {()}
    |grant_line  {()}
    |revoke_line  {()}
    |init_line   {()}
    |move_line  {()};

line:
    empty_lines content_line {()};
lines:
    /*empty*/ {()}
    |lines EOL line {()};