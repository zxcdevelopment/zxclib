# frozen_string_literal: true

require_relative "zxclib/version"
require_relative "zxclib/service"
require_relative "zxclib/formatters"

module Zxclib
  class Error < StandardError; end

  class ServiceCallError < StandardError
  end
  # Your code goes here...
end
