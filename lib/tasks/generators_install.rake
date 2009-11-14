namespace :generators do
	desc "Installs the coredata generator scripts"
	task :install do
		system "mkdir -p ~/.rails/generators"
		system "cp -R #{RAILS_ROOT}/generators/coredata_controller ~/.rails/generators"
		puts "coredata_controller generator installed"
	end
end