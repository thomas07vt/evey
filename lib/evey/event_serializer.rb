class Evey::EventSerializer < Kix::Serializer
  attributes :type, :data, :metadata, :aggregates, :associations,
    :created_at, :updated_at, :errors

  def errors
    throw(:skip) if _object.errors.empty?

    _object.errors_as_json
  end
end
