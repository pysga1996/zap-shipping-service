class DeliveryRestController < SecuredApiBaseController

  before_action :authenticate, only: [:index]

  def index
    attr = {
      :id => "4",
      :partner_code => "GHTK",
      :from_lvl_3_code => "HN",
      :to_lvl_3_code => "HCM"
    }
    s1 = Delivery.new attr
    logger.debug @current_user.email
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
  # @param [Numeric] lat1
  # @param [Numeric] lon1
  # @param [Numeric] lat2
  # @param [Numeric] lon2
  # @param [String] unit
  # @return [Numeric]
  def calculate_distance(lat1, lon1, lat2, lon2, unit)
    if (lat1 == lat2) && (lon1 == lon2)
      0
    else
      # @type [Numeric]
      rad_lat_1 = Math.PI * lat1 / 180
      # @type [Numeric]
      rad_lat_2 = Math.PI * lat2 / 180
      # @type [Numeric]
      theta = lon1 - lon2
      # @type [Numeric]
      rad_theta = Math.PI * theta / 180
      # @type [Numeric]
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

  # @param [Numeric] min_lon
  # @param [Numeric] min_lat
  # @param [Numeric] max_lon
  # @param [Numeric] max_lat
  def calculate_bbox_center(min_lon, min_lat, max_lon, max_lat)
    Array.new((min_lon + max_lon) / 2, (min_lat + max_lat) / 2)
  end

  # :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  #:::                                                                         :::
  #:::  The centroid of a non-self-intersecting closed polygon defined by n    :::
  #:::  vertices (x0, y0), (x1, y1), …, (xn-1, yn-1) is the point (Cx, Cy),    :::
  #:::  where:                                                                 :::
  #:::                                                                         :::
  #:::  Cx = (1/(6A)) * sum of [(x<i> + x<i+1>) * (x<i>*y<i+1> - x<i+1>*y<i>)] :::                                                 :::
  #:::  Cy = (1/(6A)) * sum of [(y<i> + y<i+1>) * (x<i>*y<i+1> - x<i+1>*y<i>)] :::
  #:::  A = (1/2) * sum of (x<i>*y<i+1> - x<i+1>*y<i>)                         :::
  #:::     with i run from 0 to <n-1>                                          :::
  #:::                                                                         :::
  #:::                                                                         :::
  #:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  # @param [Array<Array<Numeric>>] points
  # @return [Array<Numeric>]
  def calculate_polygon_centroid(points)
    # @type [Array<Numeric>]
    ans = Array.new(2, 0)

    # @type [Numeric]
    n = points.length
    # @type [Numeric]
    signed_area = 0

    # For all vertices
    (0..(n - 1)).each { |i|
      # @type [Numeric]
      x0 = points[i][0], y0 = points[i][1]
      # @type [Numeric]
      x1 = points[(i + 1) % n][0], y1 = points[(i + 1) % n][1]

      # Calculate value of A
      # using shoelace formula
      # @type [Numeric]
      a = (x0 * y1) - (x1 * y0)
      signed_area += a

      # Calculating coordinates of
      # centroid of polygon
      ans[0] += (x0 + x1) * a
      ans[1] += (y0 + y1) * a
    }

    signed_area *= 0.5
    ans[0] = (ans[0]) / (6 * signed_area)
    ans[1]= (ans[1]) / (6 * signed_area)
    ans

  end

  # nearest polygon centroid from bbox center
  # @param [Array<Numeric>] bbox_center
  # @param [Array<Array<Array<Numeric>>>] polygons
  # @return [Array<Numeric>]
  def find_area_center(bbox_center, polygons)
    # @type [Numeric]
    lon1 = bbox_center[0]
    # @type [Numeric]
    lat1 = bbox_center[1]
    # @type [Hash]
    center_map_point_dist = polygons.map { |polygon| calculate_polygon_centroid(polygon)  }
            .map { |polygon_centroid|
              # @type [Numeric]
              dist = calculate_distance(lon1, lat1, polygon_centroid[0], polygon_centroid[1], 'K')
              # @type [Hash]
              map_point_dist = { point: polygon_centroid, dist: dist }
              map_point_dist
            }
            .minimum(:dist)
    center_map_point_dist[:point]
  end
end
