require 'test_helper'

class MontageRailsTest < ActiveSupport::TestCase
  context ".configure" do
    setup do
      MontageRails.username = nil
      MontageRails.password = nil
      MontageRails.token = nil
      MontageRails.domain = nil
    end

    teardown do
      MontageRails.configure do |c|
        c.token = "fb761e07-a12b-40bb-a42f-2202ecfd1046"
        c.domain = "testco"
      end
    end

    should "accept a username, password, token, and domain" do
      MontageRails.configure do |c|
        c.username = "darin"
        c.password = "foo"
        c.token = "bar"
        c.domain = "test"
      end

      assert_equal "darin", MontageRails.username
      assert_equal "foo", MontageRails.password
      assert_equal "bar", MontageRails.token
      assert_equal "test", MontageRails.domain
    end

    should "require a domain" do
      assert_raises(MontageRails::AttributeMissingError, "You must include a domain") do
        MontageRails.configure do |c|
          c.username = "darin"
          c.password = "foo"
        end
      end
    end

    should "require a username and password if no token is given" do
      assert_raises(MontageRails::AttributeMissingError, "You must include a username and password if no token is given") do
        MontageRails.configure do |c|
          c.domain = "foo"
        end
      end
    end

    should "not require a username and password if a token is given" do
      MontageRails.configure do |c|
        c.domain = "foo"
        c.token = "bar"
      end
    end

    should "call the auth method and retrieve the token if it has not been set" do
      c = Montage::Client.new do |c|
        c.domain = "foo"
        c.username = "bar"
        c.password = "foobar"
      end

      Montage::Client.expects(:new).returns(c)

      c.expects(:auth).returns(Montage::Response.new(200, { "data" => { "token" => "foobar" } }, "token"))

      MontageRails.configure do |c|
        c.domain = "foo"
        c.username = "darin"
        c.password = "foo"
      end

      assert_equal "foobar", MontageRails.token
    end

    should "raise an exception if authentication fails" do
      c = Montage::Client.new do |c|
        c.domain = "foo"
        c.username = "bar"
        c.password = "foobar"
      end

      Montage::Client.expects(:new).returns(c)

      c.expects(:auth).returns(Montage::Response.new(404, { "data" => [] }))

      assert_raises(MontageRails::MontageAPIError, "There was a problem authenticating with your username and password for domain foo") do
        MontageRails.configure do |c|
          c.domain = "foo"
          c.username = "darin"
          c.password = "bar"
        end
      end
    end
  end
end
