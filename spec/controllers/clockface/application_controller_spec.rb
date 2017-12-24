require "rails_helper"

module Clockface
  RSpec.describe ApplicationController, type: :controller do
    controller do
      def index
        @output = User.first.email
        render plain: "foo"
      end
    end

    describe "#run_user_defined_before_action" do
      before(:each) do
        tenant("public") { create(:user, email: "foo@public.com") }
        tenant("venus") { create(:user, email: "foo@venus.com") }

        # Cache old value to set in the `after()` block
        @old_before_action = clockface_before_action
      end

      after(:each) { set_clockface_before_action(@old_before_action) }

      context "before_action is defined" do
        before(:each) do
          set_clockface_before_action(Proc.new { tenant "venus" })
        end

        it "runs the user defined proc" do
          get :index
          expect(assigns(:output)).to eq("foo@venus.com")
        end
      end

      context "before_action is not defined" do
        before(:each) { set_clockface_before_action(nil) }

        it "doesn't attempt to run anything" do
          get :index
          expect(assigns(:output)).to eq("foo@public.com")
        end
      end

      context "before_action does not respond to #call" do
        before(:each) { set_clockface_before_action(Object.new) }

        it "doesn't attempt to run anything" do
          get :index
          expect(assigns(:output)).to eq("foo@public.com")
        end
      end
    end
  end
end
