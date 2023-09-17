# frozen_string_literal: true

require 'json'
require 'fileutils'
require 'open3'

module OffsetWizard

	BPS = 2.0
	TOTAL_BEATS = 64
	PREPARATION_BEATS = 4
	BEATS_PER_HIT = 2
	SAMPLE_RATE = 44100

	module_function

	def build_audio temp_dir
		puts 'Building audio...'
		one_beat = Array.new (SAMPLE_RATE / BPS).to_i do |i|
			t = i / SAMPLE_RATE.to_f
			Math.sin(2*Math::PI*0.1/(t+0.006)) * Math.exp(-40*t)
		end.pack 'E*' # double-precision little-endian
		input_options = %w[-f f64le -ar 44100 -ac 1 -i pipe:0]
		output_options = ['-nostdin', '-y', File.join(temp_dir, 'offset-wizard.ogg')]
		Open3.popen3 'ffmpeg', *input_options, *output_options do |stdin, stdout, stderr, wait_threads|
			TOTAL_BEATS.times { stdin.write one_beat }
			stdin.close
			stdout.read
		end
	end

	def build_chart temp_dir
		puts 'Building chart...'
		contents = {
			title: "Offset Wizard",
			artist: "UlyssesZhan",
			charter: "UlyssesZhan",
			difficultyName: "Master",
			difficultyColor: "#8c68f3",
			difficulty: "1",
			events: []
		}
		((TOTAL_BEATS - PREPARATION_BEATS) / BEATS_PER_HIT).times do |i|
			contents[:events].push({
				time: (PREPARATION_BEATS + i * BEATS_PER_HIT) / BPS,
				type: "tap",
				properties: {x: 0, y: 0}
			})
		end
		contents = JSON.generate contents
		filename = File.join temp_dir, 'master.json'
		IO.write filename, contents
	end

	def build_level target, temp_dir
		puts 'Building level...'
		FileUtils.cp 'README.md', temp_dir
		FileUtils.cp 'LICENSE', temp_dir
		FileUtils.rm target if File.exist? target
		Dir.chdir temp_dir do
			Open3.popen3 'zip', target, *Dir.glob('*') do |stdin, stdout, stderr, wait_threads|
				stdout.read
			end
		end
	end

	def build target, temp_dir
		FileUtils.mkdir_p temp_dir
		build_audio temp_dir
		build_chart temp_dir
		build_level target, temp_dir
		puts 'Cleaning up...'
		FileUtils.rm_rf temp_dir
	end
end
