RSpec.describe Utilities::Mobile do
  subject { described_class.new number, country }

  context 'no country, valid international number' do
    let(:country) { nil }
    let(:number) { '+1 858 693 3582' }

    its(:valid?) { should be true }
    its(:parsed_number) { should eq '+18586933582'}
    its(:masked_number) { should eq '********3582'}
    its(:parsed_country) { should eq 'US' }
    its(:india_number?) { should be false }
  end

  context 'no country, valid India national number' do
    let(:country) { nil }
    let(:number) { '9945731953' }

    its(:valid?) { should be true }
    its(:parsed_number) { should eq '+919945731953' }
    its(:masked_number) { should eq '********1953' }
    its(:parsed_country) { should eq 'IN' }
    its(:india_number?) { should be true }
  end

  context 'no country, invalid number' do
    let(:country) { nil }
    let(:number) { '123 456789' }

    its(:valid?) { should be false }
    its(:parsed_number) { should eq '123 456789' }
    its(:masked_number) { should eq '********6789' }
    its(:parsed_country) { should eq nil }
    its(:india_number?) { should be false }
  end

  context 'country specified, valid national number' do
    let(:country) { 'US' }
    let(:number) { '858 693 3582' }

    its(:valid?) { should be true }
    its(:parsed_number) { should eq '+18586933582' }
    its(:masked_number) { should eq '********3582' }
    its(:parsed_country) { should eq 'US' }
    its(:india_number?) { should be false }
  end

  context 'country specified, invalid national number' do
    let(:country) { 'US' }
    let(:number) { '1234567' }

    its(:valid?) { should be false }
    its(:parsed_number) { should eq '1234567' }
    its(:masked_number) { should eq '********4567' }
    its(:parsed_country) { should eq nil }
    its(:india_number?) { should be false }
  end

end
