class RideTheFireeagleGenerator < Rails::Generator::NamedBase
  default_options :skip_migration => false

  attr_reader   :controller_name,
               :controller_class_path,
               :controller_file_path,
               :controller_class_nesting,
               :controller_class_nesting_depth,
               :controller_class_name,
               :controller_singular_name,
               :controller_plural_name
  alias_method  :controller_file_name,  :controller_singular_name
  alias_method  :controller_table_name, :controller_plural_name

  def initialize(runtime_args, runtime_options = {})
   super

   @controller_name = @name.pluralize

   base_name, @controller_class_path, @controller_file_path, @controller_class_nesting, @controller_class_nesting_depth = extract_modules(@controller_name)
   @controller_class_name_without_nesting, @controller_singular_name, @controller_plural_name = inflect_names(base_name)

   if @controller_class_nesting.empty?
     @controller_class_name = @controller_class_name_without_nesting
   else
     @controller_class_name = "#{@controller_class_nesting}::#{@controller_class_name_without_nesting}"
   end
  end

  def manifest
   record do |m|
     # Check for class naming collisions.
     m.class_collisions(controller_class_path, "#{controller_class_name}Controller", "#{controller_class_name}Helper")
     m.class_collisions(class_path, "#{class_name}")

     # Controller, helper, views, and test directories.
     m.directory(File.join('app/models', class_path))
     m.directory(File.join('app/controllers', controller_class_path))
     m.directory(File.join('app/helpers', controller_class_path))
     m.directory(File.join('app/views', controller_class_path, controller_file_name))
     m.directory(File.join('test/functional', controller_class_path))
     m.directory(File.join('test/unit', class_path))

     m.dependency 'model', [singular_name] + @args, :collision => :skip

     # config file
     m.template 'fireeagle.yml', File.join('config', "fireeagle.yml")

     # migration
     unless options[:skip_migration]
       m.migration_template 'migration.rb', 'db/migrate', :assigns => {
         :migration_name => "#{class_name.pluralize.gsub(/::/, '')}RidesTheFireeagle"
       }, :migration_file_name => "#{file_path.gsub(/\//, '_').pluralize}_rides_the_fireeagle"
     end
   end
  end

protected
  def banner
   "Usage: #{$0} ride_the_fireeagle USERMODEL"
  end

  def add_options!(opt)
   opt.separator ''
   opt.separator 'Options:'
   opt.on("--skip-migration",
          "Don't generate a migration file for this model") { |v| options[:skip_migration] = v }
  end

  def model_name
   class_name.demodulize
  end
end