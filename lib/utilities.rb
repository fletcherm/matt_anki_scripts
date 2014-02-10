module Utilities
  module_function
  def model_id_for(model)
    model.first.to_i
  end

  def model_field_index_for(model, desired_field)
    field = model.last['flds'].find do |field|
      field['name'] == desired_field
    end

    if field.nil?
      puts "Could not find the [#{desired_field}] field on the [#{model}] model."
      exit 4
    else
      field['ord'].to_i
    end
  end
end
