# frozen_string_literal: true

require "rspec"
require "date"

RSpec.describe Zxclib::Formatters do
  include Zxclib::Formatters

  describe "#format_date" do
    it "formats a valid date" do
      date = Date.new(2023, 10, 5)
      expect(format_date(date)).to eq("05 Oct 2023")
    end

    it 'returns "No data" for nil' do
      expect(format_date(nil)).to eq("No data")
    end
  end

  describe "#format_time" do
    it "formats a valid time" do
      time = Time.new(2023, 10, 5, 14, 30, 0)
      expect(format_time(time)).to eq("October 05, 2023 14:30:00")
    end

    it 'returns "No data" for nil' do
      expect(format_time(nil)).to eq("No data")
    end
  end

  describe "#format_person" do
    it "formats a full name" do
      person = "john doe"
      expect(format_person(person)).to eq("John Doe")
    end

    it "formats a single name" do
      person = "john"
      expect(format_person(person)).to eq("John")
    end

    it "returns an empty string for an empty input" do
      person = ""
      expect(format_person(person)).to eq("")
    end
  end

  describe "#person_age" do
    it "calculates age correctly for a valid person string" do
      person = "John Doe 01.01.#{Time.now.year - 23}"
      expect(person_age(person)).to eq("23 y.o.")
    end

    it "returns nil for an invalid date of birth" do
      person = "John Doe invalid_date"
      expect(person_age(person)).to be_nil
    end

    it "returns nil for an empty string" do
      person = ""
      expect(person_age(person)).to be_nil
    end
  end

  describe "#split_fio_dob_query" do
    it "splits full name and date of birth correctly" do
      result = split_fio_dob_query("Doe John 01.01.2000")
      expect(result).to eq({last_name: "Doe", first_name: "John", middle_name: nil, dob: Date.parse("01.01.2000")})
    end

    it "handles name without middle name" do
      result = split_fio_dob_query("Doe John 01.01.2000")
      expect(result).to eq({last_name: "Doe", first_name: "John", middle_name: nil, dob: Date.parse("01.01.2000")})
    end

    it "handles name with middle name" do
      result = split_fio_dob_query("Doe John Michael 01.01.2000")
      expect(result).to eq({last_name: "Doe", first_name: "John", middle_name: "Michael", dob: Date.parse("01.01.2000")})
    end

    it "handles invalid date of birth" do
      result = split_fio_dob_query("Doe John Michael invalid_date")
      expect(result).to eq({last_name: "Doe", first_name: "John", middle_name: "Michael"})
    end

    it "handles empty string" do
      result = split_fio_dob_query("")
      expect(result).to eq({last_name: nil, first_name: nil, middle_name: nil})
    end

    it "handles nil input" do
      result = split_fio_dob_query(nil)
      expect(result).to eq({last_name: nil, first_name: nil, middle_name: nil})
    end
  end

  describe "#join_fio_dob_hash" do
    it "joins a valid hash with all fields" do
      fio_dob_hash_data = {last_name: "Doe", first_name: "John", middle_name: "Michael", dob: Date.new(2000, 1, 1)}
      expect(join_fio_dob_hash(fio_dob_hash_data)).to eq("Doe John Michael 01.01.2000")
    end

    it "joins a hash missing the dob field" do
      fio_dob_hash_data = {last_name: "Doe", first_name: "John", middle_name: "Michael"}
      expect(join_fio_dob_hash(fio_dob_hash_data)).to eq("Doe John Michael")
    end

    it "joins a hash missing the middle_name field" do
      fio_dob_hash_data = {last_name: "Doe", first_name: "John", dob: Date.new(2000, 1, 1)}
      expect(join_fio_dob_hash(fio_dob_hash_data)).to eq("Doe John 01.01.2000")
    end

    it "returns an empty string for an empty hash" do
      fio_dob_hash_data = {}
      expect(join_fio_dob_hash(fio_dob_hash_data)).to eq("")
    end

    it "returns an empty string for an invalid input" do
      fio_dob_hash_data = "invalid input"
      expect(join_fio_dob_hash(fio_dob_hash_data)).to eq("")
    end
  end

  describe "#reformat_fio_dob_query" do
    it "reformats a valid string with full name and date of birth" do
      fio_dob_data = "Doe John Michael 01.01.2000"
      expect(reformat_fio_dob_query(fio_dob_data)).to eq("Doe John Michael 01.01.2000")
    end

    it "reformats a string missing the middle name" do
      fio_dob_data = "Doe John 01.01.2000"
      expect(reformat_fio_dob_query(fio_dob_data)).to eq("Doe John 01.01.2000")
    end

    it "reformats a string missing the date of birth" do
      fio_dob_data = "Doe John Michael"
      expect(reformat_fio_dob_query(fio_dob_data)).to eq("Doe John Michael")
    end

    it "returns an empty string for an empty input" do
      fio_dob_data = ""
      expect(reformat_fio_dob_query(fio_dob_data)).to eq("")
    end

    it "returns an empty string for nil input" do
      fio_dob_data = nil
      expect(reformat_fio_dob_query(fio_dob_data)).to eq("")
    end
  end
end
