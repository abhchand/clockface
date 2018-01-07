require "rails_helper"

module Clockface
  RSpec.feature "Creating an Event", type: :feature do
    it "user can create a event" do
      tasks = create_list(:task, 2)

      visit clockface.new_event_path

      # Fill In Form
      id = tasks[1].id
      select_option("event[clockface_task_id]", id)
      find(:css, "#event_enabled").set(true)
      fill_in("event[period_value]", with: "13")
      select_option("event[period_units]", "hours")
      select_option("event[day_of_week]", "Tuesday")
      select_option("event[hour]", "17")
      select_option("event[minute]", "38")
      select_option("event[time_zone]", "Alaska")
      select_option("event[if_condition]", "weekday")

      expect do
        submit
      end.to change { Clockface::Event.count }.by(1)

      # Validate model
      event = Clockface::Event.last
      expect(event.clockface_task_id).to eq(id)
      expect(event.enabled).to eq(true)
      expect(event.tenant).to be_nil
      expect(event.last_triggered_at).to be_nil
      expect(event.period_value).to eq(13)
      expect(event.period_units).to eq("hours")
      expect(event.day_of_week).to eq(2)
      expect(event.hour).to eq(17)
      expect(event.minute).to eq(38)
      expect(event.time_zone).to eq("Alaska")
      expect(event.if_condition).to eq("weekday")

      # Validate flash
      expect(page.find(".flash")).
        to have_content(t("clockface.events.create.success"))
    end

    context "form is invalid" do
      it "user receives feedback on invalid forms" do
        tasks = create_list(:task, 2)

        # Visit new events path
        visit clockface.events_path
        find(".events-index__new-btn").click

        # Fill In Form
        fill_in("event[period_value]", with: "-1")
        select_option("event[period_units]", "Hours")

        expect do
          submit
        end.to change { Clockface::Event.count }.by(0)

        # Validate error
        expect(current_path).to eq(clockface.new_event_path)
        expect(page.find(".flash")).to have_content(
          t(
            "activerecord.errors.models.clockface/event."\
              "attributes.period_value.greater_than",
            attribute: Clockface::Event.human_attribute_name("period_value"),
            count: 0
          )
        )
      end
    end

    context "multi-tenancy is enabled", :multi_tenant do
      before do
        enable_multi_tenancy!
      end

      it "user can create events in multiple tenants" do
        tenant("earth") { create(:task) }
        tenant("mars") { create(:task) }

        with_subdomain("earth") do
          # Visit new events path
          visit clockface.new_event_path

          # Fill In Minmal Form
          fill_in("event[period_value]", with: "13")
          select_option("event[period_units]", "Hours")

          submit

          # Check count on both tenants
          expect(Clockface::Event.count).to eq(1)
          tenant("mars") do
            expect(Clockface::Event.count).to eq(0)
          end
        end

        with_subdomain("mars") do
          # Visit new events path
          visit clockface.new_event_path

          # Fill In Minmal Form
          fill_in("event[period_value]", with: "13")
          select_option("event[period_units]", "Hours")

          submit

          # Check count on both tenants
          expect(Clockface::Event.count).to eq(1)
          tenant("earth") do
            expect(Clockface::Event.count).to eq(1)
          end
        end
      end
    end

    def submit(opts = {})
      click_button(t("clockface.events.event_form.submit"))

      # Force Capybara to wait until the new page loads before progressing
      expect(current_path).to eq(current_path)
    end
  end
end
