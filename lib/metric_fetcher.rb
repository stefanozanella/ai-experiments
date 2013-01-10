class MetricFetcher
  include EM::Deferrable

  def initialize(host, metric)
    @host = host
    @metric = metric
  end

  def fetch(short_interval = '5min', long_interval = '24h', format = 'json')
    short_term_request = EM::HttpRequest.new("http://#{@host}/render/?target=transformNull(#{@metric},0)&from=-#{short_interval}&format=#{format}").get
    long_term_request = EM::HttpRequest.new("http://#{@host}/render/?target=transformNull(summarize(transformNull(#{@metric},0),\"300s\",\"avg\"),0)&from=-#{long_interval}&format=#{format}").get

    multi = EM::MultiRequest.new
    multi.add :short, short_term_request
    multi.add :long, long_term_request
    multi.callback do 
      sample = {
              :long_term => JSON.parse(long_term_request.response)[0]["datapoints"].map { |point| point[0] },
              :short_term => JSON.parse(short_term_request.response)[0]["datapoints"].map { |point| point[0] } }
      self.succeed(sample)
    end
  end
end


