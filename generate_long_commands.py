import names
import random
import time
import os

NUMBER_OF_PEOPLE = 200


def rand(prob=10):
    return bool(random.randint(0, prob) < 2)


def random_condition(i):
    attribute_condition = f"{colleges[i]}_fellow"
    for j in range(33):
        if i != j:
            if rand(45 * 2):
                attribute_condition += f" or {colleges[j]}_fellow"
            if rand(45 * 2):
                attribute_condition += f" or {colleges[j]}_student"
    return attribute_condition


def write_commands(text):
    f = open("../authentication_system/bin/parser/commands", "w")
    f.write(text)
    f.close()
    time.sleep(1 / 10)


def execute_ocaml():
    os.system("dune exec -- ../authentication_system/bin/parser/parser_main.exe")
    time.sleep(1 / 10)


if __name__ == "__main__":
    name_list = []
    colleges = []
    required_attributes = []
    building_creation = ["" for i in range(33)]
    access_granting = ["" for i in range(33)]
    for i in range(33):
        colleges.append(f"College{i}")

    for i in range(33):
        attribute_condition = f"{colleges[i]}_fellow"
        for j in range(33):
            if i != j:
                if rand(15):
                    attribute_condition += f" or {colleges[j]}_fellow"
                if rand(15):
                    attribute_condition += f" or {colleges[j]}_student"
        required_attributes.append(attribute_condition)

    for i in range(33):
        building_creation[i] = ""
        college = colleges[i]
        for j in range(7):
            parent = random.randint(-1, j - 1)
            if parent == -1:
                parent = f"{colleges[i]}_main_site"
            else:
                parent = f"{colleges[i]}_building_{parent}"
            entrances = parent
            for k in range(j):
                if rand(10):
                    building = f"{colleges[i]}_building_{k}"
                    if parent != building:
                        entrances += f", {building}"
            building_creation[
                i
            ] += f"create location {college}_building_{j} in location {parent} with entrances to {entrances}\n"

    for i in range(NUMBER_OF_PEOPLE):
        name_list.append("_".join(names.get_full_name().split()))

    for i in range(33):
        access_granting[i] = ""
        college = colleges[i]
        for j in range(7):
            access_granting[
                i
            ] += f"create attribute {college}_access_to_building{j} under attribute handler {college}_handler granted automatically if {random_condition(i)}\n"
            access_granting[
                i
            ] += f"grant access to location {college}_building_{j} with attribute {college}_access_to_building{j}\n"
        for name in name_list:
            if rand(120):
                access_granting[i] += f"grant {name} attribute {college}_fellow\n"
            if rand(120):
                access_granting[i] += f"grant {name} attribute {college}_student\n"

    admins_join = list(
        map(
            lambda name: f"""join system Cambridge_big as {name}_admin\ncreate organisation {name}\ncreate attribute handler {name}_handler
create attribute {name}_fellow under attribute handler {name}_handler\ncreate attribute {name}_student under attribute handler {name}_handler
create location {name}_main_site in organisation {name} with entrances to world\n""",
            colleges,
        )
    )
    students_join = list(
        map(
            lambda name: f"join system Cambridge_big as {name}\n",
            name_list,
        )
    )

    create_colleges = list(map(lambda name: f"create_admin\n", colleges))

    build_buildings = list(
        map(
            lambda i: f"select system Cambridge_big as {colleges[i]}_admin\n{building_creation[i]}",
            range(33),
        )
    )
    grant_accesses = list(
        map(
            lambda i: f"select system Cambridge_big as {colleges[i]}_admin\n{access_granting[i]}",
            range(33),
        )
    )

    print("".join(grant_accesses).rstrip("\n"))

    text = "create system Cambridge_big as Cambridge_admin"
    write_commands(text)
    execute_ocaml()
    write_commands("".join(admins_join).rstrip("\n"))
    execute_ocaml()
    write_commands("".join(students_join).rstrip("\n"))
    execute_ocaml()
    write_commands("".join(build_buildings).rstrip("\n"))
    execute_ocaml()
    write_commands("".join(grant_accesses).rstrip("\n"))
    execute_ocaml()

    text = "select system Cambridge_big as Cambridge_admin"
    write_commands(text)
    execute_ocaml()
