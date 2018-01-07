require "rails_helper"

module Clockface
  RSpec.feature "Creating a Task", type: :feature do
    it "user can create a task" do
      tasks = create_list(:task, 2)

      visit clockface.new_task_path

      # Fill In Form
      id = tasks[1].id
      fill_in("task[name]", with: "some name")
      fill_in("task[description]", with: "some description")
      fill_in("task[command]", with: "some command")

      expect do
        submit
      end.to change { Clockface::Task.count }.by(1)

      # Validate model
      task = Clockface::Task.last
      expect(task.name).to eq("some name")
      expect(task.description).to eq("some description")
      expect(task.command).to eq("some command")

      # Validate flash
      expect(page.find(".flash")).
        to have_content(t("clockface.tasks.create.success"))
    end

    context "form is invalid" do
      it "user receives feedback on invalid forms" do
        tasks = create_list(:task, 2)

        # Visit new tasks path
        visit clockface.tasks_path
        find(".tasks-index__new-btn").click

        # Fill In Form
        fill_in("task[name]", with: "")

        expect do
          submit
        end.to change { Clockface::Task.count }.by(0)

        # Validate error
        expect(current_path).to eq(clockface.new_task_path)
        expect(page.find(".flash")).to have_content(
          t(
            "activerecord.errors.models.clockface/task."\
              "attributes.name.blank",
            attribute: Clockface::Task.human_attribute_name("name")
          )
        )
      end
    end

    def submit(opts = {})
      click_button(t("clockface.tasks.task_form.submit"))

      # Force Capybara to wait until the new page loads before progressing
      expect(current_path).to eq(current_path)
    end
  end
end
