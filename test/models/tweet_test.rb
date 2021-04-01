require "test_helper"

binding.pry
class TweetTest < Minitest::Test
  subject { Tweet.new }

  test "#id" do
    assert subject.responds_to?(:id)
  end

  test "#id=" do
    subject.id = 1
    assert_equal 1, subject.id
  end

  test "#content" do
    assert subject.responds_to?(:content)
  end

  test "#content=" do
    subject.content = "foo"
    assert_equal "foo", subject.content
  end

  test "#retweets" do
    assert_equal 0, subject.retweets
  end

  test "#retweets=" do
    subject.retweets += 1
    assert_equal 1, subject.retweets
  end

  test "#hearts" do
    assert_equal 0, subject.hearts
  end

  test "#hearts=" do
    subject.hearts += 1
    assert_equal 1, subject.hearts
  end

  test "#full_name" do
    assert_equal "User Full Name", subject.full_name
  end

  test "#username" do
    assert_equal "@username", subject.username
  end

  test "#tweeted_at" do
    assert_kind_of Time, subject.tweeted_at
  end

  test "#increment" do
    assert_kind_of Time, subject.tweeted_at
  end

  describe "#validations" do
    test "content cannot be blank" do
      subject.content = ""
      refute subject.valid?
      refute_empty subject.errors[:content]
    end

    test "content cannot be more than 280 chars" do
      subject.content = "d" * 281
      refute subject.valid?
      refute_empty subject.errors[:content]
    end

    test "content can be 280 chars" do
      subject.content = "d" * 280
      refute subject.valid?
      assert_empty subject.errors[:content]
    end
  end
end
