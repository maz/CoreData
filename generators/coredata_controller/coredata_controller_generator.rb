class CoredataControllerGenerator<Rails::Generator::Base
  def initialize(runtime_args, runtime_options = {})
    super
    @name=runtime_args.first
    usage if @name.nil?
  end
  
  def manifest
    record do |m|
      m.directory "app/controllers"
      m.directory "app/views/#{plural_model_name}"
      m.template "controller.rb", "app/controllers/#{plural_model_name}_controller.rb"
      m.route_resources plural_model_name
    end
  end
  
  def model_name
    @name.underscore
  end
  
  def plural_model_name
    @name.underscore.pluralize
  end
  
  def plural_class_name
    plural_model_name.camelize
  end
  
  def upcase_model_name
    model_name.camelize
  end
end