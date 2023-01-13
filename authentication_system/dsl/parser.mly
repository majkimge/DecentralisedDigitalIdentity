%{ 
    open! Core
    open Authentication_system

    let system_table = ref (String.Map.empty)
    let selected_system = ref ("")
    let selected_operator ref (System_new.Node.operator "")
    let update_system system_name system = 
        system_table := Map.insert (!system_table) system 
    let get_system name = match Map.find (!system_table) name with 
        |Some system -> system 
        |None raise_s [%message "No system with that name in the table" (name:string) (system_table:String.Map.t)]
    let update_selected_system system = update_system (!selected_system) system
    let get_selected_system = get_system (!selected_system)
%}
%token CREATE MOVE SELECT GRANT ACCESS_TO
%token SYSTEM
%token LOCATION ORGANISATION ATTRIBUTE ATTRIBUTE_HANDLER OPERATOR
%token IN UNDER 
%token WITH_ENTRANCES_TO  
%token GRANTED_AUTOMATICALLY_IF
%token AS
%token COMMA LPARAM RPARAM
%token AND OR
%token <string> ID
%token EOL
%left AND OR
%start main             /* the entry point */
%type <Authentication_system.t> main
%%
main:
    empty_lines init_line EOL               { $2 }
    |empty_lines init_line EOL lines         { $4 }
;
empty_lines:
    /* empty */ {}
    empty_lines EOL {};

init_line:
    CREATE SYSTEM ID AS ID  {
                                let admin = System_new.Node.operator $5 in
                                let system = System_new.create admin $3 in 
                                let () = selected_system := $3 in 
                                let () = update_system $3 system in 
                                let () = selected_operator := admin in
                                system
                            }
    SELECT SYSTEM ID AS ID       {
                                let () = selected_system := $3 in 
                                let () = selected_operator := System_new.Node.operator $5
                                get_system $3
                            };

node:
    ORGANISATION ID {System_new.Node.organisation $2}
    |LOCATION ID {System_new.Node.location $2};

add_organisation_line:
    ADD ORGANISATION ID     {
                                let organisation = System_new.Node.organisation $3 in
                                let system = get_selected_system in
                                System_new.add_organisation system ~maintainer:(!selected_operator) ~organisation
                                    ~parent:System_new.root_node
                            }
    |ADD ORGANISATION ID IN node   {
                                let organisation = System_new.Node.organisation $3 in
                                let system = get_selected_system in
                                System_new.add_organisation system ~maintainer:(!selected_operator) ~organisation
                                    ~parent:node
                            };

add_location_line:
    ADD LOCATION ID IN node WITH_ENTRANCES_TO location_list    {
                                let location = System_new.Node.organisation $3 in
                                let system = get_selected_system in
                                System_new.add_location system location ~parent:$5
                                    ~entrances:location_list
                            };
location_list:
    ID       {[System_new.Node.location $1]}
    |ID COMMA location  {(System_new.Node.location $1) :: $3};

add_operator_line:
    ADD OPERATOR ID     {
                                let operator = System_new.Node.operator $3 in
                                let system = get_selected_system in
                                System_new.add_operator system ~operator
                            };

attribute_condition:

    ID          {let system = get_selected_system in
                System_new.Node.Attribute_required (System_new.get_attribute_by_id system $1)}
    |LPARAM attribute_condition RPARAM {$2}
    |attribute_condition AND attribute_condition {System_new.Node.And $1 $3}
    |attribute_condition OR attribute_condition {System_new.Node.Or $1 $3};

with_attribute_condition:
        /* empty */ {System_new.Node.Never}
        |GRANTED_AUTOMATICALLY_IF attribute_condition {$2};

add_attribute_handler_line:
    ADD ATTRIBUTE_HANDLER ID with_attribute_condition   {
                                let attribute_maintainer = System_new.Node.attribute_maintainer $3 $4 in
                                let system = get_selected_system in
                                System_new.add_attribute_maintainer_under_operator system ~attribute_maintainer ~operator:(!selected_operator)
                            }
    |ADD ATTRIBUTE_HANDLER ID UNDER ATTRIBUTE_HANDLER ID with_attribute_condition {
                                let attribute_maintainer = System_new.Node.attribute_maintainer $3 $7 in
                                let system = get_selected_system in
                                let parent_maintainer = System_new.get_attribute_maintainer_by_id system $6 in
                                System_new.add_attribute_maintainer_under_maintainer system ~attribute_maintainer ~attribute_maintainer_maintainer:parent_maintainer
                            };

add_attribute_line:
    ADD ATTRIBUTE ID UNDER ATTRIBUTE_HANDLER ID with_attribute_condition {
                                let attribute = System_new.Node.attribute $3 $7 in
                                let system = get_selected_system in
                                let attribute_maintainer = System_new.get_attribute_maintainer_by_id system $6 in
                                System_new.add_attribute system ~attribute ~attribute_maintainer
                            };
add_line:
    add_location_line {$1}
    |add_organisation_line {$1}
    |add_operator_line {$1}
    |add_attribute_handler_line {$1}
    |add_attribute_line {$1};

grant_line:
    GRANT ID ACCESS_TO node {let to_ =  $4 in 
                                        let from = System_new.Node.operator $2 in
                                        let system = get_selected_system in 
                                        System_new.add_permission_edge system ~operator:(!selected_operator) ~from ~to_
                                        
                                        }
    |GRANT ID ATTRIBUTE ID {
                                        let from = System_new.Node.operator $2 in
                                        let system = get_selected_system in 
                                        let to_ = System_new.get_attribute_by_id system $4 in
                                        System_new.add_permission_edge system ~operator:(!selected_operator) ~from ~to_
                                        
                                        }
    |GRANT ID ATTRIBUTE_HANDLER ID {
                                        let from = System_new.Node.operator $2 in
                                        let system = get_selected_system in 
                                        let to_ = System_new.get_attribute_maintainer_by_id system $4 in
                                        System_new.add_permission_edge system ~operator:(!selected_operator) ~from ~to_
                                        
                                        };

content_line:
    init_line {$1}
    |add_line  {$1}
    |grant_line  {$1};

line:
    empty_lines content_line EOL {$2};
lines:
    line {$1}
    |lines line {$2};