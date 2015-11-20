require 'test_helper'
require 'montage_rails/boolean'

module MontageRails
  class BooleanTest < MiniTest::Test
    describe ".is_me?" do
      context "when a 'true' string is passed in" do
        should "return true" do
          assert Boolean.is_me?('true')
        end
      end

      context "when a 'false' string is passed in" do
        should "return true" do
          assert Boolean.is_me?('false')
        end
      end

      context "when a TrueClass is passed in" do
        should "return true" do
          assert Boolean.is_me?(true)
        end
      end

      context "when a FalseClass is passed in" do
        should "return true" do
          assert Boolean.is_me?(false)
        end
      end

      context "when a 0 or 1 is passed in" do
        should "return true" do
          assert Boolean.is_me?(1)
          assert Boolean.is_me?(0)
          assert Boolean.is_me?("1")
          assert Boolean.is_me?("0")
        end
      end

      context "when the value is not a boolean" do
        should "return false" do
          refute Boolean.is_me?("foo")
          refute Boolean.is_me?(2)
          refute Boolean.is_me?("2")
        end
      end
    end
  end
end
