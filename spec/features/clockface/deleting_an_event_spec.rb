require "rails_helper"

module Clockface
  RSpec.feature "Deleting an Event", type: :feature do
    it "user can delete a event" do
      tasks = create_list(:task, 2)

      event = create(:event, task: tasks[1])
      other_event = create(:event, task: tasks[0])

      visit clockface.event_delete_path(event)

      # Fill In Captcha
      fill_in("captcha", with: captcha_for(event))

      expect do
        submit
      end.to change { Clockface::Event.count }.by(-1)

      # Validate model no longer exists
      expect { event.reload }.to raise_error(ActiveRecord::RecordNotFound)

      # Validate other event not touched
      old_attrs = other_event.attributes
      new_attrs = other_event.reload.attributes
      expect(old_attrs).to eq(new_attrs)
    end

    context "form is invalid" do
      it "user receives feedback on invalid forms" do
        event = create(:event)

        # Visit new events path
        visit clockface.event_delete_path(event)

        # Fill In Bad CAPTCHA
        fill_in("captcha", with: "foo")

        expect do
          submit
        end.to change { Clockface::Event.count }.by(0)

        # Validate error
        expect(current_path).to eq(clockface.event_delete_path(event))
        expect(page.find(".flash")).to have_content(
          t("clockface.events.destroy.validation.incorrect_captcha")
        )
      end
    end

    context "multi-tenancy is enabled", :multi_tenant do
      before(:each) do
        enable_multi_tenancy!
      end

      it "user can delete events in multiple tenants" do
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
          visit clockface.event_delete_path(earth_event)

          # Delete Event
          fill_in("captcha", with: captcha_for(earth_event))

          submit

          # Check records on both tenants
          expect(Clockface::Event.count).to eq(0)
          tenant("mars") do
            expect(Clockface::Event.count).to eq(1)
          end
        end

        with_subdomain("mars") do
          # Visit new events path
          visit clockface.event_delete_path(mars_event)

          # Delete Event
          fill_in("captcha", with: captcha_for(mars_event))

          submit

          # Check records on both tenants
          expect(Clockface::Event.count).to eq(0)
          tenant("earth") do
            expect(Clockface::Event.count).to eq(0)
          end
        end
      end
    end

    def submit
      click_button(t("clockface.events.delete.submit"))

      # Force Capybara to wait until the new page loads before progressing
      expect(current_path).to eq(current_path)
    end

    def captcha_for(event)
      Digest::SHA1.hexdigest(event.id.to_s).
        first(Clockface::EventsController::CAPTCHA_LENGTH)
    end
  end
end
