%{ 
    let file_exists = Sys.file_exists "/home/majkimge/Cambridge/DecentralisedDigitalIdentity/authentication_system/bin/parser/system_bin"
    open! Core
    open Authentication_system
    let system_table = ref (String.Map.empty)
    let () = (if file_exists then 
        system_table:= (Marshal.from_channel (In_channel.create "/home/majkimge/Cambridge/DecentralisedDigitalIdentity/authentication_system/bin/parser/system_bin") : System.t String.Map.t))
    let selected_system = ref ("")
    let selected_agent = ref (System.Node.agent "")
    let update_system system_name system = 
        system_table := Map.update (!system_table) system_name ~f:(fun _ -> system)
    let get_system name = match Map.find (!system_table) name with 
        |Some system -> system 
        |None -> raise_s [%message "No system with that name in the table" (name:string) (system_table:System.t String.Map.t ref)]
    let get_system_opt name = Map.find (!system_table) name 
    let update_selected_system system = update_system (!selected_system) system
    let get_selected_system () = get_system (!selected_system);;
%}
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
%type <Authentication_system.System.t> main
%%
main:
        
    |init_line lines EOF    { Marshal.to_channel (Out_channel.create "/home/majkimge/Cambridge/DecentralisedDigitalIdentity/authentication_system/bin/parser/system_bin") (!system_table) [Closures]; 
                                              $2
                                             }
;
empty_lines:
    /* empty */ {}
    |empty_lines EOL {};

init_line:
    CREATE SYSTEM ID AS ID  {
                                let admin = System.Node.agent $5 in
                                let system = System.create admin $3 in 
                                match get_system_opt $3 with 
                                |None ->
                                let () = selected_system := $3 in 
                                let () = update_system $3 system in 
                                let () = selected_agent := admin in
                                system
                                |Some _-> raise_s [%message "This policy already exists!" ($3:string) (system_table:System.t String.Map.t ref)]
                            }
    |SELECT SYSTEM ID AS ID       {
                                let () = selected_system := $3 in 
                                let () = selected_agent := System.Node.agent $5 in
                                get_system $3
                            }
    |JOIN SYSTEM ID AS ID       {
                                let () = selected_system := $3 in 
                                let agent = System.Node.agent $5 in
                                let system = get_system $3 in
                                let system = System.add_agent system ~agent in
                                let () = selected_agent := agent in
                                let () = update_system $3 system in 
                                system
                            };                        
                        ;



add_resource_handler_line:
    CREATE RESOURCE_HANDLER ID     {
                                let resource_handler = System.Node.resource_handler $3 in
                                let system = get_selected_system () in
                                System.add_resource_handler system ~maintainer:(!selected_agent) ~resource_handler
                                    ~parent:System.root_node
                            }
    |CREATE RESOURCE_HANDLER ID IN RESOURCE_HANDLER ID   {
                                let resource_handler = System.Node.resource_handler $3 in
                                let system = get_selected_system () in
                                let parent = System.Node.resource_handler $6 in
                                System.add_resource_handler system ~maintainer:(!selected_agent) ~resource_handler
                                    ~parent
                            }
    |CREATE RESOURCE_HANDLER ID IN RESOURCE ID   {
                                let resource_handler = System.Node.resource_handler $3 in
                                let system = get_selected_system () in
                                let parent = System.Node.resource $6 in
                                System.add_resource_handler system ~maintainer:(!selected_agent) ~resource_handler
                                    ~parent
                            };
add_resource_line:
    CREATE RESOURCE ID IN RESOURCE_HANDLER ID WITH_ENTRANCES_TO resource_list    {
                                let resource = System.Node.resource $3 in
                                let system = get_selected_system () in
                                let parent = System.Node.resource_handler $6 in
                                System.add_resource system resource ~parent
                                    ~entrances:$8
                            }
    |CREATE RESOURCE ID IN RESOURCE ID WITH_ENTRANCES_TO resource_list    {
                                let resource = System.Node.resource $3 in
                                let system = get_selected_system () in
                                let parent = System.Node.resource $6 in
                                System.add_resource system resource ~parent
                                    ~entrances:$8
                            };
