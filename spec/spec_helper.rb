# frozen_string_literal: true

require "jekyll"
require File.expand_path("../lib/jekyll-imgwh", __dir__)

Jekyll.logger.log_level = :error

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = "random"

  def source(*files)
    File.join(__dir__, "fixture/site", *files)
  end

  # def dest_dir(*files)
  #   File.join(__dir__, "dest", *files)
  # end
end
