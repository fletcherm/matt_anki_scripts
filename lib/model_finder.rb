module ModelFinder
  module_function
  def for_name(name)
    model = Collection.models.find do |(model_id, model_configuration)|
      model_configuration['name'] == name
    end

    if model.nil?
      puts "Could not find a model named [#{name}]"
      exit 3
    else
      model
    end
  end
end
