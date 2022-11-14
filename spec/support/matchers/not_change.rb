# Defines a not_change matcher that is an inverse of change
RSpec::Matchers.define_negated_matcher :not_change, :change
