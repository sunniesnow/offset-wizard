# frozen_string_literal: true

require_relative 'main.rb'

task :build, :target do |t, args|
	args.with_defaults target: 'offset-wizard.ssc'
	temp_dir = File.join __dir__, 'temp'
	target = File.expand_path args[:target]
	OffsetWizard.build target, temp_dir
end

task default: :build
