require "rails_helper"

module Clockface
  RSpec.feature "Updating a Task", type: :feature do
    it "user can update a task" do
      create_list(:task, 2)
      task = create(
        :task,
        name: "some name",
        description: "some description",
        command: "some command"
      )
      other_task = create(:task)

      visit clockface.edit_task_path(task)

      # Fill In Form
      fill_in("task[name]", with: "new name")
      fill_in("task[description]", with: "new description")
      fill_in("task[command]", with: "new command")

      expect do
        submit
      end.to change { Clockface::Task.count }.by(0)

      # Validate model
      task.reload
      expect(task.name).to eq("new name")
      expect(task.description).to eq("new description")
      expect(task.command).to eq("new command")

      # Validate other task not touched
      old_attrs = other_task.attributes
      new_attrs = other_task.reload.attributes
      expect(old_attrs).to eq(new_attrs)

      # Validate flash
      expect(page.find(".flash")).
        to have_content(t("clockface.tasks.update.success"))
    end

    context "form is invalid" do
      it "user receives feedback on invalid forms" do
        task = create(:task)

        # Visit new tasks path
        visit clockface.edit_task_path(task)

        # Fill In Form
        fill_in("task[name]", with: "")

        expect do
          submit
        end.to change { Clockface::Task.count }.by(0)

        # Validate error
        expect(page).to have_current_path(clockface.edit_task_path(task))
        expect(page.find(".flash")).to have_content(
          t(
            "activerecord.errors.models.clockface/task."\
              "attributes.name.blank",
            attribute: Clockface::Task.human_attribute_name("name")
          )
        )
      end
    end

    def submit
      click_button(t("clockface.tasks.task_form.submit"))

      # Force Capybara to wait until the new page loads before progressing
      expect(page).to have_current_path(current_path)
    end
  end
end
