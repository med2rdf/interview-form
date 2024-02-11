#!/usr/bin/env ruby
#
# Usage:
#  $ ruby if-csv2ttl.rb drugs/drug/meta.csv drugs/drug/if.csv drugs/drug/ref.csv [ontology/ifo.ttl] > drug.ttl
#

require 'csv'

class IFO

  attr_reader :sections, :if2pi
  
  def initialize(ifo_file)
    @if2pi = {}
    @sections = []
    if_id = pi_id = ''
    File.open(ifo_file).each do |line|
      case line
      when /^:IF_/
        if_id = line.strip.sub(/^:/, '')
        @sections << "if:#{if_id}"
      when /^\s+:package_insert/
        pi_id = line.strip.split(/\s+/)[-2].sub('pio:', '')
        @if2pi[if_id] = pi_id
      end
    end
  end

end

class InterviewFormCSV2RDF

  def initialize(meta_file, if_file = false, ref_file = false, ifo_file = "ontology/ifo.ttl")
    @ifo = IFO.new(ifo_file)
    meta_csv = CSV.parse(File.read(meta_file), headers: true)
    if_csv   = CSV.parse(File.read(if_file), headers: true) if if_file
    ref_csv  = CSV.parse(File.read(ref_file), headers: true) if ref_file
    parse_meta(meta_csv)
    parse(if_csv) if if_file
    parse(ref_csv) if ref_file
  end

  def encode(str)
    case str
    when /\Ahttp/
      "<#{str}>"
    when /\A[a-z]+:\S+\z/
      str
    when /\A@/
      str
    when /\A\d{4}-\d{2}-\d{2}\z/
      "\"#{str}\"^^xsd:date"
    when /\A\d{4}-\d{2}\z/
      "\"#{str}\"^^xsd:gYearMonth"
    when /\A\d{4}\z/
      "\"#{str}\"^^xsd:gYear"
    when /\A\p{ascii}+\Z/
      # "\"#{str}\""
      str.inspect
    else
      # "\"#{str}\"@ja"
      str.inspect + "@ja"
    end
  end

  def triple(subject, predicate, object)
    puts [encode(subject), predicate, encode(object), '.'].join("\t")
  end

  def empty_row?(row)
    ! ( row["subject"] and row["predicate"] and row["object"] )
  end

  def parse_row(row)
    subject   = row["subject"]
    predicate = row["predicate"]
    object    = row["object"]
    return [subject, predicate, object]
  end

  def parse_meta(csv)
    triples = []
    yjcodes = []
    yjcseen = {}
    if_id = pi_id = if_uri = pi_uri = if_url = pi_url = ''

    csv.each do |row|
      next if empty_row?(row)

      subject, predicate, object = *parse_row(row)

      case predicate
      when /dct:identifier/
        if subject[/www.pmda.go.jp/]
          if_id = object
          subject = "https://www.pmda.go.jp/PmdaSearch/iyakuDetail/ResultDataSetPDF/" + if_id
        elsif subject[/www.info.pmda.go.jp/]
          pi_id = object
          subject = "https://www.info.pmda.go.jp/go/interview/1/" + pi_id + ".pdf"
        end
      when /ifo:yjcode/
        yjcodes = object.strip.split(/,\s*/)
      else
        if subject[/^\d+/]
          subject = "yjc:#{subject}"
          triples << [subject, "rdf:type", "ifo:Drug"] unless yjcseen[subject]
          yjcseen[subject] = true
        end
        triples << [subject, predicate, object]
      end
    end

    if_uri = "http://med2rdf.org/if/#{if_id}"
    pi_uri = "http://med2rdf.org/pi/#{pi_id}"
    if_url = "https://www.info.pmda.go.jp/go/interview/1/#{if_id}"
    pi_url = "https://www.pmda.go.jp/PmdaSearch/iyakuDetail/ResultDataSetPDF/#{pi_id}"
    triple("@prefix", "if:", if_uri + '#')
    triple("@prefix", "pi:", pi_uri + '#')
    puts DATA.read

    triple(if_uri, "rdf:type", "ifo:InterviewForm")

    @ifo.sections.each do |section|
      triple(if_uri, "ifo:section", section)
    end

    triple(if_uri, "ifo:package_insert", pi_uri)
    triple(if_uri, "dct:identifier", if_id)
    triple(pi_uri, "dct:identifier", pi_id)
    triple(if_uri, "rdfs:seeAlso", if_url)
    triple(pi_uri, "rdfs:seeAlso", pi_url)

    yjcodes.each do |yjcode|
      triple(if_uri, "ifo:drug", "yjc:#{yjcode}")
    end

    triples.each do |subject, predicate, object|
      triple(subject, predicate, object)
    end
  end

  def parse(csv)
    section_uri = item_uri = ''
    references = []
    csv.each do |row|
      next if empty_row?(row)

      subject, predicate, object = *parse_row(row)

      case subject
      when /^IF/
        section = subject
        if section_uri != "if:#{section}"
          section_uri = "if:#{section}"
          triple(section_uri, "rdf:type", "ifo:#{subject}")
          triple(section_uri, "rdf:type", "ifo:Section")
          if pi_id = @ifo.if2pi[subject]
            triple(section_uri, "ifo:package_insert", "pi:#{pi_id}")
          end
        end
        subject = section_uri = "if:#{subject}"
      when /^item/
        item = subject
        if item_uri != "#{section_uri}.#{item}"
          item_uri = "#{section_uri}.#{item}"
          if_id = section_uri.sub(/^if:/, '')
          if pi_id = @ifo.if2pi[if_id]
            triple(item_uri, "rdf:type", "ifo:Item")
            triple(item_uri, "ifo:package_insert", "pi:#{pi_id}.#{item}")
            triple(item_uri, "dct:identifier", "#{if_id.sub('IF_', '').gsub('_', '.')}.#{item}")
          end
        end
        subject = item_uri = "#{section_uri}.#{item}"
      when /^\d+$/
        subject = "if:ref#{subject}"
        references << subject
      else
        subject
      end

      case predicate
      when /foaf:depicts/
        # foaf:depitcs -> schema:image
        predicate = "schema:image"
      when /rdfs:seeAlso/
        object.strip.split(/,\s*/).each do |xref|
          case xref
          when /^IF/
            triple(subject, predicate, "if:#{xref}")
          else
            triple(subject, predicate, xref)
          end
        end
      when /dct:references/
        object.strip.split(/,\s*/).each do |ref|
          if subject[/^if:ref/]
            triple(subject, predicate, "pmid:#{ref}")
          else
            triple(subject, predicate, "if:ref#{ref}")
          end
        end
      when /ifo:item/
        object.strip.split(/,\s*/).each do |item|
          triple(subject, predicate, "#{section_uri}.#{item}")
        end
      else
        triple(subject, predicate, object)
      end
    end

    references.uniq.each do |ref|
      triple("if:IF_11_1", "dct:references", ref)
    end
  end

end

InterviewFormCSV2RDF.new(*ARGV)

__END__

@prefix yjc:   <http://med2rdf.org/if/yjcode/> .
@prefix pio:   <http://med2rdf.org/ontology/pio/> .
@prefix ifo:   <http://med2rdf.org/ontology/ifo/> .

@prefix rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs:  <http://www.w3.org/2000/01/rdf-schema#> .
@prefix owl:   <http://www.w3.org/2002/07/owl#> .
@prefix xsd:   <http://www.w3.org/2001/XMLSchema#> .
@prefix dct:   <http://purl.org/dc/terms/> .
@prefix skos:  <http://www.w3.org/2004/02/skos/core#> .
@prefix foaf:  <http://xmlns.com/foaf/0.1/> .
@prefix pav:   <http://purl.org/pav/> .
@prefix olo:   <http://purl.org/ontology/olo/core#> .
@prefix bibo:  <http://purl.org/ontology/bibo/> .
@prefix prism: <http://prismstandard.org/namespaces/1.2/basic/> .
@prefix pmid:  <http://rdf.ncbi.nlm.nih.gov/pubmed/> .

