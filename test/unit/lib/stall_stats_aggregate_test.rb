class StallStatsAggregateTest < Minitest::Test


  def run_against(hour, minute)
    time = Time.local(2011, 1, 1, hour, minute)
    StallStatsAggregate::time_to_previous_bucket_key(15, time).strftime('%I:%M %p').gsub(/^0/, '')
  end
  
  def test_midnight
    assert_equal '12:00 AM', run_against(00, 00)
  end
  
  def test_on_first_quarter
    assert_equal '12:00 PM', run_against(12, 00)
  end
  
  def test_in_first_quarter
    assert_equal '12:00 PM', run_against(12, 01)
    assert_equal '12:00 PM', run_against(12, 07)
    assert_equal '12:00 PM', run_against(12, 14)
  end
    
  def test_on_second_quarter
    assert_equal '12:15 PM', run_against(12, 15)
  end
  
  def test_in_second_quarter
    assert_equal '12:15 PM', run_against(12, 16)
    assert_equal '12:15 PM', run_against(12, 22)
    assert_equal '12:15 PM', run_against(12, 29)
  end
    
  def test_on_third_quarter
    assert_equal '12:30 PM', run_against(12, 30)
  end
  
  def test_in_third_quarter
    assert_equal '12:30 PM', run_against(12, 31)
    assert_equal '12:30 PM', run_against(12, 37)
    assert_equal '12:30 PM', run_against(12, 44)
  end
  
  def test_on_fourth_quarter
    assert_equal '12:45 PM', run_against(12, 45)
  end
    
  def test_in_fourth_quarter
    assert_equal '12:45 PM', run_against(12, 46)
    assert_equal '12:45 PM', run_against(12, 52)
    assert_equal '12:45 PM', run_against(12, 59)
  end
  
end