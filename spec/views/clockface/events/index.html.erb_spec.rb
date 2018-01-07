require "rails_helper"

module Clockface
  RSpec.describe "clockface/events/index.html.erb", type: :view do
    let(:event) { create(:event) }

    before(:each) do
      event
      assign(:events, Clockface::Event.all)
      view.extend ConfigHelper
    end

    it "renders the flash" do
      render
      expect(view).to render_template(partial: "_flash")
    end

    it "renders the heading" do
      render
      expect(page).to have_content(t("clockface.events.index.heading").downcase)
    end

    it "displays a 'new' button" do
      render

      link = page.find(".events-index__new-link")
      button = link.find(".events-index__new-btn")

      expect(link["href"]).to eq(clockface.new_event_path)
      expect(button).to have_selector(".glyphicon-plus")
    end

    describe "field headings" do
      it "displays the field headings" do
        render

        columns =
          %w(id name period at time_zone if_condition last_triggered_at enabled)

        columns.each do |attribute|
          label =
            Clockface::Event.human_attribute_name(attribute)
          css_id = "thead .events-index__events-column--#{attribute}"

          expect(page.find(css_id)).to have_content(label)
        end
      end
    end

    it "displays a row for each event" do
      event1 = event
      event2 = create(:event)
      assign(:events, Clockface::Event.all)

      render

      [event1, event2].each do |event|
        expect(page).
          to have_selector("tr.events-index__events-row[data-id='#{event.id}']")
      end
    end

    describe "event row" do
      shared_examples "displayed event field" do |field_name|
        it "displays the field_value" do
          render

          field_value = event.send(field_name)

          table_row = page.find("tr.events-index__events-row[data-id='#{event.id}']")
          field = table_row.find(".events-index__events-column--#{field_name}")

          expect(field).to have_content(field_value)
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

            table_row =
              page.find("tr.events-index__events-row[data-id='#{event.id}']")
            field = table_row.find(".events-index__events-column--enabled")

            expect(field).to have_selector(".enabled-event")
            expect(field).to have_selector(".glyphicon-ok")
          end
        end

        context "event is disabled" do
          before(:each) { event.update(enabled: false) }

          it "displays the disabled icon with CSS status" do
            render

            table_row =
              page.find("tr.events-index__events-row[data-id='#{event.id}']")
            field = table_row.find(".events-index__events-column--enabled")

            expect(field).to have_selector(".disabled-event")
            expect(field).to have_selector(".glyphicon-remove")
          end
        end
      end

      it "displays a link to edit the event" do
        render

        table_row = page.find("tr.events-index__events-row[data-id='#{event.id}']")
        field = table_row.find(".events-index__events-column--edit")

        expect(field).
          to have_selector("a[href='#{clockface.edit_event_path(event)}']")
      end

      it "displays a link to delete the event" do
        render

        table_row =
          page.find("tr.events-index__events-row[data-id='#{event.id}']")
        field = table_row.find(".events-index__events-column--destroy")

        expect(field).
          to have_selector("a[href='#{clockface.event_delete_path(event)}']")
      end
    end
  end
end
