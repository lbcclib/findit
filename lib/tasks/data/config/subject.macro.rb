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
      def logger
        @logger ||= Yell.new($stderr, level: 'debug')
      end

      def topic_subject
        proc do |record, accumulator|
          record.each_by_tag(TOPIC_TAGS) do |field|
            accumulator.concat(extract_subject_from_field(field))
          end
        end
      end

      def extract_subject_from_field(field)
        subjects = []
        return subjects unless good_thesaurus(field)

        extracted_subjects = field.subfields.select { |subfield| subfield.code == 'a' }
                                  .map do |subfield|
          subject = ::Traject::Macros::Marc21.trim_punctuation subfield.value
          return OFFENSIVE_VALUE_REPLACEMENTS[subject] if OFFENSIVE_VALUE_REPLACEMENTS[subject]

          UNHELPFUL_SUBJECTS.include?(subject) ? nil : subject
        end.compact
        subjects.concat(extracted_subjects) if extracted_subjects
        subjects
      end

      def good_thesaurus(field)
        %w[0 2].include?(field.indicator2) ||
          (field['2'] && (%w[bidex qlsp].include? field['2']))
      end
    end
  end
end
