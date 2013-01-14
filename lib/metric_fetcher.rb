#require 'graphite_url_builder'
class GraphiteUrlBuilder
  def initialize(host)
    @host = host
  end

  def to_s
    "http://#{@host}/render/?"
  end
end

class MetricFetcher
  include EM::Deferrable

  def initialize(host, metric)
    @host = host
    @metric = metric
  end

  def fetch(opts = {})
    short_interval = opts[:short_interval] || '5min'
    mid_interval   = opts[:mid_interval]   || '1h'
    long_interval  = opts[:long_interval]  || '24h'
    up_to          = opts[:up_to]          || 'now'
    format         = opts[:format]         || 'json'

    url_builder = GraphiteUrlBuilder.new(@host)
    short_term_request = EM::HttpRequest.new("#{url_builder}target=transformNull(#{@metric},0)&from=#{up_to}-#{short_interval}&until=#{up_to}&format=#{format}").get
    mid_term_request = EM::HttpRequest.new("#{url_builder}target=transformNull(summarize(transformNull(#{@metric},0),\"60s\",\"avg\"),0)&from=#{up_to}-#{mid_interval}&until=#{up_to}&format=#{format}").get
    long_term_request = EM::HttpRequest.new("#{url_builder}target=transformNull(summarize(transformNull(#{@metric},0),\"300s\",\"avg\"),0)&from=#{up_to}-#{long_interval}&until=#{up_to}&format=#{format}").get

    multi = EM::MultiRequest.new
    multi.add :short, short_term_request
    multi.add :mid,   mid_term_request
    multi.add :long, long_term_request
    multi.callback do 
      sample = {
              :long_term => JSON.parse(long_term_request.response)[0]["datapoints"].map { |point| point[0] },
              :mid_term => JSON.parse(mid_term_request.response)[0]["datapoints"].map { |point| point[0] },
              :short_term => JSON.parse(short_term_request.response)[0]["datapoints"].map { |point| point[0] } }
      self.succeed(sample)
    end
  end
end


