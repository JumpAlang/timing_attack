module TimingAttack
  class TestCase
    attr_reader :input
    def initialize(input: , options: {})
      @input = input
      @options = options
      @times = []
      @percentiles = []
      @hydra_requests = []
    end

    def generate_hydra_request!
      req = Typhoeus::Request.new(
        options.fetch(:url),
        method: options.fetch(:method),
        params: default_params.merge(options.fetch(:params, {})),
        followlocation: true
      )
      @hydra_requests.push req
      req
    end

    def process!
      @hydra_requests.each do |request|
        response = request.response
        diff = response.time - response.namelookup_time
        @times.push(diff)
      end
    end

    def mean
      times.reduce(:+) / times.size.to_f
    end

    def percentile(n)
      raise ArgumentError.new("Can't have a percentile > 100") if n > 100
      if percentiles[n].nil?
        position = ((times.length - 1) * (n/100.0)).to_i
        percentiles[n] = times.sort[position]
      else
        percentiles[n]
      end
    end

    private

    def default_params
      {
        login: input,
        password: "test" * 1000
      }
    end
    attr_reader :times, :options, :percentiles
  end
end
