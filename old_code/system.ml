open Core

module Id = struct
  type person = string
  type property = string
  type organisation = string

  type _ t =
    | Person : person -> person t
    | Property : property -> property t
    | Organisation : organisation -> organisation t

  let property name = Property name
  let person name = Person name
  let organisation name = Organisation name
end
