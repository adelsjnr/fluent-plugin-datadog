describe Fluent::DatadogOutput do
  let(:time) {
    Time.parse('2014-02-08 04:14:15 UTC').to_i
  }

  it 'should receive an API key' do
    Dogapi::Client.should_receive(:new).with("test_dd_api_key")
    run_driver {|d, dog| }
  end

  it 'should receive an APP key' do
    Dogapi::Client.should_receive(:new).with("test_dd_api_key", "test_dd_api_key")
    run_driver(:dd_app_key => "test_dd_api_key") {|d, dog| }
  end

  it 'should be called emit_points' do
    run_driver do |d, dog|
      dog.should_receive(:emit_points).with(
        "some.metric.name",
        [[Time.parse("2014-02-08 04:14:15 UTC"), 50.0],
         [Time.parse("2014-02-08 04:14:15 UTC"), 100.0]],
        {"tags"=>["test.default"]}
      )

      d.emit({"metric" => "some.metric.name", "value" => 50.0}, time)
      d.emit({"metric" => "some.metric.name", "value" => 100.0}, time)
    end
  end

  it 'should be called emit_points for each tag' do
    run_driver do |d, dog|
      dog.should_receive(:emit_points).with(
        "some.metric.name",
        [[Time.parse("2014-02-08 04:14:15 UTC"), 50.0],
         [Time.parse("2014-02-08 04:14:15 UTC"), 100.0]],
        {"tags"=>["test.1"]}
      )

      dog.should_receive(:emit_points).with(
        "some.metric.name",
        [[Time.parse("2014-02-08 04:14:15 UTC"), 150.0],
         [Time.parse("2014-02-08 04:14:15 UTC"), 200.0]],
        {"tags"=>["test.2"]}
      )

      dog.should_receive(:emit_points).with(
        "some.metric.name",
        [[Time.parse("2014-02-08 04:14:15 UTC"), 250.0],
         [Time.parse("2014-02-08 04:14:15 UTC"), 300.0]],
        {"tags"=>["test.3"]}
      )

      d.tag = 'test.1'
      d.emit({"metric" => "some.metric.name", "value" => 50.0}, time)
      d.emit({"metric" => "some.metric.name", "value" => 100.0}, time)

      d.tag = 'test.2'
      d.emit({"metric" => "some.metric.name", "value" => 150.0}, time)
      d.emit({"metric" => "some.metric.name", "value" => 200.0}, time)

      d.tag = 'test.3'
      d.emit({"metric" => "some.metric.name", "value" => 250.0}, time)
      d.emit({"metric" => "some.metric.name", "value" => 300.0}, time)
    end
  end

  it 'should be called emit_points for each host' do
    run_driver do |d, dog|
      dog.should_receive(:emit_points).with(
        "some.metric.name",
        [[Time.parse("2014-02-08 04:14:15 UTC"), 50.0],
         [Time.parse("2014-02-08 04:14:15 UTC"), 100.0]],
        {"tags"=>["test.default"], "host"=>"www1.example.com"}
      )

      dog.should_receive(:emit_points).with(
        "some.metric.name",
        [[Time.parse("2014-02-08 04:14:15 UTC"), 150.0],
         [Time.parse("2014-02-08 04:14:15 UTC"), 200.0]],
        {"tags"=>["test.default"], "host"=>"www2.example.com"}
      )

      dog.should_receive(:emit_points).with(
        "some.metric.name",
        [[Time.parse("2014-02-08 04:14:15 UTC"), 250.0],
         [Time.parse("2014-02-08 04:14:15 UTC"), 300.0]],
        {"tags"=>["test.default"], "host"=>"www3.example.com"}
      )

      d.emit({"metric" => "some.metric.name", "value" => 50.0, "host" => "www1.example.com"}, time)
      d.emit({"metric" => "some.metric.name", "value" => 100.0, "host" => "www1.example.com"}, time)
      d.emit({"metric" => "some.metric.name", "value" => 150.0, "host" => "www2.example.com"}, time)
      d.emit({"metric" => "some.metric.name", "value" => 200.0, "host" => "www2.example.com"}, time)
      d.emit({"metric" => "some.metric.name", "value" => 250.0, "host" => "www3.example.com"}, time)
      d.emit({"metric" => "some.metric.name", "value" => 300.0, "host" => "www3.example.com"}, time)
    end
  end

  it 'should be called emit_points for each type' do
    run_driver do |d, dog|
      dog.should_receive(:emit_points).with(
        "some.metric.name",
        [[Time.parse("2014-02-08 04:14:15 UTC"), 50.0],
         [Time.parse("2014-02-08 04:14:15 UTC"), 100.0]],
        {"tags"=>["test.default"], "type"=>"gauge"}
      )

      dog.should_receive(:emit_points).with(
        "some.metric.name",
        [[Time.parse("2014-02-08 04:14:15 UTC"), 150.0],
         [Time.parse("2014-02-08 04:14:15 UTC"), 200.0]],
        {"tags"=>["test.default"], "type"=>"counter"}
      )

      d.emit({"metric" => "some.metric.name", "value" => 50.0, "type" => "gauge"}, time)
      d.emit({"metric" => "some.metric.name", "value" => 100.0, "type" => "gauge"}, time)
      d.emit({"metric" => "some.metric.name", "value" => 150.0, "type" => "counter"}, time)
      d.emit({"metric" => "some.metric.name", "value" => 200.0, "type" => "counter"}, time)
    end
  end

  it 'should be called emit_points with host' do
    run_driver(:host => 'www.example.com') do |d, dog|
      dog.should_receive(:emit_points).with(
        "some.metric.name",
        [[Time.parse("2014-02-08 04:14:15 UTC"), 50.0],
         [Time.parse("2014-02-08 04:14:15 UTC"), 100.0]],
        {"tags"=>["test.default"], "host"=>"www.example.com"}
      )

      d.emit({"metric" => "some.metric.name", "value" => 50.0}, time)
      d.emit({"metric" => "some.metric.name", "value" => 100.0}, time)
    end
  end

  it 'should be skipped if `metric` key does not exists' do
    run_driver do |d, dog|
      dog.should_receive(:emit_points).with(
        "some.metric.name",
        [[Time.parse("2014-02-08 04:14:15 UTC"), 50.0],
         [Time.parse("2014-02-08 04:14:15 UTC"), 100.0]],
        {"tags"=>["test.default"]}
      )

      log = d.instance.log
      log.should_receive(:warn)
         .with('`metric` key does not exist: {"no metric"=>"some.metric.name", "value"=>51.0, "time"=>"2014-02-08T04:14:15Z", "tag"=>"test.default"}')
      log.should_receive(:warn)
         .with('`metric` key does not exist: {"no metric"=>"some.metric.name", "value"=>101.0, "time"=>"2014-02-08T04:14:15Z", "tag"=>"test.default"}')

      d.emit({"no metric" => "some.metric.name", "value" => 51.0}, time)
      d.emit({"no metric" => "some.metric.name", "value" => 101.0}, time)
      d.emit({"metric" => "some.metric.name", "value" => 50.0}, time)
      d.emit({"metric" => "some.metric.name", "value" => 100.0}, time)
    end
  end
end
