RSpec.describe Aliyun::NlpApi do
  it "has a version number" do
    expect(Aliyun::NlpApi::VERSION).not_to be nil
  end

  it "shoud create with access_key_id, access_key_secret" do
    access_key_id = "test_access_key_id"
    access_key_secret = "test_access_key_secret"
    client = Aliyun::NlpApi::Client.new(access_key_id,access_key_secret)
    expect(client.ak_id).to eq(access_key_id)
    expect(client.ak_secret).to eq(access_key_secret)
    expect(client.host).to eq("nlp.cn-shanghai.aliyuncs.com")
  end

  it "shoud create with custom host" do
    access_key_id = "test_access_key_id"
    access_key_secret = "test_access_key_secret"
    client = Aliyun::NlpApi::Client.new(access_key_id,access_key_secret, "some.com")

    expect(client.host).to eq("some.com")
  end
end
