class Message < ActiveRecord::Base
  belongs_to :user
  has_one :coupon
  
  def self.send_to(coupon)
    message = self.new
    message.send_phone = Rails.application.secrets.send_phone
    message.dest_phone = coupon.user.phone
    message.msg_body = self.send_message(coupon)
    message.subject = "NEW FACE"
    message.send_name = coupon.user.name
    message.sent_at = Time.now + 5.seconds
    message.save
    message.user = coupon.user
    message.coupon = coupon
    message.save
    message.send_lms
    return message
  end
                  
  def self.send_message(coupon)
    "
"+coupon.user.name+"님
오휘를 처음 만난 오늘부터
아름다워질거예요

새로운 NEW FACE를 위해 넘버원 에센스 본품(35ml)과 CC쿠션 미니 에디션을 드립니다.

쿠폰 사용기간 :
2014.7.1(화)~2014.8.3(일)

쿠폰받기:
" + Rails.application.secrets.url + "/" + coupon.code + "
모바일 쿠폰 사용 유의사항
· 본 행사는 첫 구매 고객에게만 제공되는 혜택입니다.(기존고객 제외)
· 전국 백화점 매장(오프라인)에서만 사용 가능합니다.(면세점 제외)
· 사은품은 중복 지급되지 않으며, 한정 수량으로 조기 품절 될 수 있습니다."
  end
  
  def send_sms
    url = "http://api.openapi.io/ppurio/1/message/sms/minivertising"
    api_key = Rails.application.secrets.apistore_key
    time = (Time.now + 1.seconds)
    res = RestClient.post(url,
      {
        "send_time" => time.strftime("%Y%m%d%H%M%S"), 
        "dest_phone" => self.dest_phone, 
        "dest_name" => "LG",
        "send_phone" => self.send_phone, 
        "send_name" => self.send_name,
        "subject" => self.subject,
        "apiVersion" => "1",
        "id" => "minivertising",
        "msg_body" => self.msg_body
      },
      content_type: 'multipart/form-data',
      'x-waple-authorization' => api_key
    )
    parsed_result = JSON.parse(res)
    cmid = parsed_result["cmid"]
    call_status = String.new
    start = Time.new
    during_time = 0
    puts res
    return JSON.parse(res)
  end
  
  
  def send_lms
    url = "http://api.openapi.io/ppurio/1/message/lms/minivertising"
    api_key = Rails.application.secrets.apistore_key
    time = (Time.now + 1.seconds)
    res = RestClient.post(url,
      {
        "send_time" => time.strftime("%Y%m%d%H%M%S"), 
        "dest_phone" => self.dest_phone, 
        "dest_name" => "LG",
        "send_phone" => self.send_phone, 
        "send_name" => self.send_name,
        "subject" => self.subject,
        "apiVersion" => "1",
        "id" => "minivertising",
        "msg_body" => self.msg_body
      },
      content_type: 'multipart/form-data',
      'x-waple-authorization' => api_key
    )
    parsed_result = JSON.parse(res)
    cmid = parsed_result["cmid"]
    call_status = String.new
    start = Time.new
    during_time = 0
    puts res
    return JSON.parse(res)
  end
  
  def waiting_for_result(interval_time, finish_time)
    start_time = Time.now
    during_time = Time.now - start_time
    result = false
    while finish_time > during_time
      during_time = Time.now - start_time
      sleep(interval_time)
    end
    if finish_time < during_time
      result = true
    end
    return result
  end
  
  def report
    api_key = Rails.application.secrets.apistore_key
    url = "http://api.openapi.io/ppurio/1/message/report/minivertising?cmid="+self.cmid
    result = RestClient.get(url, 'x-waple-authorization' => api_key)
    call_status = JSON.parse(result)["call_status"].to_s
    # self.sent_at = time
    self.result = result
    self.call_status = call_status
    self.save!    
    return call_status
  end
  

end
