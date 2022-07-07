with open('logfile.txt', 'r') as ifile:
    with open('logfiletmp.txt', 'w') as ofile:
        lines = ifile.readlines()
        last = lines[len(lines)-1]
        print(last.split('media'))
        newlines = ['media'+el+'\n' for el in last.split('media')]
        for line in newlines:
            ofile.write(line)