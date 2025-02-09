require 'rails_helper'

RSpec.describe TicketableCreation do
  before(:all) do
    ActiveRecord::Base.connection.create_table :test_models, temporary: true do |t|
      t.timestamps
    end
  end

  after(:all) do
    ActiveRecord::Base.connection.drop_table :test_models
  end

  class TestModel < ApplicationRecord
    include TicketableCreation
  end

  describe 'callbacks' do
    let(:test_model) { TestModel.new }
  end
end
