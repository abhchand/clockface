require "rails_helper"

module Clockface
  RSpec.describe "clockface/jobs/_job_form.html.erb", type: :view do
    let(:task) { job.task }
    let(:job) { create(:clockwork_scheduled_job) }

    describe "task (name)" do
      let(:section) { page.find(".jobs-form__form-element--name") }

      it "displays the section label and dropdown selector" do
        render_partial

        expect(section.find("label")).to have_content("Task")

        dropdown_elements = section.find("select").all("option")

        actual_options = dropdown_elements.map(&:text)
        expected_options =
          Clockface::Task.order(:id).pluck(:name)

        expect(actual_options).to eq(expected_options)
      end

      it "defaults the dropdwon to the job's value" do
        task2 = create(:task)
        job.update!(task: task2)

        render_partial

        selected = find_selected_option(section.find("select"))
        expect(selected.to_i).to eq(task.id)
      end

      context "dropdown is not editable" do
        it "displays the job name" do
          render_partial(allow_editing_task: false)

          expect(section).to_not have_selector("select")
          expect(section).to have_content(job.name)
        end
      end
    end

    describe "enabled" do
      let(:section) { page.find(".jobs-form__form-element--enabled") }

      it "displays the section label" do
        render_partial

        expect(section.find("label")).to have_content("Enabled")
      end

      context "job is enabled" do
        before(:each) { job.update!(enabled: true) }

        it "displays the checked box" do
          render_partial

          checkbox = section.find("input[type='checkbox']")
          expect(checkbox["checked"]).to eq(true)
        end
      end

      context "job is disabled" do
        before(:each) { job.update!(enabled: false) }

        it "displays the unchecked box" do
          render_partial

          checkbox = section.find("input[type='checkbox']")
          expect(checkbox["checked"]).to eq(false)
        end
      end
    end

    describe "period" do
      let(:section) { page.find(".jobs-form__form-element--period") }

      it "displays the section label and the dropdown selectors" do
        render_partial

        expect(section.find("label")).to have_content("Every")

        # Period Value
        expect(section).to have_selector("input")

        # Period Units
        dropdown_elements =
          section.find(".jobs-form__form-element--period-units").all("option")

        actual_options = dropdown_elements.map(&:text)
        expected_options =
          Clockface::ClockworkScheduledJob::PERIOD_UNITS.map do |unit|
            t("datetime.units.#{unit}")
          end

        expect(actual_options).to eq(expected_options)
      end

      it "defaults the period form fields" do
        job.update!(period_value: "17", period_units: "hours")

        render_partial

        input_value = section.find("input").value
        selected_units = find_selected_option(
          section.find(".jobs-form__form-element--period-units")
        )

        expect(input_value).to eq("17")
        expect(selected_units).to eq("hours")
      end
    end

    describe "at" do
      let(:section) { page.find(".jobs-form__form-element--at") }

      it "displays the section label and dropdown selectors" do
        render_partial

        expect(section.find("label")).to have_content("At")

        # Day of Week
        dropdown_elements =
          section.find(".jobs-form__form-element--day-of-week").all("option")

        actual_options = dropdown_elements.map(&:text)
        expected_options = [""] + t("date.day_names")

        expect(actual_options).to eq(expected_options)

        # Hour
        dropdown_elements =
          section.find(".jobs-form__form-element--hour").all("option")

        actual_options = dropdown_elements.map(&:text)
        expected_options =
          (["**"] + (0..23).to_a).map { |h| h.to_s.rjust(2, "0") }

        expect(actual_options).to eq(expected_options)

        # Minute
        dropdown_elements =
          section.find(".jobs-form__form-element--minute").all("option")

        actual_options = dropdown_elements.map(&:text)
        expected_options =
          (["**"] + (0..59).to_a).map { |h| h.to_s.rjust(2, "0") }

        expect(actual_options).to eq(expected_options)
      end

      it "defaults the `at` form fields" do
        job.update!(day_of_week: 1, hour: 2, minute: 3)

        render_partial

        selected_day_of_week = find_selected_option(
          section.find(".jobs-form__form-element--day-of-week")
        )
        selected_hour = find_selected_option(
          section.find(".jobs-form__form-element--hour")
        )
        selected_minute = find_selected_option(
          section.find(".jobs-form__form-element--minute")
        )

        expect(selected_day_of_week.to_i).to eq(1)
        expect(selected_hour.to_i).to eq(2)
        expect(selected_minute.to_i).to eq(3)
      end

      context "hour or minute is null" do
        it "defaults to the as the '**' option" do
          job.update!(day_of_week: nil, hour: nil, minute: nil)

          render_partial

          selected_hour = find_selected_option(
            section.find(".jobs-form__form-element--hour")
          )
          selected_minute = find_selected_option(
            section.find(".jobs-form__form-element--minute")
          )

          # Select forms don't handle nil values mapped to non-nil labels very
          # well. So technically the above doesn't select any option, it just
          # defaults to the first value which happens to be '**'
          expect(selected_hour).to be_nil
          expect(selected_minute).to be_nil
        end
      end
    end

    describe "time zone" do
      let(:section) { page.find(".jobs-form__form-element--time_zone") }

      it "displays the section label and dropdown selector" do
        render_partial

        expect(section.find("label")).to have_content("Time Zone")

        # Since we use the `time_zone_select` helper, no need to test values
        # in detail. That also makes it easier since we don't have to replicate
        # that method's formatting of the time zones. Just test the dropdown
        # exists with the first element
        dropdown_elements = section.find("select").all("option")
        expect(dropdown_elements[0].text).to eq("(GMT-11:00) American Samoa")
      end

      it "defaults to that time zone selection " do
        job.update!(time_zone: "Samoa")

        render_partial

        selected = find_selected_option(section.find("select"))
        expect(selected).to eq("Samoa")
      end

      context "job time zone is nil" do
        before(:each) { job.update!(time_zone: nil) }

        it "defaults to the clockface time zone" do
          render_partial

          selected = find_selected_option(section.find("select"))
          expect(selected).to eq(clockface_time_zone)
        end
      end
    end

    describe "if condition" do
      let(:section) { page.find(".jobs-form__form-element--if_condition") }

      it "displays the section label and dropdown selector" do
        render_partial

        expect(section.find("label")).to have_content("Only run on...")

        dropdown_elements = section.find("select").all("option")

        actual_options = dropdown_elements.map(&:text)
        # rubocop:disable Layout/MultilineMethodCallIndentation
        expected_options =
          [""] +
          Clockface::ClockworkScheduledJob::IF_CONDITIONS.keys.map do |i|
            Clockface::ClockworkScheduledJob.
            human_attribute_name("if_condition.#{i}")
          end
        # rubocop:enable Layout/MultilineMethodCallIndentation

        expect(actual_options).to eq(expected_options)
      end

      it "defaults the dropdwon to the job's value" do
        job.update!(if_condition: "last_of_month")

        render_partial

        selected = find_selected_option(section.find("select"))
        expect(selected).to eq("last_of_month")
      end
    end

    describe "form" do
      it "submits to the URL specified by `form_url`" do
        render_partial(form_url: "/foo")
        form = page.find(".jobs-new__form-container > form")
        expect(form["action"]).to eq("/foo")
      end

      it "displays the submit button" do
        render_partial
        form = page.find(".jobs-new__form-submit")

        expect(form.find("input[type='submit']")["value"]).
          to eq(t("clockface.jobs.job_form.submit"))
      end

      it "displays the cancel button, linking back to jobs_path" do
        render_partial
        form = page.find(".jobs-new__form-submit")

        expect(form).
          to have_link(
            t("clockface.jobs.job_form.cancel"),
            href: clockface.jobs_path
          )
      end
    end

    def render_partial(opts = {})
      render(
        partial: "clockface/jobs/job_form",
        locals: {
          job: job,
          form_url: clockface.jobs_path,
          allow_editing_task: true,
          time_zone_selector_default: nil
        }.merge(opts)
      )
    end

    def find_selected_option(select_el)
      options = select_el.all("option").map { |o| [o["selected"], o["value"]] }
      options.detect { |o| o.first == "selected" }.try(:last)
    end
  end
end
