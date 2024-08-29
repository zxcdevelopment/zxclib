module Zxclib
  module Formatters
    def format_date(date)
      date ? date.strftime("%d %b %Y") : "No data"
    end

    def format_time(time)
      time ? time.strftime("%B %d, %Y %H:%M:%S") : "No data"
    end

    def format_person(person)
      person.split(" ").map(&:capitalize).join(" ")
    end

    def person_age(person)
      return nil unless person.is_a?(String)

      dob_str = person.split(" ").last
      return nil unless dob_str

      dob = Date.parse(dob_str)
      seconds_in_a_year = 31536000
      age = ((Time.now - dob.to_time) / seconds_in_a_year).floor
      "#{age} y.o."
    rescue Date::Error
    end

    def split_fio_dob_query(fio_dob_data)
      data_spl = (fio_dob_data || "").split(" ")
      middle_name = data_spl[2]&.capitalize unless /\d/.match?(data_spl[2])
      res = {last_name: data_spl[0]&.capitalize, first_name: data_spl[1]&.capitalize, middle_name: middle_name}
      begin
        res[:dob] = Date.parse(data_spl.last) if data_spl.last
      rescue Date::Error
      end
      res
    end

    def join_fio_dob_hash(fio_dob_hash_data)
      return "" unless fio_dob_hash_data.is_a?(Hash)

      parts = [fio_dob_hash_data[:last_name], fio_dob_hash_data[:first_name], fio_dob_hash_data[:middle_name]]
      parts.push(fio_dob_hash_data[:dob].strftime("%d.%m.%Y")) if fio_dob_hash_data[:dob]
      parts.compact.join(" ")
    end

    def reformat_fio_dob_query(fio_dob_data)
      join_fio_dob_hash(split_fio_dob_query(fio_dob_data))
    end
  end
end
