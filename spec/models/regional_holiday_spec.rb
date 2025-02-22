require 'rails_helper'

describe RegionalHoliday do
  let(:regional_holiday) { FactoryBot.build(:regional_holiday) }

  describe 'relations' do
    it { is_expected.to have_and_belong_to_many :offices }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:day) }
    it { is_expected.to validate_presence_of(:month) }
  end

  context "with valid attributes" do
    it "is valid" do
      expect(regional_holiday).to be_valid
    end
  end

  context "with invalid day" do
    before do
      regional_holiday.day = 32
    end

    it "is not valid" do
      expect(regional_holiday).to_not be_valid
    end

    it "should include an error message" do
      regional_holiday.valid?
      expect(regional_holiday.errors[:base]).to include('date must be valid')
    end
  end

  context "with invalid month" do
    before do
      regional_holiday.month = 13
    end

    it "is not valid" do
      expect(regional_holiday).to_not be_valid
    end

    it "should include an error message" do
      regional_holiday.validate
      expect(regional_holiday.errors[:base]).to include('date must be valid')
    end
  end
end
