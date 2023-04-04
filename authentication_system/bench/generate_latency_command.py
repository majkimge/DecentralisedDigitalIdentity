import time
import os

WIDTH = 10
DEPTH = 30


def write_commands(text):
    f = open("../authentication_system/bin/parser/commands", "w")
    f.write(text)
    f.close()
    time.sleep(1 / 10)


def execute_ocaml():
    os.system("dune exec -- ../authentication_system/bin/parser/parser_main.exe")
    time.sleep(1 / 10)


def attribute_text(WIDTH, DEPTH):
    text = ""
    for i in range(DEPTH):
        condition = f"Attribute_{i-1}_0"
        for j in range(1, WIDTH):
            condition += f" and Attribute_{i-1}_{j}"
        for j in range(WIDTH):
            if i > 0:
                text += f"create attribute Attribute_{i}_{j} under attribute handler Latency_handler granted automatically if {condition}\n"
            else:
                text += f"create attribute Attribute_{i}_{j} under attribute handler Latency_handler\n"
    text += "create organisation Resource_handler\n"
    for i in range(WIDTH):
        text += f"create location Resource_{i} in organisation Resource_handler with entrances to world\ngrant access to location Resource_{i} with attribute Attribute_{DEPTH-1}_{i}\n"
    for i in range(WIDTH):
        text += f"grant Tester_admin attribute Attribute_0_{i}\n"
    return text


if __name__ == "__main__":
    for j in range(8, 10):
        text = (
            "create system Latency as Tester_admin\ncreate attribute handler Latency_handler\n"
            + attribute_text(10, (j + 1) * 10)
        )
        # print(text)
        write_commands(text.rstrip("\n"))
        for i in range(10):
            try:
                execute_ocaml()
            except:
                pass
