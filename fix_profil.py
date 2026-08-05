import re

path = r'lib/app/modules/principal/passager/profil/views/profil_view.dart'
with open(path, 'rb') as f:
    raw = f.read()

t7 = b'\t' * 7
t9 = b'\t' * 9

old = (
    t7 + b'value: loaded && controller.statsTotalSpendingFcfa.value > 0\r\n' +
    t9 + b"? '${_fmtFcfa(controller.statsTotalSpendingFcfa.value)} F'\r\n" +
    t9 + b": '\xe2\x80\x94',"
)

new = (
    t7 + b'value: loaded\r\n' +
    t9 + b'? (controller.statsTotalSpendingFcfa.value > 0\r\n' +
    t9 + b"\t? '\${_fmtFcfa(controller.statsTotalSpendingFcfa.value)} F'\r\n" +
    t9 + b"\t: '0 F')\r\n" +
    t9 + b": '\xe2\x80\x94',"
)

if old in raw:
    with open(path, 'wb') as f:
        f.write(raw.replace(old, new, 1))
    print('SUCCESS')
else:
    # Try LF
    old_lf = old.replace(b'\r\n', b'\n')
    new_lf = new.replace(b'\r\n', b'\n')
    raw_lf = raw
    if old_lf in raw_lf:
        with open(path, 'wb') as f:
            f.write(raw_lf.replace(old_lf, new_lf, 1))
        print('SUCCESS LF')
    else:
        idx = raw.find(b'statsTotalSpendingFcfa.value > 0')
        print(f'NOT FOUND. idx={idx}')
        if idx >= 0:
            print('Context:', repr(raw[max(0,idx-14):idx+50]))
