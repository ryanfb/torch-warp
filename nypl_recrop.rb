#!/usr/bin/env ruby

require 'json'
require 'rest-client'
require 'dimensions'

NYPL_API_TOKEN = ENV["NYPL_API_TOKEN"]
NYPL_AUTH = "Token token=\"#{NYPL_API_TOKEN}\""
NYPL_ENDPOINT = "http://api.repo.nypl.org/api/v1/items"

if NYPL_API_TOKEN.nil?
  abort("You must set an NYPL_API_TOKEN environment variable with your token from http://api.repo.nypl.org/")
end

stereo_metadata = JSON.parse(RestClient.get("http://stereo.nypl.org/view/#{ARGV[0]}.json"))

unless stereo_metadata['external_id'] == 0
  abort('Image must be from NYPL collections.')
end

digital_id = stereo_metadata['digitalid'].upcase
image_id = JSON.parse(RestClient.get("#{NYPL_ENDPOINT}/local_image_id/#{digital_id}", :Authorization => NYPL_AUTH))
image_uuid = image_id['nyplAPI']['response']['uuid']
image_captures = JSON.parse(RestClient.get("#{NYPL_ENDPOINT}/#{image_uuid}", :Authorization => NYPL_AUTH))

matching_captures = image_captures['nyplAPI']['response']['capture'].select{|c| c['imageID'].upcase == digital_id}

if matching_captures && matching_captures.length > 0
  # capture_uuid = matching_captures[0]['uuid']
  # capture_details = JSON.parse(RestClient.get("#{NYPL_ENDPOINT}/item_details/#{capture_uuid}", :Authorization => NYPL_AUTH))
  highres_url = matching_captures[0]['highResLink']
  lowres_url = stereo_metadata['url']

  if highres_url.nil? || highres_url.empty?
    puts image_captures.to_json
    abort("No highResLink for #{digital_id}")
  end

  # download images
  $stderr.puts "Downloading images..."
  `wget -nc -O #{ARGV[0]}.jpg '#{lowres_url}'`
  `wget -nc -O #{ARGV[0]}.tif '#{highres_url}'`

  # calculate the crop for the original image using multiscale template matching
  $stderr.puts "Calculating crop..."
  crop_params = `./template_match_multiscale.py --template #{ARGV[0]}.jpg --image #{ARGV[0]}.tif`.chomp

  # apply the crop
  `convert #{ARGV[0]}.tif -crop #{crop_params} +repage #{ARGV[0]}_cropped.tif`

  # calculate dimensions
  lowres_dims = Dimensions.dimensions("#{ARGV[0]}.jpg")
  highres_dims = Dimensions.dimensions("#{ARGV[0]}_cropped.tif")

  # calculate scaling
  x_scale = highres_dims[0].to_f / lowres_dims[0].to_f
  y_scale = highres_dims[1].to_f / lowres_dims[1].to_f

  # calculate scaled dimensions
  cropped_width = stereo_metadata['width'] * x_scale
  cropped_height = stereo_metadata['height'] * y_scale
  x1 = stereo_metadata['x1'] * x_scale
  x2 = stereo_metadata['x2'] * x_scale
  y1 = stereo_metadata['y1'] * y_scale
  y2 = stereo_metadata['y2'] * y_scale

  # use the scaled dimensions to split the cropped original into the component images
  $stderr.puts "Cropping image..."
  `convert #{ARGV[0]}_cropped.tif -crop #{cropped_width}x#{cropped_height}+#{x1}+#{y1} +repage #{ARGV[0]}_0.png`

  `convert #{ARGV[0]}_cropped.tif -crop #{cropped_width}x#{cropped_height}+#{x2}+#{y2} +repage #{ARGV[0]}_1.png`
else
  puts image_captures.to_json
  abort("No matching captures for #{digital_id}")
end
