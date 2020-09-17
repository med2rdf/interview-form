#!/usr/bin/env ruby
#
# Usage:
#  $ ruby if-csv2ttl.rb drug/meta.csv drug/if.csv drug/ref.csv > drug.ttl
#

require 'csv'

class InterviewFormCSV2RDF

  def initialize(meta_file, if_file, ref_file)
    meta_csv = CSV.parse(File.read(meta_file), headers: true)
    if_csv   = CSV.parse(File.read(if_file), headers: true)
    ref_csv  = CSV.parse(File.read(ref_file), headers: true)
    parse_meta(meta_csv)
    parse(if_csv)
    parse(ref_csv)
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
    else
      # "\"#{str}\""
      str.inspect
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
    if_id = pi_id = if_uri = pi_uri = if_url = pi_url = ''

    csv.each do |row|
      next if empty_row?(row)

      subject, predicate, object = *parse_row(row)

      case predicate
      when /ifo:if_id/
        if_id = object
      when /ifo:pi_id/
        pi_id = object
      when /ifo:yjcode/
        yjcodes = object.strip.split(/,\s*/)
      else
        if subject[/^\d+/]
          subject = "yjc:#{subject}"
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

    sections.each do |section|
      triple(if_uri, "ifo:section", section)
    end

    triple(if_uri, "ifo:package_insert", pi_uri)
    triple(if_uri, "dct:identifier", if_id)
    triple(pi_uri, "dct:identifier", pi_id)
    triple(if_uri, "rdfs:seeAlso", if_url)
    triple(pi_uri, "rdfs:seeAlso", pi_url)

    yjcodes.each do |yjcode|
      triple(if_uri, "ifo:yjcode", "yjc:#{yjcode}")
    end

    triples.each do |subject, predicate, object|
      triple(subject, predicate, object)
    end
  end

  def sections
    [ "if:IF_0", "if:IF_1", "if:IF_1_1", "if:IF_1_2", "if:IF_1_3", "if:IF_1_4", "if:IF_1_4_1", "if:IF_1_4_2", "if:IF_1_4_3", "if:IF_1_4_4", "if:IF_1_5", "if:IF_1_5_1", "if:IF_1_5_2", "if:IF_1_6", "if:IF_2", "if:IF_2_1", "if:IF_2_1_1", "if:IF_2_1_2", "if:IF_2_1_3", "if:IF_2_2", "if:IF_2_2_1", "if:IF_2_2_2", "if:IF_2_2_3", "if:IF_2_3", "if:IF_2_4", "if:IF_2_5", "if:IF_2_6", "if:IF_3", "if:IF_3_1", "if:IF_3_1_1", "if:IF_3_1_2", "if:IF_3_1_3", "if:IF_3_1_4", "if:IF_3_1_5", "if:IF_3_1_6", "if:IF_3_1_7", "if:IF_3_2", "if:IF_3_3", "if:IF_4", "if:IF_4_1", "if:IF_4_1_1", "if:IF_4_1_2", "if:IF_4_1_3", "if:IF_4_1_4", "if:IF_4_1_5", "if:IF_4_2", "if:IF_4_2_1", "if:IF_4_2_2", "if:IF_4_2_3", "if:IF_4_3", "if:IF_4_4", "if:IF_4_5", "if:IF_4_6", "if:IF_4_7", "if:IF_4_8", "if:IF_4_9", "if:IF_4_10", "if:IF_4_10_1", "if:IF_4_10_2", "if:IF_4_10_3", "if:IF_4_10_4", "if:IF_4_11", "if:IF_4_12", "if:IF_5", "if:IF_5_1", "if:IF_5_2", "if:IF_5_3", "if:IF_5_3_1", "if:IF_5_3_2", "if:IF_5_4", "if:IF_5_5", "if:IF_5_5_1", "if:IF_5_5_2", "if:IF_5_5_3", "if:IF_5_5_4", "if:IF_5_5_4_1", "if:IF_5_5_4_2", "if:IF_5_5_5", "if:IF_5_5_6", "if:IF_5_5_6_1", "if:IF_5_5_6_2", "if:IF_5_5_7", "if:IF_6", "if:IF_6_1", "if:IF_6_2", "if:IF_6_2_1", "if:IF_6_2_2", "if:IF_6_2_3", "if:IF_7", "if:IF_7_1", "if:IF_7_1_1", "if:IF_7_1_2", "if:IF_7_1_3", "if:IF_7_1_4", "if:IF_7_2", "if:IF_7_2_1", "if:IF_7_2_2", "if:IF_7_2_3", "if:IF_7_2_4", "if:IF_7_2_5", "if:IF_7_2_6", "if:IF_7_3", "if:IF_7_3_1", "if:IF_7_3_2", "if:IF_7_4", "if:IF_7_5", "if:IF_7_5_1", "if:IF_7_5_2", "if:IF_7_5_3", "if:IF_7_5_4", "if:IF_7_5_5", "if:IF_7_5_6", "if:IF_7_6", "if:IF_7_6_1", "if:IF_7_6_2", "if:IF_7_6_3", "if:IF_7_6_4", "if:IF_7_7", "if:IF_7_8", "if:IF_7_9", "if:IF_7_10", "if:IF_7_11", "if:IF_8", "if:IF_8_1", "if:IF_8_2", "if:IF_8_3", "if:IF_8_4", "if:IF_8_5", "if:IF_8_6", "if:IF_8_6_1", "if:IF_8_6_2", "if:IF_8_6_3", "if:IF_8_6_4", "if:IF_8_6_5", "if:IF_8_6_6", "if:IF_8_6_7", "if:IF_8_6_8", "if:IF_8_7", "if:IF_8_7_1", "if:IF_8_7_2", "if:IF_8_8", "if:IF_8_8_1", "if:IF_8_8_2", "if:IF_8_9", "if:IF_8_10", "if:IF_8_11", "if:IF_8_12", "if:IF_8_12_1", "if:IF_8_12_2", "if:IF_9", "if:IF_9_1", "if:IF_9_1_1", "if:IF_9_1_2", "if:IF_9_1_3", "if:IF_9_2", "if:IF_9_2_1", "if:IF_9_2_2", "if:IF_9_2_3", "if:IF_9_2_4", "if:IF_9_2_5", "if:IF_9_2_6", "if:IF_9_2_7", "if:IF_10", "if:IF_10_1", "if:IF_10_2", "if:IF_10_3", "if:IF_10_4", "if:IF_10_5", "if:IF_10_6", "if:IF_10_7", "if:IF_10_8", "if:IF_10_9", "if:IF_10_10", "if:IF_10_11", "if:IF_10_12", "if:IF_10_13", "if:IF_10_14", "if:IF_11", "if:IF_11_1", "if:IF_11_2", "if:IF_12", "if:IF_12_1", "if:IF_12_2", "if:IF_13" ]
  end
  
  def parse(csv)
    section_id = ''
    references = []
    csv.each do |row|
      next if empty_row?(row)

      subject, predicate, object = *parse_row(row)

      case subject
      when /^IF/
        if section_id != "if:#{subject}"
          triple("if:#{subject}", "rdf:type", "ifo:#{subject}")
        end
        subject = "if:#{subject}"
        section_id = subject
      when /^item/
        subject = "#{section_id}.#{subject}"
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
          triple(subject, predicate, "#{section_id}.#{item}")
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

