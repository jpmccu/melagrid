<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
			xmlns:db="http://drugbank.ca" exclude-result-prefixes="db">
<xsl:output method="text" encoding="UTF-8"/>

<xsl:template name="nanopubDefine">
<xsl:param name="drugid" />
<xsl:param name="partnerid" />
    {
       :<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/> a nanopub:Nanopublication ;
                   nanopub:hasAssertion :<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/>_Assertion ;
                   nanopub:hasProvenance :<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/>_Provenance .
 
       :<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/>_Provenance nanopub:hasAttribution :<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/>_Attribution ;
                   nanopub:hasSupporting :<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="uniprotid"/>_Supporting .
 
       :<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/>_Assertion a nanopub:Assertion .
       :<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/>_Provenance a nanopub:Provenance .
       :<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/>_Attribution a nanopub:Attribution .
       :<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/>_Supporting a nanopub:Supporting .
    }
</xsl:template>

<xsl:template name="nanopubAssertion">
<xsl:param name="drugid" />
<xsl:param name="partnerid" />
<xsl:param name="drug" />
<xsl:param name="target" />

:<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/>_Assertion {
    drugbank:<xsl:copy-of select="$drugid"/> a sio:drug;
        rdfs:label &quot;<xsl:value-of select="$drug/db:name"/>&quot;;
        dcterms:description &quot;&quot;&quot;<xsl:value-of select="normalize-space($drug/db:description/text())"/>&quot;&quot;&quot;.
    uniprot:<xsl:copy-of select="$partnerid"/> a sio:protein.
  :interaction_<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/> sio:has-participant drugbank:<xsl:copy-of select="$drugid"/>;
    sio:has-target uniprot:<xsl:copy-of select="$partnerid"/>.
<xsl:for-each select="$target/db:actions/db:action">
<xsl:variable name="action" select="."/>
<xsl:choose>
<xsl:when test="lower-case($action) = 'antagonist' or lower-case($action) = 'inhibitor'">
    drugbank:<xsl:copy-of select="$drugid"/> a sio:inhibitor.
    :interaction_<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/> a mi:0623; chebi:48706; mi:0626; gro:antagonist; sio_010435.
</xsl:when>
<xsl:when test="lower-case($action) = 'binder'">
    drugbank:<xsl:copy-of select="$drugid"/> a vocab:binder.
    :interaction_<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/> a GO:0005488
</xsl:when>
<xsl:when test="$action = 'activator' or $action = 'agonist'">
    drugbank:<xsl:copy-of select="$drugid"/> a sio:activator.
    :interaction_<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/> a mi:0840; sio:010434; go:0048018; chebi:48705.
</xsl:when>
<xsl:when test="$action = 'adduct'">
    drugbank:<xsl:copy-of select="$drugid"/> a vocab:adduct; complex properties.
    :interaction_<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/> a mi:0629; go:0008144.

</xsl:when>
<xsl:when test="$action = 'allosteric modulator'">
    drugbank:<xsl:copy-of select="$drugid"/> a vocab:allosteric-modulator; effector.
    :interaction_<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/> a chebi:35224.
</xsl:when>
<xsl:when test="$action = 'antibody'">
    drugbank:<xsl:copy-of select="$drugid"/> a sio:antibody, vocab:antigen binder.
    :interaction_<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/> a mi:0190; sio:010465; go:0003823..
</xsl:when>
<xsl:when test="$action = 'chaperone'">
    drugbank:<xsl:copy-of select="$drugid"/> a vocab:chaperone.
    :interaction_<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/> a go:0051087; go:0006457.
</xsl:when>
<xsl:when test="$action = 'chelator'">
    drugbank:<xsl:copy-of select="$drugid"/> a vocab:chelator.
    :interaction_<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/> a &lt;http://purl.obolibrary.org/obo/CHEBI_38161&gt;.
</xsl:when>
<xsl:when test="$action = 'cleavage'">
    drugbank:<xsl:copy-of select="$drugid"/> a vocab:hydrolysis; hydrolyase activity; lyase activity.
    :interaction_<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/> a mi:0194; go:0016787; go:0016829.
</xsl:when>
<xsl:when test="$action = 'cofactor'">
    drugbank:<xsl:copy-of select="$drugid"/> a sio: cofactor
    :interaction_<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/> a mi:0682; go:0048037; chebi:23357.
</xsl:when>
<xsl:when test="$action = 'component of'">
    drugbank:<xsl:copy-of select="$drugid"/>  sio:is-component-part-of uniprot:<xsl:copy-of select="$partnerid"/>.
</xsl:when>
<xsl:when test="$action = 'conversion inhibitor'">
    drugbank:<xsl:copy-of select="$drugid"/> a sio:inhibitor, vocab:conversion-inhibitor.
    :interaction_<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/> a mi:0623.
</xsl:when>
<xsl:when test="$action = 'cross-linking/alkylation'">
    drugbank:<xsl:copy-of select="$drugid"/> alkylating agent; crosslinker, vocab:protein alkylation; DNA alkylation
    :interaction_<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/> :mi:0911; go :0008213; go:0006305; chebi:22333.;
</xsl:when>
<xsl:when test="$action = 'inactivator'">
    drugbank:<xsl:copy-of select="$drugid"/> a sio:inhibitor.
    :interaction_<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/> a mi:0623.
</xsl:when>
<xsl:when test="$action = 'incorporation into and destabilization'">
    drugbank:<xsl:copy-of select="$drugid"/> a sio:.
    :interaction_<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/> a mi:.
</xsl:when>
<xsl:when test="$action = 'inducer'">
    drugbank:<xsl:copy-of select="$drugid"/> a sio:activator, vocab:agonist.
    :interaction_<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/> a sio:010434; mi:0840; chebi:48705; go:0048018.
</xsl:when>
<xsl:when test="$action = 'inhibitor, competitive'">
    drugbank:<xsl:copy-of select="$drugid"/> a sio:inhibitor.
    :interaction_<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/> a mi:0623.
</xsl:when>
<xsl:when test="$action = 'inhibitory allosteric modulator'">
    drugbank:<xsl:copy-of select="$drugid"/> a sio:inhibitor, vocab:allosteric-modulator; effector.
    :interaction_<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/> a mi:0623; chebi:35224.
</xsl:when>
<xsl:when test="$action = 'intercalation'">
    # drugbank:<xsl:copy-of select="$drugid"/> a sio:intercalator
    :interaction_<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/> chebi:24853
</xsl:when>
<xsl:when test="$action = 'inverse agonist'">
    drugbank:<xsl:copy-of select="$drugid"/> a sio:inhibitor.
    :interaction_<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/> a a mi:0623; chebi:48706; mi:0626; gro:antagonist; sio_010435.
</xsl:when>
<xsl:when test="$action = 'ligand'">
          <action>ligand</action>
drugbank:<xsl:copy-of select="$drugid"/>a sio:ligand
    :interaction_<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/> a sio:010432; chebi:52214.
</xsl:when>
<xsl:when test="$action = 'metabolizer'">
          <action>metabolizer</action>
drugbank:<xsl:copy-of select="$drugid"/> vocab: metabolites
    :interaction_<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/> a mi:2048; cheb:25212; sio:000592
</xsl:when>
<xsl:when test="$action = 'modulator'">
          <action>modulator</action>
drugbank:<xsl:copy-of select="$drugid"/> vocab: effector; enzyme regulator
    :interaction_<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/> a go:0030234; chebi:35224.
</xsl:when>
<xsl:when test="$action = 'multitarget'">
          <action>multitarget</action>
</xsl:when>
<xsl:when test="$action = 'negative modulator'">
    drugbank:<xsl:copy-of select="$drugid"/> a sio:inhibitor, vocab: effector
    :interaction_<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/> a mi:0623; chebi:35224.
</xsl:when>
<xsl:when test="$action = 'neutralizer'">
    drugbank:<xsl:copy-of select="$drugid"/>.
    :interaction_<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/> a mi:0623.
</xsl:when>
<xsl:when test="$action = 'partial agonist'">
    drugbank:<xsl:copy-of select="$drugid"/> a sio:activator, vocab: stimulator
    :interaction_<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/> a mi:0840; sio:010434; chebi:48705; go:0048018.
</xsl:when>
<xsl:when test="$action = 'partial antagonist'">
    drugbank:<xsl:copy-of select="$drugid"/> a sio:inhibitor.
    :interaction_<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/> a mi:0623; sio:010435; gro:antagonist;chebi:48706.
</xsl:when>
<xsl:when test="$action = 'positive allosteric modulator'">
    drugbank:<xsl:copy-of select="$drugid"/> a sio:activator, vocab:allosteric-modulator; effector.
    :interaction_<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/> a chebi:35224
</xsl:when>
<xsl:when test="$action = 'potentiator'">
          <action>potentiator</action>
drugbank:<xsl:copy-of select="$drugid"/> a sio:stimulator.
    :interaction_<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/> a mi:0624; chebi:50847.

</xsl:when>
<xsl:when test="$action = 'product of'">
          <action>product of</action>
drugbank:<xsl:copy-of select="$drugid"/> a sio:product of , vocab:metabolite.
    :interaction_<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/> a mi:2048; cheb:25212; sio:000592.
</xsl:when>
<xsl:when test="$action = 'reducer'">
    drugbank:<xsl:copy-of select="$drugid"/> a sio:inhibitor.
    :interaction_<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/> a mi:0623; sio:010435; go:0030547.
</xsl:when>
<xsl:when test="$action = 'stimulator'">
          <action>stimulator</action>
drugbank:<xsl:copy-of select="$drugid"/> a sio:activator
    :interaction_<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/> a mi:0624; sio: 010434. 
</xsl:when>
<xsl:when test="$action = 'substrate'">
drugbank:<xsl:copy-of select="$drugid"/> a sio:substrate/>a vocab:enzyme target
    :interaction_<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/> a mi:0502; sio:010362. 
</xsl:when>
<xsl:when test="$action = 'suppressor'">
    drugbank:<xsl:copy-of select="$drugid"/> a sio:inhibitor.
    :interaction_<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/> a mi:0623; sio:010435; go:0030547.
</xsl:when>
<xsl:otherwise>
</xsl:otherwise>
</xsl:choose>
</xsl:for-each>
}
</xsl:template>
<xsl:template name="nanopubAttribution">
<xsl:param name="drugid" />
<xsl:param name="partnerid" />
<xsl:param name="created" />

