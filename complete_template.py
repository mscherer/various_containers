import requests
from string import Template
import sys

# Q48267 => Fedora Linux
# P348 => identifiant de version
# P548 => type de version
# Q2804309 => "stable version"
payload = {
        "format": "json",
        "query": '''SELECT ?versionstable WHERE {
                      wd:Q48267 p:P348 ?n.
                      ?n ps:P348 ?versionstable;
                        pq:P548 wd:Q2804309.
                    }
                    ORDER BY DESC (?versionstable)
                    LIMIT 1 '''
}

version = requests.get('https://query.wikidata.org/sparql', params=payload).json()['results']['bindings'][0]['versionstable']['value']

with open(sys.argv[1],'r') as input_file:
    with open(sys.argv[2], 'w') as output_file:
        f = input_file.read()
        s = Template(f)
        output_file.write(s.substitute(VERSION=version))
