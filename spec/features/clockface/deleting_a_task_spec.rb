require "rails_helper"

module Clockface
  RSpec.feature "Deleting a Task", type: :feature do
    it "user can delete a task" do
      task = create(:task)
      visit clockface.task_delete_path(task)

      # Fill In Captcha
      fill_in("captcha", with: captcha_for(task))

      expect do
        submit
      end.to change { Clockface::Task.count }.by(-1)

      # Validate model no longer exists
      expect { task.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    context "form is invalid" do
      it "user receives feedback on invalid forms" do
        task = create(:task)

        # Visit new tasks path
        visit clockface.task_delete_path(task)

        # Fill In Bad CAPTCHA
        fill_in("captcha", with: "foo")

        expect do
          submit
        end.to change { Clockface::Task.count }.by(0)

        # Validate error
        expect(page).to have_current_path(clockface.task_delete_path(task))
        expect(page.find(".flash")).to have_content(
          t("clockface.tasks.destroy.validation.incorrect_captcha")
        )
      end
    end

    # This should be checked as part of the controller/interactor validation,
    # but since it's an important protection feature add a spec for it
    # explicitly
    context "task has events" do
      it "user can delete a task" do
        task = create(:task)
        create(:event, task: task)

        visit clockface.task_delete_path(task)

        # Fill In Captcha
        fill_in("captcha", with: captcha_for(task))

        expect do
          submit
        end.to change { Clockface::Task.count }.by(0)

        # Validate error
        expect(page).to have_current_path(clockface.task_delete_path(task))
        expect(page.find(".flash")).to have_content(
          t("clockface.tasks.destroy.validation.events_exist", count: 1)
        )
      end
    end

    def submit
      click_button(t("clockface.tasks.delete.submit"))

      # Force Capybara to wait until the new page loads before progressing
      expect(page).to have_current_path(current_path)
    end

    def captcha_for(task)
      Digest::SHA1.hexdigest(task.id.to_s).
        first(Clockface::TasksController::CAPTCHA_LENGTH)
    end
  end
end
