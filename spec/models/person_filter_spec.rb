require 'spec_helper'

describe PersonFilter do
  context '#filter' do
    it 'should work' do
      p = create(:person, first_name: 'first_name', last_name: 'last_name', strategy: 'strategy', gender: '1')
      p.primary_email_address = 'a@b.com'
      filter = PersonFilter.new(id: p.id, ids: "#{p.id}, 12345", first_name_like: 'first', last_name_like: 'last',
                                name_or_email_like: 'first_name last_name', name_like: 'me la',
                                email_like: p.email, gender: 1, strategy: 'strategy')
      expect(filter.filter(Person.all).to_a).to eq([p])
    end

    it 'should work with name_or_email_like being an email' do
      p = create(:person, first_name: 'first_name', last_name: 'last_name', strategy: 'strategy', gender: '1')
      p.primary_email_address = 'a@b.com'
      filter = PersonFilter.new(id: p.id, ids: "#{p.id}, 12345", name_or_email_like: p.email)
      expect(filter.filter(Person.all).to_a).to eq([p])
    end

    it 'should work with name_or_email_like being a name with no whitespace' do
      p = create(:person, first_name: 'first_name', last_name: 'last_name', strategy: 'strategy', gender: '1')
      p.primary_email_address = 'a@b.com'
      filter = PersonFilter.new(id: p.id, ids: "#{p.id}, 12345", name_or_email_like: 'fir')
      expect(filter.filter(Person.all).to_a).to eq([p])
       filter = PersonFilter.new(id: p.id, ids: "#{p.id}, 12345", name_or_email_like: 'las')
      expect(filter.filter(Person.all).to_a).to eq([p])
    end

    it 'should work with name_like not having whitespace and thus searches first or last name like' do
      p = create(:person, first_name: 'first_name', last_name: 'last_name', strategy: 'strategy', gender: '1')
      p.primary_email_address = 'a@b.com'
      filter = PersonFilter.new(id: p.id, ids: "#{p.id}, 12345", name_like: 'fir')
      expect(filter.filter(Person.all).to_a).to eq([p])
      filter = PersonFilter.new(id: p.id, ids: "#{p.id}, 12345", name_like: 'las')
      expect(filter.filter(Person.all).to_a).to eq([p])
    end
  end
end
