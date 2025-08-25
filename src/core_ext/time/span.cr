struct Time::Span
  private PATTERN = %r{
    (?:(?<days>\d+)(?:d|\s*days?),?\s*)?
    (?:(?<hours>\d+)(?:h|\s*hours?),?\s*)?
    (?:(?<minutes>\d+)(?:m|\s*min(?:utes?)?),?\s*)?
    (?:(?<seconds>\d+)(?:s|\s*sec(?:onds?)?))?
  }ix

  # Parses a time span string into a `Time::Span`, or returns `nil` if the
  # string is invalid.
  #
  # Valid examples:
  #
  # ```
  # "1d2h3m4s"
  # "1d 2h 3m 4s"
  # "1d 2h 3 min 4 sec"
  # "1 day 2 hours 3 minutes 4 seconds"
  # "1 day, 2 hours, 3 minutes, 4 seconds"
  # ```
  def self.parse?(string : String) : Time::Span?
    return unless string = string.presence
    return unless match = string.match_full(PATTERN)
    return unless match.size > 0

    Time::Span.new(
      days: match["days"]?.try(&.to_i) || 0,
      hours: match["hours"]?.try(&.to_i) || 0,
      minutes: match["minutes"]?.try(&.to_i) || 0,
      seconds: match["seconds"]?.try(&.to_i) || 0,
    )
  end

  # Same as `#parse?`, but raises an `ArgumentError` if the string is invalid.
  def self.parse(string : String) : Time::Span
    parse?(string) ||
      raise ArgumentError.new "Invalid time span: #{string.inspect}"
  end
end

# Module for YAML (de)serialization of `Time::Span`.
module Time::Span::Converter
  def self.from_yaml(ctx : YAML::ParseContext, node : YAML::Nodes::Node) : Time::Span
    unless node.is_a?(YAML::Nodes::Scalar)
      node.raise "Expected scalar, not #{node.kind}"
    end
    Time::Span.parse(node.value)
  end
end
