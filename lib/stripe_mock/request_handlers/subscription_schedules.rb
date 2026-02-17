module StripeMock
  module RequestHandlers
    module SubscriptionSchedules

      def SubscriptionSchedules.included(klass)
        klass.add_handler 'post /v1/subscription_schedules',               :new_subscription_schedule
        klass.add_handler 'get /v1/subscription_schedules/(.*)/cancel',    :cancel_subscription_schedule
        klass.add_handler 'post /v1/subscription_schedules/(.*)/cancel',   :cancel_subscription_schedule
        klass.add_handler 'get /v1/subscription_schedules/(.*)/release',   :release_subscription_schedule
        klass.add_handler 'post /v1/subscription_schedules/(.*)/release',  :release_subscription_schedule
        klass.add_handler 'get /v1/subscription_schedules/(.*)',           :get_subscription_schedule
        klass.add_handler 'post /v1/subscription_schedules/(.*)',          :update_subscription_schedule
        klass.add_handler 'get /v1/subscription_schedules',                :list_subscription_schedules
      end

      def new_subscription_schedule(route, method_url, params, headers)
        params[:id] ||= new_id('sub_sched')
        schedule = Data.mock_subscription_schedule(params)
        subscription_schedules[schedule[:id]] = schedule
      end

      def get_subscription_schedule(route, method_url, params, headers)
        route =~ method_url
        assert_existence :subscription_schedule, $1, subscription_schedules[$1]
      end

      def update_subscription_schedule(route, method_url, params, headers)
        route =~ method_url
        schedule = assert_existence :subscription_schedule, $1, subscription_schedules[$1]
        schedule.merge!(params)
        schedule
      end

      def list_subscription_schedules(route, method_url, params, headers)
        Data.mock_list_object(subscription_schedules.values, params)
      end

      def cancel_subscription_schedule(route, method_url, params, headers)
        route =~ method_url
        schedule = assert_existence :subscription_schedule, $1, subscription_schedules[$1]
        schedule[:status] = 'canceled'
        schedule[:canceled_at] = Time.now.to_i
        schedule
      end

      def release_subscription_schedule(route, method_url, params, headers)
        route =~ method_url
        schedule = assert_existence :subscription_schedule, $1, subscription_schedules[$1]
        schedule[:status] = 'released'
        schedule[:released_at] = Time.now.to_i
        schedule
      end

    end
  end
end
