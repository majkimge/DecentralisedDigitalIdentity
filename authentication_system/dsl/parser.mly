%{ 
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
%}
%token CREATE MOVE SELECT JOIN GRANT ACCESS_TO
%token SYSTEM
%token LOCATION ORGANISATION ATTRIBUTE ATTRIBUTE_HANDLER OPERATOR
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
%type <Authentication_system.System_new.t> main
%%
main:
        
    |init_line lines EOF    { Marshal.to_channel (Out_channel.create "/home/majkimge/Cambridge/DecentralisedDigitalIdentity/authentication_system/bin/parser/system_bin") (!system_table) [Closures]; print_string "PrintingPtint";
                                              $2
                                             }
;
empty_lines:
    /* empty */ {}
    |empty_lines EOL {};

init_line:
    CREATE SYSTEM ID AS ID  {
                                let admin = System_new.Node.operator $5 in
                                let system = System_new.create admin $3 in 
                                let () = selected_system := $3 in 
                                let () = update_system $3 system in 
                                let () = selected_operator := admin in
                                system
                            }
    |SELECT SYSTEM ID AS ID       {
                                let () = selected_system := $3 in 
                                let () = selected_operator := System_new.Node.operator $5 in
                                get_system $3
                            }
    |JOIN SYSTEM ID AS ID       {
                                let () = selected_system := $3 in 
                                let operator = System_new.Node.operator $5 in
                                let system = get_system $3 in
                                let system = System_new.add_operator system ~operator in
                                let () = selected_operator := operator in
                                let () = update_system $3 system in 
                                system
                            };                        
                        ;



add_organisation_line:
    CREATE ORGANISATION ID     {
                                let organisation = System_new.Node.organisation $3 in
                                let system = get_selected_system () in
                                System_new.add_organisation system ~maintainer:(!selected_operator) ~organisation
                                    ~parent:System_new.root_node
                            }
    |CREATE ORGANISATION ID IN ORGANISATION ID   {
                                let organisation = System_new.Node.organisation $3 in
                                let system = get_selected_system () in
                                let parent = System_new.Node.organisation $6 in
                                System_new.add_organisation system ~maintainer:(!selected_operator) ~organisation
                                    ~parent
                            }
    |CREATE ORGANISATION ID IN LOCATION ID   {
                                let organisation = System_new.Node.organisation $3 in
                                let system = get_selected_system () in
                                let parent = System_new.Node.location $6 in
                                System_new.add_organisation system ~maintainer:(!selected_operator) ~organisation
                                    ~parent
                            };
add_location_line:
    CREATE LOCATION ID IN ORGANISATION ID WITH_ENTRANCES_TO location_list    {
                                let location = System_new.Node.location $3 in
                                let system = get_selected_system () in
                                let parent = System_new.Node.organisation $6 in
                                System_new.add_location system location ~parent
                                    ~entrances:$8
                            }
    |CREATE LOCATION ID IN LOCATION ID WITH_ENTRANCES_TO location_list    {
                                let location = System_new.Node.location $3 in
                                let system = get_selected_system () in
                                let parent = System_new.Node.location $6 in
                                System_new.add_location system location ~parent
                                    ~entrances:$8
                            };
location_list:
    ID       {[System_new.Node.location $1]}
    |ID COMMA location_list  {(System_new.Node.location $1) :: $3};

add_operator_line:
    CREATE OPERATOR ID     {
                                let operator = System_new.Node.operator $3 in
                                let system = get_selected_system () in
                                System_new.add_operator system ~operator
                            };

attribute_condition:

    ID          {let system = get_selected_system () in
                let attribute_id = System_new.Node.attribute_id $1 in
                System_new.Node.Attribute_required (System_new.get_attribute_by_id system attribute_id)}
    |LPAREN attribute_condition RPAREN {$2}
    |attribute_condition AND attribute_condition {System_new.Node.And ($1, $3)}
    |attribute_condition OR attribute_condition {System_new.Node.Or ($1, $3)};

with_attribute_condition:
        /* empty */ {System_new.Node.Never}
        |GRANTED_AUTOMATICALLY_IF attribute_condition {$2};

