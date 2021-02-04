# frozen_string_literal: true

require 'traject/macros/marc21'

TOPIC_TAGS = %w[
  630
  650
  654
].freeze

UNHELPFUL_SUBJECTS = [
  'Electronic book',
  'Electronic books',
  'History',
  'Internet videos',
  'Streaming video'
].freeze

OFFENSIVE_VALUE_REPLACEMENTS = {
  'Aliens' => 'Noncitizens',
  'Illegal aliens' => 'Undocumented immigrants',
  'Alien detention centers' => 'Immigrant detention centers',
  'Children of illegal aliens' => 'Children of undocumented immigrants',
  'Illegal alien children' => 'Undocumented immigrant children',
  'Illegal aliens in literature' => 'Undocumented immigrants in literature',
  'Women illegal aliens' => 'Women undocumented immigrants',
  'Alien criminals' => 'Noncitizen criminals',
  'Aliens in motion pictures' => 'Noncitizens in motion pictures',
  'Church work with aliens' => 'Church work with noncitizens',
  'Aliens in literature' => 'Noncitizens in literature',
  'Aliens in art' => 'Noncitizens in art',
  'Aliens in mass media' => 'Noncitizens in mass media',
  'Alien property' => 'Foreign-owned property',
  'Alien property (Greek law)' => 'Foreign-owned property (Greek law)',
  'Aliens (Greek law)' => 'Noncitizens (Greek law)',
  'Aliens (Jewish law)' => 'Noncitizens (Jewish law)',
  'Aliens (Islamic law)' => 'Noncitizens (Islamic law)',
  'Aliens (Roman law)' => 'Noncitizens (Roman law)',
  'Alien labor' => 'Foreign workers',
  'Children of alien laborers' => 'Children of foreign workers',
  'Alien labor certification' => 'Foreign worker certification',
  'Women alien labor' => 'Women foreign workers',
  'Officials and employees, Alien' => 'Officials and employees, Noncitizen'
}.freeze

module FindIt
  module Macros
    # Macro for handling topics
    module TopicSubject
      def topic_subject
        proc do |record, accumulator|
          fields = record.find_all { |f| TOPIC_TAGS.include? f.tag }
          accumulator.concat(fields.map { |field| extract_subject_from_field(field) }
                               .compact)
        end
      end

      def extract_subject_from_field(field)
        return nil if unused_thesaurus(field)

        subject = ::Traject::Macros::Marc21.trim_punctuation field['a']
        return OFFENSIVE_VALUE_REPLACEMENTS[subject] if OFFENSIVE_VALUE_REPLACEMENTS[subject]

        return subject unless UNHELPFUL_SUBJECTS.include? subject

        nil
      end

      def unused_thesaurus(field)
        return false if [0, 2].include? field.indicator2
        return false if field['2'] && (%w[bidex qlsp].include? field['2'])

        true
      end
    end
  end
end
