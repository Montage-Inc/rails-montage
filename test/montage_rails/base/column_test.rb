require 'test_helper'
require 'montage_rails/base/column'

class MontageRails::Base::ColumnTest < Minitest::Test
  context "#value_valid?" do
    should "return false if the value is required and nil is passed in" do
      @column = MontageRails::Base::Column.new("foo", "integer", true)
      assert !@column.value_valid?(nil)
    end

    should "return true if the value is required and a proper value is passed in" do
      @column = MontageRails::Base::Column.new("foo", "integer", true)
      assert @column.value_valid?(1)
    end

    should "return true if the value is not required and nil is passed in" do
      @column = MontageRails::Base::Column.new("foo", "integer", false)
      assert @column.value_valid?(nil)
    end
  end
end
