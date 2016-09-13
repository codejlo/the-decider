require 'twilio-ruby'
require 'awesome_print'

post '/inbound' do
  incoming = {message: params["Body"], sender: params["From"]}

  user = User.find_by(phone_number: incoming[:sender])

  if user
    time_since_contact = Time.new - user.updated_at
    ap time_since_contact

    if time_since_contact > 1800
      convo = WatsonConversations.new()
      ap response = convo.start_convo(incoming[:message])

      user.update(last_context: response["context"])
      
      message_back = Twilio::TwiML::Response.new do |r|
        r.Message "#{response["output"]["text"][0]}"
      end

      message_back.to_xml
    else
      last_context = user.last_context
      convo = WatsonConversations.new()
      ap response = convo.continue_convo(incoming[:message], last_context)

      user.update(last_context: response["context"])
      response_text = response["output"]["text"][0]
      if response_text[0..16] == "Finding food near"
        ap "Googling ========================"
        ap incoming[:message]
        location_requested = incoming[:message]
          locations = {
            "soma" => "37.782623,-122.397372",
            "mission" => "37.782623,-122.397372",
            "north beach" => "37.799485,-122.408739"
          }
        search_params = {
          location: locations[location_requested],
          radius: "500",
          query: "restaurant",
          opennow: true,
          key: ENV['GOOGLE_PLACES_API_KEY']
        }

        search = GooglePlaces.new(search_params)
        search_to_parse = search.nearby
        results = parse_nearby(search_to_parse)
        result = sample_place(results)

        detail_search = parse_details(search.details(result["place_id"]))
        if detail_search[:success]
          response_text = "Go here: #{detail_search[:name]} #{detail_search[:url]}"
        else
          result = sample_place(results)
          ap detail_search = parse_details(search.details(result["place_id"]))
          response_text = "Go here: #{detail_search[:name]} #{detail_search[:url]}"
        end

      end

      message_back = Twilio::TwiML::Response.new do |r|
        r.Message response_text
      end

      message_back.to_xml
    end
  else
    user = User.create(phone_number: incoming[:sender])
    convo = WatsonConversations.new()
    response = convo.start_convo(incoming[:message])

    user.update(last_context: response["context"])
      
    message_back = Twilio::TwiML::Response.new do |r|
      r.Message "#{response["output"]["text"][0]}"
    end

    message_back.to_xml
  end
end



### EXAMPLE CODE ###

# post '/receive_sms' do
#   content_type 'text/xml'

#   response = Twilio::TwiML::Response.new do |r|
#     r.Message 'Hey thanks for messageing me!'
#   end

#   response.to_xml
# end

# post '/send_sms' do
#   to = params["to"]
#   message = params["body"]

#   client = Twilio::REST::Client.new(
#   ENV["TWILIO_ACCOUNT_SID"],
#   ENV["TWILIO_AUTH_TOKEN"]
#   )

#   client.messages.create(
#   to: "+14156999097",
#   from: "+14155781513",
#   body: "Yo yo" #message
#   )
# end
