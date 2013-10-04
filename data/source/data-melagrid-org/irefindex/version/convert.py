#!/usr/bin/env python

import sys, csv
from genshi.template import NewTextTemplate

def convert(inputFile, templateFile, outputFile):
    def preprocess(x):
        return x
    v = {
        'delimiter' : ",",
        'header' : None,
        'footer' : '',
        'preamble' : '',
        'body' : '',
        'skip_rows' : 0,
        'process_rows' : 0,
        'preprocess':preprocess
    }
    execfile(templateFile,{},v)
    template = NewTextTemplate(v['body'])
    #print v['preamble']
    output = open(outputFile,'wb')
    output.write(v['preamble'])
    i = 0
    for row in csv.DictReader(open(inputFile),fieldnames = v['header'], delimiter=v['delimiter']):
        if v['skip_rows'] > 0:
            print 'skipping', row
            v['skip_rows'] -= 1
            continue
        i += 1
        if v['process_rows'] > 0 and i > v['process_rows']:
            break
        row['linenum'] = str(i)
        row = v['preprocess'](row)
        if row == None: continue
        o = template.generate(**row)
        output.write(o.render())
    output.write(v['footer'])

if __name__ == "__main__":
    convert(sys.argv[1], sys.argv[2], sys.argv[3])