add_attribute_handler_line:
    CREATE ATTRIBUTE_HANDLER ID with_attribute_condition   {
                                let attribute_maintainer = System_new.Node.attribute_maintainer $3 $4 in
                                let system = get_selected_system () in
                                System_new.add_attribute_maintainer_under_operator system ~attribute_maintainer ~operator:(!selected_operator)
                            }
    |CREATE ATTRIBUTE_HANDLER ID UNDER ATTRIBUTE_HANDLER ID with_attribute_condition {
                                let attribute_maintainer = System_new.Node.attribute_maintainer $3 $7 in
                                let system = get_selected_system () in
                                let attribute_id = System_new.Node.attribute_id $6 in

                                let parent_maintainer = System_new.get_attribute_maintainer_by_id system attribute_id in
                                System_new.add_attribute_maintainer_under_maintainer system 
                                ~attribute_maintainer ~attribute_maintainer_maintainer:(System_new.Node.attribute_maintainer_node_of_attribute_maintainer parent_maintainer)
                            };

add_attribute_line:
    CREATE ATTRIBUTE ID UNDER ATTRIBUTE_HANDLER ID with_attribute_condition {
                                let attribute = System_new.Node.attribute $3 $7 in
                                let system = get_selected_system () in
                                let attribute_id = System_new.Node.attribute_id $6 in
                                let attribute_maintainer = System_new.get_attribute_maintainer_by_id system attribute_id in
                                System_new.add_attribute system ~attribute ~attribute_maintainer:(System_new.Node.attribute_maintainer_node_of_attribute_maintainer attribute_maintainer)

                            };
add_line:
    add_location_line {$1}
    |add_organisation_line {$1}
    |add_operator_line {$1}
    |add_attribute_handler_line {$1}
    |add_attribute_line {$1};

grant_line:
    GRANT ID ACCESS_TO ORGANISATION ID {let to_ =  System_new.Node.organisation $5 in 
                                        let from = System_new.Node.operator $2 in
                                        let system = get_selected_system () in 
                                        System_new.add_permission_edge system ~operator:(!selected_operator) ~from ~to_
                                        
                                        }
    |GRANT ID ACCESS_TO LOCATION ID {let to_ =  System_new.Node.location $5 in 
                                        let from = System_new.Node.operator $2 in
                                        let system = get_selected_system () in 
                                        System_new.add_permission_edge system ~operator:(!selected_operator) ~from ~to_
                                        
                                        }                               
    |GRANT ID ATTRIBUTE ID {
                                        let from = System_new.Node.operator $2 in
                                        let system = get_selected_system () in 
                                        let attribute_id = System_new.Node.attribute_id $4 in
                                        let to_ = System_new.get_attribute_by_id system attribute_id |> System_new.Node.attribute_node_of_attribute in
                                        System_new.add_permission_edge system ~operator:(!selected_operator) ~from ~to_
                                        
                                        }
    |GRANT ID ATTRIBUTE_HANDLER ID {
                                        let from = System_new.Node.operator $2 in
                                        let system = get_selected_system () in 
                                        let attribute_maintainer_id = System_new.Node.attribute_id $4 in
                                        let to_ = System_new.get_attribute_maintainer_by_id system attribute_maintainer_id |>
                                        System_new.Node.attribute_maintainer_node_of_attribute_maintainer in
                                        System_new.add_permission_edge system ~operator:(!selected_operator) ~from ~to_
                                        
                                        }
    |GRANT ACCESS_TO ORGANISATION ID WITH ATTRIBUTE ID {
                                        let system = get_selected_system () in 
                                        let attribute_id = System_new.Node.attribute_id $7 in
                                        let from = System_new.get_attribute_by_id system attribute_id |> System_new.Node.attribute_node_of_attribute in
                                        let to_ = System_new.Node.organisation $4 in
                                        System_new.add_permission_edge system ~operator:(!selected_operator) ~from ~to_
                                        
                                        }
    |GRANT ACCESS_TO LOCATION ID WITH ATTRIBUTE ID {
                                        let system = get_selected_system () in 
                                        let attribute_id = System_new.Node.attribute_id $7 in
                                        let from = System_new.get_attribute_by_id system attribute_id |> System_new.Node.attribute_node_of_attribute in
                                        let to_ = System_new.Node.location $4 in
                                        System_new.add_permission_edge system ~operator:(!selected_operator) ~from ~to_
                                        };               

move_line:
    MOVE ID TO ID                   {
                                        let operator = System_new.Node.operator $2 in 
                                        let system = get_selected_system () in 
                                        let to_ = System_new.Node.location $4 in 
                                        System_new.move_operator system ~operator ~to_

                                    }

content_line:
    |add_line  {let () = update_selected_system $1 in $1}
    |grant_line  {let () = update_selected_system $1 in $1}
    |init_line   {$1}
    |move_line  {let () = update_selected_system $1 in $1};

line:
    empty_lines content_line {
      Yojson.to_file "system_rep"
        (Authentication_system.System_new.to_json $2);
      $2};
lines:
    /*empty*/ {get_selected_system ()}
    |lines EOL line {$3};