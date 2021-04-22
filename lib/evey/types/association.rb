class Evey::Types::Association < ActiveRecord::Type::Value
  def type
    :json
  end

  def cast(hash)
    return if hash.nil?

    hash.transform_values { |v| GlobalID::Locator.locate(v) }
  end

  def deserialize(hash)
    return cast(hash) unless hash.is_a?(::String)

    cast(decode_value(hash))
  end

  def serialize(hash)
    return if hash.nil?

    ::ActiveSupport::JSON.encode(hash.transform_values { |v| v.to_global_id.to_s })
  end

  private

  def decode_value(value)
    ::ActiveSupport::JSON.decode(value)
  rescue StandardError
    nil
  end
end
