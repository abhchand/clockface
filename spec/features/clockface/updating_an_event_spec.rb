require "rails_helper"

module Clockface
  RSpec.feature "Updating an Event", type: :feature do
    it "user can update a event" do
      task = create(:task)
      event = create(
        :event,
        task: task,
        enabled: false,
        period_value: 99,
        period_units: "seconds",
        day_of_week: 5,
        hour: 22,
        minute: 32,
        time_zone: "Samoa",
        if_condition: "odd_week"
      )
      visit clockface.edit_event_path(event)

      # Fill In Form
      find(:css, "#event_enabled").set(true)
      fill_in("event[period_value]", with: "13")
      select_option("event[period_units]", "Hours")
      select_option("event[day_of_week]", "Tuesday")
      select_option("event[hour]", "17")
      select_option("event[minute]", "38")
      select_option("event[time_zone]", "Alaska")
      select_option("event[if_condition]", "weekday")

      expect do
        submit
      end.to change { Clockface::Event.count }.by(0)

      # Validate model
      event.reload
      expect(event.clockface_task_id).to eq(task.id)
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
        to have_content(t("clockface.events.update.success"))
    end

    context "form is invalid" do
      it "user receives feedback on invalid forms" do
        event = create(:event)

        # Visit new events path
        visit clockface.edit_event_path(event)

        # Fill In Form
        fill_in("event[period_value]", with: "-1")
        select_option("event[period_units]", "Hours")

        expect do
          submit
        end.to change { Clockface::Event.count }.by(0)

        # Validate error
        expect(page).to have_current_path(clockface.edit_event_path(event))
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

      it "user can update events in multiple tenants" do
        earth_event =
          tenant("earth") do
            create(:event, period_units: "seconds")
          end

        mars_event =
          tenant("mars") do
            create(:event, period_units: "seconds")
          end

        with_subdomain("earth") do
          # Visit new events path
          visit clockface.edit_event_path(earth_event)

          # Update records
          select_option("event[period_units]", "Hours")

          submit

          # Check records on both tenants
          expect(Clockface::Event.first.period_units).
            to eq("hours")
          tenant("mars") do
            expect(Clockface::Event.first.period_units).
              to eq("seconds")
          end
        end

        with_subdomain("mars") do
          # Visit new events path
          visit clockface.edit_event_path(mars_event)

          # Update records
          select_option("event[period_units]", "Hours")

          submit

          # Check records on both tenants
          expect(Clockface::Event.first.period_units).
            to eq("hours")
          tenant("earth") do
            expect(Clockface::Event.first.period_units).
              to eq("hours")
          end
        end
      end
    end

    def submit
      click_button(t("clockface.events.event_form.submit"))

      # Force Capybara to wait until the new page loads before progressing
      expect(page).to have_current_path(current_path)
    end
  end
end