resource_list:
    ID       {[System.Node.resource $1]}
    |ID COMMA resource_list  {(System.Node.resource $1) :: $3};

add_agent_line:
    CREATE AGENT ID     {
                                let agent = System.Node.agent $3 in
                                let system = get_selected_system () in
                                System.add_agent system ~agent
                            };

attribute_condition:

    ID          {let system = get_selected_system () in
                let attribute_id = System.Node.attribute_id $1 in
                System.Node.Attribute_required (System.get_attribute_by_id system attribute_id)}
    |LPAREN attribute_condition RPAREN {$2}
    |attribute_condition AND attribute_condition {System.Node.And ($1, $3)}
    |attribute_condition OR attribute_condition {System.Node.Or ($1, $3)};

with_attribute_condition:
        /* empty */ {System.Node.Never}
        |GRANTED_AUTOMATICALLY_IF attribute_condition {$2};

add_attribute_handler_line:
    CREATE ATTRIBUTE_HANDLER ID with_attribute_condition   {
                                let attribute_handler = System.Node.attribute_handler $3 $4 in
                                let system = get_selected_system () in
                                System.add_attribute_handler_under_agent system ~attribute_handler ~agent:(!selected_agent)
                            }
    |CREATE ATTRIBUTE_HANDLER ID UNDER ATTRIBUTE_HANDLER ID with_attribute_condition {
                                let attribute_handler = System.Node.attribute_handler $3 $7 in
                                let system = get_selected_system () in
                                let attribute_id = System.Node.attribute_id $6 in

                                let parent_maintainer = System.get_attribute_handler_by_id system attribute_id in
                                System.add_attribute_handler_under_maintainer system 
                                ~attribute_handler ~attribute_handler_maintainer:(System.Node.attribute_handler_node_of_attribute_handler parent_maintainer)
                            };

add_attribute_line:
    CREATE ATTRIBUTE ID UNDER ATTRIBUTE_HANDLER ID with_attribute_condition {
                                let attribute = System.Node.attribute $3 $7 in
                                let system = get_selected_system () in
                                let attribute_id = System.Node.attribute_id $6 in
                                let attribute_handler = System.get_attribute_handler_by_id system attribute_id in
                                System.add_attribute system ~attribute ~attribute_handler:(System.Node.attribute_handler_node_of_attribute_handler attribute_handler)

                            };
add_line:
    add_resource_line {$1}
    |add_resource_handler_line {$1}
    |add_agent_line {$1}
    |add_attribute_handler_line {$1}
    |add_attribute_line {$1};

grant_line:
    GRANT ID ACCESS_TO RESOURCE_HANDLER ID {let to_ =  System.Node.resource_handler $5 in 
                                        let from = System.Node.agent $2 in
                                        let system = get_selected_system () in 
                                        System.grant_access system ~agent:(!selected_agent) ~from ~to_
                                        
                                        }
    |GRANT ID ACCESS_TO RESOURCE ID {let to_ =  System.Node.resource $5 in 
                                        let from = System.Node.agent $2 in
                                        let system = get_selected_system () in 
                                        System.grant_access system ~agent:(!selected_agent) ~from ~to_
                                        
                                        }                               
    |GRANT ID ATTRIBUTE ID {
                                        let from = System.Node.agent $2 in
                                        let system = get_selected_system () in 
                                        let attribute_id = System.Node.attribute_id $4 in
                                        let to_ = System.get_attribute_by_id system attribute_id |> System.Node.attribute_node_of_attribute in
                                        System.grant_attribute system ~agent:(!selected_agent) ~from ~to_
                                        
                                        }
    |GRANT ID ATTRIBUTE_HANDLER ID {
                                        let from = System.Node.agent $2 in
                                        let system = get_selected_system () in 
                                        let attribute_handler_id = System.Node.attribute_id $4 in
                                        let to_ = System.get_attribute_handler_by_id system attribute_handler_id |>
                                        System.Node.attribute_handler_node_of_attribute_handler in
                                        System.grant_attribute system ~agent:(!selected_agent) ~from ~to_
                                        
                                        }
    |GRANT ACCESS_TO RESOURCE_HANDLER ID WITH ATTRIBUTE ID {
                                        let system = get_selected_system () in 
                                        let attribute_id = System.Node.attribute_id $7 in
                                        let from = System.get_attribute_by_id system attribute_id |> System.Node.attribute_node_of_attribute in
                                        let to_ = System.Node.resource_handler $4 in
                                        System.automatic_permission system ~agent:(!selected_agent) ~from ~to_
                                        
                                        }
    |GRANT ACCESS_TO RESOURCE ID WITH ATTRIBUTE ID {
                                        let system = get_selected_system () in 
                                        let attribute_id = System.Node.attribute_id $7 in
                                        let from = System.get_attribute_by_id system attribute_id |> System.Node.attribute_node_of_attribute in
                                        let to_ = System.Node.resource $4 in
                                        System.automatic_permission system ~agent:(!selected_agent) ~from ~to_
                                        };    

