#!/usr/bin/env ruby

require 'json'
require 'json-schema'
require 'net/http'
require 'uri'
require 'fileutils'
require 'open-uri'

module Jira
  # ADF (Atlassian Document Format) validator using official Atlassian schema
  class ADFValidator
    SCHEMA_URL = 'https://unpkg.com/@atlaskit/adf-schema@latest/dist/json-schema/v1/full.json'
    SCHEMA_CACHE_PATH = File.expand_path('~/.claude/cache/adf_schema.json')
    
    # Validate ADF JSON against official Atlassian schema
    # @param adf_json [Hash] The ADF document to validate
    # @param verbose [Boolean] Whether to show detailed output
    # @return [Boolean] True if valid, false otherwise
    def self.validate(adf_json, verbose: false)
      schema = load_schema
      
      begin
        JSON::Validator.validate!(schema, adf_json)
        puts "✅ ADF is valid!" if verbose
        return true
      rescue JSON::Schema::ValidationError => e
        puts "❌ ADF validation failed:" if verbose
        puts e.message if verbose
        return false
      end
    end
    
    # Validate markdown file by converting to ADF first
    # @param markdown_file [String] Path to markdown file
    # @param verbose [Boolean] Whether to show detailed output
    # @return [Boolean] True if valid, false otherwise
    def self.validate_markdown_file(markdown_file, verbose: true)
      require_relative 'markdown_formatter'
      
      content = File.read(markdown_file)
      adf = MarkdownFormatter.convert_markdown_to_adf(content)
      
      if verbose
        puts "Markdown file: #{markdown_file}"
        puts "Generated ADF:"
        puts JSON.pretty_generate(adf)
        puts "\nValidation result:"
      end
      
      validate(adf, verbose: verbose)
    end
    
    # Validate ADF and return detailed results
    # @param adf_json [Hash] The ADF document to validate
    # @return [Hash] Validation results with status and errors
    def self.validate_with_details(adf_json)
      schema = load_schema
      
      begin
        JSON::Validator.validate!(schema, adf_json)
        { valid: true, errors: [] }
      rescue JSON::Schema::ValidationError => e
        { valid: false, errors: [e.message] }
      end
    end
    
    private
    
    # Load ADF schema, downloading and caching if necessary
    # @return [Hash] Parsed JSON schema
    def self.load_schema
      # Create cache directory if it doesn't exist
      cache_dir = File.dirname(SCHEMA_CACHE_PATH)
      FileUtils.mkdir_p(cache_dir) unless Dir.exist?(cache_dir)
      
      # Only download schema if not cached (never expire cached schema)
      if !File.exist?(SCHEMA_CACHE_PATH)
        download_schema
      end
      
      JSON.parse(File.read(SCHEMA_CACHE_PATH))
    end
    
    # Download ADF schema from Atlassian
    def self.download_schema
      puts "Downloading ADF schema from #{SCHEMA_URL}..."
      
      # Use open-uri which handles redirects automatically
      URI.open(SCHEMA_URL) do |response|
        File.write(SCHEMA_CACHE_PATH, response.read)
        puts "ADF schema cached successfully at #{SCHEMA_CACHE_PATH}"
      end
    rescue => e
      raise "Failed to download ADF schema: #{e.message}"
    end
  end
end

# CLI usage when called directly
if __FILE__ == $0
  if ARGV.empty?
    puts "Usage: #{$0} markdown_file.md [--quiet]"
    puts "       #{$0} --help"
    puts ""
    puts "Examples:"
    puts "  #{$0} ticket_description.md"
    puts "  #{$0} ticket_description.md --quiet"
    puts ""
    puts "Validates Atlassian Document Format (ADF) generated from markdown files"
    puts "using the official Atlassian JSON schema."
    exit 1
  end
  
  if ARGV.include?('--help')
    puts "ADF Validator - Validates Atlassian Document Format"
    puts ""
    puts "This tool validates markdown files by converting them to ADF"
    puts "and checking against the official Atlassian JSON schema."
    puts ""
    puts "Usage: #{$0} markdown_file.md [--quiet]"
    puts ""
    puts "Options:"
    puts "  --quiet    Suppress detailed output, only show result"
    puts "  --help     Show this help message"
    puts ""
    puts "The schema is automatically downloaded and cached in ~/.claude/cache/"
    exit 0
  end
  
  markdown_file = ARGV[0]
  verbose = !ARGV.include?('--quiet')
  
  if !File.exist?(markdown_file)
    puts "Error: File not found: #{markdown_file}"
    exit 1
  end
  
  begin
    result = Jira::ADFValidator.validate_markdown_file(markdown_file, verbose: verbose)
    exit(result ? 0 : 1)
  rescue => e
    puts "Error: #{e.message}"
    exit 1
  end
end