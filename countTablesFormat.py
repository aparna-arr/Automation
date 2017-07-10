# Author: Aparna Rajpurkar
import sys
import os.path

def usage():
    print("usage: python3 countTablesFormat.py <list of count files> <count program name: featureCounts or HTSeq> <output filename>", file=sys.stderr)


def parseFC(files):
    # test each file first rather than having it crash later
    for curr_file in files:
        if not os.path.isfile(curr_file):
            raise RuntimeError("File [" + curr_file + "] Does not exist!")

    # now that they are tested, actually run what we want
    data = dict()
    all_names = list()
    for curr_file in files:
        fp = open(curr_file, 'rU')

        #name = list()
        for line in fp:
            if line.startswith('#'):
                continue

            line_ar = line.rstrip().split('\t')

            if line.startswith('Geneid'):
                # handles case of multiple counts in this FC file
                #name.extend(line_ar[6:])
                all_names.extend(line_ar[6:])
                continue

            gene_name = line_ar[0]
            counts = line_ar[6:]

            if gene_name not in data:
                data[gene_name] = list()

            data[gene_name].extend(counts)

        fp.close()

    return all_names, data

def parseHT(files):
    # test each file first rather than having it crash later
    for curr_file in files:
        if not os.path.isfile(curr_file):
            raise RuntimeError("File [" + curr_file + "] Does not exist!")
    # now that they are tested, actually run what we want
    data = dict()
    all_names = list()

    for curr_file in files:
        fp = open(curr_file, 'rU')

        for line in fp:
            line_ar = line.rstrip().split('\t')
            gene_name = line_ar[0]
            count = line_ar[1]

            if gene_name not in data:
                data[gene_name] = list()

            data[gene_name].append(count)
        
        all_names.append(curr_file)

        fp.close()

    return all_names, data

def getFiles(filelist_name):
    if not os.path.isfile(filelist_name):
        raise RuntimeError("File [" + filelist_name + "] Does not exist!")
    
    fp = open(filelist_name, 'rU')
    files = list()

    for line in fp:
        files.append(line.rstrip())

    fp.close()

    return files

def main():
    
    if len(sys.argv) < 4:
        usage()
        sys.exit(2)

    try:
        filelist = getFiles(sys.argv[1])
    except RuntimeError as e:
        print(type(e).__name__ + ":", e.arg, file=sys.stderr)
        usage()
        sys.exit(2)

    data = dict()
    names = list()

    if sys.argv[2] == "featureCounts":
        try:
            names,data = parseFC(filelist)
        except RuntimeError as e:
             print(type(e).__name__ + ":", e.arg, file=sys.stderr)
             usage()
             sys.exit(2)

    elif sys.argv[2] == "HTSeq":
        try:
            names,data = parseHT(filelist)
        except RuntimeError as e:
             print(type(e).__name__ + ":", e.arg, file=sys.stderr)
             usage()
             sys.exit(2)
    else:
        print("Error: count program name must be featureCounts or HTSeq! Yours:[",sys.argv[2],"]")
        usage()
        sys.exit(2)


    outname = sys.argv[3]

    outfp = open(outname, 'w')

    outstr = "Gene\t" + "\t".join(names) + "\n"
    outfp.write(outstr)

    for gene in data:
        outstr = gene + "\t" + "\t".join(data[gene]) + "\n" 
        outfp.write(outstr)

    outfp.close()
    
main()

