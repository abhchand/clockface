require "rails_helper"

module Clockface
  RSpec.describe TaskValidationInteractor do
    let(:task) { create(:task) }
    let(:action) { "update" }

    it "succeeds the context" do
      run

      expect(result.success?).to be_truthy
      expect(result.errors).to be_empty
    end

    it "never saves the model" do
      task.name = task.name + " foo"

      run

      expect(task.reload.name).to_not match(/foo/)
    end

    context "model is invalid" do
      before { task.command = nil }

      it "fails the context and sets the error" do
        attribute =
          Clockface::Task.human_attribute_name("command")

        run

        expect(result.success?).to be_falsey
        expect(result.errors).to eq(
          [
            t(
              "activerecord.errors.models.clockface/task."\
              "attributes.command.blank",
              attribute: attribute
            )
          ]
        )
      end
    end

    def run
      @result ||=
        Clockface::TaskValidationInteractor.call(task: task, action: action)
    end

    def result
      raise "Interactor has not run yet" if @result.nil?
      @result
    end
  end
end