:<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/>_Attribution {
       :<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/>_Assertion prov:wasAttributedTo  &lt;http://drugbank.ca&gt;;
           dcterms:created &quot;<xsl:value-of select="@created"/>&quot;^^xsd:dateTime .
}
</xsl:template>
<xsl:template name="nanopubSupporting">
<xsl:param name="drugid" />
<xsl:param name="partnerid" />
<xsl:param name="target" />
:<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/>_Supporting {
<xsl:if test="$target/db:known-action = 'yes'">
    :<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/>_Assertion a vocab:KnownActionAssertion.
</xsl:if>
<xsl:for-each select="tokenize($target/db:references/text(),'&#xD;?\n?# ','m')">
  <xsl:analyze-string select="." regex=":http://www.ncbi.nlm.nih.gov/pubmed/([0-9]+)">
   <xsl:matching-substring>
     <xsl:analyze-string select="." regex="([0-9]+)">
      <xsl:matching-substring>
    :<xsl:copy-of select="$drugid"/>_<xsl:copy-of select="$partnerid"/>_Assertion prov:wasDerivedFrom pubmed:<xsl:value-of select="."/> .
    pubmed:<xsl:value-of select="."/> a sio:peer-reviewed-article;
        rdfs:seeAlso &lt;http://www.ncbi.nlm.nih.gov/pubmed/<xsl:value-of select="."/>&gt; .
      </xsl:matching-substring>
     </xsl:analyze-string>
   </xsl:matching-substring>
  </xsl:analyze-string>
</xsl:for-each>
}
</xsl:template>

