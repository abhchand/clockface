require "rails_helper"

module Clockface
  RSpec.describe "clockface/tasks/index.html.erb", type: :view do
    let(:task) { create(:task) }

    before do
      task
      assign(:tasks, Clockface::Task.all)
      view.extend ConfigHelper
    end

    it "renders the flash" do
      render
      expect(view).to render_template(partial: "_flash")
    end

    it "renders the heading" do
      render
      expect(page).to have_content(t("clockface.tasks.index.heading").downcase)
    end

    it "displays a 'new' button" do
      render

      link = page.find(".tasks-index__new-link")
      button = link.find(".tasks-index__new-btn")

      expect(link["href"]).to eq(clockface.new_task_path)
      expect(button).to have_selector(".glyphicon-plus")
    end

    describe "field headings" do
      it "displays the field headings" do
        render

        columns = %w(id name description command)

        columns.each do |attribute|
          label =
            Clockface::Task.human_attribute_name(attribute)
          css_id = "thead .tasks-index__tasks-column--#{attribute}"

          expect(page.find(css_id)).to have_content(label)
        end
      end
    end

    it "displays a row for each task" do
      task1 = task
      task2 = create(:task)
      assign(:tasks, Clockface::Task.all)

      render

      [task1, task2].each do |task|
        expect(page).
          to have_selector("tr.tasks-index__tasks-row[data-id='#{task.id}']")
      end
    end

    describe "task row" do
      shared_examples "displayed task field" do |field_name|
        it "displays the field_value" do
          render

          field_value = task.send(field_name)

          table_row = page.find("tr.tasks-index__tasks-row[data-id='#{task.id}']")
          field = table_row.find(".tasks-index__tasks-column--#{field_name}")

          expect(field).to have_content(field_value)
        end
      end

      before do
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

      it "displays a link to edit the task" do
        render

        table_row = page.find("tr.tasks-index__tasks-row[data-id='#{task.id}']")
        field = table_row.find(".tasks-index__tasks-column--edit")

        expect(field).
          to have_selector("a[href='#{clockface.edit_task_path(task)}']")
      end

      it "displays a link to delete the task" do
        render

        table_row = page.find("tr.tasks-index__tasks-row[data-id='#{task.id}']")
        field = table_row.find(".tasks-index__tasks-column--destroy")

        expect(field).
          to have_selector("a[href='#{clockface.task_delete_path(task)}']")
      end
    end
  end
end
