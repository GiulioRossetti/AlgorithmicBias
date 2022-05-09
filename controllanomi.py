import os

for filename in os.listdir("aggregate/"):
    if filename.startswith("averages"):
        l = filename.split(" ")
        if l[2] == "media":
            print("wrong filename")
            l.remove(l[2])
            s = ' '.join(l)
            if not os.path.exists(f'aggregate/{s}'):
                os.rename(f'aggregate/{filename}', f'aggregate/{s}')
            else:
                os.remove(f'aggregate/{filename}')
            print("done ranaming")
        else:
            continue
print("done")

