require 'json'
require 'faraday'
require 'uri'
require 'time'
require 'date'

def auth_azure(tenant_id, client_id, client_secret)
  url = "https://login.microsoftonline.com/#{tenant_id}/oauth2/v2.0/token"
  body = {
    scope: 'https://graph.microsoft.com/.default',
    grant_type: 'client_credentials',
    client_id:,
    client_secret:,
  }
  res = Faraday.post(url) do |req|
    req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
    req.body = URI.encode_www_form(body)
  end

  JSON.parse(res.body)['access_token']
end

def fetch_schedules(access_token, azure_user_principal_name)
  url = "https://graph.microsoft.com/v1.0/users/#{azure_user_principal_name}/calendar/calendarview" 
  res = Faraday.get(url) do |req|
    req.headers['Authorization'] = "Bearer #{access_token}"
    req.headers['Accept'] = 'application/json'
    req.headers['Prefer'] = "outlook.timezone=\"Asia/Tokyo\""
    req.params = {
      startDateTime: Date.today.to_time.iso8601,
      endDateTime: (Date.today + 1).to_time.iso8601,
      orderby: 'start/dateTime asc'
    }
  end

  JSON.parse(res.body)['value']
end

def print_schedule(schedule)
  started_at = Time.parse(schedule.dig('start', 'dateTime'))
  ended_at = Time.parse(schedule.dig('end', 'dateTime'))
  subject = schedule['type'] == 'exception' ? '非公開' : schedule['subject']
  puts "#{started_at.strftime('%Y/%m/%d %H:%M')}〜#{ended_at.strftime('%Y/%m/%d %H:%M')}: #{subject}"
end

def lambda_handler(event:, context:)
  access_token = auth_azure(
    ENV.fetch('AZURE_TENANT_ID', nil),
    ENV.fetch('AZURE_APP_ID', nil),
    ENV.fetch('AZURE_APP_SECRET', nil)
  )
  schedules = fetch_schedules(access_token, ENV.fetch('AZURE_USER_PRINCIPAL_NAME', nil))
  schedules&.each do |schedule|
    print_schedule(schedule)
  end
rescue => e
  puts e.full_message
end
