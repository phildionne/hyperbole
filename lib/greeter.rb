require 'date'

class Greeter

  def at(time_with_zone)
    datetime = time_with_zone.to_datetime

    case
    when morning.cover?(datetime)
      message = "Good morning"
    when afternoon.cover?(datetime)
      message = "Good afternoon"
    when evening.cover?(datetime)
      message = "Good evening"
    when night.cover?(datetime)
      message = "Good night"
    else
    end

    message
  end


  protected

  def today
    DateTime.now
  end

  def morning
    today.at_midnight + 4.hours..today.at_midnight + 12.hours
  end

  def afternoon
    today.at_midnight + 12.hours..today.at_midnight + 19.hours
  end

  def evening
    today.at_midnight + 19.hours..today.at_midnight + 23.hours
  end

  def night
    today.at_midnight + 23.hours..today.at_midnight + 4.hours
  end

end # class Greetings