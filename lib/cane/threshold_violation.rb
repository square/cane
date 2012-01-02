# Value object used by ThresholdCheck.
class ThresholdViolation < Struct.new(:name, :operator, :value, :limit)
  def description
    "Quality threshold crossed"
  end

  def columns
    ["%s is %s, should be %s %s" % [
      name,
      value,
      operator,
      limit
    ]]
  end
end
