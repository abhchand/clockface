require "rails_helper"

module Clockface
  RSpec.describe JobValidationInteractor do
    let(:job) { create(:clockwork_scheduled_job) }
    let(:action) { "update" }

    it "succeeds the context" do
      job.hour = job.hour + 1

      run

      expect(result.success?).to be_truthy
      expect(result.errors).to be_empty
    end

    it "never saves the model" do
      expect(job).to_not receive(:save)

      job.hour = job.hour + 1

      run
    end

    context "model is invalid" do
      before(:each) { job.hour = -1 }

      it "fails the context and sets the error" do
        attribute =
            Clockface::ClockworkScheduledJob.human_attribute_name("hour")

        run

        expect(result.success?).to be_falsey
        expect(result.errors).to eq(
          [
            t(
              "activerecord.errors.models.clockface/clockwork_scheduled_job."\
              "attributes.hour.inclusion",
              attribute: attribute
            )
          ]
        )
      end
    end

    context "job is a duplicate" do
      before(:each) { job.dup.tap { |job| job.save } }

      it "fails the context and sets the error" do
        run

        expect(result.success?).to be_falsey
        expect(result.errors).to eq(
          [t("clockface.jobs.#{action}.duplicate_job")]
        )
      end
    end

    def run
      @result ||=
        Clockface::JobValidationInteractor.call(job: job, action: action)
    end

    def result
      raise "Interactor has not run yet" if @result.nil?
      @result
    end
  end
end