revoke_line:
    REVOKE ID ACCESS_TO RESOURCE_HANDLER ID {let to_ =  System.Node.resource_handler $5 in 
                                        let from = System.Node.agent $2 in
                                        let system = get_selected_system () in 
                                        System.revoke_access system ~agent:(!selected_agent) ~from ~to_
                                        
                                        }
    |REVOKE ID ACCESS_TO RESOURCE ID {let to_ =  System.Node.resource $5 in 
                                        let from = System.Node.agent $2 in
                                        let system = get_selected_system () in 
                                        System.revoke_access system ~agent:(!selected_agent) ~from ~to_
                                        
                                        }                               
    |REVOKE ID ATTRIBUTE ID {
                                        let from = System.Node.agent $2 in
                                        let system = get_selected_system () in 
                                        let attribute_id = System.Node.attribute_id $4 in
                                        let to_ = System.get_attribute_by_id system attribute_id |> System.Node.attribute_node_of_attribute in
                                        System.revoke_attribute system ~agent:(!selected_agent) ~from ~to_
                                        
                                        }
    |REVOKE ID ATTRIBUTE_HANDLER ID {
                                        let from = System.Node.agent $2 in
                                        let system = get_selected_system () in 
                                        let attribute_handler_id = System.Node.attribute_id $4 in
                                        let to_ = System.get_attribute_handler_by_id system attribute_handler_id |>
                                        System.Node.attribute_handler_node_of_attribute_handler in
                                        System.revoke_attribute system ~agent:(!selected_agent) ~from ~to_
                                        
                                        }
    |REVOKE ACCESS_TO RESOURCE_HANDLER ID WITH ATTRIBUTE ID {
                                        let system = get_selected_system () in 
                                        let attribute_id = System.Node.attribute_id $7 in
                                        let from = System.get_attribute_by_id system attribute_id |> System.Node.attribute_node_of_attribute in
                                        let to_ = System.Node.resource_handler $4 in
                                        System.revoke_automatic_permission system ~agent:(!selected_agent) ~from ~to_
                                        
                                        }
    |REVOKE ACCESS_TO RESOURCE ID WITH ATTRIBUTE ID {
                                        let system = get_selected_system () in 
                                        let attribute_id = System.Node.attribute_id $7 in
                                        let from = System.get_attribute_by_id system attribute_id |> System.Node.attribute_node_of_attribute in
                                        let to_ = System.Node.resource $4 in
                                        System.revoke_automatic_permission system ~agent:(!selected_agent) ~from ~to_
                                        };              

move_line:
    MOVE ID TO ID                   {
                                        let agent = System.Node.agent $2 in 
                                        let system = get_selected_system () in 
                                        let to_ = System.Node.resource $4 in 
                                        System.move_agent system ~agent ~to_

                                    }

content_line:
    |add_line  {let () = update_selected_system $1 in $1}
    |grant_line  {let () = update_selected_system $1 in $1}
    |revoke_line  {let () = update_selected_system $1 in $1}
    |init_line   {$1}
    |move_line  {let () = update_selected_system $1 in $1};

line:
    empty_lines content_line {
      Yojson.to_file "system_rep"
        (Authentication_system.System.to_json $2);
      $2};
lines:
    /*empty*/ {get_selected_system ()}
    |lines EOL line {$3};