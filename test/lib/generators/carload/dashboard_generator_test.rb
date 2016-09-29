require 'test_helper'
require 'generators/dashboard/dashboard_generator'

module Carload
  class DashboardGeneratorTest < Rails::Generators::TestCase
    tests DashboardGenerator
    destination Rails.root.join('tmp/generators')
    setup :prepare_destination

    # test "generator runs without errors" do
    #   assert_nothing_raised do
    #     run_generator ["arguments"]
    #   end
    # end
  end
end
