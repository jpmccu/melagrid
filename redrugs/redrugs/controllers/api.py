# -*- coding: utf-8 -*-
"""Main Controller"""

from tg import expose, flash, require, url, lurl, request, redirect, tmpl_context, config
from tg.i18n import ugettext as _, lazy_ugettext as l_
from redrugs.model import graph
from redrugs import model
import rdflib
from rdflib.query import Result

from redrugs.lib.base import BaseController
from redrugs.controllers.error import ErrorController
from tg.controllers import RestController
from genshi.template import NewTextTemplate
from genshi.template.base import Context

import collections, math

from SPARQLWrapper import SPARQLWrapper, JSON

__all__ = ['RootController']

class LRU_Cache:

    def __init__(self, original_function, maxsize=1000):
        self.original_function = original_function
        self.maxsize = maxsize
        self.mapping = {}

        PREV, NEXT, KEY, VALUE = 0, 1, 2, 3         # link fields
        self.head = [None, None, None, None]        # oldest
        self.tail = [self.head, None, None, None]   # newest
        self.head[NEXT] = self.tail

    def __call__(self, *key):
        PREV, NEXT = 0, 1
        mapping, head, tail = self.mapping, self.head, self.tail

        link = mapping.get(key, head)
        if link is head:
            value = self.original_function(*key)
            if len(mapping) >= self.maxsize:
                old_prev, old_next, old_key, old_value = head[NEXT]
                head[NEXT] = old_next
                old_next[PREV] = head
                del mapping[old_key]
            last = tail[PREV]
            link = [last, tail, key, value]
            mapping[key] = last[NEXT] = tail[PREV] = link
        else:
            link_prev, link_next, key, value = link
            link_prev[NEXT] = link_next
            link_next[PREV] = link_prev
            last = tail[PREV]
            last[NEXT] = tail[PREV] = link
            link[PREV] = last
            link[NEXT] = tail
        return value


def geomean(nums):
    return (reduce(lambda x, y: x*y, nums))**(1.0/len(nums))

def logLikelihood(p):
    return math.atanh(2*p-1)

def confidenceVote(nums):
    return (math.tanh(sum([math.atanh(2*x-1) for x in nums])) +1)/2

appendQueryTemplate = NewTextTemplate('''
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX prov: <http://www.w3.org/ns/prov#>
prefix go: <http://purl.org/obo/owl/GO#GO_>

SELECT distinct ?participant ?participantLabel ?target ?targetLabel ?interaction ?interactionType ?typeLabel ?probability ?searchEntity ?searchTerm where {
  let ( 
    ?searchEntity :=
{% for s in search %}\
    <${s}>
{% end %}\
  )
  let ( 
    ${position} :=
{% for s in search %}\
    <${s}>
{% end %}\
  )
  ?searchEntity rdfs:label ?searchTerm.
  graph ?assertion {
    ?interaction sio:has-participant ?participant.
    ?interaction sio:has-target ?target.
    ?interaction a ?interactionType.
  }
  OPTIONAL { ?interactionType rdfs:label ?typeLabel. }
  OPTIONAL {
    ?assertion sio:SIO_000008 [
      a sio:SIO_000765;
      sio:SIO_000300 ?probability;
    ].
  }
  
  ?target rdfs:label ?targetLabel.
  ?participant rdfs:label ?participantLabel.
} LIMIT 10000''')

processAppendQueryTemplate = NewTextTemplate('''
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX prov: <http://www.w3.org/ns/prov#>
prefix go: <http://purl.org/obo/owl/GO#GO_>

SELECT distinct ?participant ?participantLabel ?target ?targetLabel ?interaction ?interactionType ?typeLabel ?probability ?searchEntity ?searchTerm where {
  let ( 
    ?searchEntity :=
{% for s in search %}\
    <${s}>
{% end %}\
  )
  ?searchEntity rdfs:label ?searchTerm.
  ?searchEntity sio:has-participant ?participant.
  
  graph ?assertion {
    ?interaction sio:has-participant ?participant.
    ?interaction sio:has-target ?target.
    ?interaction a ?interactionType.
  }
  OPTIONAL { ?interactionType rdfs:label ?typeLabel. }
  OPTIONAL {
    ?assertion sio:SIO_000008 [
      a sio:SIO_000765;
      sio:SIO_000300 ?probability;
    ].
  }
  
  ?target rdfs:label ?targetLabel.
  ?participant rdfs:label ?participantLabel.
} LIMIT 10000''')

searchRelations = [
    '''?target''',
    '''?participant''',
#    '''[] sio:has-participant ?target; sio:has-target ?searchEntity.''',
#    '''[] sio:has-participant ?searchEntity; sio:has-target ?target.''',
    ]

def mergeByInteraction(edges):
    def mergeInteractions(interactions):
        for i in interactions:
            if i['probability'] == None:
                print i
                i['probability'] = rdflib.Literal(0.5)
        result = interactions[0]
        result['probability'] = geomean([i['probability'].value for i in interactions])
        return result
    
    byInteraction = collections.defaultdict(list)
    for edge in edges:
        byInteraction[(edge['participant'],edge['interaction'],edge['target'])].append(edge)
    result = map(mergeInteractions, byInteraction.values())
    return result

def mergeByInteractionType(edges):
    def mergeInteractions(interactions):
        result = interactions[0]
        result['interactions'] = [i['interaction'] for i in interactions]
        result['likelihood'] = logLikelihood(result['probability'])
        return result
    
    byInteraction = collections.defaultdict(list)
    for edge in edges:
        byInteraction[(edge['participant'],edge['interactionType'],edge['target'])].append(edge)
    result = map(mergeInteractions, byInteraction.values())
    return result

def addToGraphFn(search):
    edges = []
    queries = [processAppendQueryTemplate.generate(Context(search=search)).render()]+[
        appendQueryTemplate.generate(Context(search=search, position=searchRelation)).render() 
        for searchRelation in searchRelations]
    for q in queries:
        print q
        resultSet = model.graph.query(q)
        variables = [x.replace("?","") for x in resultSet.vars]
        edges.extend([dict([(variables[i],x[i]) for i  in range(len(x))]) for x in resultSet])
        print len(edges)
    print "initial:", [edge for edge in edges if edge['participantLabel'] == "Topiramate"]
    edges = mergeByInteraction(edges)
    print "merge 1:", [edge for edge in edges if edge['participantLabel'] == "Topiramate"]
    edges = mergeByInteractionType(edges)
    print "merge 2:", [edge for edge in edges if edge['participantLabel'] == "Topiramate"]
    return edges

addToGraphCache = LRU_Cache(addToGraphFn,maxsize=100)

def typeaheadFn(search):
    resultSet = model.graph.query('''prefix bd: <http://www.bigdata.com/rdf/search#>
    select distinct ?o ?s where {{
      ?o bd:search "{0}.*" .
      ?s rdfs:label ?o.
      FILTER(isURI(?s))
    }}  limit 10'''.format(search))
    result = [[y for y in x] for x in resultSet]
    return result

typeaheadCache = LRU_Cache(typeaheadFn,maxsize=100)

class ApiController(BaseController):

    
    @expose('json')
    def addToGraph(self,*args, **kw):
        search = tuple(kw['uris'].split(","))
        print search
        edges = addToGraphCache(search)
        print len(edges)
        return dict(edges=edges)
    

    @expose('json')
    def typeahead(self, *args,**kw):
        search = kw['q']
        print search
        result = typeaheadFn(search)
        print result
        return dict(keywords=result)
