# The BaseService class serves as a base class for other service classes in the application.
# It provides common functionality for handling errors, input validation, and method invocation.

# Available methods:
# - input: Defines an input parameter for the service class.
#   last parameter: Additional options for the input parameter (e.g., default value).
# - inputs: Basically call input multiple times with same arguments
# - warn_empty_inputs: Logs a warning if the specified input parameter is missing when the service is invoked.

# Example definition:
#
# class MultiplyService < BaseService
#   input :multiplier, default: 1
#   inputs :num1, :num2, default: 0
#   warn_empty_inputs :multiplier

#   def call
#     (num1 * num2) * multiplier
#   end
# end

# # Usage:
# multiplication = MultiplyService.call(multiplier: 2, num1: 3, num2: 4)
# multiplication.valid? # Outputs: true
# puts multiplication.result # Outputs: 24

# Returns
# @attr_accessor errors [Array] The array of errors.
# @attr_accessor result [Object] The result of the service call.

module Zxclib
  class Service
    attr_accessor :errors, :result, :arguments

    def initialize
      self.errors = []
    end

    def call
      raise NotImplementedError, "#{self.class.name}#call not implemented"
    end

    # @return [Boolean] true if there are no errors, false otherwise.
    def valid?
      errors.empty?
    end

    # @return [Boolean] true if there are errors, false otherwise.
    def invalid?
      !valid?
    end

    private

    class << self
      # Defines an input parameter for the service class.
      #
      # @param name [Symbol] The name of the input parameter.
      # @param options [Hash] Additional options for the input parameter (e.g., default value).
      def input(name, options = {})
        @inputs ||= []
        @inputs << {name: name, options: options}
        attr_accessor name
      end

      # Defines multiple input parameters for the service class.
      #
      # @param args [Array<Symbol>] The names of the input parameters.
      # @param options [Hash] Additional options for the input parameters (e.g., default value).
      def inputs(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        args.each { |name| input(name, options) }
      end

      def warn_empty_inputs(*args)
        @warn_empty_inputs = (@warn_empty_inputs || []) + args
      end

      # Invokes the service class with the provided arguments.
      #
      # Parameters:
      # - args_hash: A hash containing the input parameter values.
      #
      # Returns:
      # - An instance of the service class with the result of the `call` method, if valid.
      # - Otherwise, an instance of the service class with the validation errors.
      def call(args_hash = {}, s_pass_exceptions = false)
        instance = new
        instance.public_send(:arguments=, args_hash)
        @inputs&.each do |arg|
          value = args_hash[arg[:name]]

          next instance.errors.push("#{arg[:name]} is required") if value.nil? && !arg[:options].key?(:default)

          unless args_hash.key?(arg[:name])
            default = arg.dig(:options, :default)
            value = default.is_a?(Proc) ? default.call : default
          end
          instance.public_send(:"#{arg[:name]}=", value)
        end

        instance.result = instance.call if instance.valid?
        instance
      rescue => e
        raise e if s_pass_exceptions
        instance.errors.push(e.message)
        instance
      end

      def call!(args_hash = {})
        call(args_hash, true).then do |instance|
          raise ServiceCallError.new(instance.errors.join("; ")) if instance.invalid?
          instance.result
        end
      end
    end
  end
end
