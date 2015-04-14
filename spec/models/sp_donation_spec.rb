require 'spec_helper'

describe SpDonation do
  let(:person) { create(:person) }
  let(:user) { create(:user, person: person) }
  let(:user2) { create(:user, person: create(:person)) }
  let(:sp_user) { create(:sp_user, person: person) }
  let(:sp_director) { create(:sp_director, person: person, user: user) }

  context '#update_from_siebel' do
    it 'should work' do
      p = person
      dn = create(:sp_designation_number, designation_number: '0588176', person: p)
      d = create(:sp_donation, designation_number: dn.designation_number)
      donation_json_body = '[ { "id": "XGF5T", "amount": "10.00", "designation": "0588176", "donorId": "000457337", "donationDate": "2007-10-21", "paymentMethod": "Credit Card", "paymentType": "Visa", "channel": "Recurring", "campaignCode": "CCWBST" } ]'

      stub_request(:get, "https://wsapi.cru.org/wsapi/rest/donations?designations=0588176&end_date=#{Time.now.strftime('%Y-%m-%d')}&response_timeout=60000&start_date=#{2.years.ago.strftime('%Y-%m-%d')}")
        .to_return(status: 200, body: donation_json_body, headers: {})

      donors_response = %(
[
    {
        "id": "000457337",
        "accountName": "Langford, Brian E & Robin",
        "contacts": [
        {
            "id": "1-86-2695",
            "primary": true,
            "firstName": "Brian",
            "preferredName": "Brian",
            "middleName": "Eugene",
            "lastName": "Langford",
            "title": "Mr.",
            "suffix": "",
            "sex": "M",
            "phoneNumbers": [
                {
                    "type": "Home",
                    "primary": true,
                    "phone": "517/351-9883"
                }
            ],
            "emailAddresses": [
                {
                    "type": "Business",
                    "primary": true,
                    "email": "Brian.langford@uscm.org"
                }
            ]
        },
        {
            "id": "1-86-2694",
            "secondary": true,
            "firstName": "Robin",
            "preferredName": "Robin",
            "middleName": "Anne",
            "lastName": "Langford",
            "title": "Mrs.",
            "suffix": "",
            "sex": "F",
            "phoneNumbers": [
                {
                    "type": "Home",
                    "primary": true,
                    "phone": "517/351-9883"
                }
            ],
            "emailAddresses": [
                {
                    "type": "Business",
                    "primary": true,
                    "email": "Robin.langford@uscm.org"
                }
            ]
        }
        ],
        "addresses": [
            {
                "type": "Mailing",
                "primary": false,
                "seasonal": false,
                "address1": "1582 W. Liberty",
                "address2": "",
                "address3": "",
                "address4": "",
                "city": "Ann Arbor",
                "state": "MI",
                "zip": "48103"
            },
            {
                "type": "Mailing",
                "primary": false,
                "seasonal": false,
                "address1": "1307 Kay Pkwy",
                "address2": "",
                "address3": "",
                "address4": "",
                "city": "Ann Arbor",
                "state": "MI",
                "zip": "48103"
            },
            {
                "type": "Mailing",
                "primary": true,
                "seasonal": false,
                "address1": "1369 Ramblewood Dr",
                "address2": "",
                "address3": "",
                "address4": "",
                "city": "East Lansing",
                "state": "MI",
                "zip": "48823"
            }
        ],
        "type": "Household"
    }
])
      stub_request(:get, 'https://wsapi.cru.org/wsapi/rest/donors?having_given_to_designations=0588176&response_timeout=60000')
        .to_return(status: 200, body: donors_response, headers: {})

      SpDonation.update_from_siebel
    end
  end
end
