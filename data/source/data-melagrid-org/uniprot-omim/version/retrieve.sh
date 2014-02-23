#!/bin/bash
#
#3> <> prov:wasGeneratedBy [ 
#3>    a prov:Activity;
#3>    prov:qualifiedAssociation [ 
#3>       a prov:Association;
#3>       prov:hadPlan <https://github.com/timrdf/csv2rdf4lod-automation/tree/master/bin/cr-retrieve.sh>;
#3>    ];
#3> ] .
#3> <#>
#3>    a doap:Project; 
#3>    dcterms:description 
#3>      "Script to retrieve and convert a new version of the dataset.";
#3>    rdfs:seeAlso 
#3>      <https://github.com/timrdf/csv2rdf4lod-automation/wiki/Automated-creation-of-a-new-Versioned-Dataset>;
#3> .

#$CSV2RDF4LOD_HOME/bin/cr-create-versioned-dataset-dir.sh cr:auto                                               \
#                                                        'http://logd.tw.rpi.edu/sparql.php?query-option=uri&query-uri=https%3A%2F%2Fraw.github.com%2Fjimmccusker%2Fmelagrid%2Fmaster%2Fdata%2Fsource%2Fdata-melagrid-org%2Funiprot-omim%2Fversion%2Fretreive.rq&service-uri=http%3A%2F%2Fbeta.sparql.uniprot.org%2Fsparql&output=csv&callback=&tqx=&tp=' \
#                                                       --header-line        0                                  \
#                                                       --delimiter         ','
version=`date "+%Y-%m-%d"`
mkdir -p $version/source $version/automatic
curl 'http://logd.tw.rpi.edu/sparql.php?query-option=uri&query-uri=https%3A%2F%2Fraw.github.com%2Fjimmccusker%2Fmelagrid%2Fmaster%2Fdata%2Fsource%2Fdata-melagrid-org%2Funiprot-omim%2Fversion%2Fretreive.rq&service-uri=http%3A%2F%2Fbeta.sparql.uniprot.org%2Fsparql&output=csv&callback=&tqx=&tp=' -o $version/source/uniprot-omim.csv

curl 'http://omim.bio2rdf.org/sparql?default-graph-uri=&query=construct+%7B%0D%0A++%3Fphenotype+rdfs%3Alabel+%3Flabel.%0D%0A%7D+where+%7B%0D%0A++%3Fphenotype+a+%3Chttp%3A%2F%2Fbio2rdf.org%2Fomim_vocabulary%3APhenotype%3E.%0D%0A++%7B%3Fphenotype+%3Chttp%3A%2F%2Fbio2rdf.org%2Fomim_vocabulary%3Apreferred-title%3E+%3Flabel.%7D%0D%0A++UNION%0D%0A++%7B%3Fphenotype+%3Chttp%3A%2F%2Fbio2rdf.org%2Fomim_vocabulary%3Aalternative-title%3E+%3Flabel.%7D%0D%0A++++%0D%0A%7D++limit+10000&format=text%2Frdf%2Bn3&timeout=0&debug=on' -o $version/source/omim-labels-1.ttl

curl 'http://omim.bio2rdf.org/sparql?default-graph-uri=&query=construct+%7B%0D%0A++%3Fphenotype+rdfs%3Alabel+%3Flabel.%0D%0A%7D+where+%7B%0D%0A++%3Fphenotype+a+%3Chttp%3A%2F%2Fbio2rdf.org%2Fomim_vocabulary%3APhenotype%3E.%0D%0A++%7B%3Fphenotype+%3Chttp%3A%2F%2Fbio2rdf.org%2Fomim_vocabulary%3Apreferred-title%3E+%3Flabel.%7D%0D%0A++UNION%0D%0A++%7B%3Fphenotype+%3Chttp%3A%2F%2Fbio2rdf.org%2Fomim_vocabulary%3Aalternative-title%3E+%3Flabel.%7D%0D%0A++++%0D%0A%7D++limit+10000+offset+10000&format=text%2Frdf%2Bn3&timeout=0&debug=on' -o $version/source/omim-labels-2.ttl

cat $version/source/omim-labels*.ttl > $version/automatic/omim-labels.ttl