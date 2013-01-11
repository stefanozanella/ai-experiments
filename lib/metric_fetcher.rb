class MetricFetcher
  include EM::Deferrable

  def initialize(host, metric)
    @host = host
    @metric = metric
  end

  def fetch(opts = {})
    short_interval = opts[:short_interval] || '5min'
    long_interval  = opts[:long_interval]  || '24h'
    up_to          = opts[:up_to]          || 'now'
    format         = opts[:format]         || 'json'

    short_term_request = EM::HttpRequest.new("http://#{@host}/render/?target=transformNull(#{@metric},0)&from=#{up_to}-#{short_interval}&until=#{up_to}&format=#{format}").get
    long_term_request = EM::HttpRequest.new("http://#{@host}/render/?target=transformNull(summarize(transformNull(#{@metric},0),\"300s\",\"avg\"),0)&from=#{up_to}-#{long_interval}&until=#{up_to}&format=#{format}").get

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


