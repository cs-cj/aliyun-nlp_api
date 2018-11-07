require "aliyun/nlp_api/version"
require 'json'
# require 'rest-client'
require 'base64'
require 'digest/md5'
require 'securerandom'
require 'uri'
require 'net/http'
require 'net/https'
require 'time'

module Aliyun
  module NlpApi
    # Your code goes here...

    attr_accessor :ak_id, :ak_secret, :host

    def initialize(ak_id, ak_secret)
      @ak_id = ak_id
      @ak_secret = ak_secret
      @host = 'nlp.cn-shanghai.aliyuncs.com'
    end

    def post_api(url, body)
      body = body.force_encoding("utf-8")  rescue "请求数据编码请使用 UTF-8 字符集"
      # 计算body的MD5值，然后再对其进行base64编码，编码后的值设置到 Header中。
      puts net_url = URI.parse("#{url}")
      path =  net_url.request_uri
      host = net_url.host
      http_or_https = net_url.scheme

      method = "POST"
      accept = "application/json"
      body_md5 = Base64.strict_encode64(OpenSSL::Digest::MD5.digest(body)) ## 1.对body做MD5+BASE64加密
      content_type = "application/json;chrset=utf-8"
      date = Time.now.httpdate #Time.new(20181116).httpdate
      uuid = SecureRandom.uuid

      # puts "stringToSign==========>"
      stringToSign = method + "\n" + accept + "\n" + body_md5+ "\n" +  content_type + "\n" + date + "\n" + "x-acs-signature-method:HMAC-SHA1\n" + "x-acs-signature-nonce:" + uuid + "\n" + path
      # + "x-acs-version:2018-04-04\n"
      # 2.计算 HMAC-SHA1

      signature = Base64.strict_encode64(OpenSSL::HMAC.digest('sha1', ak_secret, stringToSign))

      # 3.得到 authorization header
      authHeader = "acs " + ak_id + ":" + signature

      #
      # header = {
      #     "Accept"=> accept,
      #     "Content-MD5"=> body_md5,
      #     "Content-Type"=> content_type,
      #     "Date"=> date,
      #     "x-acs-signature-nonce"=> uuid,
      #     "x-acs-signature-method"=> "HMAC-SHA1",
      #     "Content-Length"=> "#{body.length}",
      #     "Host"=> host,
      #     "Authorization"=> authHeader
      # }

      if http_or_https == "https"
        use_ssl = true
      else
        use_ssl = false
      end
      # todo 待完善 post https
      response = Net::HTTP.start(net_url.host, net_url.port, use_ssl: use_ssl) do |http|
        # req = Net::HTTP::Post.new(uri)
        if use_ssl
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end

        request = Net::HTTP::Post.new(net_url)

        request["Accept"] = accept
        request["Content-Type"] = content_type
        request["Content-MD5"] = body_md5

        request["Date"] = date
        request["Host"] = host
        request["Authorization"] = authHeader
        request["x-acs-signature-nonce"] = uuid
        request["x-acs-signature-method"] = "HMAC-SHA1"
        # request["x-acs-version"] =  '2018-04-04'
        request["Content-Length"] = "#{body.length}"

        # puts "header==========>"
        # # p header
        # request.each_header do |head|
        #   p "#{head}: #{request[head]}"
        # end

        # puts "body==========>"
        request.body = body
        http.request(request)
      end

      response.read_body.force_encoding("utf-8")

    end

    # Aliyun::NlpApi.test_try
    def self.test_try(ak_id = "",ak_secret = "")
      body = {
          "lang"=> "ZH",
          "text"=> "Iphone专用数据线"
      }
      client = Aliyun::NlpApi.new(ak_id,ak_secret)
      api_path = "/nlp/api/wordsegment/general"
      whole_url = "https://" + client.host + api_path
      puts res = client.post_api( whole_url , body.to_json)
      res
    end

    # params
    # @ak_id = ak_id
    # @ak_secret = ak_secret
    # api_path: nlp/api/wordsegment/general
    # body
    # Aliyun::NlpApi.test_try_api()
    def self.test_try_api(ak_id,ak_secret, api_path="/nlp/api/wordpos/general", body = {"text"=> "真丝韩都衣舍连衣裙"})
    # whole_api_url "http://" + @host + api
    client = Aliyun::NlpApi.new(ak_id,ak_secret)
    whole_api_url = "http://" + client.host + api_path
    puts res = client.post_api( whole_api_url , body.to_json)
    res
    end

    # Aliyun::NlpApi.example
    def self.example(ak_id,ak_secret)
      client = Aliyun::NlpApi.new(ak_id,ak_secret)
      body = {
          "lang"=>"ZH",
          "text"=>"Iphone专用数据线"
      }
      client.common_api(body, "/nlp/api/wordpos/general"  )
      # client.wordsegment(body)
      # client.wordpos(body)

    end

    # api 列表

    def common_api(body , api_path="/nlp/api/wordpos/general")
    whole_url = "http://" + host + api_path
    post_api( whole_url , body.to_json)
    end

    # todo 待完善 post https
    # def common_api_https(body = {"text"=> "真丝韩都衣舍连衣裙"}, api_path="/nlp/api/wordpos/general")
    #   whole_url = "https://" + host + api_path
    #   post_api( whole_url , body.to_json)
    # end

    # 多语言分词
    #  https://nlp.cn-shanghai.aliyuncs.com/nlp/api/wordsegment/{Domain}
    #  Domain: general
    #  body :
    #           {
    #                "lang"=>"ZH",
    #                "text"=>"Iphone专用数据线"
    #            }
    def wordsegment(body, domian="general")
      api_path = "/nlp/api/wordsegment/#{domian}"
      whole_url = "http://" + host + api_path
      post_api( whole_url , body.to_json)
    end

    # def wordsegment_https(body, domian="general")
    #   api_path = "/nlp/api/wordsegment/#{domian}"
    #   whole_url = "https://" + host + api_path
    #   post_api( whole_url , body.to_json)
    # end


    # 词性标注
    #  [http|https]://nlp.cn-shanghai.aliyuncs.com/nlp/api/wordpos/{Domain}
    #  Domain: general
    #  body: { "text"=>"真丝韩都衣舍连衣裙" }

    def wordpos(body, domian="general")
      api_path = "/nlp/api/wordpos/#{domian}"
      whole_url = "http://" + host + api_path
      post_api( whole_url , body.to_json)
    end

    # 命名实体
    # [http|https]://nlp.cn-shanghai.aliyuncs.com/nlp/api/entity/{Domain}
    # Domain: ecommerce
    # body:
    # {
    #     "text"=>"真丝韩都衣舍连衣裙",
    #     "type"=>"full" # simple, full
    # }

    def entity(body, domian="ecommerce")
      api_path = "/nlp/api/entity/#{domian}"
      whole_url = "http://" + host + api_path
      post_api( whole_url , body.to_json)
    end

    # 情感分析
    # [http|https]://nlp.cn-shanghai.aliyuncs.com/nlp/api/sentiment/{Domain}
    # Domain: ecommerce
    #  body: { "text"=>"真丝韩都衣舍连衣裙" }

    def sentiment(body, domian="ecommerce")
      api_path = "/nlp/api/sentiment/#{domian}"
      whole_url = "http://" + host + api_path
      post_api( whole_url , body.to_json)
    end

    # 机器翻译 作为自然语言处理的一个基础应用，提供中文、英文、俄语、葡萄牙语、西班牙语、法语的翻译服务，支持通用场景和电商垂直场
    # [http|https]://nlp.cn-shanghai.aliyuncs.com/nlp/api/translate/[Domain]
    # Domain: standard,general, ecommerce
    #  body:
    #  {
    #      "q"=>"hello",
    #      "source"=>"en",
    #      "target"=>"zh",
    #      "format"=>"text"
    #  }

    def translate(body, domian="standard")
      api_path = "/nlp/api/translate/#{domian}"
      whole_url = "http://" + host + api_path
      post_api( whole_url , body.to_json)
    end

    # 信息抽取 信息抽取领域（目前支持contract，合同信息抽取）
    # https://nlp.cn-shanghai.aliyuncs.com/nlp/api/ie/{Domain}
    # Domain: contract
    #  body:
    #  {
    #      "lang"=> "ZH",
    #      "content"=> "合同内容字符串",
    #  }
    def ie(body, domian="contract")
      api_path = "/nlp/api/ie/#{domian}"
      whole_url = "http://" + host + api_path
      post_api( whole_url , body.to_json)
    end

    # 中心词识别
    # https://nlp.cn-shanghai.aliyuncs.com/nlp/api/kwe/{Domain}
    # Domain: ecommerce
    #  body:
    #  {
    #      "lang"=>"ZH",
    #      "text"=>"新鲜桔子"
    #  }
    def kwe(body, domian="ecommerce")
      api_path = "/nlp/api/kwe/#{domian}"
      whole_url = "http://" + host + api_path
      post_api( whole_url , body.to_json)
    end


    # 商品评价解析 商品评价解析主要用于分析消费者反馈的评价、点评内容，同时也可以对类似微博的口语化、短文本进行分析。对于长篇幅的新闻篇章不适用。
    # [http|https]://nlp.cn-shanghai.aliyuncs.com/nlp/api/reviewanalysis/{Domain}
    # Domain: ecommerce
    #  body:
    #  {
    #      "text"=> "面料舒适，款式好，只是尺码偏小，好在我看了其他买家的评价，在原尺码上加了一号，正合适，很满意！给满分！服务好，发货快！",
    #      "cate"=> "clothing"
    #  }
    #  cate: 行业类别,
    #  “clothing”：服装, “makeup”：美妆, “snacks”：零食, “milkpowder”：奶粉, “paperdiaper”：纸尿裤, “shoes”：鞋类, “furniture”：住宅家具, “bedding”：床上用品, “underwear”:内衣, “bags”:箱包, “cellphone”:手机, “cycling”:骑行配饰, “bicycle”:自行车, “bigball”:大型球类, “littleball”:小型球类, “watch”:手表, “glasses”:眼镜, “television”:电视机, “refrigeration”:制冷设备, “washingmachine”:洗衣机, “waterheater”:热水器, “decoration”:家装主材, “wine”:酒类, “ballacessory”:球类配件"
    #  行业逐步增加中，请关注文档更新或咨询客服人员
    def reviewanalysis(body, domian="ecommerce")
      api_path = "/nlp/api/reviewanalysis/#{domian}"
      whole_url = "http://" + host + api_path
      post_api( whole_url , body.to_json)
    end

    #  智能文档分类 对用户输入的一段文本，映射到具体的类目上。
    #  https://nlp.cn-shanghai.aliyuncs.com/nlp/api/textstructure/{Domain}
    #  Domain: ecommerce（电商领域）, news（新闻领域）
    # body:
    #  {
    #      "text"=>"脚蹬Mra，帅里帅气Mra是2013年新崛起的新锐品牌，作为Mra的大Boss福叔他爱鞋如痴，从皮料到包装他都严格把关，当收集到足够多的意见后，他总会用纯手工打扮出第一双样鞋，然后再不断 的调整改进，>每双都能精益求精！福叔常说要用品质为顾客撑腰，因此Mra都是选用的上等小牛皮加工，由经验丰富的老工匠在一边亲自操刀。",
    #      "tag_flag"=>"true"  #是否需要关键词抽取功能
    #  }
    def textstructure(body, domian="ecommerce")
      api_path = "/nlp/api/textstructure/#{domian}"
      whole_url = "http://" + host + api_path
      post_api( whole_url , body.to_json)
    end


    # 词性列表
    def wordpos_k_cn
      {
          VA:	"谓词性形容词",
          VC:	"系动词，如：是",
          VE:	"存在性动词，如：有，没{有}，无",
          VV:	"其他动词",
          NR:	"专有名词",
          NT:	"时间名词",
          NN:	"其他名词",
          LC:	"方位词",
          PN:	"代词",
          DT:	"限定词",
          CD:	"基数词",
          OD:	"序列词",
          M:	"度量词",
          AD:	"副词",
          P:	"介词",
          CC:	"并列连接词",
          CS:	"从属连接词",
          DEC:	"“的”作为补语标记/名词化标记，如：吃的",
          DEG:	"“的”作为关联标记/所有格标记，如：淡淡的花香",
          DER:	"“得”，如：穿得好看",
          DEV:	"“地”，如：不断地提醒",
          AS:	"动词助词，仅包括：着，了，过，的",
          SP:	"句末助词，如：了，呢，吧，啊，呀，吗",
          ETC:	"“等”，“等等”",
          MSP:	"其他助词，如：所，以，来，而",
          IJ:	"感叹词，如：啊",
          ON:	"拟声词，如：哗啦啦，咯吱",
          LB:	"长“被”结构，如：他被我训了一顿",
          SB:	"短“被”结构，如：他被训了一顿",
          BA:	"把字结构，如：他把你骗了",
          JJ:	"其他名词修饰词",
          FW:	"外来词",
          PU:	"标点",
      }
    end

  end
end
