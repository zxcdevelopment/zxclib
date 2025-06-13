require "spec_helper"
require "zxclib"

class TestService < Zxclib::Service
  input :test_arg_without_default
  input :test_arg_with_default_nil, default: nil
  input :test_arg_with_default_string, default: "default string!!"
  input :test_arg_with_default_proc, default: -> { Time.now }

  def call
    "success!"
  end
end

class NotImplementedTestService < Zxclib::Service
end

class TestMultipleInputsService < Zxclib::Service
  inputs :test_arg_without_default, :test_arg_without_default2
  inputs :test_arg_with_default, :test_arg_with_default2, default: "default string!!"

  def call
    "success!"
  end
end

class TestExceptionService < Zxclib::Service
  def call
    raise "An error occurred"
  end
end

class BaseTestService < Zxclib::Service
  input :base_input
  input :base_input_with_default, default: "base_default"

  def call
    "base_success!"
  end
end

class InheritedTestService < BaseTestService
  input :inherited_input

  def call
    "inherited_success!"
  end
end

class GrandParentTestService < Zxclib::Service
  input :grandparent_input
  input :grandparent_input_with_default, default: "grandparent_default"

  def call
    "grandparent_success!"
  end
end

class ParentTestService < GrandParentTestService
  input :parent_input

  def call
    "parent_success!"
  end
end

class ChildTestService < ParentTestService
  input :child_input

  def call
    "child_success!"
  end
end

RSpec.describe Zxclib::Service, type: :service do
  subject { TestService.call(attributes) }

  context "when all inputs are present" do
    let(:attributes) do
      {
        test_arg_without_default: "test",
        test_arg_with_default_nil: "test",
        test_arg_with_default_string: "test",
        test_arg_with_default_proc: "test"
      }
    end

    it { is_expected.to be_valid }
    it { expect(subject.result).to eq "success!" }
  end

  context "when an input is missing" do
    context "without default value" do
      let(:attributes) do
        {
          test_arg_with_default_nil: "test",
          test_arg_with_default_string: "test",
          test_arg_with_default_proc: "test"
        }
      end

      it { is_expected.not_to be_valid }
      it { expect(subject.errors).to include "test_arg_without_default is required" }
    end

    context "with default value" do
      context "nil" do
        let(:attributes) do
          {
            test_arg_without_default: "test",
            test_arg_with_default_string: "test",
            test_arg_with_default_proc: "test"
          }
        end

        it { is_expected.to be_valid }
        it { expect(subject.test_arg_with_default_nil).to be_nil }
      end

      context "string" do
        let(:attributes) do
          {
            test_arg_without_default: "test",
            test_arg_with_default_nil: "test",
            test_arg_with_default_proc: "test"
          }
        end

        it { is_expected.to be_valid }
        it { expect(subject.test_arg_with_default_string).to eq "default string!!" }
      end

      context "proc" do
        let(:attributes) do
          {
            test_arg_without_default: "test",
            test_arg_with_default_nil: "test",
            test_arg_with_default_string: "test"
          }
        end

        it { is_expected.to be_valid }
        it { expect(subject.test_arg_with_default_proc).to be_a Time }
      end
    end
  end

  context "when an input is nil" do
    context "it doesn't get replaced with default value" do
      let(:attributes) do
        {
          test_arg_without_default: "test",
          test_arg_with_default_string: nil
        }
      end

      it { is_expected.to be_valid }
      it { expect(subject.test_arg_with_default_string).to be_nil }
    end
  end

  context "NotImplementedError" do
    subject { NotImplementedTestService.call }

    it { expect { subject }.to raise_error(NotImplementedError, "NotImplementedTestService#call not implemented") }
  end

  context "multiple inputs definition" do
    subject { TestMultipleInputsService.call(attributes) }

    context "when all inputs are present" do
      let(:attributes) do
        {
          test_arg_without_default: "test",
          test_arg_without_default2: "test",
          test_arg_with_default: "test"
        }
      end

      it { is_expected.to be_valid }
      it { expect(subject.result).to eq "success!" }
    end

    context "when an input is missing" do
      let(:attributes) do
        {
          test_arg_without_default: "test",
          test_arg_with_default: "test"
        }
      end

      it { is_expected.not_to be_valid }
      it { expect(subject.errors).to include "test_arg_without_default2 is required" }
    end
  end

  context "when an exception is raised" do
    subject { TestExceptionService.call }

    it { is_expected.not_to be_valid }
    it { expect(subject.errors).to include "An error occurred" }
  end

  describe "#call!" do
    context "with valid result" do
      subject { TestService.call!(test_arg_without_default: "123") }

      it { is_expected.to eq "success!" }
    end

    context "with invalid iputs" do
      subject { TestService.call! }
      it { expect { subject }.to raise_error(Zxclib::ServiceCallError, "test_arg_without_default is required") }
    end

    context "when an exception is raised" do
      subject { TestExceptionService.call! }

      it { expect { subject }.to raise_error(RuntimeError, "An error occurred") }
    end
  end

  describe "inheritance" do
    context "inherited service should have parent inputs" do
      subject { InheritedTestService.call(attributes) }

      context "when all inputs are present" do
        let(:attributes) do
          {
            base_input: "base_value",
            base_input_with_default: "custom_base_value",
            inherited_input: "inherited_value"
          }
        end

        it { is_expected.to be_valid }
        it { expect(subject.result).to eq "inherited_success!" }
        it { expect(subject.base_input).to eq "base_value" }
        it { expect(subject.base_input_with_default).to eq "custom_base_value" }
        it { expect(subject.inherited_input).to eq "inherited_value" }
      end

      context "when parent input is missing" do
        let(:attributes) do
          {
            inherited_input: "inherited_value"
          }
        end

        it { is_expected.not_to be_valid }
        it { expect(subject.errors).to include "base_input is required" }
      end

      context "when parent input with default is missing" do
        let(:attributes) do
          {
            base_input: "base_value",
            inherited_input: "inherited_value"
          }
        end

        it { is_expected.to be_valid }
        it { expect(subject.base_input_with_default).to eq "base_default" }
      end
    end
  end

  describe "deep inheritance" do
    context "child service should have grandparent and parent inputs" do
      subject { ChildTestService.call(attributes) }

      context "when all inputs are present" do
        let(:attributes) do
          {
            grandparent_input: "grandparent_value",
            grandparent_input_with_default: "custom_grandparent_value",
            parent_input: "parent_value",
            child_input: "child_value"
          }
        end

        it { is_expected.to be_valid }
        it { expect(subject.result).to eq "child_success!" }
        it { expect(subject.grandparent_input).to eq "grandparent_value" }
        it { expect(subject.grandparent_input_with_default).to eq "custom_grandparent_value" }
        it { expect(subject.parent_input).to eq "parent_value" }
        it { expect(subject.child_input).to eq "child_value" }
      end

      context "when grandparent input is missing" do
        let(:attributes) do
          {
            parent_input: "parent_value",
            child_input: "child_value"
          }
        end

        it { is_expected.not_to be_valid }
        it { expect(subject.errors).to include "grandparent_input is required" }
      end

      context "when grandparent input with default is missing" do
        let(:attributes) do
          {
            grandparent_input: "grandparent_value",
            parent_input: "parent_value",
            child_input: "child_value"
          }
        end

        it { is_expected.to be_valid }
        it { expect(subject.grandparent_input_with_default).to eq "grandparent_default" }
      end
    end
  end
end
