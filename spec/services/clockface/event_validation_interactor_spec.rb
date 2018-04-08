require "rails_helper"

module Clockface
  RSpec.describe EventValidationInteractor do
    let(:event) { create(:event) }
    let(:action) { "update" }

    it "succeeds the context" do
      event.hour = event.hour + 1

      run

      expect(result.success?).to be_truthy
      expect(result.errors).to be_empty
    end

    it "never saves the model" do
      expect(event).to_not receive(:save)

      event.hour = event.hour + 1

      run
    end

    context "model is invalid" do
      before { event.hour = -1 }

      it "fails the context and sets the error" do
        attribute = Clockface::Event.human_attribute_name("hour")

        run

        expect(result.success?).to be_falsey
        expect(result.errors).to eq(
          [
            t(
              "activerecord.errors.models.clockface/event."\
              "attributes.hour.inclusion",
              attribute: attribute
            )
          ]
        )
      end
    end

    context "event is a duplicate" do
      before { event.dup.tap(&:save) }

      it "fails the context and sets the error" do
        run

        expect(result.success?).to be_falsey
        expect(result.errors).to eq(
          [t("clockface.events.#{action}.duplicate_event")]
        )
      end
    end

    def run
      @result ||=
        Clockface::EventValidationInteractor.call(event: event, action: action)
    end

    def result
      raise "Interactor has not run yet" if @result.nil?
      @result
    end
  end
end
