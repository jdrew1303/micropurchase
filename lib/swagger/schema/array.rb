require_relative '../schema'

class Swagger::Schema::Array < Swagger::Schema
  def compact_type
    "array of #{element_type.compact_type}".html_safe
  end

  def default_sample_value
    "[#{element_type.sample_value}...]".html_safe
  end

  def element_type
    @_element_type ||= Swagger::Schema.factory(nil, fields['items'], @specification)
  end
end
