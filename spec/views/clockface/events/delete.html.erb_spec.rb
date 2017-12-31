require "rails_helper"

module Clockface
  RSpec.describe "clockface/events/delete.html.erb", type: :view do
    let(:event) { Clockface::EventsPresenter.new(create(:event)) }
    let(:captcha) { "abcde" }

    before(:each) do
      event
      assign(:event, event)
      assign(:captcha, captcha)
      view.extend ConfigHelper
    end

    it "renders the flash" do
      render
      expect(view).to render_template(partial: "_flash")
    end

    it "renders the heading" do
      render
      expect(page).to have_content(t("clockface.events.delete.heading").downcase)
    end

    it "displays the warning" do
      render
      expect(page.find(".events-delete__warning.alert-danger")).
        to have_content(t("clockface.events.delete.warning"))
    end

    describe "event detail" do
      shared_examples "displayed event field" do |field_name|
        it "displays the field_value" do
          render

          field_label =
            Clockface::Event.human_attribute_name(field_name)
          field_value = event.send(field_name)
          field_value = strip_tags(field_value) if field_value.is_a?(String)

          row = page.find(".events-delete__event-detail-element--#{field_name}")

          expect(row.find("label")).to have_content(field_label)
          expect(row).to have_content(field_value)
        end
      end

      before(:each) do
        # Ensure each event field has a non-nil value so the view test is
        # valid

        # Some fields are not populated by the factor, so update manually
        event.update(if_condition: "odd_week")
        event.update(last_triggered_at: 1.day.ago)


        # Run a sanity check to make sure every field is not nil, should the
        # factory ever change in the future
        %w(
          period_value
          period_units
          day_of_week
          hour
          minute
          time_zone
          if_condition
          last_triggered_at
        ).each do |attr|
          raise "#{attr} can not be nil!" if event.send(attr).blank?
        end
      end

      it_behaves_like "displayed event field", :id
      it_behaves_like "displayed event field", :name
      it_behaves_like "displayed event field", :period
      it_behaves_like "displayed event field", :at
      it_behaves_like "displayed event field", :time_zone
      it_behaves_like "displayed event field", :if_condition
      it_behaves_like "displayed event field", :last_triggered_at

      describe "enabled field" do
        context "event is enabled" do
          before(:each) { event.update(enabled: true) }

          it "displays the enabled icon with CSS status" do
            render

            field_label =
              Clockface::Event.human_attribute_name("enabled")

            row = page.find(".events-delete__event-detail-element--enabled")

            expect(row.find("label")).to have_content(field_label)
            expect(row).to have_selector(".enabled-event")
            expect(row).to have_selector(".glyphicon-ok")
          end
        end

        context "event is disabled" do
          before(:each) { event.update(enabled: false) }

          it "displays the disabled icon with CSS status" do
            render

            field_label =
              Clockface::Event.human_attribute_name("enabled")

            row = page.find(".events-delete__event-detail-element--enabled")

            expect(row.find("label")).to have_content(field_label)
            expect(row).to have_selector(".disabled-event")
            expect(row).to have_selector(".glyphicon-remove")
          end
        end
      end
    end

    it "displays the captcha label" do
      render
      expect(page.find(".events-delete__captcha-label")).to have_content(
        strip_tags(t("clockface.events.delete.captcha_label", captcha: captcha))
      )
    end

    describe "form" do
      it "displays the captcha text input field" do
        render
        expect(page).to have_selector(".events-delete__form-element--captcha")
      end

      it "displays the submit button" do
        render
        form = page.find(".events-delete__form-submit")

        expect(form.find("input[type='submit']")["value"]).
          to eq(t("clockface.events.delete.submit"))
      end

      it "displays the cancel button, linking back to events_path" do
        render
        form = page.find(".events-delete__form-submit")

        expect(form).
          to have_link(
            t("clockface.events.delete.cancel"),
            href: clockface.events_path
          )
      end
    end
  end
end
