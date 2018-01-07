require "rails_helper"

module Clockface
  RSpec.describe "clockface/tasks/_task_form.html.erb", type: :view do
    let(:task) { task.task }
    let(:task) { create(:task) }

    describe "name" do
      let(:section) { page.find(".tasks-form__form-element--name") }
      let(:label) { Clockface::Task.human_attribute_name("name") }

      it "displays the section label and input field" do
        render_partial

        expect(section.find("label")).to have_content(label)
        expect(section.find("input")["placeholder"]).
          to eq(t("clockface.tasks.task_form.placeholder.name"))
      end
    end

    describe "description" do
      let(:section) { page.find(".tasks-form__form-element--description") }
      let(:label) { Clockface::Task.human_attribute_name("description") }

      it "displays the section label and textarea field" do
        render_partial

        expect(section.find("label")).to have_content(label)
        expect(section.find("textarea")["placeholder"]).
          to eq(t("clockface.tasks.task_form.placeholder.description"))
      end
    end

    describe "command" do
      let(:section) { page.find(".tasks-form__form-element--command") }
      let(:label) { Clockface::Task.human_attribute_name("command") }

      it "displays the section label and input field" do
        render_partial

        expect(section.find("label")).to have_content(label)
        expect(section.find("input")["placeholder"]).
          to eq(t("clockface.tasks.task_form.placeholder.command"))
      end
    end

    describe "form" do
      it "submits to the URL specified by `form_url`" do
        render_partial(form_url: "/foo")
        form = page.find(".tasks-new__form-container > form")
        expect(form["action"]).to eq("/foo")
      end

      it "displays the submit button" do
        render_partial
        form = page.find(".tasks-new__form-submit")

        expect(form.find("input[type='submit']")["value"]).
          to eq(t("clockface.tasks.task_form.submit"))
      end

      it "displays the cancel button, linking back to tasks_path" do
        render_partial
        form = page.find(".tasks-new__form-submit")

        expect(form).
          to have_link(
            t("clockface.tasks.task_form.cancel"),
            href: clockface.tasks_path
          )
      end
    end

    def render_partial(opts = {})
      render(
        partial: "clockface/tasks/task_form",
        locals: {
          task: task,
          form_url: clockface.tasks_path
        }.merge(opts)
      )
    end

    def find_selected_option(select_el)
      options = select_el.all("option").map { |o| [o["selected"], o["value"]] }
      options.detect { |o| o.first == "selected" }.try(:last)
    end
  end
end
