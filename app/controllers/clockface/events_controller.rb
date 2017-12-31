module Clockface
  class EventsController < ApplicationController
    CAPTCHA_LENGTH = 5

    def index
      @events = all_events.map { |event| Clockface::EventsPresenter.new(event) }
    end

    def new
    end

    def create
      event = Clockface::Event.new(events_params_for_create)
      validation = validate_event(event)

      if validation.success?
        event.save
        flash[:success] = t("clockface.events.create.success")
        clockface_log(:info, "Created Event: #{event.inspect}")
        redirect_to clockface.events_path
      else
        flash[:error] = validation.errors
        redirect_to clockface.new_event_path
      end
    end

    def edit
      @event = Clockface::Event.find_by_id(params[:id])

      unless @event
        redirect_to events_path
        flash[:error] = t("clockface.events.edit.validation.invalid_id")
      end
    end

    def update
      event = Clockface::Event.find_by_id(params[:id])

      if !event
        flash[:error] =
          t("clockface.events.update.event_not_found", id: params[:id])
        redirect_to events_path
        return
      end

      event.attributes = events_params_for_update
      validation = validate_event(event)

      if validation.success?
        event.save
        flash[:success] = t("clockface.events.update.success")
        clockface_log(:info, "Updated Event: #{event.inspect}")
        redirect_to clockface.events_path
      else
        flash[:error] = validation.errors
        redirect_to clockface.edit_event_path(event)
      end
    end

    def delete
      event = Clockface::Event.find_by_id(params[:event_id])

      unless event
        redirect_to events_path
        flash[:error] = t("clockface.events.delete.validation.invalid_id")
        return
      end

      @event = Clockface::EventsPresenter.new(event)
      @captcha = captcha_for(event)
    end

    def destroy
      event = Clockface::Event.find_by_id(params[:id])

      if !event
        flash[:error] =
          t("clockface.events.destroy.event_not_found", id: params[:id])
        redirect_to events_path
        return
      end

      if (params[:captcha] || "") != captcha_for(event)
        flash[:error] =
          t("clockface.events.destroy.validation.incorrect_captcha")
        redirect_to event_delete_path(event)
        return
      end

      if event.destroy
        flash[:success] = t("clockface.events.destroy.success")
        clockface_log(:info, "Destroyed Event: #{event.inspect}")
        redirect_to events_path
      else
        flash[:error] = t("clockface.events.destroy.failure")
        redirect_to event_delete_path(event)
      end
    end

    private

    def all_events
      Clockface::Event.includes(:task).order(:id)
    end

    def events_params_for_create
      params.require(:event).permit(
        :clockface_task_id,
        :name,
        :enabled,
        :period_value,
        :period_units,
        :day_of_week,
        :hour,
        :minute,
        :time_zone,
        :if_condition
      ).tap do |params|
        params[:hour] = nil if params[:hour] == "**"
        params[:minute] = nil if params[:minute] == "**"
      end
    end

    def events_params_for_update
      params.require(:event).permit(
        :name,
        :enabled,
        :period_value,
        :period_units,
        :day_of_week,
        :hour,
        :minute,
        :time_zone,
        :if_condition
      ).tap do |params|
        params[:hour] = nil if params[:hour] == "**"
        params[:minute] = nil if params[:minute] == "**"
      end
    end

    def validate_event(event)
      Clockface::EventValidationInteractor.
        call(event: event, action: params[:action])
    end

    def captcha_for(event)
      Digest::SHA1.hexdigest(event.id.to_s).first(CAPTCHA_LENGTH)
    end
  end
end
