class Mobile::HomeController < ApplicationController
  layout "mobile"
  def index
    if request.referer.nil?
      referer = "-"
    else
      referer = URI(request.referer || '').scheme + "://" + URI(request.referer || '').host 
    end
    source = params[:s] || "-"
    device="mobile"
    @traffic_log = TrafficLog.new
    @traffic_log.ip = request.remote_ip 
    @traffic_log.device = device
    @traffic_log.referer = referer
    @traffic_log.source = source
    @traffic_log.save
    session[:source] = source    
  end
  
  def test
  end
  
  def thank_you
  
  end
  
  def unique_error
  
  end

  def terms

  end
  def product

  end
  def qna
  end
end