<xsl:template match="/">
@prefix drugbank: &lt;http://bio2rdf.org/drugbank:&gt; .
@prefix uniprot: &lt;http://bio2rdf.org/uniprot:&gt; .
@prefix pubmed: &lt;http://bio2rdf.org/pubmed:&gt; .
@prefix dcterms: &lt;http://purl.org/dc/terms/&gt; .
@prefix nanopub: &lt;http://www.nanopub.org/nschema#&gt; .
@prefix prov: &lt;http://www.w3.org/ns/prov#&gt; .
@prefix rdfs: &lt;http://www.w3.org/2000/01/rdf-schema#&gt; .
@prefix sio: &lt;http://semanticscience.org/resource/&gt; .
@prefix xsd: &lt;http://www.w3.org/2001/XMLSchema#&gt; .
@prefix vocab: &lt;http://lod.melagrid.org/source/data-melagrid-org/dataset/drugbank/vocab/&gt; .
@prefix : &lt;http://lod.melagrid.org/source/data-melagrid-org/dataset/drugbank/nanopub&gt; .
@prefix mi: &lt;http://purl.obolibrary.org/obo/MI_&gt; .
@prefix go: &lt;http://purl.org/obo/owl/GO#GO_&gt; .

&lt;http://lod.melagrid.org/source/data-melagrid-org/dataset/drugbank/vocab/&gt; {
mi:0195 rdfs:label "covalent binding".
vocab:adduct-reaction rdfs:subClassOf sio:addition-reaction;
    rdfs:label "adduct reaction".
}
<xsl:for-each select="db:drugs/db:drug">
<xsl:variable name="drug" select="."/>
<xsl:variable name="drugid" select="db:drugbank-id"/>
<xsl:variable name="drugname" select="db:name"/>
<xsl:variable name="drugdescription" select="normalize-space(db:description/text())"/>
<xsl:variable name="drugcreated" select="@db:created"/>
<xsl:for-each select="db:targets/db:target">
<xsl:variable name="partnerid" select="@partner"/>
<xsl:variable name="partner" select="/db:partners/db:partner[@id=$partnerid]"/>
<xsl:variable name="uniprotid" select="//db:partner[@id=$partnerid]/db:external-identifiers/db:external-identifier[db:resource='UniProtKB']/db:identifier"/>

<xsl:call-template name="nanopubDefine">
    <xsl:with-param name="drugid" select="$drugid"/>
    <xsl:with-param name="partnerid" select="$uniprotid"/>
</xsl:call-template>
<xsl:call-template name="nanopubAssertion">
    <xsl:with-param name="drugid" select="$drugid"/>
    <xsl:with-param name="partnerid" select="$uniprotid"/>
    <xsl:with-param name="drug" select="$drug"/>
    <xsl:with-param name="target" select="."/>
</xsl:call-template>
<xsl:call-template name="nanopubAttribution">
    <xsl:with-param name="drugid" select="$drugid"/>
    <xsl:with-param name="partnerid" select="$uniprotid"/>
    <xsl:with-param name="created" select="$drugcreated"/>
</xsl:call-template>
<xsl:call-template name="nanopubSupporting">
    <xsl:with-param name="drugid" select="$drugid"/>
    <xsl:with-param name="partnerid" select="$uniprotid"/>
    <xsl:with-param name="target" select="."/>
</xsl:call-template>
</xsl:for-each>    
</xsl:for-each>
</xsl:template>
</xsl:stylesheet>






	