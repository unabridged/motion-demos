require "test_helper"

class Tweetit < Minitest::Spec
  subject { Tweet.new }

  it "works for #id" do
    assert subject.respond_to?(:id)
  end

  it "works for #id=" do
    subject.id = 1
    assert_equal 1, subject.id
  end

  it "works for #content" do
    assert subject.respond_to?(:content)
  end

  it "works for #content=" do
    subject.content = "foo"
    assert_equal "foo", subject.content
  end

  it "works for #retweets" do
    assert_equal 0, subject.retweets
  end

  it "works for #retweets=" do
    subject.retweets += 1
    assert_equal 1, subject.retweets
  end

  it "works for #hearts" do
    assert_equal 0, subject.hearts
  end

  it "works for #hearts=" do
    subject.hearts += 1
    assert_equal 1, subject.hearts
  end

  it "works for #full_name" do
    assert_equal "User Full Name", subject.full_name
  end

  it "works for #username" do
    assert_equal "@username", subject.username
  end

  it "works for #tweeted_at" do
    assert_kind_of Time, subject.tweeted_at
  end

  it "works for #increment" do
    %i(hearts retweets).each do |method_name|
      init = subject.send(method_name)
      subject.increment(method_name, 2)
      assert_equal init + 2, subject.send(method_name)
    end
  end

  describe "#validations" do
    it "#content cannot be blank" do
      subject.content = ""
      refute subject.valid?
      refute_empty subject.errors[:content]
    end

    it "#content cannot be more than 280 chars" do
      subject.content = "d" * 281
      refute subject.valid?
      refute_empty subject.errors[:content]
    end

    it "#content can be 280 chars" do
      subject.content = "d" * 280
      assert subject.valid?
      assert_empty subject.errors[:content]
    end
  end
end
