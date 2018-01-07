require "rails_helper"

module Clockface
  RSpec.describe "clockface/tasks/delete.html.erb", type: :view do
    let(:task) { create(:task) }
    let(:captcha) { "abcde" }

    before(:each) do
      task
      assign(:task, task)
      assign(:captcha, captcha)
      view.extend ConfigHelper
    end

    it "renders the flash" do
      render
      expect(view).to render_template(partial: "_flash")
    end

    it "renders the heading" do
      render
      expect(page).to have_content(t("clockface.tasks.delete.heading").downcase)
    end

    it "displays the warning" do
      render
      expect(page.find(".tasks-delete__warning.alert-danger")).
        to have_content(t("clockface.tasks.delete.warning"))
    end

    describe "task detail" do
      shared_examples "displayed task field" do |field_name|
        it "displays the field_value" do
          render

          field_label =
            Clockface::Task.human_attribute_name(field_name)
          field_value = task.send(field_name)
          field_value = strip_tags(field_value) if field_value.is_a?(String)

          row = page.find(".tasks-delete__task-detail-element--#{field_name}")

          expect(row.find("label")).to have_content(field_label)
          expect(row).to have_content(field_value)
        end
      end

      before(:each) do
        # Ensure each task field has a non-nil value so the view test is
        # valid

        # Some fields are not populated by the factory, so update manually
        task.update(description: "some description")


        # Run a sanity check to make sure every field is not nil, should the
        # factory ever change in the future
        %w(
          name
          description
          command
        ).each do |attr|
          raise "#{attr} can not be nil!" if task.send(attr).blank?
        end
      end

      it_behaves_like "displayed task field", :id
      it_behaves_like "displayed task field", :name
      it_behaves_like "displayed task field", :description
      it_behaves_like "displayed task field", :command
    end

    it "displays the captcha label" do
      render
      expect(page.find(".tasks-delete__captcha-label")).to have_content(
        strip_tags(t("clockface.tasks.delete.captcha_label", captcha: captcha))
      )
    end

    describe "form" do
      it "displays the captcha text input field" do
        render
        expect(page).to have_selector(".tasks-delete__form-element--captcha")
      end

      it "displays the submit button" do
        render
        form = page.find(".tasks-delete__form-submit")

        expect(form.find("input[type='submit']")["value"]).
          to eq(t("clockface.tasks.delete.submit"))
      end

      it "displays the cancel button, linking back to tasks_path" do
        render
        form = page.find(".tasks-delete__form-submit")

        expect(form).
          to have_link(
            t("clockface.tasks.delete.cancel"),
            href: clockface.tasks_path
          )
      end
    end
  end
end
