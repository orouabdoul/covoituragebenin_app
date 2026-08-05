path = r'lib/app/modules/principal/passager/home/controllers/home_controller.dart'
with open(path, encoding='utf-8') as f:
    lines = f.readlines()

target = "r.uuid.substring(0, 8)"
fixed = False
new_lines = []
for i, line in enumerate(lines):
    if target in line and not fixed:
        # Insert guard line before this line
        indent = "      "
        new_lines.append(indent + "final shortId = r.uuid.length > 8 ? r.uuid.substring(0, 8) : r.uuid;\n")
        # Fix this line
        new_lines.append(line.replace(target, "shortId"))
        fixed = True
    else:
        new_lines.append(line)

if fixed:
    with open(path, 'w', encoding='utf-8') as f:
        f.writelines(new_lines)
    print("OK: fixed uuid.substring")
else:
    print("NOT FOUND")
