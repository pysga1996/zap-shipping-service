class Fucker
  attr_accessor :name, :age
end

class ShipmentController < ActionController::API
  def index
    attr = {
      :id => "4",
      :code => "lozz",
      :from => "HN",
      :to => "HCM"
    }
    s1 = Shipment.new attr
    render json: s1
  end

  def go
    values = ActiveRecord::Base.connection.exec_query('select tablename from system.tables')
  end

  def read_data
    @post = request.raw_post
    # puts @post.refId
    @fucker = JSON.parse(request.raw_post)['fuckers'][0]
    @fucker_obj = OpenStruct.new(@fucker)
    logger.debug @fucker_obj.name
    render json: @post
  end

  # :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  #:::                                                                         :::
  #:::  This routine calculates the distance between two points (given the     :::
  #:::  latitude/longitude of those points). It is being used to calculate     :::
  #:::  the distance between two locations using GeoDataSource (TM) prodducts  :::
  #:::                                                                         :::
  #:::  Definitions:                                                           :::
  #:::    South latitudes are negative, east longitudes are positive           :::
  #:::                                                                         :::
  #:::  Passed to function:                                                    :::
  #:::    lat1, lon1 = Latitude and Longitude of point 1 (in decimal degrees)  :::
  #:::    lat2, lon2 = Latitude and Longitude of point 2 (in decimal degrees)  :::
  #:::    unit = the unit you desire for results                               :::
  #:::           where: 'M' is statute miles (default)                         :::
  #:::                  'K' is kilometers                                      :::
  #:::                  'N' is nautical miles                                  :::
  #:::                                                                         :::
  #:::  Worldwide cities and other features databases with latitude longitude  :::
  #:::  are available at https://www.geodatasource.com                         :::
  #:::                                                                         :::
  #:::  For enquiries, please contact sales@geodatasource.com                  :::
  #:::                                                                         :::
  #:::  Official Web site: https://www.geodatasource.com                       :::
  #:::                                                                         :::
  #:::               GeoDataSource.com (C) All Rights Reserved 2018            :::
  #:::                                                                         :::
  #:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  def calculate_distance(lat1, lon1, lat2, lon2, unit)
    if (lat1 == lat2) && (lon1 == lon2)
      0
    else
      rad_lat_1 = Math.PI * lat1 / 180
      rad_lat_2 = Math.PI * lat2 / 180
      theta = lon1 - lon2
      rad_theta = Math.PI * theta / 180
      dist = Math.sin(rad_lat_1) * Math.sin(rad_lat_2) + Math.cos(rad_lat_1) * Math.cos(rad_lat_2) * Math.cos(rad_theta)
      if dist > 1
        dist = 1
      end
      dist = Math.acos(dist)
      dist = dist * 180 / Math.PI
      dist = dist * 60 * 1.1515
      if unit == "K"
        dist = dist * 1.609344
      end
      if unit == "N"
        dist = dist * 0.8684
      end
      dist
    end
  end
end
