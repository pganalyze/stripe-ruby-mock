require 'spec_helper'

shared_examples 'Subscription Schedule API' do

  context 'create subscription schedule' do
    it 'creates a subscription schedule' do
      schedule = Stripe::SubscriptionSchedule.create(customer: 'cus_123', end_behavior: 'release')

      expect(schedule.id).to match(/sub_sched/)
      expect(schedule.object).to eq('subscription_schedule')
      expect(schedule.customer).to eq('cus_123')
      expect(schedule.end_behavior).to eq('release')
      expect(schedule.status).to eq('not_started')
    end

    it 'creates a subscription schedule with phases' do
      phases = [{ items: [{ price: 'price_123', quantity: 1 }], iterations: 1 }]
      schedule = Stripe::SubscriptionSchedule.create(customer: 'cus_123', phases: phases)

      expect(schedule.phases).to_not be_empty
    end

    it 'stores a created subscription schedule in memory' do
      schedule = Stripe::SubscriptionSchedule.create(customer: 'cus_123')

      data = test_data_source(:subscription_schedules)
      expect(data[schedule.id]).to_not be_nil
      expect(data[schedule.id][:customer]).to eq('cus_123')
    end
  end

  context 'retrieve subscription schedule' do
    it 'retrieves a subscription schedule' do
      created = Stripe::SubscriptionSchedule.create(customer: 'cus_123')

      schedule = Stripe::SubscriptionSchedule.retrieve(created.id)

      expect(schedule.id).to eq(created.id)
      expect(schedule.customer).to eq('cus_123')
    end

    it "cannot retrieve a subscription schedule that doesn't exist" do
      expect { Stripe::SubscriptionSchedule.retrieve('sub_sched_nope') }.to raise_error {|e|
        expect(e).to be_a Stripe::InvalidRequestError
        expect(e.param).to eq('subscription_schedule')
        expect(e.http_status).to eq(404)
      }
    end
  end

  context 'update subscription schedule' do
    it 'updates a subscription schedule' do
      created = Stripe::SubscriptionSchedule.create(customer: 'cus_123', end_behavior: 'release')

      schedule = Stripe::SubscriptionSchedule.update(created.id, end_behavior: 'cancel')

      expect(schedule.end_behavior).to eq('cancel')
    end

    it 'updates metadata' do
      created = Stripe::SubscriptionSchedule.create(customer: 'cus_123')

      schedule = Stripe::SubscriptionSchedule.update(created.id, metadata: { key: 'value' })

      expect(schedule.metadata.to_hash).to eq({ key: 'value' })
    end
  end

  context 'list subscription schedules' do
    it 'lists all subscription schedules' do
      Stripe::SubscriptionSchedule.create(customer: 'cus_123')
      Stripe::SubscriptionSchedule.create(customer: 'cus_456')

      schedules = Stripe::SubscriptionSchedule.list

      expect(schedules.count).to eq(2)
    end
  end

  context 'cancel subscription schedule' do
    it 'cancels a subscription schedule' do
      created = Stripe::SubscriptionSchedule.create(customer: 'cus_123')

      schedule = Stripe::SubscriptionSchedule.cancel(created.id)

      expect(schedule.status).to eq('canceled')
      expect(schedule.canceled_at).to_not be_nil
    end

    it "cannot cancel a subscription schedule that doesn't exist" do
      expect { Stripe::SubscriptionSchedule.cancel('sub_sched_nope') }.to raise_error {|e|
        expect(e).to be_a Stripe::InvalidRequestError
        expect(e.http_status).to eq(404)
      }
    end
  end

  context 'release subscription schedule' do
    it 'releases a subscription schedule' do
      created = Stripe::SubscriptionSchedule.create(customer: 'cus_123')

      schedule = Stripe::SubscriptionSchedule.release(created.id)

      expect(schedule.status).to eq('released')
      expect(schedule.released_at).to_not be_nil
    end

    it "cannot release a subscription schedule that doesn't exist" do
      expect { Stripe::SubscriptionSchedule.release('sub_sched_nope') }.to raise_error {|e|
        expect(e).to be_a Stripe::InvalidRequestError
        expect(e.http_status).to eq(404)
      }
    end
  end

end
