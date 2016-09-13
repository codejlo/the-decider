require 'dotenv'
Dotenv.load
require 'open-uri'
require 'json'
require 'httparty'
require 'awesome_print'

helpers do

  class GooglePlaces
    include HTTParty
    base_uri 'https://maps.googleapis.com/maps/api/place'

    def initialize(params = {})
      @options = { query: params }
    end

    def nearby
      self.class.get("/nearbysearch/json", @options)
    end

    def details(place_id)
      detail_options = { query: {placeid: place_id, key: ENV['GOOGLE_PLACES_API_KEY']} }
      self.class.get("/details/json", detail_options)
    end
  end

# parse google places object
# params: response, min_places, min_rating
  def parse_nearby(response)
    min_rating = 3
    # min_places = 1 if !params[:min_places]

    places = response["results"]

    #places.select { |place| place["rating"] > min_rating if place["rating"]}
  end

  def sample_place(place_ary)
    place_ary.delete_at(rand(place_ary.length))
  end

  def parse_details(detailed_response)
    name = detailed_response["results"]["name"]
    url = detailed_response["results"]["url"]
    if name && url
      {success: true, name: name, url: url}
    else
      {success: false}
    end
  end

#   if places.length < min_places do
#   new_query = response["next_page_token"]
#   next_response = GooglePlaces.new({new_page_token: new_query})
# end

# end

# trial_params = {location: "-33.8670,151.1957", radius: "500", types: "food", opennow: true, key: ENV['GOOGLE_PLACES_API_KEY']}
# trial = GooglePlaces.new(trial_params)
# results = trial.nearby

# ap parse_nearby(results)



  class WatsonConversations
    include HTTParty
    base_uri "https://watson-api-explorer.mybluemix.net/conversation/api/v1/workspaces/#{ENV['WATSON_WORKSPACE']}/message?version=2016-07-11"

    def initialize(params = {})
      @options = { query: params }
    end

    def start_convo(input_text)
      response = self.class.post("",
                                 :body => {
                                   :input => {
                                     :text => input_text
                                   },
                                   "alternate_intents": true,
                                 }.to_json,
                                 :headers => {
                                   'Content-Type' => 'application/json',
                                   'Accept' => 'application/json',
                                   'Authorization' => 'Basic YzA5ZmQxOTAtMzUxZC00M2Y5LWFiODYtMTdjYjQyOGI4ZjY2OlpyODFEOEczUE9EWg=='
      } )
    end

    def continue_convo(input_text, id_data)
      response = self.class.post("",
                                 :body => {
                                   :input => {
                                     :text => input_text
                                   },
                                   "alternate_intents": true,
                                   "context" => id_data
                                 }.to_json,
                                 :headers => {
                                   'Content-Type' => 'application/json',
                                   'Accept' => 'application/json',
                                   'Authorization' => 'Basic YzA5ZmQxOTAtMzUxZC00M2Y5LWFiODYtMTdjYjQyOGI4ZjY2OlpyODFEOEczUE9EWg=='
      } )
    end

  end

  # trial = WatsonConversations.new()
  # response = trial.start_convo("Feed me now")
  # ap response

  # new_response = trial.continue_convo("in the mission", response["context"])
  # ap new_response


  def conversation()
    convo = WatsonConversations.new()

    puts "Text me:"
    input_txt = gets.chomp()
    response = convo.start_convo(input_txt)
    puts "#{response["output"]["text"][0]}"
    continue = true

    while continue do
      puts "Another text?"
      input = gets.chomp()

      if input == "y"
        puts "Text me:"
        input_txt = gets.chomp()
        response = convo.continue_convo(input_txt, response["context"])
        puts "#{response["output"]["text"][0]}"
      end
    end

  end


  def twilio_send
    # to = params["to"]
    # message = params["body"]

    # client = Twilio::REST::Client.new(
    # ENV["TWILIO_ACCOUNT_SID"],
    # ENV["TWILIO_AUTH_TOKEN"]
    # )

    # client.messages.create(
    # to: "+14156999097",
    # from: "+14155781513",
    # body: "Yo yo" #message
    # )
  end
end
